package controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.Base64;

@WebServlet("/payment/confirm")
public class PaymentConfirmServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ⚠️ 실제 배포 시에는 코드에 직접 넣지 말고 환경변수/설정파일로 분리 추천
    private static final String SECRET_KEY = "test_sk_ZLKGPx4M3MnQeAYAGQN2VBaWypv1";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        PrintWriter out = resp.getWriter();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }

        JsonObject requestBody = JsonParser.parseString(sb.toString()).getAsJsonObject();

        String paymentKey = requestBody.get("paymentKey").getAsString();
        String orderId = requestBody.get("orderId").getAsString();
        int amount = requestBody.get("amount").getAsInt();

        String checkIn = requestBody.has("checkIn")
                ? requestBody.get("checkIn").getAsString()
                : "";

        String checkOut = requestBody.has("checkOut")
                ? requestBody.get("checkOut").getAsString()
                : "";

        int peopleCount = requestBody.has("peopleCount")
                ? Integer.parseInt(requestBody.get("peopleCount").getAsString())
                : 1;

        int campId = requestBody.has("campId")
                ? Integer.parseInt(requestBody.get("campId").getAsString())
                : 0;

        Integer userId = (Integer) req.getSession().getAttribute("userId");

        if (userId == null) {
            JsonObject result = new JsonObject();
            result.addProperty("success", false);
            result.addProperty("message", "로그인이 필요합니다.");
            out.print(result.toString());
            out.flush();
            return;
        }

        // 결제 승인 전에 한 번 중복 예약 검사
        if (isAlreadyReserved(campId, checkIn, checkOut, orderId)) {
            JsonObject result = new JsonObject();
            result.addProperty("success", false);
            result.addProperty("message", "이미 예약된 날짜입니다.");
            out.print(result.toString());
            out.flush();
            return;
        }

        URL url = new URL("https://api.tosspayments.com/v1/payments/confirm");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);

        String encoded = Base64.getEncoder()
                .encodeToString((SECRET_KEY + ":").getBytes(StandardCharsets.UTF_8));

        conn.setRequestProperty("Authorization", "Basic " + encoded);
        conn.setRequestProperty("Content-Type", "application/json");

        String body = String.format(
                "{\"paymentKey\":\"%s\",\"orderId\":\"%s\",\"amount\":%d}",
                paymentKey, orderId, amount
        );

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();

        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();

        StringBuilder responseBody = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                responseBody.append(line);
            }
        }

        JsonObject tossResponse = JsonParser.parseString(responseBody.toString()).getAsJsonObject();

        if (status == 200) {
            String orderName = tossResponse.has("orderName")
                    ? tossResponse.get("orderName").getAsString()
                    : "";

            boolean saved = saveReservation(
                    orderId,
                    paymentKey,
                    userId,
                    orderName,
                    amount,
                    checkIn,
                    checkOut,
                    peopleCount,
                    campId
            );

            JsonObject result = new JsonObject();

            if (saved) {
                result.addProperty("success", true);
                result.addProperty("orderName", orderName);
                result.addProperty("amount", amount);
            } else {
                result.addProperty("success", false);
                result.addProperty("message", "이미 예약된 날짜입니다.");
            }

            out.print(result.toString());

        } else {
            String message = tossResponse.has("message")
                    ? tossResponse.get("message").getAsString()
                    : "결제 승인 실패";

            JsonObject result = new JsonObject();
            result.addProperty("success", false);
            result.addProperty("message", message);
            out.print(result.toString());
        }

        out.flush();
    }

    private boolean isAlreadyReserved(
            int campIdParam,
            String checkIn,
            String checkOut,
            String orderId
    ) {
        int campId = resolveCampId(campIdParam, orderId);

        String inDate = normalizeCheckIn(checkIn);
        String outDate = normalizeCheckOut(checkOut);

        String sql =
                "SELECT COUNT(*) " +
                "FROM reservations " +
                "WHERE camp_id = ? " +
                "AND status IN ('PENDING', 'APPROVED', 'PAID', 'pending', 'approved', 'paid') " +
                "AND NOT (check_out <= ? OR check_in >= ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, campId);
            ps.setString(2, inDate);
            ps.setString(3, outDate);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return true;
    }

    private boolean saveReservation(
            String orderId,
            String paymentKey,
            Integer userId,
            String orderName,
            int amount,
            String checkIn,
            String checkOut,
            int peopleCount,
            int campIdParam
    ) {
        int campId = resolveCampId(campIdParam, orderId);

        String inDate = normalizeCheckIn(checkIn);
        String outDate = normalizeCheckOut(checkOut);

        String checkSql =
                "SELECT COUNT(*) " +
                "FROM reservations " +
                "WHERE camp_id = ? " +
                "AND status IN ('PENDING', 'APPROVED', 'PAID', 'pending', 'approved', 'paid') " +
                "AND NOT (check_out <= ? OR check_in >= ?)";

        String insertSql =
                "INSERT INTO reservations " +
                "(user_id, camp_id, reserve_date, check_in, check_out, people_count, status, order_id, payment_key, amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'PAID', ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection()) {

            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, campId);
                checkPs.setString(2, inDate);
                checkPs.setString(3, outDate);

                ResultSet rs = checkPs.executeQuery();

                if (rs.next() && rs.getInt(1) > 0) {
                    return false;
                }
            }

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setInt(1, userId != null ? userId : 0);
                insertPs.setInt(2, campId);
                insertPs.setString(3, inDate);
                insertPs.setString(4, inDate);
                insertPs.setString(5, outDate);
                insertPs.setInt(6, peopleCount);
                insertPs.setString(7, orderId);
                insertPs.setString(8, paymentKey);
                insertPs.setInt(9, amount);

                insertPs.executeUpdate();
            }

            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private int resolveCampId(int campIdParam, String orderId) {
        int campId = campIdParam;

        if (campId == 0 && orderId != null) {
            try {
                String[] parts = orderId.split("-");
                if (parts.length >= 2) {
                    campId = Integer.parseInt(parts[1]);
                }
            } catch (Exception e) {
                campId = 0;
            }
        }

        return campId;
    }

    private String normalizeCheckIn(String checkIn) {
        if (checkIn != null && !checkIn.trim().isEmpty()) {
            return checkIn.trim();
        }

        return LocalDate.now().toString();
    }

    private String normalizeCheckOut(String checkOut) {
        if (checkOut != null && !checkOut.trim().isEmpty()) {
            return checkOut.trim();
        }

        return LocalDate.now().plusDays(1).toString();
    }
}
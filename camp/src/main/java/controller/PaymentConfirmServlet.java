package controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Base64;

@WebServlet("/payment/confirm")
public class PaymentConfirmServlet extends HttpServlet {

    // ⚠️ 반드시 본인 시크릿 키로 교체하세요 (절대 외부 노출 금지)
    private static final String SECRET_KEY = "test_sk_ZLKGPx4M3MnQeAYAGQN2VBaWypv1";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        // 요청 바디 읽기
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }

        JsonObject requestBody = JsonParser.parseString(sb.toString()).getAsJsonObject();
        String paymentKey = requestBody.get("paymentKey").getAsString();
        String orderId    = requestBody.get("orderId").getAsString();
        int    amount     = requestBody.get("amount").getAsInt();

        // ── 토스 결제 승인 API 호출 ──────────────────────────────
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

        // ── 응답 읽기 ───────────────────────────────────────────
        InputStream is = (status == 200) ? conn.getInputStream() : conn.getErrorStream();
        StringBuilder responseBody = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) responseBody.append(line);
        }

        JsonObject tossResponse = JsonParser.parseString(responseBody.toString()).getAsJsonObject();
        PrintWriter out = resp.getWriter();

        if (status == 200) {
            // 승인 성공
            String orderName = tossResponse.has("orderName")
                    ? tossResponse.get("orderName").getAsString() : "";

            // ── DB에 예약 내역 저장 ──────────────────────────────
            Integer userId = (Integer) req.getSession().getAttribute("userId");
            saveReservation(orderId, paymentKey, userId, orderName, amount);

            // 성공 응답
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.addProperty("orderName", orderName);
            result.addProperty("amount", amount);
            out.print(result.toString());

        } else {
            // 승인 실패
            String message = tossResponse.has("message")
                    ? tossResponse.get("message").getAsString() : "결제 승인 실패";

            JsonObject result = new JsonObject();
            result.addProperty("success", false);
            result.addProperty("message", message);
            out.print(result.toString());
        }

        out.flush();
    }

    // reservations 테이블에 저장
    private void saveReservation(String orderId, String paymentKey,
                                  Integer userId, String orderName, int amount) {
        String sql = "INSERT INTO reservations (user_id, camp_id, reserve_date, status, order_id, payment_key, amount) " +
                     "VALUES (?, ?, CURDATE(), 'RESERVED', ?, ?, ?)";

        // orderId에서 camp_id 추출 (예: "ORDER-1-1716000000000" → camp_id = 1)
        int campId = 0;
        try {
            String[] parts = orderId.split("-");
            if (parts.length >= 2) campId = Integer.parseInt(parts[1]);
        } catch (Exception e) {
            campId = 0;
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId != null ? userId : 0);
            ps.setInt(2, campId);
            ps.setString(3, orderId);
            ps.setString(4, paymentKey);
            ps.setInt(5, amount);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

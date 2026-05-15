package controller;

import util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/checkAvailability")
public class CheckAvailabilityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        String campIdStr = request.getParameter("campId");
        String checkIn   = request.getParameter("checkIn");
        String checkOut  = request.getParameter("checkOut");

        if (campIdStr == null || campIdStr.trim().isEmpty()
                || checkIn == null || checkIn.trim().isEmpty()
                || checkOut == null || checkOut.trim().isEmpty()) {

            out.print("{\"available\":false,\"message\":\"필수 정보가 부족합니다.\"}");
            out.flush();
            return;
        }

        try {
            int campId = Integer.parseInt(campIdStr);

            String sql =
                    "SELECT COUNT(*) " +
                    "FROM reservations " +
                    "WHERE camp_id = ? " +
                    "AND LOWER(status) IN ('pending', 'approved', 'paid', 'reserved') " +
                    "AND NOT (check_out <= ? OR check_in >= ?)";

            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, campId);
                ps.setString(2, checkIn.trim());
                ps.setString(3, checkOut.trim());

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int count = rs.getInt(1);
                    boolean available = count == 0;

                    out.print("{\"available\":" + available + "}");
                } else {
                    out.print("{\"available\":false}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"available\":false,\"message\":\"예약 가능 여부 확인 중 오류가 발생했습니다.\"}");
        } finally {
            out.flush();
        }
    }
}
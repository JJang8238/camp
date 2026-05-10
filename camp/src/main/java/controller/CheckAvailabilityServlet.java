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

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        String campIdStr = request.getParameter("campId");
        String date      = request.getParameter("date");

        if (campIdStr == null || date == null) {
            out.print("{\"available\":true}");
            return;
        }

        try {
            int campId = Integer.parseInt(campIdStr);

            // 해당 날짜에 approved 또는 reserved 예약이 있는지 확인
            String sql = "SELECT COUNT(*) FROM reservations " +
                         "WHERE camp_id = ? AND reserve_date = ? " +
                         "AND LOWER(status) IN ('reserved', 'approved')";

            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, campId);
                ps.setString(2, date);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int count = rs.getInt(1);
                    boolean available = (count == 0);
                    out.print("{\"available\":" + available + "}");
                } else {
                    out.print("{\"available\":true}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"available\":true}");
        }
    }
}

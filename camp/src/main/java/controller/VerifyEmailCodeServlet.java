package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBUtil;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/email/verify")
public class VerifyEmailCodeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String email = req.getParameter("email");
        String code  = req.getParameter("code");

        if (email == null || code == null || email.isBlank() || code.isBlank()) {
            resp.getWriter().write("{\"ok\":false, \"msg\":\"입력값 오류\"}");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {

            String sql = "SELECT code, expires_at FROM email_verification WHERE email=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();

                if (!rs.next()) {
                    resp.getWriter().write("{\"ok\":false, \"msg\":\"코드 없음\"}");
                    return;
                }

                String dbCode = rs.getString("code");
                LocalDateTime expires = LocalDateTime.parse(
                        rs.getString("expires_at"),
                        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
                );

                if (LocalDateTime.now().isAfter(expires)) {
                    resp.getWriter().write("{\"ok\":false, \"msg\":\"코드 만료\"}");
                    return;
                }

                if (!dbCode.equals(code)) {
                    resp.getWriter().write("{\"ok\":false, \"msg\":\"코드 불일치\"}");
                    return;
                }

                // 🔥 성공 시 세션 저장
                req.getSession().setAttribute("verifiedEmail", email);

                resp.getWriter().write("{\"ok\":true}");

            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"ok\":false, \"msg\":\"서버 오류\"}");
        }
    }
}
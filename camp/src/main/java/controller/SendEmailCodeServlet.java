package controller;

import util.EmailUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@WebServlet("/email/send")
public class SendEmailCodeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain; charset=UTF-8");

        String email = req.getParameter("email");

        if (email == null || email.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().println("이메일을 입력하세요.");
            return;
        }

        // 🔥 인증코드 생성
        String code = String.format("%06d", new Random().nextInt(1000000));

        // 🔥 만료시간 (10분)
        String expires = LocalDateTime.now()
                .plusMinutes(10)
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // 🔥 DB 저장
        try (Connection conn = DBUtil.getConnection()) {

            String sql = "INSERT INTO email_verification (email, code, expires_at, attempts) " +
                         "VALUES (?, ?, ?, 0) " +
                         "ON DUPLICATE KEY UPDATE code=?, expires_at=?, attempts=0";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                ps.setString(2, code);
                ps.setString(3, expires);
                ps.setString(4, code);
                ps.setString(5, expires);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().println("DB 오류");
            return;
        }

        // 🔥 이메일 발송
        try {
            String body = "캠프메이트 인증코드: " + code + "\n\n10분간 유효합니다.";
            EmailUtil.sendText(email, "이메일 인증코드", body);

            resp.getWriter().println("인증코드를 전송했습니다.");

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().println("메일 전송 실패");
        }
    }
}
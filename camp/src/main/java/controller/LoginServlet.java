package controller;

import dao.UserDAO; // UserDAO 임포트
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // 1. DAO 객체 생성
        UserDAO userDAO = new UserDAO();

        // 2. DAO의 login 메서드를 호출하여 DB 검증 (BCrypt 비교 포함됨)
        if (userDAO.login(username, password)) {
            // 로그인 성공!
            HttpSession session = req.getSession();

            // 3. 사용자 이름(Name) 가져오기
            String realName = userDAO.getNameByUsername(username);

            Map<String, String> loginUser = new HashMap<>();
            loginUser.put("username", username);
            loginUser.put("name", realName);
            loginUser.put("role", "user"); // 필요에 따라 설정

            session.setAttribute("loginUser", loginUser);

            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            // 로그인 실패 시
            String errorMsg = URLEncoder.encode("아이디 또는 비밀번호가 일치하지 않습니다.", "UTF-8");
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=" + errorMsg);
        }
    }
}


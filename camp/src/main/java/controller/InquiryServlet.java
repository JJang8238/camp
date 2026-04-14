package controller;

import dao.InquiryDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import com.google.gson.Gson;
import java.util.HashMap;

@WebServlet("/inquiry")
public class InquiryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        // 🔥 인코딩 & 응답 타입
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        // 🔥 세션에서 사용자 정보 가져오기 (기존 프로젝트 방식)
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        String userName = (String) req.getSession().getAttribute("userName");

        HashMap<String, Object> map = new HashMap<>();

        // 🔥 로그인 체크
        if (userId == null) {
            map.put("success", false);
            map.put("msg", "로그인이 필요합니다.");
        } else {
            // 🔥 파라미터 받기
            String title = req.getParameter("title");
            String content = req.getParameter("content");

            // 🔥 DB 저장
            InquiryDAO dao = new InquiryDAO();
            boolean result = dao.insertInquiry(userId, userName, title, content);

            map.put("success", result);
        }

        // 🔥 JSON 응답
        resp.getWriter().write(new Gson().toJson(map));
    }
}
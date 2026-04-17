package controller;

import dao.InquiryDAO;
import dao.AdminLogDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;

import com.google.gson.Gson;

@WebServlet("/admin/inquiryReply")
public class InquiryReplyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HashMap<String, Object> map = new HashMap<>();

        try {
            Integer adminUserId = (Integer) req.getSession().getAttribute("userId");
            String role = (String) req.getSession().getAttribute("role");

            if (adminUserId == null || role == null || !"admin".equals(role)) {
                map.put("success", false);
                map.put("message", "권한이 없습니다.");
                resp.getWriter().write(new Gson().toJson(map));
                return;
            }

            String idStr = req.getParameter("id");
            String reply = req.getParameter("reply");

            if (idStr == null || idStr.trim().isEmpty() ||
                reply == null || reply.trim().isEmpty()) {
                map.put("success", false);
                map.put("message", "잘못된 요청입니다.");
                resp.getWriter().write(new Gson().toJson(map));
                return;
            }

            int id = Integer.parseInt(idStr);
            reply = reply.trim();

            InquiryDAO dao = new InquiryDAO();
            boolean result = dao.updateReply(id, reply);

            if (result) {
                AdminLogDAO logDAO = new AdminLogDAO();
                logDAO.insertLog(
                    adminUserId,
                    "문의 답변 등록",
                    "문의",
                    id,
                    "문의 답변을 등록함"
                );
            }

            map.put("success", result);

        } catch (Exception e) {
            e.printStackTrace();
            map.put("success", false);
            map.put("message", "서버 오류가 발생했습니다.");
        }

        resp.getWriter().write(new Gson().toJson(map));
    }
}
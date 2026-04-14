package controller;

import dao.InquiryDAO;
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

        int id = Integer.parseInt(req.getParameter("id"));
        String reply = req.getParameter("reply");

        InquiryDAO dao = new InquiryDAO();
        boolean result = dao.updateReply(id, reply);

        HashMap<String, Object> map = new HashMap<>();
        map.put("success", result);

        resp.getWriter().write(new Gson().toJson(map));
    }
}
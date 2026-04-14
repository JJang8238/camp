package controller;

import dao.InquiryDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

import com.google.gson.Gson;

@WebServlet("/admin/inquiryDetail")
public class InquiryDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        int id = Integer.parseInt(req.getParameter("id"));

        InquiryDAO dao = new InquiryDAO();
        Map<String, String> data = dao.getInquiryById(id);

        resp.getWriter().write(new Gson().toJson(data));
    }
}
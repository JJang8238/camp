package controller;

import dao.ChatDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/chat/unreadCount")
public class UnreadCountServlet extends HttpServlet {

    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.getWriter().write("{\"count\":0}");
            return;
        }

        int count = chatDAO.getTotalUnreadCount(userId);
        response.getWriter().write("{\"count\":" + count + "}");
    }
}

package controller;

import dao.ChatDAO;
import dto.ChatRoom;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/chat/list")
public class ChatListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String ctx = request.getContextPath();

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        List<ChatRoom> chatRooms = chatDAO.getMyChatRooms(userId);

        request.setAttribute("chatRooms", chatRooms);
        request.getRequestDispatcher("/chatList.jsp").forward(request, response);
    }
}
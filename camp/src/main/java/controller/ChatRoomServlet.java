package controller;

import dao.ChatDAO;
import dto.ChatMessage;
import dto.ChatRoom;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/chat/room")
public class ChatRoomServlet extends HttpServlet {

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

        String roomIdStr = request.getParameter("roomId");

        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        int roomId = Integer.parseInt(roomIdStr);

        if (!chatDAO.isRoomMember(roomId, userId)) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        ChatRoom room = chatDAO.getRoomById(roomId);
        List<ChatMessage> messages = chatDAO.getMessages(roomId);

        chatDAO.markAsRead(roomId, userId);

        request.setAttribute("room", room);
        request.setAttribute("messages", messages);

        request.getRequestDispatcher("/chatRoom.jsp").forward(request, response);
    }
}
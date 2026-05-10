package controller;

import dao.ChatDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/chat/send")
public class ChatSendServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String ctx = request.getContextPath();

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String roomIdStr = request.getParameter("roomId");
        String message = request.getParameter("message");

        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        int roomId = Integer.parseInt(roomIdStr);

        if (!chatDAO.isRoomMember(roomId, userId)) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        if (message != null && !message.trim().isEmpty()) {
            chatDAO.insertMessage(roomId, userId, message.trim());
        }

        response.sendRedirect(ctx + "/chat/room?roomId=" + roomId);
    }
}
package controller;

import dao.ChatDAO;
import dto.ChatMessage;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/chat/messages")
public class ChatMessagesServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"LOGIN_REQUIRED\"}");
            return;
        }

        String roomIdStr = request.getParameter("roomId");

        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"INVALID_ROOM\"}");
            return;
        }

        int roomId = Integer.parseInt(roomIdStr);

        if (!chatDAO.isRoomMember(roomId, userId)) {
            response.getWriter().write("{\"success\":false,\"message\":\"NO_PERMISSION\"}");
            return;
        }

        List<ChatMessage> messages = chatDAO.getMessages(roomId);
        chatDAO.markAsRead(roomId, userId);

        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"userId\":").append(userId).append(",\"messages\":[");

        for (int i = 0; i < messages.size(); i++) {
            ChatMessage msg = messages.get(i);

            if (i > 0) json.append(",");

            json.append("{");
            json.append("\"id\":").append(msg.getId()).append(",");
            json.append("\"senderId\":").append(msg.getSenderId()).append(",");
            json.append("\"senderName\":\"").append(escapeJson(msg.getSenderName())).append("\",");
            json.append("\"message\":\"").append(escapeJson(msg.getMessage())).append("\",");
            json.append("\"createdAt\":\"").append(msg.getCreatedAt()).append("\"");
            json.append("}");
        }

        json.append("]}");

        response.getWriter().write(json.toString());
    }

    private String escapeJson(String value) {
        if (value == null) return "";

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
}
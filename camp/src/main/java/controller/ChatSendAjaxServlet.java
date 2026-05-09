package controller;

import dao.ChatDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/chat/sendAjax")
public class ChatSendAjaxServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"LOGIN_REQUIRED\"}");
            return;
        }

        String roomIdStr = request.getParameter("roomId");
        String message = request.getParameter("message");

        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"INVALID_ROOM\"}");
            return;
        }

        int roomId = Integer.parseInt(roomIdStr);

        if (!chatDAO.isRoomMember(roomId, userId)) {
            response.getWriter().write("{\"success\":false,\"message\":\"NO_PERMISSION\"}");
            return;
        }

        if (message == null || message.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"EMPTY_MESSAGE\"}");
            return;
        }

        boolean result = chatDAO.insertMessage(roomId, userId, message.trim());

        if (result) {
            response.getWriter().write("{\"success\":true}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"SEND_FAIL\"}");
        }
    }
}
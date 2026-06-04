package controller;

import dao.ChatDAO;
import dto.ChatRoom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/chat/productRooms")
public class ChatProductRoomsServlet extends HttpServlet {

    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        int sellerId = chatDAO.getProductSellerId(productId);
        if (sellerId != userId) {
            response.sendRedirect(ctx + "/chat/list");
            return;
        }

        List<ChatRoom> chatRooms = chatDAO.getChatRoomsByProductId(productId, userId);

        String productName = "";
        if (chatRooms != null && !chatRooms.isEmpty()) {
            productName = chatRooms.get(0).getProductName();
        }

        request.setAttribute("chatRooms", chatRooms);
        request.setAttribute("productId", productId);
        request.setAttribute("productName", productName);

        request.getRequestDispatcher("/chatProductRooms.jsp").forward(request, response);
    }
}

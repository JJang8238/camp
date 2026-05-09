package controller;

import dao.ChatDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/chat/start")
public class ChatStartServlet extends HttpServlet {

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

        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(ctx + "/productList.jsp");
            return;
        }

        int productId = Integer.parseInt(productIdStr);

        int sellerId = chatDAO.getProductSellerId(productId);

        if (sellerId == 0) {
            String msg = URLEncoder.encode("상품 정보를 찾을 수 없습니다.", "UTF-8");
            response.sendRedirect(ctx + "/productList.jsp?msg=" + msg);
            return;
        }

        if (sellerId == userId) {
            String msg = URLEncoder.encode("자신의 상품에는 채팅할 수 없습니다.", "UTF-8");
            response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId + "&msg=" + msg);
            return;
        }

        int roomId = chatDAO.getOrCreateRoom(productId, userId, sellerId);

        if (roomId <= 0) {
            String msg = URLEncoder.encode("채팅방 생성에 실패했습니다.", "UTF-8");
            response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId + "&msg=" + msg);
            return;
        }

        response.sendRedirect(ctx + "/chat/room?roomId=" + roomId);
    }
}
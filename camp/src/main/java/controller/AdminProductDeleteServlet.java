package controller;

import dao.AdminProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/productDelete")
public class AdminProductDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);

        // 관리자 권한 체크
        if (session == null || session.getAttribute("userId") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String idStr = request.getParameter("productId");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(ctx + "/admin/products.jsp?error="
                    + URLEncoder.encode("잘못된 요청입니다.", "UTF-8"));
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/admin/products.jsp?error="
                    + URLEncoder.encode("잘못된 요청입니다.", "UTF-8"));
            return;
        }

        AdminProductDAO dao = new AdminProductDAO();
        boolean success = dao.deleteProduct(productId);

        if (success) {
            response.sendRedirect(ctx + "/admin/products.jsp?success="
                    + URLEncoder.encode("상품이 삭제되었습니다.", "UTF-8"));
        } else {
            response.sendRedirect(ctx + "/admin/products.jsp?error="
                    + URLEncoder.encode("삭제에 실패했습니다.", "UTF-8"));
        }
    }
}

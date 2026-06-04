package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/product/delete")
public class ProductDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);

        // 로그인 + owner 권한 체크
        if (session == null || session.getAttribute("userId") == null
                || !"owner".equals(session.getAttribute("role"))) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('로그인이 필요합니다.');");
            response.getWriter().println("location.href='" + ctx + "/login.jsp';");
            response.getWriter().println("</script>");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String idStr = request.getParameter("productId");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('잘못된 요청입니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('잘못된 요청입니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        ProductDAO dao = new ProductDAO();
        boolean success = dao.deleteProduct(productId, userId);

        if (success) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('상품이 삭제되었습니다.');");
            response.getWriter().println("location.href='" + ctx + "/owner/productManage.jsp';");
            response.getWriter().println("</script>");
        } else {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('삭제에 실패했습니다. 본인 상품인지 확인해주세요.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
        }
    }
}

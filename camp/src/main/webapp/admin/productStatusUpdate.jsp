<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.AdminProductDAO" %>
<%@ page import="java.net.URLEncoder" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String productIdStr = request.getParameter("productId");
    String status = request.getParameter("status");

    if (productIdStr == null || productIdStr.trim().isEmpty()
            || status == null || status.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/products.jsp?error=" + URLEncoder.encode("잘못된 요청입니다.", "UTF-8"));
        return;
    }

    int productId = Integer.parseInt(productIdStr);

    if (!"selling".equals(status) && !"hidden".equals(status) && !"soldout".equals(status)) {
        response.sendRedirect(ctx + "/admin/products.jsp?error=" + URLEncoder.encode("허용되지 않은 상태값입니다.", "UTF-8"));
        return;
    }

    AdminProductDAO dao = new AdminProductDAO();
    boolean success = dao.updateProductStatus(productId, status);

    if (success) {
        response.sendRedirect(ctx + "/admin/products.jsp?success=" + URLEncoder.encode("상태가 변경되었습니다.", "UTF-8"));
    } else {
        response.sendRedirect(ctx + "/admin/products.jsp?error=" + URLEncoder.encode("상태 변경에 실패했습니다.", "UTF-8"));
    }
%>
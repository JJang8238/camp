<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();
    Integer loginUserId = (Integer) session.getAttribute("userId");

    if (loginUserId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String productIdStr = request.getParameter("productId");
    String status = request.getParameter("status");

    if (productIdStr == null || status == null) {
        response.sendRedirect(ctx + "/productList.jsp");
        return;
    }

    int productId;
    try {
        productId = Integer.parseInt(productIdStr);
    } catch (Exception e) {
        response.sendRedirect(ctx + "/productList.jsp");
        return;
    }

    if (!"selling".equals(status)
            && !"soldout".equals(status)
            && !"hidden".equals(status)) {
        response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId);
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        conn = DBUtil.getConnection();

        String sql = "UPDATE product SET status = ? WHERE id = ? AND seller_id = ?";

        ps = conn.prepareStatement(sql);
        ps.setString(1, status);
        ps.setInt(2, productId);
        ps.setInt(3, loginUserId);

        int result = ps.executeUpdate();

        if (result > 0) {
            response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId);
        } else {
            response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId + "&error=auth");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(ctx + "/productDetail.jsp?id=" + productId + "&error=server");
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
%>

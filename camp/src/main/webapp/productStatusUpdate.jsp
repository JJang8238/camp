<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();
    Integer loginUserId = (Integer) session.getAttribute("userId");

    if (loginUserId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    String productIdStr = request.getParameter("productId");
    String status = request.getParameter("status");

    if (productIdStr == null || status == null) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    int productId;

    try {
        productId = Integer.parseInt(productIdStr);
    } catch (Exception e) {
        out.println("<script>alert('잘못된 상품 번호입니다.'); history.back();</script>");
        return;
    }

    if (!"selling".equals(status)
            && !"soldout".equals(status)
            && !"hidden".equals(status)) {
        out.println("<script>alert('변경할 수 없는 상태입니다.'); history.back();</script>");
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
            out.println("<script>alert('거래 상태가 변경되었습니다.'); location.href='" + ctx + "/productDetail.jsp?id=" + productId + "';</script>");
        } else {
            out.println("<script>alert('본인 상품만 상태를 변경할 수 있습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('상태 변경 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
%>
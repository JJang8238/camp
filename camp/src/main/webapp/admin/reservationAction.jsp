<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idParam = request.getParameter("id");
    String action  = request.getParameter("action");

    if (idParam == null || action == null) {
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        return;
    }

    int reservationId = 0;
    try {
        reservationId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        if ("cancel".equals(action)) {
            // 현재 상태가 reserved인지 확인 후 cancelled로 변경
            pstmt = conn.prepareStatement(
            		"UPDATE reservations SET status = 'cancelled' WHERE id = ? AND LOWER(status) NOT IN ('cancelled', 'completed')"
            );
            pstmt.setInt(1, reservationId);
            int updated = pstmt.executeUpdate();

            if (updated > 0) {
                response.sendRedirect(ctx + "/admin/reservations.jsp?result=cancelled");
            } else {
                response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
            }
        } else {
            response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn  != null) conn.close();  } catch (Exception ignore) {}
    }
%>

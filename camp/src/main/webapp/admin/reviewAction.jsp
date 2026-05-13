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
        response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
        return;
    }

    int postId = 0;
    try {
        postId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        if ("delete".equals(action)) {
            // 후기 삭제
            pstmt = conn.prepareStatement("DELETE FROM posts WHERE id = ?");
            pstmt.setInt(1, postId);
            int updated = pstmt.executeUpdate();
            if (updated > 0) {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=deleted");
            } else {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
            }

        } else if ("hide".equals(action)) {
            // 숨김 처리
            pstmt = conn.prepareStatement("UPDATE posts SET status = 'hidden' WHERE id = ?");
            pstmt.setInt(1, postId);
            int updated = pstmt.executeUpdate();
            if (updated > 0) {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=hidden");
            } else {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
            }

        } else if ("show".equals(action)) {
            // 숨김 해제
            pstmt = conn.prepareStatement("UPDATE posts SET status = 'published' WHERE id = ?");
            pstmt.setInt(1, postId);
            int updated = pstmt.executeUpdate();
            if (updated > 0) {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=shown");
            } else {
                response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
            }

        } else {
            response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(ctx + "/admin/reviews.jsp?result=error");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn  != null) conn.close();  } catch (Exception ignore) {}
    }
%>

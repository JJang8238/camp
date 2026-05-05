<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.PostDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    String status = request.getParameter("status");

    if (idStr == null || idStr.trim().isEmpty()
            || status == null || status.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/posts.jsp");
        return;
    }

    if (!"published".equals(status) && !"hidden".equals(status) && !"draft".equals(status)) {
        response.sendRedirect(ctx + "/admin/posts.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);

    PostDAO dao = new PostDAO();
    dao.updatePostStatus(id, status);

    response.sendRedirect(ctx + "/admin/posts.jsp");
%>
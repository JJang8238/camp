<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    String actionType = request.getParameter("actionType");

    if (idStr == null || idStr.trim().isEmpty() ||
        actionType == null || actionType.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/ownerRequests.jsp?error=invalid");
        return;
    }

    int id = 0;
    try {
        id = Integer.parseInt(idStr);
    } catch (Exception e) {
        response.sendRedirect(ctx + "/admin/ownerRequests.jsp?error=invalid");
        return;
    }

    UserDAO dao = new UserDAO();
    boolean success = false;

    if ("approve".equals(actionType)) {
        success = dao.approveOwnerRequest(id);
        if (success) {
            response.sendRedirect(ctx + "/admin/ownerRequests.jsp?result=approved");
            return;
        }
    } else if ("reject".equals(actionType)) {
        success = dao.rejectOwnerRequest(id);
        if (success) {
            response.sendRedirect(ctx + "/admin/ownerRequests.jsp?result=rejected");
            return;
        }
    }

    response.sendRedirect(ctx + "/admin/ownerRequests.jsp?error=fail");
%>
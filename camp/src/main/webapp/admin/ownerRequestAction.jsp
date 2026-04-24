<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.AdminLogDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
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
    AdminLogDAO logDAO = new AdminLogDAO();

    boolean success = false;

    if ("approve".equals(actionType)) {
        success = dao.approveOwnerRequest(id);

        if (success) {
            logDAO.insertLog(
                adminUserId,
                "사업자 승인",
                "사업자",
                id,
                "사업자 승인 요청을 승인 처리"
            );

            response.sendRedirect(ctx + "/admin/ownerRequests.jsp?result=approved");
            return;
        }

    } else if ("reject".equals(actionType)) {
        success = dao.rejectOwnerRequest(id);

        if (success) {
            logDAO.insertLog(
                adminUserId,
                "사업자 반려",
                "사업자",
                id,
                "사업자 승인 요청을 반려 처리"
            );

            response.sendRedirect(ctx + "/admin/ownerRequests.jsp?result=rejected");
            return;
        }
    }

    response.sendRedirect(ctx + "/admin/ownerRequests.jsp?error=fail");
%>
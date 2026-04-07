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
    String newRole = request.getParameter("newRole");
    String newStatus = request.getParameter("newStatus");

    String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("statusFilter");
    String roleFilter = request.getParameter("roleFilter");

    if (keyword == null) keyword = "";
    if (statusFilter == null) statusFilter = "";
    if (roleFilter == null) roleFilter = "";

    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/users.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);

    UserDAO dao = new UserDAO();
    boolean result = dao.updateUserRoleAndStatus(id, newRole, newStatus);

    String redirectUrl = ctx + "/admin/users.jsp?keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8")
            + "&status=" + java.net.URLEncoder.encode(statusFilter, "UTF-8")
            + "&userRole=" + java.net.URLEncoder.encode(roleFilter, "UTF-8");

    if (result) {
        response.sendRedirect(redirectUrl);
    } else {
%>
<script>
    alert("회원 정보 변경에 실패했습니다.");
    location.href = "<%=redirectUrl%>";
</script>
<%
    }
%>
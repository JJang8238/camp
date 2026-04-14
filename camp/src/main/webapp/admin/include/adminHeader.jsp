<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    String userName = (String) session.getAttribute("userName");

    if (adminUserId == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    if (userName == null || userName.trim().isEmpty()) {
        userName = "관리자";
    }
%>

<header class="admin-header">
    <div class="admin-header-left">
        <a href="<%=ctx%>/admin/dashboard.jsp" class="admin-logo">
            <span class="admin-logo-icon">🛠</span>
            <span class="admin-logo-text">Camp Mate Admin</span>
        </a>
    </div>

    <div class="admin-header-right">
        <span class="admin-welcome"><%= userName %> 관리자님</span>

        <a href="<%=ctx%>/main.jsp" class="admin-top-btn admin-top-btn-light">
            사용자 페이지
        </a>

        <a href="<%=ctx%>/logout.jsp" class="admin-top-btn admin-top-btn-point">
            로그아웃
        </a>
    </div>
</header>
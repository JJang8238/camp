<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");
    String status = request.getParameter("status");
    String userRole = request.getParameter("userRole");

    if (keyword == null) keyword = "";
    if (status == null) status = "";
    if (userRole == null) userRole = "";

    UserDAO dao = new UserDAO();
    List<User> userList = dao.getAdminUserList(keyword, status, userRole);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 회원 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>

<body class="admin-body">

    <jsp:include page="/admin/include/adminHeader.jsp" />

    <div class="admin-layout">
        <jsp:include page="/admin/include/adminSidebar.jsp" />

        <main class="admin-content">
            <div class="admin-page-head">
                <div>
                    <h1 class="admin-page-title">회원 관리</h1>
                    <p class="admin-page-desc">회원 조회, 회원 유형 변경, 계정 상태 관리</p>
                </div>
            </div>

            <!-- 검색 -->
            <section class="admin-filter-card">
                <form method="get" action="<%=ctx%>/admin/users.jsp" class="admin-search-form">
                    <div class="admin-form-row">

                        <div class="admin-form-group">
                            <label>검색어</label>
                            <input type="text" name="keyword" value="<%=keyword%>" class="admin-input"
                                   placeholder="아이디 또는 이름 검색">
                        </div>

                        <div class="admin-form-group">
                            <label>계정 상태</label>
                            <select name="status" class="admin-select">
                                <option value="">전체</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>ACTIVE</option>
                                <option value="PENDING" <%= "PENDING".equals(status) ? "selected" : "" %>>PENDING</option>
                                <option value="BLOCKED" <%= "BLOCKED".equals(status) ? "selected" : "" %>>BLOCKED</option>
                            </select>
                        </div>

                        <div class="admin-form-group">
                            <label>회원 유형</label>
                            <select name="userRole" class="admin-select">
                                <option value="">전체</option>
                                <option value="user" <%= "user".equals(userRole) ? "selected" : "" %>>USER</option>
                                <option value="owner" <%= "owner".equals(userRole) ? "selected" : "" %>>OWNER</option>
                                <option value="admin" <%= "admin".equals(userRole) ? "selected" : "" %>>ADMIN</option>
                            </select>
                        </div>

                        <div class="admin-form-group admin-form-btn-group">
                            <label>&nbsp;</label>
                            <button type="submit" class="admin-btn admin-btn-primary">검색</button>
                        </div>
                    </div>
                </form>
            </section>

            <!-- 테이블 -->
            <section class="admin-table-wrap">
                <div class="admin-table-top">
                    <div class="admin-table-title">회원 목록</div>
                    <div class="admin-table-count">총 <strong><%= userList.size() %></strong>명</div>
                </div>

                <div class="admin-table-scroll">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>아이디</th>
                                <th>이름</th>
                                <th>이메일</th>
                                <th>회원 유형</th>
                                <th>계정 상태</th>
                                <th>가입일</th>
                                <th>유형/상태 변경</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% if (userList == null || userList.isEmpty()) { %>
                            <tr>
                                <td colspan="8">
                                    <div class="admin-empty-inline">조회된 회원이 없습니다.</div>
                                </td>
                            </tr>
                        <% } else {
                            for (User u : userList) {
                        %>
                            <tr>
                                <td><%= u.getId() %></td>
                                <td><%= u.getUserId() %></td>
                                <td><%= u.getName() %></td>
                                <td><%= u.getEmail() %></td>

                                <td>
                                    <span class="admin-badge admin-badge-role"><%= u.getRole() %></span>
                                </td>

                                <td>
                                    <span class="admin-badge
                                        <%= "ACTIVE".equals(u.getStatus()) ? "admin-badge-active" : "" %>
                                        <%= "PENDING".equals(u.getStatus()) ? "admin-badge-warn" : "" %>
                                        <%= "BLOCKED".equals(u.getStatus()) ? "admin-badge-danger" : "" %>">
                                        <%= u.getStatus() %>
                                    </span>
                                </td>

                                <td><%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0, 10) : "-" %></td>

                                <td>
                                    <div class="admin-user-control">

                                        <select class="admin-mini-select admin-role-select">
                                            <option value="user" <%= "user".equals(u.getRole()) ? "selected" : "" %>>USER</option>
                                            <option value="owner" <%= "owner".equals(u.getRole()) ? "selected" : "" %>>OWNER</option>
                                            <option value="admin" <%= "admin".equals(u.getRole()) ? "selected" : "" %>>ADMIN</option>
                                        </select>

                                        <select class="admin-mini-select admin-status-select">
                                            <option value="ACTIVE" <%= "ACTIVE".equals(u.getStatus()) ? "selected" : "" %>>ACTIVE</option>
                                            <option value="PENDING" <%= "PENDING".equals(u.getStatus()) ? "selected" : "" %>>PENDING</option>
                                            <option value="BLOCKED" <%= "BLOCKED".equals(u.getStatus()) ? "selected" : "" %>>BLOCKED</option>
                                        </select>

                                        <form method="post" action="<%=ctx%>/admin/userUpdate.jsp" class="admin-inline-form">
                                            <input type="hidden" name="id" value="<%=u.getId()%>">
                                            <input type="hidden" name="newRole" class="role-hidden">
                                            <input type="hidden" name="newStatus" class="status-hidden">
                                            <button type="submit" class="admin-btn admin-btn-sm admin-save-btn">저장</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <script>
    document.querySelectorAll('.admin-user-control').forEach(function (row) {
        const roleSelect = row.querySelector('.admin-role-select');
        const statusSelect = row.querySelector('.admin-status-select');
        const form = row.querySelector('form');

        form.addEventListener('submit', function () {
            form.querySelector('.role-hidden').value = roleSelect.value;
            form.querySelector('.status-hidden').value = statusSelect.value;
        });
    });
    </script>

</body>
</html>
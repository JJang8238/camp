<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.AdminLogDAO" %>
<%@ page import="dto.AdminLog" %>

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
    String type = request.getParameter("type");

    if (keyword == null) keyword = "";
    if (type == null || type.trim().isEmpty()) type = "all";

    keyword = keyword.trim();
    type = type.trim();

    AdminLogDAO logDAO = new AdminLogDAO();
    List<AdminLog> allLogs = logDAO.getAllLogs();

    java.util.List<AdminLog> filteredList = new java.util.ArrayList<>();

    for (AdminLog log : allLogs) {

        boolean matchesType =
                "all".equals(type)
                || (log.getTargetType() != null && type.equals(log.getTargetType()));

        boolean matchesKeyword =
                keyword.isEmpty()
                || (log.getAction() != null && log.getAction().contains(keyword))
                || (log.getTargetType() != null && log.getTargetType().contains(keyword))
                || (log.getAdminName() != null && log.getAdminName().contains(keyword))
                || (log.getDetail() != null && log.getDetail().contains(keyword))
                || String.valueOf(log.getTargetId()).contains(keyword);

        if (matchesType && matchesKeyword) {
            filteredList.add(log);
        }
    }

    int totalCount = filteredList.size();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 운영 로그</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>

<body class="admin-body">

    <jsp:include page="/admin/include/adminHeader.jsp" />

    <div class="admin-layout">
        <jsp:include page="/admin/include/adminSidebar.jsp" />

        <main class="admin-content">

            <!-- 제목 -->
            <div class="admin-page-head">
                <div>
                    <h1 class="admin-page-title">운영 로그</h1>
                    <p class="admin-page-desc">관리자 작업 이력을 확인하세요.</p>
                </div>
            </div>

            <!-- 요약 카드 -->
            <section class="admin-card-grid">
                <div class="admin-stat-card">
                    <div class="admin-stat-label">조회 결과</div>
                    <div class="admin-stat-value"><%= totalCount %></div>
                    <div class="admin-stat-link">현재 필터 기준</div>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">전체 로그</div>
                    <div class="admin-stat-value"><%= allLogs.size() %></div>
                    <div class="admin-stat-link">누적 데이터</div>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">최근 관리자</div>
                    <div class="admin-stat-value">
                        <%= allLogs.size() > 0 ? allLogs.get(0).getAdminName() : "-" %>
                    </div>
                    <div class="admin-stat-link">마지막 작업자</div>
                </div>
            </section>

            <!-- 검색 -->
            <section class="admin-filter-card">

                <form method="get" action="<%=ctx%>/admin/logs.jsp" class="admin-search-form">

                    <div class="admin-form-row">

                        <div class="admin-form-group">
                            <label>검색어</label>
                            <input type="text"
                                   name="keyword"
                                   class="admin-input"
                                   placeholder="작업, 대상, 관리자, 상세내용"
                                   value="<%=keyword%>">
                        </div>

                        <div class="admin-form-group">
                            <label>구분</label>
                            <select name="type" class="admin-select">
                                <option value="all" <%= "all".equals(type) ? "selected" : "" %>>전체</option>
                                <option value="회원" <%= "회원".equals(type) ? "selected" : "" %>>회원</option>
                                <option value="게시글" <%= "게시글".equals(type) ? "selected" : "" %>>게시글</option>
                                <option value="문의" <%= "문의".equals(type) ? "selected" : "" %>>문의</option>
                                <option value="캠핑장" <%= "캠핑장".equals(type) ? "selected" : "" %>>캠핑장</option>
                                <option value="거래" <%= "거래".equals(type) ? "selected" : "" %>>거래</option>
                            </select>
                        </div>

                        <div class="admin-form-group">
                            <label>&nbsp;</label>
                            <a href="<%=ctx%>/admin/logs.jsp" class="admin-btn">초기화</a>
                        </div>

                        <div class="admin-form-btn-group">
                            <button type="submit" class="admin-btn admin-btn-primary">검색</button>
                        </div>

                    </div>

                </form>

            </section>

            <!-- 테이블 -->
            <section class="admin-table-wrap">

                <div class="admin-table-top">
                    <div class="admin-table-title">로그 목록</div>
                    <div class="admin-table-count">총 <%= totalCount %>건</div>
                </div>

                <div class="admin-table-scroll">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>구분</th>
                                <th>작업</th>
                                <th>관리자</th>
                                <th>대상</th>
                                <th>상세 내용</th>
                                <th>처리일시</th>
                            </tr>
                        </thead>
                        <tbody>

                        <% if (filteredList.isEmpty()) { %>

                            <tr>
                                <td colspan="7" class="admin-empty-inline">
                                    조회된 로그가 없습니다.
                                </td>
                            </tr>

                        <% } else { %>

                            <% for (AdminLog log : filteredList) { %>
                            <tr>
                                <td><%= log.getId() %></td>

                                <td>
                                    <span class="admin-badge">
                                        <%= log.getTargetType() %>
                                    </span>
                                </td>

                                <td><%= log.getAction() %></td>

                                <td>
                                    <%= log.getAdminName() != null ? log.getAdminName() : "-" %>
                                </td>

                                <td>
                                    <%= log.getTargetType() %> #<%= log.getTargetId() %>
                                </td>

                                <td style="text-align:left; line-height:1.6;">
                                    <%= log.getDetail() != null ? log.getDetail() : "-" %>
                                </td>

                                <td><%= log.getCreatedAt() %></td>
                            </tr>
                            <% } %>

                        <% } %>

                        </tbody>
                    </table>
                </div>

            </section>

        </main>
    </div>

</body>
</html>
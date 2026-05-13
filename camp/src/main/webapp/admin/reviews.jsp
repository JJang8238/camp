<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*" %>
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

    String keyword = request.getParameter("keyword");
    String ratingFilter = request.getParameter("rating");
    if (keyword == null) keyword = "";
    if (ratingFilter == null) ratingFilter = "all";
    keyword = keyword.trim();

    String result = request.getParameter("result");

    List<Map<String, Object>> reviewList = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.id, p.content, p.summary AS rating, p.created_at, p.status, ")
           .append("       u.username, u.name AS user_name, ")
           .append("       p.title AS place ")
           .append("FROM posts p ")
           .append("LEFT JOIN users u ON p.author_id = u.id ")
           .append("WHERE p.post_type = 'review' ");

        if (!"all".equals(ratingFilter)) {
            sql.append("AND p.summary = ? ");
        }
        if (!keyword.isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.name LIKE ? OR p.title LIKE ? OR p.content LIKE ?) ");
        }
        sql.append("ORDER BY p.id DESC");

        pstmt = conn.prepareStatement(sql.toString());
        int idx = 1;
        if (!"all".equals(ratingFilter)) {
            pstmt.setString(idx++, ratingFilter);
        }
        if (!keyword.isEmpty()) {
            String kw = "%" + keyword + "%";
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
        }

        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",        rs.getInt("id"));
            row.put("content",   rs.getString("content"));
            String ratingStr = rs.getString("rating");
            int ratingVal = 0;
            try { ratingVal = Integer.parseInt(ratingStr != null ? ratingStr.trim() : "0"); } catch(Exception ignore) {}
            row.put("rating", ratingVal);
            row.put("place",     rs.getString("place"));
            row.put("status",    rs.getString("status"));
            row.put("username",  rs.getString("username"));
            row.put("userName",  rs.getString("user_name"));
            row.put("createdAt", rs.getString("created_at"));
            reviewList.add(row);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs    != null) rs.close();    } catch (Exception ignore) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn  != null) conn.close();  } catch (Exception ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 후기 관리</title>
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
                <h1 class="admin-page-title">후기 관리</h1>
                <p class="admin-page-desc">캠핑장 후기를 조회하고 관리합니다.</p>
            </div>
        </div>

        <!-- 처리 결과 알림 -->
        <% if ("deleted".equals(result)) { %>
            <div class="admin-alert admin-alert-success">✅ 후기가 삭제되었습니다.</div>
        <% } else if ("hidden".equals(result)) { %>
            <div class="admin-alert admin-alert-info">🔒 후기가 숨김 처리되었습니다.</div>
        <% } else if ("shown".equals(result)) { %>
            <div class="admin-alert admin-alert-success">🔓 숨김이 해제되었습니다.</div>
        <% } else if ("error".equals(result)) { %>
            <div class="admin-alert admin-alert-danger">⚠️ 처리 중 오류가 발생했습니다.</div>
        <% } %>

        <!-- 검색 -->
        <section class="admin-filter-card">
            <form method="get" action="<%=ctx%>/admin/reviews.jsp" class="admin-search-form">
                <div class="admin-form-row">
                    <div class="admin-form-group">
                        <label>검색어</label>
                        <input type="text" name="keyword" value="<%=keyword%>" class="admin-input"
                               placeholder="아이디, 이름, 캠핑장명, 내용 검색">
                    </div>
                    <div class="admin-form-group">
                        <label>별점</label>
                        <select name="rating" class="admin-select">
                            <option value="all" <%= "all".equals(ratingFilter) ? "selected" : "" %>>전체</option>
                            <option value="5" <%= "5".equals(ratingFilter) ? "selected" : "" %>>⭐⭐⭐⭐⭐ (5점)</option>
                            <option value="4" <%= "4".equals(ratingFilter) ? "selected" : "" %>>⭐⭐⭐⭐ (4점)</option>
                            <option value="3" <%= "3".equals(ratingFilter) ? "selected" : "" %>>⭐⭐⭐ (3점)</option>
                            <option value="2" <%= "2".equals(ratingFilter) ? "selected" : "" %>>⭐⭐ (2점)</option>
                            <option value="1" <%= "1".equals(ratingFilter) ? "selected" : "" %>>⭐ (1점)</option>
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
                <div class="admin-table-title">후기 목록</div>
                <div class="admin-table-count">총 <strong><%= reviewList.size() %></strong>건</div>
            </div>

            <div class="admin-table-scroll">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <th>작성자</th>
                            <th>캠핑장</th>
                            <th>별점</th>
                            <th>내용</th>
                            <th>상태</th>
                            <th>작성일</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (reviewList.isEmpty()) { %>
                        <tr>
                            <td colspan="8">
                                <div class="admin-empty-inline">조회된 후기가 없습니다.</div>
                            </td>
                        </tr>
                    <% } else {
                        for (Map<String, Object> r : reviewList) {
                            int rating = r.get("rating") != null ? (Integer) r.get("rating") : 0;
                            StringBuilder stars = new StringBuilder();
                            for (int i = 1; i <= 5; i++) stars.append(i <= rating ? "★" : "☆");

                            String st = r.get("status") != null ? String.valueOf(r.get("status")) : "";
                            String statusLabel = "hidden".equals(st) ? "숨김" : "공개";
                            String statusBadge = "hidden".equals(st) ? "admin-badge-danger" : "admin-badge-active";

                            String content = r.get("content") != null ? String.valueOf(r.get("content")) : "";
                            if (content.length() > 40) content = content.substring(0, 40) + "...";

                            String place = r.get("place") != null ? String.valueOf(r.get("place")) : "-";
                    %>
                        <tr>
                            <td><%= r.get("id") %></td>
                            <td>
                                <%= r.get("userName") %><br>
                                <span style="font-size:12px; color:#888;">(<%= r.get("username") %>)</span>
                            </td>
                            <td><%= place %></td>
                            <td style="color:#f5a623; font-size:15px;"><%= stars.toString() %></td>
                            <td style="max-width:220px; word-break:break-all;"><%= content %></td>
                            <td>
                                <span class="admin-badge <%= statusBadge %>"><%= statusLabel %></span>
                            </td>
                            <td style="font-size:12px;">
                                <%= r.get("createdAt") != null ? String.valueOf(r.get("createdAt")).substring(0, 10) : "-" %>
                            </td>
                            <td>
                                <a href="<%=ctx%>/admin/reviewAction.jsp?id=<%=r.get("id")%>&action=delete"
                                   class="admin-btn admin-btn-sm admin-btn-danger"
                                   onclick="return confirm('이 후기를 삭제하시겠습니까?');">삭제</a>
                                <% if (!"hidden".equals(st)) { %>
                                <a href="<%=ctx%>/admin/reviewAction.jsp?id=<%=r.get("id")%>&action=hide"
                                   class="admin-btn admin-btn-sm admin-btn-outline"
                                   onclick="return confirm('이 후기를 숨김 처리하시겠습니까?');">숨김</a>
                                <% } else { %>
                                <a href="<%=ctx%>/admin/reviewAction.jsp?id=<%=r.get("id")%>&action=show"
                                   class="admin-btn admin-btn-sm"
                                   style="background:#e67e22;color:#fff;border:none;"
                                   onclick="return confirm('숨김을 해제하시겠습니까?');">공개</a>
                                <% } %>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<style>
.admin-alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
    font-weight: 500;
}
.admin-alert-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
.admin-alert-info    { background: #dbeafe; color: #1e40af; border: 1px solid #93c5fd; }
.admin-alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
</style>

</body>
</html>

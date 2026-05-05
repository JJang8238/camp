<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.Post" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String type = request.getParameter("type");
    if (type == null) type = "all";

    String keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";

    PostDAO dao = new PostDAO();
    List<Post> posts = dao.getAdminPosts(type, keyword);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    
</head>

<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">

        <div class="admin-page-header">
            <div>
                <h1 class="admin-page-title">소식 / 이벤트 관리</h1>
                <p class="admin-page-desc">캠핑 소식과 이벤트 게시글을 통합 관리합니다.</p>
            </div>

            <a href="<%=ctx%>/admin/postWrite.jsp" class="admin-btn admin-btn-primary">
                글 작성
            </a>
        </div>

        <div class="admin-card">

            <form method="get" action="<%=ctx%>/admin/posts.jsp" class="admin-filter-form post-filter-form">
                <select name="type" class="admin-select">
                    <option value="all" <%= "all".equals(type) ? "selected" : "" %>>전체</option>
                    <option value="news" <%= "news".equals(type) ? "selected" : "" %>>소식</option>
                    <option value="event" <%= "event".equals(type) ? "selected" : "" %>>이벤트</option>
                </select>

                <input type="text"
                       name="keyword"
                       class="admin-input"
                       placeholder="제목 또는 내용 검색"
                       value="<%= keyword %>">

                <button type="submit" class="admin-btn admin-btn-primary">검색</button>
            </form>

            <table class="admin-table">
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>구분</th>
                        <th>제목</th>
                        <th>카테고리</th>
                        <th>상태</th>
                        <th>조회수</th>
                        <th>작성일</th>
                        <th>관리</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (posts == null || posts.isEmpty()) {
                %>
                    <tr>
                        <td colspan="8" class="admin-empty">
                            등록된 소식/이벤트가 없습니다.
                        </td>
                    </tr>
                <%
                    } else {
                        for (Post p : posts) {
                            String postType = p.getPostType();
                            String typeLabel = "event".equals(postType) ? "이벤트" : "소식";

                            String status = p.getStatus();
                            if (status == null) status = "published";

                            String statusLabel = "published".equals(status) ? "공개"
                                                : "hidden".equals(status) ? "숨김"
                                                : "draft".equals(status) ? "임시저장"
                                                : status;
                %>
                    <tr>
                        <td><%= p.getId() %></td>

                        <td>
                            <span class="admin-badge <%= "event".equals(postType) ? "badge-orange" : "badge-green" %>">
                                <%= typeLabel %>
                            </span>
                        </td>

                        <td class="admin-title-cell">
                            <%= p.getTitle() %>
                        </td>

                        <td><%= p.getCategory() != null ? p.getCategory() : "-" %></td>

                        <td>
                            <span class="admin-badge <%= "hidden".equals(status) ? "badge-gray" : "badge-green" %>">
                                <%= statusLabel %>
                            </span>
                        </td>

                        <td><%= p.getViewCount() %></td>
                        <td><%= p.getCreatedAt() %></td>

                        <td class="admin-actions">
                            <a href="<%=ctx%>/admin/postWrite.jsp?id=<%=p.getId()%>"
                               class="admin-btn admin-btn-sm">
                                수정
                            </a>

                            <% if ("hidden".equals(status)) { %>
                                <a href="<%=ctx%>/admin/postStatus.jsp?id=<%=p.getId()%>&status=published"
                                   class="admin-btn admin-btn-sm admin-btn-outline">
                                    공개
                                </a>
                            <% } else { %>
                                <a href="<%=ctx%>/admin/postStatus.jsp?id=<%=p.getId()%>&status=hidden"
                                   class="admin-btn admin-btn-sm admin-btn-outline">
                                    숨김
                                </a>
                            <% } %>

                            <a href="<%=ctx%>/admin/postDelete.jsp?id=<%=p.getId()%>"
                               class="admin-btn admin-btn-sm admin-btn-danger"
                               onclick="return confirm('정말 삭제하시겠습니까?');">
                                삭제
                            </a>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>

        </div>

    </main>
</div>

</body>
</html>
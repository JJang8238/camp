<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.NewsDAO" %>
<%@ page import="dto.News" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/newsList.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);

    NewsDAO.increaseViews(id);
    News n = NewsDAO.getById(id);

    if (n == null) {
        response.sendRedirect(ctx + "/newsList.jsp");
        return;
    }

    News prevNews = NewsDAO.getPrevNews(id);
    News nextNews = NewsDAO.getNextNews(id);

    String img = n.getImage();
    String imgPath = (img != null && !img.trim().isEmpty())
            ? ctx + "/assets/img/" + img
            : ctx + "/assets/img/default.jpg";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | <%=n.getTitle()%></title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="news-detail-page py-4">
        <div class="container">

            <div class="news-detail-wrap">
                <div class="news-detail-top">
                    <div class="news-detail-category">
                        <%= n.getCategory() != null ? n.getCategory() : "캠핑 소식" %>
                    </div>

                    <h2 class="news-detail-title"><%= n.getTitle() %></h2>

                    <div class="news-detail-meta">
                        <span>작성일 <%= n.getCreatedAt() %></span>
                        <span>조회 <%= n.getViews() %></span>
                    </div>
                </div>

                <div class="news-detail-thumb">
                    <img src="<%=imgPath%>" alt="캠핑 소식 이미지" class="news-detail-img">
                </div>

                <% if (n.getSummary() != null && !n.getSummary().trim().isEmpty()) { %>
                    <div class="news-detail-summary">
                        <%= n.getSummary() %>
                    </div>
                <% } %>

                <div class="news-detail-content">
                    <%= n.getContent() != null ? n.getContent().replace("\n", "<br>") : "" %>
                </div>

<div class="news-detail-nav">
    <div class="news-detail-nav-item">
        <div class="news-detail-nav-label">이전글</div>
        <% if (prevNews != null) { %>
            <a href="<%=ctx%>/newsDetail.jsp?id=<%=prevNews.getId()%>" class="news-detail-nav-link">
                <%= prevNews.getTitle() %>
            </a>
        <% } else { %>
            <div class="news-detail-nav-empty">이전 글이 없습니다.</div>
        <% } %>
    </div>

    <div class="news-detail-nav-item">
        <div class="news-detail-nav-label">다음글</div>
        <% if (nextNews != null) { %>
            <a href="<%=ctx%>/newsDetail.jsp?id=<%=nextNews.getId()%>" class="news-detail-nav-link">
                <%= nextNews.getTitle() %>
            </a>
        <% } else { %>
            <div class="news-detail-nav-empty">다음 글이 없습니다.</div>
        <% } %>
    </div>
</div>

                <div class="news-detail-bottom">
                    <a href="<%=ctx%>/newsList.jsp" class="news-back-btn">목록으로</a>
                </div>
            </div>

        </div>
    </main>

</body>
</html>
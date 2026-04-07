<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.Post" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String category = request.getParameter("category");
    if (category == null) category = "";

    String keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";

    PostDAO dao = new PostDAO();
    List<Post> list = dao.getFilteredNewsPosts(category, keyword);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 캠핑 소식</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="news-page py-4">
        <div class="container">

            <div class="news-title mb-4">
                <h2>캠핑 소식</h2>
                <p>캠핑 관련 최신 정보와 유용한 팁을 확인해보세요.</p>
            </div>

            <div class="news-category-filter mb-4">
                <a href="<%=ctx%>/newsList.jsp"
                   class="news-filter-btn <%= category.equals("") ? "active" : "" %>">전체</a>

                <a href="<%=ctx%>/newsList.jsp?category=캠핑 팁"
                   class="news-filter-btn <%= category.equals("캠핑 팁") ? "active" : "" %>">캠핑 팁</a>

                <a href="<%=ctx%>/newsList.jsp?category=추천 캠핑장"
                   class="news-filter-btn <%= category.equals("추천 캠핑장") ? "active" : "" %>">추천 캠핑장</a>

                <a href="<%=ctx%>/newsList.jsp?category=안전 정보"
                   class="news-filter-btn <%= category.equals("안전 정보") ? "active" : "" %>">안전 정보</a>

                <a href="<%=ctx%>/newsList.jsp?category=행사/축제"
                   class="news-filter-btn <%= category.equals("행사/축제") ? "active" : "" %>">행사/축제</a>
            </div>

            <form action="<%=ctx%>/newsList.jsp" method="get" class="news-search-form mb-4">
                <input type="hidden" name="category" value="<%=category%>">

                <div class="news-search-box">
                    <input type="text"
                           name="keyword"
                           class="news-search-input"
                           placeholder="검색어를 입력하세요"
                           value="<%=keyword%>">

                    <button type="submit" class="news-search-btn">검색</button>
                </div>
            </form>

            <div class="news-result-count mb-4">
                총 <span><%= list != null ? list.size() : 0 %></span>건의 소식이 있습니다.
            </div>

            <div class="row g-4">
                <% if (list == null || list.isEmpty()) { %>
                    <div class="col-12">
                        <div class="empty-box">
                            등록된 캠핑 소식이 없습니다.
                        </div>
                    </div>
                <% } else { %>
                    <% for (Post n : list) {
                        String imgPath = ctx + "/assets/img/default.jpg";
                        String thumb = n.getThumbnail();

                        if (thumb != null && !thumb.trim().isEmpty()) {
                            if (thumb.startsWith("http://") || thumb.startsWith("https://")) {
                                imgPath = thumb;
                            } else if (thumb.startsWith(ctx + "/")) {
                                imgPath = thumb;
                            } else if (thumb.startsWith("/")) {
                                imgPath = ctx + thumb;
                            } else {
                                imgPath = ctx + "/assets/img/" + thumb;
                            }
                        }
                    %>

                    <div class="col-md-6 col-lg-4">
                        <div class="news-card">
                            <a href="<%=ctx%>/newsDetail.jsp?id=<%=n.getId()%>" class="news-card-link">
                                <div class="news-thumb-wrap">
                                    <img src="<%=imgPath%>" alt="캠핑 소식 이미지" class="news-img">
                                </div>

                                <div class="news-body">
                                    <div class="news-category">
                                        <%= n.getCategory() != null && !n.getCategory().trim().isEmpty() ? n.getCategory() : "캠핑 소식" %>
                                    </div>

                                    <h5 class="news-title-text">
                                        <%= n.getTitle() %>
                                    </h5>

                                    <p class="news-summary">
                                        <%= n.getSummary() != null ? n.getSummary() : "" %>
                                    </p>

                                    <div class="news-meta">
                                        <span><%= n.getCreatedAt() != null ? n.getCreatedAt() : "" %></span>
                                        <span>조회 <%= n.getViewCount() %></span>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>

                    <% } %>
                <% } %>
            </div>

        </div>
    </main>

</body>
</html>
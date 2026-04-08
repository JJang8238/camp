<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.Post" %>
<%@ page import="dto.EventDetail" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/eventList.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);

    PostDAO dao = new PostDAO();
    Post p = dao.getPostById(id);

    if (p == null || !"event".equals(p.getPostType())) {
        response.sendRedirect(ctx + "/eventList.jsp");
        return;
    }

    EventDetail e = dao.getEventDetailByPostId(id);

    String imgPath = ctx + "/assets/img/default.jpg";
    String thumb = p.getThumbnail();

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

    String statusText = "이벤트";
    String eventStatus = (e != null && e.getEventStatus() != null) ? e.getEventStatus() : "";

    if ("upcoming".equals(eventStatus)) {
        statusText = "진행예정";
    } else if ("ongoing".equals(eventStatus)) {
        statusText = "진행중";
    } else if ("ended".equals(eventStatus)) {
        statusText = "종료";
    }

    String startDate = (e != null && e.getStartDate() != null) ? e.getStartDate() : "-";
    String endDate = (e != null && e.getEndDate() != null) ? e.getEndDate() : "-";

    String createdDate = "-";
    if (p.getCreatedAt() != null && p.getCreatedAt().length() >= 10) {
        createdDate = p.getCreatedAt().substring(0, 10);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 이벤트 상세</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

<main class="news-detail-page py-5">
    <div class="container">

        <div class="news-detail-wrap">

            <div class="news-detail-top">
                <div class="news-detail-category"><%= statusText %></div>
                <h1 class="news-detail-title"><%= p.getTitle() %></h1>

                <div class="news-detail-meta">
                    <span>진행 기간: <%= startDate %> ~ <%= endDate %></span>
                    <span>등록일: <%= createdDate %></span>
                </div>
            </div>

            <div class="news-detail-thumb">
                <img src="<%= imgPath %>" alt="이벤트 이미지" class="news-detail-img">
            </div>

            <% if (p.getSummary() != null && !p.getSummary().trim().isEmpty()) { %>
                <div class="news-detail-summary">
                    <%= p.getSummary() %>
                </div>
            <% } %>

            <div class="news-detail-content">
                <%= p.getContent() != null ? p.getContent().replace("\n", "<br>") : "" %>
            </div>

            <div class="news-detail-bottom">
                <a href="<%=ctx%>/eventList.jsp" class="news-back-btn">목록으로</a>
            </div>

        </div>

    </div>
</main>

</body>
</html>
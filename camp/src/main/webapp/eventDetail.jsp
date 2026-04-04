<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.EventDAO" %>
<%@ page import="dto.Event" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/eventList.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);

    Event e = EventDAO.getEventById(id);
    if (e == null) {
        response.sendRedirect(ctx + "/eventList.jsp");
        return;
    }

    String imgPath = (e.getImage() != null && !e.getImage().trim().isEmpty())
            ? ctx + e.getImage()
            : ctx + "/assets/img/default.jpg";

    String statusText = "이벤트";
    if ("ongoing".equals(e.getStatus())) {
        statusText = "진행중";
    } else if ("ended".equals(e.getStatus())) {
        statusText = "종료";
    } else if ("winner".equals(e.getStatus())) {
        statusText = "당첨자 발표";
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
                <h1 class="news-detail-title"><%= e.getTitle() %></h1>

                <div class="news-detail-meta">
                    <span>진행 기간: <%= e.getStartDate() %> ~ <%= e.getEndDate() %></span>
                    <span>등록일: <%= e.getCreatedAt() != null ? e.getCreatedAt().substring(0, 10) : "-" %></span>
                </div>
            </div>

            <div class="news-detail-thumb">
                <img src="<%= imgPath %>" alt="이벤트 이미지" class="news-detail-img">
            </div>

            <div class="news-detail-summary">
                <%= e.getSummary() != null ? e.getSummary() : "" %>
            </div>

            <div class="news-detail-content">
                <%= e.getContent() != null ? e.getContent().replace("\n", "<br>") : "" %>
            </div>

            <div class="news-detail-bottom">
                <a href="<%=ctx%>/eventList.jsp" class="news-back-btn">목록으로</a>
            </div>

        </div>

    </div>
</main>

</body>
</html>
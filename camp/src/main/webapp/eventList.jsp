<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.Post" %>
<%@ page import="dto.EventDetail" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String status = request.getParameter("status");
    if (status == null || status.trim().isEmpty()) {
        status = "all";
    }

    PostDAO dao = new PostDAO();
    List<Map<String, Object>> list;

    if ("all".equals(status)) {
        list = dao.getEventPostList();
    } else {
        list = dao.getEventPostListByEventStatus(status);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 이벤트</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="event-page py-5">
        <div class="container">

            <div class="event-title">
                <h2>이벤트</h2>
                <p>캠프 메이트에서 준비한 다양한 이벤트와 특별한 혜택을 만나보세요.</p>
            </div>

            <div class="event-category-filter">
                <a href="<%=ctx%>/eventList.jsp?status=all"
                   class="event-filter-btn <%= "all".equals(status) ? "active" : "" %>">전체</a>

                <a href="<%=ctx%>/eventList.jsp?status=upcoming"
                   class="event-filter-btn <%= "upcoming".equals(status) ? "active" : "" %>">진행예정</a>

                <a href="<%=ctx%>/eventList.jsp?status=ongoing"
                   class="event-filter-btn <%= "ongoing".equals(status) ? "active" : "" %>">진행중</a>

                <a href="<%=ctx%>/eventList.jsp?status=ended"
                   class="event-filter-btn <%= "ended".equals(status) ? "active" : "" %>">종료</a>
            </div>

<div class="event-result-count">
    총 <span><%= list != null ? list.size() : 0 %></span>건의 이벤트가 있습니다.
</div>

<% if (list == null || list.isEmpty()) { %>

    <!-- 빈 상태 -->
    <div class="event-empty-box">
        등록된 이벤트가 없습니다.
    </div>

<% } else { %>

    <!-- 리스트 있을 때만 row 시작 -->
    <div class="row g-4">

        <%
            for (Map<String, Object> item : list) {

                Post p = (Post) item.get("post");
                EventDetail e = (EventDetail) item.get("event");

                String imgPath = ctx + "/assets/img/default.jpg";
                String thumb = p.getThumbnail();

                if (thumb != null && !thumb.trim().isEmpty()) {
                    if (thumb.startsWith("http")) {
                        imgPath = thumb;
                    } else if (thumb.startsWith("/")) {
                        imgPath = ctx + thumb;
                    } else {
                        imgPath = ctx + "/assets/img/" + thumb;
                    }
                }

                String statusText = "이벤트";
                String eventStatus = (e != null) ? e.getEventStatus() : "";

                if ("upcoming".equals(eventStatus)) {
                    statusText = "진행예정";
                } else if ("ongoing".equals(eventStatus)) {
                    statusText = "진행중";
                } else if ("ended".equals(eventStatus)) {
                    statusText = "종료";
                }

                String periodText = "";
                if (e != null) {
                    String startDate = e.getStartDate() != null ? e.getStartDate() : "";
                    String endDate = e.getEndDate() != null ? e.getEndDate() : "";

                    if (!startDate.isEmpty() || !endDate.isEmpty()) {
                        periodText = startDate + " ~ " + endDate;
                    }
                }
        %>

        <div class="col-md-6 col-lg-4">
            <div class="event-card">
                <a href="<%=ctx%>/eventDetail.jsp?id=<%=p.getId()%>" class="event-card-link">

                    <div class="event-thumb-wrap">
                        <img src="<%=imgPath%>" class="event-img">
                    </div>

                    <div class="event-body">

                        <div class="event-category"><%= statusText %></div>

                        <h3 class="event-title-text"><%= p.getTitle() %></h3>

                        <p class="event-summary">
                            <%= p.getSummary() != null ? p.getSummary() : "" %>
                        </p>

                        <div class="event-meta">
                            <span><%= periodText %></span>
                        </div>

                    </div>

                </a>
            </div>
        </div>

        <%
            } // for 끝
        %>

    </div>

<% } %>
            </div>

        </div>
    </main>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.EventDAO" %>
<%@ page import="dto.Event" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String status = request.getParameter("status");
    if (status == null || status.trim().isEmpty()) {
        status = "all";
    }

    List<Event> list;
    if ("all".equals(status)) {
        list = EventDAO.getAllEvents();
    } else {
        list = EventDAO.getEventsByStatus(status);
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

                <a href="<%=ctx%>/eventList.jsp?status=ongoing"
                   class="event-filter-btn <%= "ongoing".equals(status) ? "active" : "" %>">진행중</a>

                <a href="<%=ctx%>/eventList.jsp?status=ended"
                   class="event-filter-btn <%= "ended".equals(status) ? "active" : "" %>">종료</a>

                <a href="<%=ctx%>/eventList.jsp?status=winner"
                   class="event-filter-btn <%= "winner".equals(status) ? "active" : "" %>">당첨자 발표</a>
            </div>

            <div class="event-result-count">
                총 <span><%= list != null ? list.size() : 0 %></span>건의 이벤트가 있습니다.
            </div>

            <div class="row g-4">
                <%
                    if (list == null || list.isEmpty()) {
                %>
                    <div class="col-12">
                        <div class="event-empty-box">
                            등록된 이벤트가 없습니다.
                        </div>
                    </div>
                <%
                    } else {
                        for (Event e : list) {
                            String imgPath;

                            if (e.getImage() != null && !e.getImage().trim().isEmpty()) {
                                if (e.getImage().startsWith("/")) {
                                    imgPath = ctx + e.getImage();
                                } else {
                                    imgPath = ctx + "/assets/img/" + e.getImage();
                                }
                            } else {
                                imgPath = ctx + "/assets/img/default.jpg";
                            }

                            String statusText = "이벤트";
                            if ("ongoing".equals(e.getStatus())) {
                                statusText = "진행중";
                            } else if ("ended".equals(e.getStatus())) {
                                statusText = "종료";
                            } else if ("winner".equals(e.getStatus())) {
                                statusText = "당첨자 발표";
                            }
                %>
                    <div class="col-md-6 col-lg-4">
                        <div class="event-card">
                            <a href="<%=ctx%>/eventDetail.jsp?id=<%=e.getId()%>" class="event-card-link">
                                <div class="event-thumb-wrap">
                                    <img src="<%=imgPath%>" alt="이벤트 이미지" class="event-img">
                                </div>

                                <div class="event-body">
                                    <div class="event-category"><%= statusText %></div>

                                    <h3 class="event-title-text"><%= e.getTitle() %></h3>

                                    <p class="event-summary">
                                        <%= e.getSummary() != null ? e.getSummary() : "" %>
                                    </p>

                                    <div class="event-meta">
                                        <span><%= e.getStartDate() %> ~ <%= e.getEndDate() %></span>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>
                <%
                        }
                    }
                %>
            </div>

        </div>
    </main>

</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" %>
<%-- 1. 에러를 유발하는 JSTL taglib 줄을 삭제했습니다. --%>
<%
    String headerCtx = request.getContextPath();

    // 세션 정보 수신
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role"); 
%>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">

        <div class="logo">
            <a href="<%=headerCtx%>/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>

        <nav class="nav-menu">
            <a href="<%=headerCtx%>/campList.jsp">예약하기</a>
            <a href="<%=headerCtx%>/productList.jsp">캠핑용품</a>

            <div class="dropdown">
                <a href="<%=headerCtx%>/community.jsp" class="dropbtn">
                    커뮤니티 <span class="arrow-small">▼</span>
                </a>
                <div class="dropdown-content">
                    <a href="<%=headerCtx%>/review.jsp">후기</a>
                    <a href="<%=headerCtx%>/newsList.jsp">캠핑소식</a>
                    <a href="<%=headerCtx%>/eventList.jsp">이벤트</a>
                </div>
            </div>

            <a href="<%=headerCtx%>/cs.jsp">고객센터</a>
        </nav>

        <div class="nav-right d-flex align-items-center">
            <% if (userId == null) { %>
                <a href="<%=headerCtx%>/login.jsp" class="btn-outline-custom">로그인</a>
                <a href="<%=headerCtx%>/register.jsp" class="btn-main-custom">회원가입</a>
            <% } else { %>

                <span class="welcome-msg me-3">
                    👋 
                    <strong>
                    <%= (userName != null && !userName.isEmpty()) 
                        ? userName 
                        : (username != null ? username : "사용자") %>
                    </strong>님 환영합니다!
                </span>

                <%-- 사장님 권한 확인 --%>
                <% if ("OWNER".equals(role)) { %>
                    <a href="<%=headerCtx%>/owner/dashboard.jsp" class="btn-owner-custom me-2" 
                       style="background-color: #2d5a27; color: white; padding: 6px 15px; border-radius: 20px; text-decoration: none; font-size: 13px; font-weight: 500;">
                        내 캠핑장 관리
                    </a>
                <% } %>

                <%-- 관리자 권한 확인 --%>
                <% if ("ADMIN".equals(role)) { %>
                    <a href="<%=headerCtx%>/admin/dashboard.jsp" class="btn-admin me-2"
                       style="background-color: #333; color: white; padding: 6px 15px; border-radius: 20px; text-decoration: none; font-size: 13px; font-weight: 500;">
                        관리자
                    </a>
                <% } %>

                <a href="<%=headerCtx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>
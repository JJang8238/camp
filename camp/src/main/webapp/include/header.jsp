<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String headerCtx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role"); // ⭐ 추가
%>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">

        <!-- 로고 -->
        <div class="logo">
            <a href="<%=headerCtx%>/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>

        <!-- 메뉴 -->
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

        <!-- 오른쪽 -->
        <div class="nav-right">
            <% if (userId == null) { %>
                <a href="<%=headerCtx%>/login.jsp" class="btn-outline-custom">로그인</a>
                <a href="<%=headerCtx%>/register.jsp" class="btn-main-custom">회원가입</a>
            <% } else { %>

                <span class="welcome-msg">
                    👋 
                    <%= (userName != null && !userName.isEmpty()) 
                        ? userName 
                        : (username != null ? username : "사용자") %>님 환영합니다!
                </span>

                <!-- ⭐ 관리자 버튼 -->
                <% if ("ADMIN".equals(role)) { %>
                    <a href="<%=headerCtx%>/admin/dashboard.jsp" class="btn-admin">
                        관리자
                    </a>
                <% } %>

                <a href="<%=headerCtx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>

            <% } %>
        </div>

    </div>
</header>
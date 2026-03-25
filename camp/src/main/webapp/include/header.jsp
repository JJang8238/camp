<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String headerCtx = request.getContextPath();
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
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
                <button type="button" class="dropbtn">커뮤니티</button>
                <div class="dropdown-content">
                    <a href="<%=headerCtx%>/review.jsp">후기</a>
                    <a href="<%=headerCtx%>/news.jsp">캠핑소식</a>
                </div>
            </div>

            <a href="<%=headerCtx%>/cs.jsp">고객센터</a>
        </nav>

        <div class="nav-right">
            <% if (userId == null) { %>
                <a href="<%=headerCtx%>/login.jsp" class="btn-outline-custom">로그인</a>
                <a href="<%=headerCtx%>/register.jsp" class="btn-main-custom">회원가입</a>
            <% } else { %>
                <span class="welcome-msg">👋 <%= (userName != null && !userName.isEmpty()) ? userName : userId %>님 환영합니다!</span>
                <a href="<%=headerCtx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>
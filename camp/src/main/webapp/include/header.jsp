<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String userName = (String) session.getAttribute("userName");

    // 표시용 이름 처리 (안전하게)
    String displayName = "사용자";
    if (userName != null && !userName.trim().isEmpty()) {
        displayName = userName;
    } else if (username != null && !username.trim().isEmpty()) {
        displayName = username;
    }
%>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">

        <!-- 로고 -->
        <div class="logo">
            <a href="<%=ctx%>/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>

        <!-- 메뉴 -->
        <nav class="nav-menu">
            <a href="<%=ctx%>/campList.jsp">예약하기</a>
            <a href="<%=ctx%>/productList.jsp">캠핑용품</a>

            <div class="dropdown">
                <a href="<%=ctx%>/community.jsp" class="dropbtn">
                    커뮤니티 <span class="arrow-small">▼</span>
                </a>
                <div class="dropdown-content">
                    <a href="<%=ctx%>/review.jsp">후기</a>
                    <a href="<%=ctx%>/news.jsp">캠핑소식</a>
                    <a href="<%=ctx%>/event.jsp">이벤트</a>
                </div>
            </div>

            <a href="<%=ctx%>/cs.jsp">고객센터</a>
        </nav>

        <!-- 오른쪽 -->
        <div class="nav-right">
            <% if (userId == null) { %>

                <a href="<%=ctx%>/login.jsp" class="btn-outline-custom">로그인</a>
                <a href="<%=ctx%>/register.jsp" class="btn-main-custom">회원가입</a>

            <% } else { %>

                <span class="welcome-msg">
                    👋 <%= displayName %>님 환영합니다!
                </span>

                <a href="<%=ctx%>/mypage.jsp" class="btn-outline-custom">마이페이지</a>
                <a href="<%=ctx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>

            <% } %>
        </div>

    </div>
</header>
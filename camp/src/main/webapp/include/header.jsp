<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String headerCtx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role");
%>
<%
String roleBtnStyle = "padding:6px 15px; border-radius:20px; text-decoration:none; font-size:13px; font-weight:500; color:white; background-color:#2d5a27;";
String mypageBtnStyle = "padding:6px 15px; border-radius:20px; text-decoration:none; font-size:13px; font-weight:500; color:#2d5a27; border:1.5px solid #2d5a27; background:transparent; transition:background 0.2s;";
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
            <a href="<%=headerCtx%>/campList">예약하기</a>
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

                <%-- OWNER 전용 버튼 --%>
<% if ("owner".equals(role)) { %>
    <a href="<%=headerCtx%>/owner/dashboard.jsp"
       class="me-2"
       style="<%=roleBtnStyle%>">
        캠핑장 관리
    </a>
<% } %>

<%-- ADMIN 전용 버튼 --%>
<% if ("admin".equals(role)) { %>
    <a href="<%=headerCtx%>/admin/dashboard.jsp"
       class="me-2"
       style="<%=roleBtnStyle%>">
        관리자
    </a>
<% } %>

                <%-- ✅ 마이페이지 버튼: role에 따라 다른 페이지로 이동 --%>
<% if ("owner".equals(role)) { %>
    <a href="<%=headerCtx%>/mypage/owner_mypage.jsp"
       class="me-2"
       style="<%=mypageBtnStyle%>">
        👤 마이페이지
    </a>
<% } else if ("user".equals(role)) { %>
    <a href="<%=headerCtx%>/mypage/user_mypage.jsp"
       class="me-2"
       style="<%=mypageBtnStyle%>">
        👤 마이페이지
    </a>
<% } %>

                <a href="<%=headerCtx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>

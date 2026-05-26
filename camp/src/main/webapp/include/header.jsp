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

<style>
    .mypage-btn-wrap {
        position: relative;
        display: inline-block;
    }

    .chat-alarm-badge {
        position: absolute;
        top: -6px;
        right: -6px;
        min-width: 18px;
        height: 18px;
        border-radius: 999px;
        background: #ff4444;
        color: white;
        font-size: 11px;
        font-weight: 700;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 0 4px;
        pointer-events: none;
    }
</style>

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

                <%-- 마이페이지 버튼 (알림 뱃지 포함) --%>
                <% if ("owner".equals(role)) { %>
                    <div class="mypage-btn-wrap me-2">
                        <a href="<%=headerCtx%>/mypage/owner_mypage.jsp"
                           style="<%=mypageBtnStyle%>">
                            👤 마이페이지
                        </a>
                        <span class="chat-alarm-badge" id="chatAlarmBadge">!</span>
                    </div>
                <% } else if ("user".equals(role)) { %>
                    <div class="mypage-btn-wrap me-2">
                        <a href="<%=headerCtx%>/mypage/user_mypage.jsp"
                           style="<%=mypageBtnStyle%>">
                            👤 마이페이지
                        </a>
                        <span class="chat-alarm-badge" id="chatAlarmBadge">!</span>
                    </div>
                <% } %>

                <a href="<%=headerCtx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>

<% if (userId != null) { %>
<script>
(function () {
    const ctx = "<%=headerCtx%>";
    const badge = document.getElementById("chatAlarmBadge");

    function checkUnread() {
        fetch(ctx + "/chat/unreadCount")
            .then(res => res.json())
            .then(data => {
                if (data.count > 0) {
                    badge.style.display = "inline-flex";
                } else {
                    badge.style.display = "none";
                }
            })
            .catch(() => {});
    }

    checkUnread();
    setInterval(checkUnread, 5000); // 5초마다 체크
})();
</script>
<% } %>

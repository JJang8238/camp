<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();

    if (session.getAttribute("userId") != null) {
        response.sendRedirect(ctx + "/main.jsp");
        return;
    }

    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>로그인 | Camp Mate</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/login.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <div class="login-container">
        <div class="login-header">
            <h2>Welcome Back!</h2>
            <p>오늘도 즐거운 캠핑을 위해 로그인해 주세요.</p>
        </div>

        <div class="login-card">
            <% if ("fail".equals(error)) { %>
                <div class="alert alert-danger mb-3">
                    아이디 또는 비밀번호가 올바르지 않습니다.
                </div>
            <% } else if ("required".equals(error)) { %>
                <div class="alert alert-warning mb-3">
                    로그인 후 이용해주세요.
                </div>
            <% } %>

            <form action="<%=ctx%>/login_process.jsp" method="post">
                <div class="mb-3">
                    <label class="form-label" for="username">아이디</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        class="form-control"
                        placeholder="아이디를 입력하세요"
                        required
                    >
                </div>

                <div class="mb-3">
                    <label class="form-label" for="password">비밀번호</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        class="form-control"
                        placeholder="비밀번호를 입력하세요"
                        required
                    >
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4 login-sub-row">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="saveId" name="saveId">
                        <label class="form-check-label" for="saveId">아이디 저장</label>
                    </div>
                    <a href="<%=ctx%>/findPassword.jsp" class="login-find-link">비밀번호를 잊으셨나요?</a>
                </div>

                <button type="submit" class="btn-login">로그인하기</button>
            </form>

            <div class="login-footer">
                <span>계정이 없으신가요?</span>
                <a href="<%=ctx%>/register.jsp"><strong>회원가입</strong></a>
            </div>
        </div>
    </div>

    <jsp:include page="/include/footer.jsp" />

</body>
</html>
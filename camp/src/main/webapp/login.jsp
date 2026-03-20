<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>로그인 | Camp Mate</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">

<style>
:root {
    --main-green: #1b4d3e;
    --point-orange: #ff6b35;
    --light-gray: #f8f9fa;
}

body {
    background-color: var(--light-gray);
    font-family: 'Noto Sans KR', sans-serif;
    color: #333;
}

/* --- 헤더 스타일 (기존 유지 및 보정) --- */
.main-header {
    width: 100%;
    background: white;
    border-bottom: 1px solid #eee;
    position: sticky;
    top: 0;
    z-index: 999;
}
.logo a { text-decoration: none; display: flex; align-items: center; }
.logo-icon { font-size: 24px; margin-right: 8px; }
.logo-text { font-size: 22px; font-weight: 700; color: var(--main-green); }
.nav-menu a { margin: 0 15px; text-decoration: none; color: #555; font-weight: 500; transition: 0.3s; }
.nav-menu a:hover { color: var(--main-green); }
.btn-outline { padding: 7px 16px; border: 1px solid #ddd; border-radius: 25px; color: #555; text-decoration: none; font-size: 14px; }
.btn-main { padding: 8px 18px; background: var(--main-green); color: white; border-radius: 25px; text-decoration: none; font-size: 14px; transition: 0.3s; }
.btn-main:hover { background: #12362b; color: #fff; }

/* --- 로그인 UI 핵심 --- */
.login-container {
    max-width: 440px;
    margin: 80px auto;
    padding: 0 20px;
}

.login-header {
    text-align: center;
    margin-bottom: 35px;
}
.login-header h2 {
    font-weight: 700;
    font-size: 32px;
    color: var(--main-green);
    margin-bottom: 10px;
}
.login-header p {
    color: #777;
    font-size: 15px;
}

.login-card {
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(27, 77, 62, 0.05); /* 메인 컬러를 섞은 부드러운 그림자 */
}

/* 입력창 스타일 업그레이드 */
.form-label { font-weight: 500; font-size: 14px; color: #555; }
.form-control {
    height: 52px;
    border-radius: 12px;
    border: 1px solid #e1e1e1;
    padding: 0 15px;
    transition: all 0.3s;
}
.form-control:focus {
    border-color: var(--main-green);
    box-shadow: 0 0 0 4px rgba(27, 77, 62, 0.1);
    outline: none;
}

/* 로그인 버튼 */
.btn-login {
    width: 100%;
    height: 55px;
    background: var(--main-green);
    color: white;
    border-radius: 12px;
    border: none;
    font-size: 17px;
    font-weight: 600;
    margin-top: 10px;
    transition: all 0.3s;
    cursor: pointer;
}
.btn-login:hover {
    background: #163d31;
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(27, 77, 62, 0.2);
}

/* 하단 링크 영역 */
.login-footer {
    margin-top: 25px;
    text-align: center;
    font-size: 14px;
    color: #888;
}
.login-footer a {
    color: #555;
    text-decoration: none;
    margin: 0 8px;
    transition: 0.2s;
}
.login-footer a:hover { color: var(--main-green); text-decoration: underline; }

/* 체크박스 스타일 */
.form-check-input:checked {
    background-color: var(--main-green);
    border-color: var(--main-green);
}
</style>
</head>

<body>

<header class="main-header">
    <div class="container d-flex justify-content-between align-items-center py-3">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/index.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>
        <nav class="nav-menu d-none d-md-block">
            <a href="${pageContext.request.contextPath}/productList.jsp">캠핑용품</a>
            <a href="${pageContext.request.contextPath}/community.jsp">커뮤니티</a>
            <a href="${pageContext.request.contextPath}/cs.jsp">고객센터</a>
        </nav>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/login.jsp" class="btn-outline">로그인</a>
            <a href="${pageContext.request.contextPath}/register.jsp" class="btn-main">회원가입</a>
        </div>
    </div>
</header>

<div class="login-container">
    <div class="login-header">
        <h2>Welcome Back!</h2>
        <p>오늘도 즐거운 캠핑을 위해 로그인해 주세요.</p>
    </div>

    <div class="login-card">
        <form action="login_process.jsp" method="post">
            <div class="mb-3">
                <label class="form-label">아이디</label>
                <input type="text" name="username" class="form-control" placeholder="아이디를 입력하세요" required>
            </div>

            <div class="mb-3">
                <label class="form-label">비밀번호</label>
                <input type="password" name="password" class="form-control" placeholder="비밀번호를 입력하세요" required>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="saveId">
                    <label class="form-check-label" for="saveId" style="font-size: 13px; color: #777;">아이디 저장</label>
                </div>
                <a href="#" style="font-size: 13px; color: #777; text-decoration: none;">비밀번호를 잊으셨나요?</a>
            </div>

            <button type="submit" class="btn-login">로그인하기</button>
        </form>

        <div class="login-footer">
            <span>계정이 없으신가요?</span>
            <a href="${pageContext.request.contextPath}/register.jsp"><strong>회원가입</strong></a>
        </div>
    </div>
</div>

</body>
</html>
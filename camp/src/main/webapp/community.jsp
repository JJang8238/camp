<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.UserDAO" %>
<%
    // 세션에서 로그인한 아이디 가져오기
    String userId = (String) session.getAttribute("userId");
    String userName = "";
    String ctx = request.getContextPath();
    
    // 커뮤니티는 로그인이 필요한 페이지이므로 체크
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO uDao = new UserDAO();
    userName = uDao.getNameByUsername(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | 커뮤니티</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --main-green: #1b4d3e; --point-orange: #ff6b35; --dark-text: #2d3436; --bg-beige: #f4f1ea; }
        body { background: var(--bg-beige); font-family: 'Noto Sans KR', sans-serif; color: var(--dark-text); margin: 0; }
        
        /* main.jsp와 동일한 HEADER 스타일 */
        .main-header { width: 100%; background: white; border-bottom: 1px solid #eee; position: sticky; top: 0; z-index: 999; }
        .logo a { text-decoration: none; display: flex; align-items: center; }
        .logo-icon { font-size: 24px; margin-right: 8px; }
        .logo-text { font-size: 22px; font-weight: bold; color: var(--main-green); }

        .nav-menu { display: flex; align-items: center; }
        .nav-menu > a, .nav-menu > .dropdown > .dropbtn { 
            margin: 0 20px; text-decoration: none; color: #444; font-weight: 500; transition: 0.2s; border: none; background: none; cursor: pointer; display: inline-block; padding: 10px 0;
        }
        .nav-menu a:hover, .nav-menu .dropdown:hover .dropbtn { color: var(--main-green); }
        .arrow-small { font-size: 11px; margin-left: 3px; vertical-align: middle; }

        /* 드롭다운 스타일 */
        .dropdown { position: relative; display: inline-block; }
        .dropdown-content {
            display: none; position: absolute; top: 100%; left: 50%; transform: translateX(-50%); background-color: white; min-width: 140px; box-shadow: 0px 8px 16px rgba(0,0,0,0.1); border-radius: 12px; padding: 10px 0; z-index: 1000; border: 1px solid #eee; margin-top: 0; 
        }
        .dropdown-content a { color: #555; padding: 10px 20px; text-decoration: none; display: block; font-size: 14px; font-weight: 400; transition: 0.2s; text-align: center; }
        .dropdown-content a:hover { background-color: #f8f9fa; color: var(--main-green); }
        .dropdown:hover .dropdown-content { display: block; }
        
        /* 오른쪽 영역 스타일 */
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .welcome-msg { font-weight: bold; color: var(--main-green); margin-right: 8px; font-size: 15px; }
        .btn-logout { padding: 6px 16px; border: 1px solid var(--point-orange); color: var(--point-orange); border-radius: 20px; text-decoration: none; font-size: 14px; transition: 0.2s; }
        .btn-logout:hover { background: var(--point-orange); color: white; }

        /* 커뮤니티 전용 레이아웃 */
        .comm-container { max-width: 1100px; margin: 60px auto; padding: 0 20px; }
        .comm-header { text-align: center; margin-bottom: 50px; }
        .comm-header h2 { font-weight: 700; color: var(--main-green); font-size: 36px; }
        
        .menu-card { 
            background: white; border-radius: 30px; padding: 40px; 
            text-align: center; transition: 0.3s; height: 100%;
            border: 1px solid #eee; box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            text-decoration: none; display: block; color: inherit;
        }
        .menu-card:hover { transform: translateY(-10px); box-shadow: 0 15px 40px rgba(0,0,0,0.1); border-color: var(--main-green); }
        .menu-icon { font-size: 60px; margin-bottom: 20px; display: block; }
        .menu-title { font-size: 24px; font-weight: 700; color: var(--main-green); margin-bottom: 15px; }
        .menu-desc { color: #777; font-size: 15px; line-height: 1.6; }
        
        .badge-new { background: var(--point-orange); color: white; padding: 4px 10px; border-radius: 10px; font-size: 12px; vertical-align: middle; margin-left: 5px; }
    </style>
</head>
<body>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">
        <div class="logo">
            <a href="<%=ctx%>/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>

        <nav class="nav-menu">
            <a href="<%=ctx%>/campList.jsp?mode=all">예약하기</a>
            <a href="<%=ctx%>/productList.jsp">캠핑용품</a>
            
            <div class="dropdown">
                <a href="<%=ctx%>/community.jsp" class="dropbtn" style="color: var(--main-green);">커뮤니티 <span class="arrow-small">▼</span></a>
                <div class="dropdown-content">
                    <a href="<%=ctx%>/review.jsp">후기</a>
                    <a href="<%=ctx%>/news.jsp">캠핑소식</a>
                    <a href="<%=ctx%>/event.jsp">이벤트</a>
                </div>
            </div>

            <a href="<%=ctx%>/cs.jsp">고객센터</a>
        </nav>

        <div class="nav-right">
            <span class="welcome-msg">👋 <%= userName %>님 환영합니다!</span>
            <a href="<%=ctx%>/logout.jsp" class="btn-logout">로그아웃</a>
        </div>
    </div>
</header>

<div class="comm-container">
    <div class="comm-header">
        <h2>커뮤니티 광장 🌲</h2>
        <p class="text-muted">캠퍼들과 소통하고 실시간 캠핑 정보를 확인하세요.</p>
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <a href="<%=ctx%>/review.jsp" class="menu-card">
                <span class="menu-icon">📸</span>
                <div class="menu-title">캠핑 후기</div>
                <div class="menu-desc">직접 다녀온 캠핑장의 생생한 리뷰와 별점을 확인하고 공유하세요.</div>
            </a>
        </div>

        <div class="col-md-4">
            <a href="<%=ctx%>/news.jsp" class="menu-card">
                <span class="menu-icon">📰</span>
                <div class="menu-title">캠핑 소식 <span class="badge-new">NEW</span></div>
                <div class="menu-desc">새로운 캠핑장 개장 소식과 캠핑 트렌드, 꿀팁 정보를 전해드립니다.</div>
            </a>
        </div>

        <div class="col-md-4">
            <a href="<%=ctx%>/event.jsp" class="menu-card">
                <span class="menu-icon">🎁</span>
                <div class="menu-title">이벤트</div>
                <div class="menu-desc">캠프 메이트에서 준비한 특별한 혜택과 즐거운 이벤트에 참여하세요.</div>
            </a>
        </div>
    </div>

    <div class="mt-5 p-5 bg-white rounded-5 shadow-sm text-center">
        <h5 class="fw-bold">궁금한 점이 있으신가요?</h5>
        <p class="text-muted mb-4">커뮤니티 이용 가이드나 문의사항은 고객센터를 이용해 주세요.</p>
        <a href="<%=ctx%>/cs.jsp" class="btn btn-outline-dark rounded-pill px-4">고객센터 바로가기</a>
    </div>
</div>

</body>
</html>
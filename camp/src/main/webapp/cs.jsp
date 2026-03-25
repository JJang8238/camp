<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.UserDAO" %>
<%
    // 세션에서 사용자 정보 가져오기
    String userId = (String) session.getAttribute("userId");
    String userName = "";
    String ctx = request.getContextPath();
    
    // 로그인 체크 (main.jsp 로직 반영)
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
    <title>캠프 메이트 | 고객센터</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --main-green: #1b4d3e; --point-orange: #ff6b35; --bg-beige: #f4f1ea; --dark-text: #2d3436; }
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

        /* 드롭다운 스타일 (main.jsp 동일) */
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

        /* 고객센터 컨텐츠 레이아웃 */
        .cs-main { max-width: 900px; margin: 60px auto; background: white; border-radius: 30px; padding: 50px; }
        .cs-header { text-align: center; margin-bottom: 50px; }
        .cs-header h2 { font-weight: 700; color: var(--main-green); font-size: 32px; }

        /* FAQ 아코디언 스타일 */
        .accordion-item { border: none; border-bottom: 1px solid #eee; margin-bottom: 10px; }
        .accordion-button { font-weight: 600; color: #444; padding: 20px 10px; }
        .accordion-button:not(.collapsed) { background-color: transparent; color: var(--main-green); box-shadow: none; }
        .accordion-button::after { background-size: 15px; }
        .accordion-body { color: #666; line-height: 1.8; padding: 10px 10px 30px 10px; }
        
        /* 문의 섹션 */
        .contact-box { background: #f8f9fa; border-radius: 20px; padding: 30px; margin-top: 50px; text-align: center; }
        .contact-title { font-weight: 700; margin-bottom: 5px; color: var(--main-green); }
        .contact-info { color: #888; font-size: 14px; }
        .btn-contact { background: var(--main-green); color: white; border-radius: 30px; padding: 12px 30px; border: none; margin-top: 20px; font-weight: 600; transition: 0.2s; }
        .btn-contact:hover { background: #143a2f; }
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
                <a href="<%=ctx%>/community.jsp" class="dropbtn">커뮤니티 <span class="arrow-small">▼</span></a>
                <div class="dropdown-content">
                    <a href="<%=ctx%>/review.jsp">후기</a>
                    <a href="<%=ctx%>/news.jsp">캠핑소식</a>
                    <a href="<%=ctx%>/event.jsp">이벤트</a>
                </div>
            </div>

            <a href="<%=ctx%>/cs.jsp" style="color: var(--main-green);">고객센터</a>
        </nav>

        <div class="nav-right">
            <span class="welcome-msg">👋 <%= userName %>님 환영합니다!</span>
            <a href="<%=ctx%>/logout.jsp" class="btn-logout">로그아웃</a>
        </div>
    </div>
</header>

<div class="cs-main shadow-sm">
    <div class="cs-header">
        <h2>고객센터 💬</h2>
        <p class="text-muted">무엇을 도와드릴까요? 자주 묻는 질문을 확인해 보세요.</p>
    </div>

    <div class="accordion" id="faqAccordion">
        <div class="accordion-item">
            <h2 class="accordion-header">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                    Q. 예약 취소는 어떻게 하나요?
                </button>
            </h2>
            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                <div class="accordion-body">
                    마이페이지 > 예약 내역에서 취소 버튼을 클릭하여 진행하실 수 있습니다. 취소 수수료 규정은 각 캠핑장마다 다를 수 있으니 유의해 주세요.
                </div>
            </div>
        </div>

        <div class="accordion-item">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                    Q. 캠핑장 후기는 언제 작성할 수 있나요?
                </button>
            </h2>
            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body">
                    매치(예약)가 완료되고 이용이 확인된 이후에 커뮤니티 > 후기 게시판에서 작성이 가능합니다.
                </div>
            </div>
        </div>

        <div class="accordion-item">
            <h2 class="accordion-header">
                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                    Q. 아이디나 비밀번호를 잊어버렸어요.
                </button>
            </h2>
            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                <div class="accordion-body">
                    로그인 페이지 하단의 '아이디/비밀번호 찾기'를 통해 가입하신 이메일로 정보를 확인하실 수 있습니다.
                </div>
            </div>
        </div>
    </div>

    <div class="contact-box">
        <div class="contact-title">찾으시는 질문이 없으신가요?</div>
        <div class="contact-info">평일 09:00 - 18:00 (주말 및 공휴일 제외)</div>
        <button class="btn-contact" onclick="location.href='mailto:support@campmate.com'">1:1 메일 문의하기</button>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
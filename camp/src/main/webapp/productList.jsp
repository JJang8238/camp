<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.UserDAO" %>
<%
    // 1. 세션 및 사용자 정보 조회
    String userId = (String) session.getAttribute("userId");
    String userName = "";
    String ctx = request.getContextPath(); // 프로젝트 루트 경로
    
    // 상품 페이지는 로그인이 필요한 서비스로 설정 (main.jsp 로직 반영)
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
    <title>캠프 메이트 | 캠핑용품 스토어</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        :root { 
            --main-green: #1b4d3e; 
            --point-orange: #ff6b35; 
            --bg-beige: #f4f1ea; 
            --dark-text: #2d3436;
        }
        
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

        /* 상품 컨테이너 */
        .product-container { max-width: 1200px; margin: 60px auto; padding: 0 20px; }
        .page-header { text-align: center; margin-bottom: 50px; }
        .page-header h2 { font-weight: 700; color: var(--main-green); font-size: 32px; }

        /* 상품 카드 디자인 */
        .product-card { background: white; border-radius: 25px; overflow: hidden; transition: all 0.3s ease; border: 1px solid #eee; height: 100%; display: flex; flex-direction: column; box-shadow: 0 10px 20px rgba(0,0,0,0.03); }
        .product-card:hover { transform: translateY(-10px); box-shadow: 0 15px 35px rgba(0,0,0,0.08); }
        
        .product-img-box { width: 100%; height: 250px; background: #f8f9fa; overflow: hidden; }
        .product-img-box img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s; }
        .product-card:hover .product-img-box img { transform: scale(1.08); }
        
        .product-info { padding: 25px; flex-grow: 1; text-align: left; }
        .product-category { color: #bbb; font-size: 13px; font-weight: 500; margin-bottom: 5px; text-transform: uppercase; }
        .product-name { font-size: 19px; font-weight: 700; margin-bottom: 12px; color: #333; }
        .product-price { font-size: 22px; font-weight: 800; color: var(--main-green); }
        
        .btn-buy { background: var(--main-green); color: white; border: none; padding: 12px; width: 100%; border-radius: 15px; font-weight: 700; margin-top: 20px; transition: 0.2s; }
        .btn-buy:hover { background: #2a6352; box-shadow: 0 4px 10px rgba(27, 77, 62, 0.2); }
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
            <a href="<%=ctx%>/productList.jsp" style="color: var(--main-green);">캠핑용품</a>
            
            <div class="dropdown">
                <a href="<%=ctx%>/community.jsp" class="dropbtn">커뮤니티 <span class="arrow-small">▼</span></a>
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

<div class="product-container">
    <div class="page-header">
        <h2>캠핑 기어 스토어 ⚒️</h2>
        <p class="text-muted">전문가가 엄선한 최고의 캠핑 장비를 만나보세요.</p>
    </div>

    <div class="row g-4">
        <div class="col-md-3">
            <div class="product-card">
                <div class="product-img-box">
                    <img src="<%=ctx%>/assets/img/tent.jpg" alt="텐트" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                </div>
                <div class="product-info">
                    <div class="product-category">Tents</div>
                    <div class="product-name">포레스트 돔 텐트 (4인용)</div>
                    <div class="product-price">289,000원</div>
                    <button class="btn-buy" onclick="alert('장바구니에 담겼습니다.')">장바구니 담기</button>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="product-card">
                <div class="product-img-box">
                    <img src="<%=ctx%>/assets/img/lantern.jpg" alt="랜턴" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                </div>
                <div class="product-info">
                    <div class="product-category">Lighting</div>
                    <div class="product-name">빈티지 에디슨 랜턴</div>
                    <div class="product-price">45,000원</div>
                    <button class="btn-buy" onclick="alert('장바구니에 담겼습니다.')">장바구니 담기</button>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="product-card">
                <div class="product-img-box">
                    <img src="<%=ctx%>/assets/img/chair.jpg" alt="의자" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                </div>
                <div class="product-info">
                    <div class="product-category">Furniture</div>
                    <div class="product-name">경량릴렉스 체어</div>
                    <div class="product-price">72,000원</div>
                    <button class="btn-buy" onclick="alert('장바구니에 담겼습니다.')">장바구니 담기</button>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="product-card">
                <div class="product-img-box">
                    <img src="<%=ctx%>/assets/img/table.jpg" alt="테이블" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                </div>
                <div class="product-info">
                    <div class="product-category">Table</div>
                    <div class="product-name">초경량 알루미늄 테이블</div>
                    <div class="product-price">58,000원</div>
                    <button class="btn-buy" onclick="alert('장바구니에 담겼습니다.')">장바구니 담기</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
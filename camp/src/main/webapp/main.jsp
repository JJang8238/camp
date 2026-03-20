<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.UserDAO" %> <%-- 🔥 UserDAO 임포트 확인 --%>
<%
    // 🔥 세션에서 로그인한 아이디 가져오기
    String userId = (String) session.getAttribute("userId");
    String userName = "";
    
    // 로그인이 된 상태라면 DB에서 이름을 조회함 (DAO에 getNameByUsername 메서드가 있어야 함)
    if (userId != null) {
        UserDAO dao = new UserDAO();
        userName = dao.getNameByUsername(userId);
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | Camp & Market</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        :root { --main-green: #1b4d3e; --point-orange: #ff6b35; --dark-text: #2d3436; }
        body { background: #ffffff; font-family: 'Noto Sans KR', sans-serif; color: var(--dark-text); }
        
        /* 🔥 HEADER - index.jsp와 동일한 비율로 조정 */
		.main-header { 
            width: 100%; 
            background: white; 
            border-bottom: 1px solid #eee; 
            position: sticky; 
            top: 0; 
            z-index: 999; 
        }

		/* 로고 - 미세하게 크기 키움 */
		.logo a { text-decoration: none; display: flex; align-items: center; }
		.logo-icon { font-size: 24px; margin-right: 8px; } /* index보다 약간 큼 */
		.logo-text { font-size: 22px; font-weight: bold; color: #1b4d3e; } /* index보다 약간 큼 */

		/* 메뉴 - 간격 넓힘 */
		.nav-menu a { 
            margin: 0 25px; /* 🔥 15px -> 25px로 간격 넓힘 */
            text-decoration: none; 
            color: #444; 
            font-weight: 500; 
            transition: 0.2s; 
        }
		.nav-menu a:hover { color: #1b4d3e; }
		
		/* 오른쪽 영역 */
		.nav-right { display: flex; align-items: center; gap: 12px; }

        /* 로그인 전 버튼 스타일 (기준) */
		.btn-outline { 
            padding: 6px 16px; 
            border: 1px solid #ccc; 
            border-radius: 20px; 
            color: #555; 
            text-decoration: none; 
            font-size: 14px;
        }
        .btn-main { 
            padding: 6px 18px; 
            background: #1b4d3e; 
            color: white; 
            border-radius: 20px; 
            text-decoration: none; 
            font-size: 14px;
        }

        /* 로그인 후 스타일 */
        .welcome-msg { 
            font-weight: bold; 
            color: #1b4d3e; 
            margin-right: 8px; 
            font-size: 15px;
        }

        /* 🔥 로그아웃 버튼 - index.jsp의 btn-outline 스타일 적용 후 색상만 변경 */
        .btn-logout { 
            padding: 6px 16px; /* btn-outline과 동일 */
            border: 1px solid #ff6b35; /* 테두리 주황색 */
            color: #ff6b35; /* 글자 주황색 */
            border-radius: 20px; /* 동일한 둥글기 */
            text-decoration: none; 
            font-size: 14px; 
            transition: 0.2s; 
        }
        .btn-logout:hover { 
            background: #ff6b35; 
            color: white; 
        }

        /* 기존 본문 스타일 유지 */
        .hero-container { position: relative; margin-bottom: 80px; }
        .hero-slide { width: 100%; height: 580px; position: relative; overflow: hidden; border-radius: 0 0 80px 0; }
        .hero-slide img { position: absolute; width: 100%; height: 100%; object-fit: cover; opacity: 0; transition: opacity 1.2s ease; z-index: 0; }
        .hero-slide img.active { opacity: 1; z-index: 1; transform: scale(1.1); transition: opacity 1.2s ease, transform 6s linear; }
        .overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(180deg, rgba(0,0,0,0.5), rgba(0,0,0,0.2)); z-index: 2; }
        .hero-text { position: absolute; top: 40%; left: 10%; color: white; z-index: 3; }
        .search-wrapper { position: absolute; bottom: -60px; left: 50%; transform: translateX(-50%); width: 90%; max-width: 900px; z-index: 10; }
        .search-card { background: white; border-radius: 30px; padding: 30px; }
        .nav-pills .nav-link { color: #888; border-radius: 50px; padding: 10px 25px; }
        .nav-pills .nav-link.active { background: #1b4d3e; color: white; }
        .btn-main-search { background: #1b4d3e; color: white; border-radius: 12px; padding: 12px; text-decoration: none; border: none; }
        .tag { display: inline-block; padding: 10px 24px; margin: 6px; border-radius: 50px; background: #f4f1ea; cursor: pointer; }
        .tag.active { background: #ff6b35; color: white; }
        .tag-search { background: #1b4d3e; color: white; }
        .card-item { background: white; border-radius: 10px; overflow: visible; }
        .card-img-wrapper { width: 100%; aspect-ratio: 1 / 1; overflow: hidden; border-radius: 10px; }
        .card-img-wrapper img { width: 100%; height: 100%; object-fit: cover; }
        .card-body-custom { padding: 12px 4px; }
        .item-price { color: #ff6b35; font-weight: bold; }
        .view-all-btn { text-decoration: none; font-weight: 600; color: #555; transition: 0.2s; }
        .view-all-btn:hover { color: #ff6b35; }
    </style>
</head>

<header class="main-header">
    <%-- 🔥 container -> container-fluid px-5 로 변경하여 가로폭 넓힘 --%>
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">
        <div class="logo">
            <a href="${pageContext.request.contextPath}/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>

        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/productList.jsp">캠핑용품</a>
            <a href="${pageContext.request.contextPath}/community.jsp">커뮤니티</a>
            <a href="${pageContext.request.contextPath}/cs.jsp">고객센터</a>
        </nav>

        <div class="nav-right">
            <% if (userId == null) { %>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-outline">로그인</a>
                <a href="${pageContext.request.contextPath}/register.jsp" class="btn-main">회원가입</a>
            <% } else { %>
                <span class="welcome-msg">👋 <%= userName %>님 환영합니다!</span>
                <a href="${pageContext.request.contextPath}/logout.jsp" class="btn-logout">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>

<body>
<div class="hero-container">
    <div class="hero-slide">
        <img src="${pageContext.request.contextPath}/assets/img/camp1.jpg" class="active">
        <img src="${pageContext.request.contextPath}/assets/img/camp2.jpg">
        <img src="${pageContext.request.contextPath}/assets/img/camp3.jpg">
        <div class="overlay"></div>
        <div class="hero-text">
            <h1>자연 속으로,<br><span style="color:#ff6b35;">더 가볍게</span> 떠나세요</h1>
        </div>
    </div>

    <div class="search-wrapper">
        <div class="card search-card">
            <ul class="nav nav-pills mb-3 justify-content-center">
                <li class="nav-item"><button class="nav-link active">⛺ 캠핑장 찾기</button></li>
                <li class="nav-item"><button class="nav-link">🛒 용품 거래하기</button></li>
            </ul>
            <div class="row g-2">
                <div class="col-md-9">
                    <input type="text" id="campKeyword" class="form-control form-control-lg border-0 bg-light rounded-4 px-4" placeholder="어디로 떠나고 싶으신가요?">
                </div>
                <div class="col-md-3">
                    <button class="btn-main-search w-100 shadow-sm" onclick="performSearch()">검색하기</button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container text-center" style="margin-top: 100px;">
    <div class="d-flex flex-wrap justify-content-center pt-4">
        <span class="tag" data-tag="물놀이">#물놀이 🏊</span>
        <span class="tag" data-tag="깨끗한">#깨끗한 ✨</span>
        <span class="tag" data-tag="여유있는">#여유있는 🧘</span>
        <span class="tag" data-tag="캠핑카">#캠핑카 🚐</span>
        <span class="tag" data-tag="반려견">#반려견 🐾</span>
        <span class="tag" data-tag="계곡">#계곡 🏞️</span>
        <span class="tag" data-tag="글램핑">#글램핑 ⛺</span>
        <span class="tag" data-tag="카라반">#카라반 🚍</span>
        <span class="tag tag-search" onclick="performSearch()">검색 🔍</span>
    </div>
</div>

<div class="container my-5 pb-5">
    <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
            <h3 class="fw-bold m-0">🔥 지금 가장 핫한 장비</h3>
            <p class="text-muted m-0 mt-2">캠퍼들이 직접 추천하는 베스트 매물</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/productList.jsp" class="view-all-btn">전체보기 👀</a>
        </div>
    </div>
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4" id="listDisplay"></div>
</div>

<script>
const contextPath = "${pageContext.request.contextPath}";
let selectedTags = [];

document.addEventListener("DOMContentLoaded", function () {
    const slides = document.querySelectorAll(".hero-slide img");
    let current = 0;
    setInterval(() => {
        slides[current].classList.remove("active");
        current = (current + 1) % slides.length;
        slides[current].classList.add("active");
    }, 4500);

    document.querySelectorAll(".tag:not(.tag-search)").forEach(tag => {
        tag.addEventListener("click", function () {
            const val = this.dataset.tag;
            if (selectedTags.includes(val)) {
                selectedTags = selectedTags.filter(t => t !== val);
                this.classList.remove("active");
            } else {
                selectedTags.push(val);
                this.classList.add("active");
            }
        });
    });
    loadInitialProducts();
});

function loadInitialProducts() {
    fetch(contextPath + "/product")
        .then(res => res.json())
        .then(data => renderList(data))
        .catch(err => console.log("장비 목록 로딩 실패"));
}

function performSearch() {
    const keyword = document.getElementById("campKeyword").value;
    const tags = selectedTags.join(",");
    let url = contextPath + "/camp/search?";
    if (keyword) url += "keyword=" + encodeURIComponent(keyword) + "&";
    if (tags) url += "tags=" + encodeURIComponent(tags);
    location.href = url;
}

function renderList(items) {
    const container = document.getElementById("listDisplay");
    if (!items || items.length === 0) {
        container.innerHTML = '<div class="col-12 text-center py-5 text-muted">결과가 없습니다.</div>';
        return;
    }
    let html = "";
    items.forEach(item => {
        const price = item.price ? Number(item.price) : 0;
        const img = (item.image && item.image !== "false") 
            ? contextPath + "/assets/img/" + item.image
            : contextPath + "/assets/img/default.jpg";
        html += 
        '<div class="col">' +
            '<div class="card-item">' +
                '<div class="card-img-wrapper">' +
                    '<img src="' + img + '" onerror="this.src=\'' + contextPath + '/assets/img/default.jpg\'">' +
                '</div>' +
                '<div class="card-body-custom">' +
                    '<div class="category-label">' + (item.category || '중고거래') + '</div>' +
                    '<div class="item-title text-truncate">' + item.name + '</div>' +
                    '<div class="item-price">' + price.toLocaleString() + '원</div>' +
                '</div>' +
            '</div>' +
        '</div>';
    });
    container.innerHTML = html;
}
</script>
</body>
</html>
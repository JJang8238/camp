<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.UserDAO, dao.ProductDAO, dto.Product, java.util.List" %>
<%
    String ctx = request.getContextPath();
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");

    List<Product> mainProducts = ProductDAO.getAllProducts();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | Camp & Market</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/main.css">
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
            <a href="<%=ctx%>/campList">예약하기</a>
            <a href="<%=ctx%>/productList.jsp">캠핑용품</a>

            <div class="dropdown">
                <a href="#" class="dropbtn">커뮤니티</a>
                <div class="dropdown-content">
                    <a href="<%=ctx%>/review.jsp">후기</a>
                    <a href="<%=ctx%>/news.jsp">캠핑소식</a>
                </div>
            </div>

            <a href="<%=ctx%>/cs.jsp">고객센터</a>
        </nav>

        <div class="nav-right">
            <% if (userId == null) { %>
                <a href="<%=ctx%>/login.jsp" class="btn-outline-custom">로그인</a>
                <a href="<%=ctx%>/register.jsp" class="btn-main-custom">회원가입</a>
            <% } else { %>
                <span class="welcome-msg">👋 <%= (userName != null && !userName.isEmpty()) ? userName : userId %>님 환영합니다!</span>
                <a href="<%=ctx%>/logout.jsp" class="btn-logout-custom">로그아웃</a>
            <% } %>
        </div>
    </div>
</header>

<div class="hero-container">
    <div class="hero-slide">
        <img src="<%=ctx%>/assets/img/camp1.jpg" class="active" alt="캠핑 이미지 1">
        <img src="<%=ctx%>/assets/img/camp2.jpg" alt="캠핑 이미지 2">
        <img src="<%=ctx%>/assets/img/camp3.jpg" alt="캠핑 이미지 3">

        <div class="overlay"></div>

        <div class="hero-text">
            <h1>
                자연 속으로,<br>
                <span class="hero-point">더 가볍게</span> 떠나세요
            </h1>
        </div>
    </div>

    <div class="search-wrapper">
        <div class="card search-card border-0">
            <ul class="nav nav-pills mb-3 justify-content-center" id="searchTab">
                <li class="nav-item">
                    <button type="button" class="nav-link active" onclick="changeSearchMode('camp', this)">⛺ 캠핑장 찾기</button>
                </li>
                <li class="nav-item">
                    <button type="button" class="nav-link" onclick="changeSearchMode('product', this)">🛒 용품 거래하기</button>
                </li>
            </ul>

            <div class="row g-2">
                <div class="col-md-9">
                    <input
                        type="text"
                        id="mainSearchInput"
                        class="form-control form-control-lg border-0 bg-light rounded-4 px-4 main-search-input"
                        placeholder="어디로 떠나고 싶으신가요?"
                        onkeyup="if(window.event.keyCode==13){handleSearch()}"
                    >
                </div>
                <div class="col-md-3">
                    <button class="btn-main-search shadow-sm" onclick="handleSearch()">검색하기</button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container text-center mt-5 pt-5">
    <div class="d-flex flex-wrap justify-content-center pt-4">
        <span class="tag" data-tag="물놀이">#물놀이 🏊</span>
        <span class="tag" data-tag="깨끗한">#깨끗한 ✨</span>
        <span class="tag" data-tag="여유있는">#여유있는 🧘</span>
        <span class="tag" data-tag="캠핑카">#캠핑카 🚐</span>
        <span class="tag" data-tag="반려견">#반려견 🐾</span>
        <span class="tag" data-tag="계곡">#계곡 🏞️</span>
        <span class="tag" data-tag="글램핑">#글램핑 ⛺</span>
        <span class="tag" data-tag="카라반">#카라반 🚍</span>
        <span class="tag tag-search" onclick="performTagSearch()">검색 🔍</span>
    </div>
</div>

<div class="container my-5 pb-5">
    <div class="d-flex justify-content-between align-items-end mb-4 px-2">
        <div>
            <h3 class="hot-title m-0">🔥 지금 가장 핫한 장비</h3>
        </div>
        <a href="<%=ctx%>/productList.jsp" class="view-all-btn">전체보기 👀</a>
    </div>

    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
        <%
            if (mainProducts != null && !mainProducts.isEmpty()) {
                int limit = Math.min(mainProducts.size(), 4);
                for (int i = 0; i < limit; i++) {
                    Product p = mainProducts.get(i);
                    String imgFile = p.getImage();
                    String imgPath = ctx + "/assets/img/default.jpg";

                    if (imgFile != null && !imgFile.trim().isEmpty()) {
                        imgFile = imgFile.trim();

                        // 1) 이미 /assets 또는 /uploads처럼 /로 시작하는 경로
                        if (imgFile.startsWith("/")) {
                            imgPath = ctx + imgFile;
                        }
                        // 2) http 이미지
                        else if (imgFile.startsWith("http://") || imgFile.startsWith("https://")) {
                            imgPath = imgFile;
                        }
                        // 3) DB에 파일명만 들어간 경우: tent.jpg
                        else {
                            imgPath = ctx + "/assets/img/" + imgFile;
                        }
                    }
        %>
        <div class="col">
            <a href="<%=ctx%>/productList.jsp" class="card-item">
                <div class="card-img-wrapper">
                    <img src="<%=imgPath%>" alt="<%= p.getName() %>" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                </div>
                <div class="card-body-custom">
                    <div class="item-title text-truncate"><%= p.getName() %></div>
                    <div class="item-price"><%= String.format("%,d", p.getPrice()) %>원</div>
                </div>
            </a>
        </div>
        <%
                }
            } else {
        %>
        <div class="col-12 text-center py-5">
            <p class="text-muted">등록된 상품이 없습니다. 🏕️</p>
        </div>
        <% } %>
    </div>
</div>

<footer class="site-footer">
    <div class="container">
        <div class="footer-text">
            Copyright © Camp Mate. All rights reserved.
        </div>
    </div>
</footer>

<script>
const contextPath = "<%=ctx%>";
let currentSearchMode = 'camp';
let selectedTags = [];

document.addEventListener("DOMContentLoaded", function () {
    const slides = document.querySelectorAll(".hero-slide img");
    let current = 0;

    if (slides.length > 0) {
        setInterval(() => {
            slides[current].classList.remove("active");
            current = (current + 1) % slides.length;
            slides[current].classList.add("active");
        }, 4500);
    }

    document.querySelectorAll(".tag:not(.tag-search)").forEach(tag => {
        tag.addEventListener("click", function () {
            const val = this.dataset.tag;
            this.classList.toggle("active");

            if (selectedTags.includes(val)) {
                selectedTags = selectedTags.filter(t => t !== val);
            } else {
                selectedTags.push(val);
            }
        });
    });
});

function changeSearchMode(mode, btn) {
    currentSearchMode = mode;

    document.querySelectorAll('#searchTab .nav-link').forEach(el => el.classList.remove('active'));
    btn.classList.add('active');

    const input = document.getElementById("mainSearchInput");
    input.placeholder = (mode === 'camp')
        ? "어디로 떠나고 싶으신가요?"
        : "어떤 장비가 필요하신가요?";
}

function handleSearch() {
    const keyword = document.getElementById("mainSearchInput").value.trim();

    if (!keyword) {
        alert("검색어를 입력해주세요.");
        return;
    }

    if (currentSearchMode === 'camp') {
        location.href = contextPath + "/campList?keyword=" + encodeURIComponent(keyword);
    } else {
        location.href = contextPath + "/productList.jsp?keyword=" + encodeURIComponent(keyword);
    }
}

function performTagSearch() {
    if (selectedTags.length === 0) {
        alert("필터를 선택해주세요.");
        return;
    }

    location.href = contextPath + "/campList?tags=" + encodeURIComponent(selectedTags.join(","));
}
</script>

</body>
</html>
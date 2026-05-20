<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ProductDAO, dto.Product, java.util.List" %>
<%
    String ctx = request.getContextPath();
    List<Product> mainProducts = ProductDAO.getAllProducts();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | Camp & Market</title>

    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/main.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="hero-container">
    <div class="hero-slide">
        <img src="<%=ctx%>/assets/img/camp1.jpg" class="active" alt="캠핑 이미지1">
        <img src="<%=ctx%>/assets/img/camp2.jpg" alt="캠핑 이미지2">
        <img src="<%=ctx%>/assets/img/camp3.jpg" alt="캠핑 이미지3">

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
                    <button type="button" class="nav-link active" onclick="changeSearchMode('camp', this)">
                        ⛺ 캠핑장 찾기
                    </button>
                </li>
                <li class="nav-item">
                    <button type="button" class="nav-link" onclick="changeSearchMode('product', this)">
                        🛒 용품 거래하기
                    </button>
                </li>
            </ul>

            <div class="row g-2">
                <div class="col-md-9">
                    <input
                        type="text"
                        id="mainSearchInput"
                        class="form-control form-control-lg border-0 bg-light rounded-4 px-4 main-search-input"
                        placeholder="어디로 떠나고 싶으신가요?"
                    >
                </div>
                <div class="col-md-3">
                    <button class="btn-main-search w-100 shadow-sm" type="button" onclick="handleSearch()">
                        검색하기
                    </button>
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

<!-- ✅ AI 캠핑 스타일 추천 위젯 -->
<div class="container mt-2 mb-5" id="styleQuizSection">
    <div class="style-quiz-card">
        <div class="style-quiz-header">
            <span class="style-quiz-badge">✨ 캠핑장 추천</span>
            <h3 class="style-quiz-title">어떤 캠핑을 원하세요?</h3>
            <p class="style-quiz-sub">스타일을 선택하면 딱 맞는 캠핑장을 추천해드려요 (중복 선택 가능)</p>
        </div>

        <div class="style-options" id="styleOptions">
            <button class="style-btn" data-style="감성힐링" onclick="toggleStyle(this)">
                <span class="style-icon">🌙</span>
                <span class="style-label">감성 힐링</span>
                <span class="style-desc">글램핑 · 야경 · 조용한</span>
            </button>
            <button class="style-btn" data-style="액티브" onclick="toggleStyle(this)">
                <span class="style-icon">🏊</span>
                <span class="style-label">액티브</span>
                <span class="style-desc">물놀이 · 계곡 · 수영장</span>
            </button>
            <button class="style-btn" data-style="반려동물" onclick="toggleStyle(this)">
                <span class="style-icon">🐾</span>
                <span class="style-label">반려동물과</span>
                <span class="style-desc">반려견 · 애견동반 · 산책로</span>
            </button>
            <button class="style-btn" data-style="럭셔리" onclick="toggleStyle(this)">
                <span class="style-icon">👑</span>
                <span class="style-label">럭셔리</span>
                <span class="style-desc">풀빌라 · 스파 · 프리미엄</span>
            </button>
            <button class="style-btn" data-style="자연탐험" onclick="toggleStyle(this)">
                <span class="style-icon">🏕️</span>
                <span class="style-label">자연 탐험</span>
                <span class="style-desc">차박 · 계곡 · 산</span>
            </button>
            <button class="style-btn" data-style="가족여행" onclick="toggleStyle(this)">
                <span class="style-icon">👨‍👩‍👧‍👦</span>
                <span class="style-label">가족 여행</span>
                <span class="style-desc">어린이놀이터 · 바베큐</span>
            </button>
            <button class="style-btn" data-style="로맨틱" onclick="toggleStyle(this)">
                <span class="style-icon">🌹</span>
                <span class="style-label">로맨틱</span>
                <span class="style-desc">야경 · 글램핑 · 감성</span>
            </button>
            <button class="style-btn" data-style="당일치기" onclick="toggleStyle(this)">
                <span class="style-icon">☀️</span>
                <span class="style-label">당일치기</span>
                <span class="style-desc">피크닉 · 바베큐 · 가볍게</span>
            </button>
        </div>

        <div class="style-quiz-footer" id="styleQuizFooter" style="display:none;">
            <div class="selected-styles-wrap">
                <span class="selected-label">선택한 스타일:</span>
                <span id="selectedStylesText"></span>
            </div>
            <button class="btn-style-search" onclick="handleStyleSearch()">
                이 스타일로 캠핑장 찾기 →
            </button>
        </div>
    </div>
</div>

<style>
.style-quiz-card {
    background: linear-gradient(135deg, #f0f8f2 0%, #fafff7 100%);
    border: 1.5px solid #d4edda;
    border-radius: 20px;
    padding: 32px;
}
.style-quiz-header { text-align: center; margin-bottom: 24px; }
.style-quiz-badge {
    display: inline-block;
    background: var(--main-green, #2c7846);
    color: #fff;
    font-size: 12px;
    font-weight: 700;
    padding: 4px 14px;
    border-radius: 20px;
    margin-bottom: 10px;
}
.style-quiz-title { font-size: 22px; font-weight: 700; color: #1a1a1a; margin: 8px 0 6px; }
.style-quiz-sub { font-size: 14px; color: #666; margin: 0; }
.style-options {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 20px;
}
.style-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    padding: 16px 10px;
    background: #fff;
    border: 2px solid #e8f5e9;
    border-radius: 14px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: center;
}
.style-btn:hover {
    border-color: var(--main-green, #2c7846);
    background: #f0f8f2;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(44,120,70,0.12);
}
.style-btn.active {
    border-color: var(--main-green, #2c7846);
    background: #e8f5e9;
    box-shadow: 0 0 0 3px rgba(44,120,70,0.15);
}
.style-icon { font-size: 26px; line-height: 1; }
.style-label { font-size: 13px; font-weight: 700; color: #222; }
.style-desc  { font-size: 11px; color: #888; line-height: 1.3; }
.style-quiz-footer {
    border-top: 1px solid #d4edda;
    padding-top: 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
}
.selected-styles-wrap { font-size: 14px; color: #444; }
.selected-label { font-weight: 600; margin-right: 6px; color: #333; }
#selectedStylesText { color: var(--main-green, #2c7846); font-weight: 600; }
.btn-style-search {
    background: var(--main-green, #2c7846);
    color: #fff;
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.2s, transform 0.1s;
}
.btn-style-search:hover { background: #225e38; transform: translateY(-1px); }
@media (max-width: 768px) {
    .style-options { grid-template-columns: repeat(2, 1fr); }
    .style-quiz-footer { flex-direction: column; align-items: flex-start; }
    .btn-style-search { width: 100%; text-align: center; }
}
</style>

<div class="container my-5 pb-5">
    <div class="d-flex justify-content-between align-items-end mb-4 px-2">
        <div>
            <h3 class="fw-bold m-0 hot-title">🔥 지금 가장 핫한 장비</h3>
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
            <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="card-item">
                <div class="card-img-wrapper">
                    <img
                        src="<%=imgPath%>"
                        alt="<%=p.getName()%>"
                        onerror="this.src='<%=ctx%>/assets/img/default.jpg'"
                    >
                </div>
                <div class="card-body-custom">
                    <div class="category-label">CAMPING GEAR</div>
                    <div class="item-title"><%= p.getName() %></div>
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

<jsp:include page="/include/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
const contextPath = "<%=ctx%>";
let currentSearchMode = "camp";
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

    const searchInput = document.getElementById("mainSearchInput");
    if (searchInput) {
        searchInput.addEventListener("keydown", function (e) {
            if (e.key === "Enter") {
                handleSearch();
            }
        });
    }
});

function changeSearchMode(mode, btn) {
    currentSearchMode = mode;

    document.querySelectorAll("#searchTab .nav-link").forEach(el => {
        el.classList.remove("active");
    });
    btn.classList.add("active");

    const input = document.getElementById("mainSearchInput");
    input.placeholder = (mode === "camp")
        ? "어디로 떠나고 싶으신가요?"
        : "어떤 장비가 필요하신가요?";
}

function handleSearch() {
    const keyword = document.getElementById("mainSearchInput").value.trim();

    if (!keyword) {
        alert("검색어를 입력해주세요.");
        return;
    }

    if (currentSearchMode === "camp") {
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

// ✅ AI 스타일 선택 토글
let selectedStyles = [];

function toggleStyle(btn) {
    const style = btn.dataset.style;
    if (selectedStyles.includes(style)) {
        selectedStyles = selectedStyles.filter(s => s !== style);
        btn.classList.remove("active");
    } else {
        selectedStyles.push(style);
        btn.classList.add("active");
    }

    const footer = document.getElementById("styleQuizFooter");
    const textEl  = document.getElementById("selectedStylesText");
    const labels  = {
        "감성힐링":"🌙 감성 힐링", "액티브":"🏊 액티브",
        "반려동물":"🐾 반려동물과", "럭셔리":"👑 럭셔리",
        "자연탐험":"🏕️ 자연 탐험", "가족여행":"👨‍👩‍👧‍👦 가족 여행",
        "로맨틱":"🌹 로맨틱",     "당일치기":"☀️ 당일치기"
    };

    if (selectedStyles.length > 0) {
        textEl.textContent = selectedStyles.map(s => labels[s] || s).join(" + ");
        footer.style.display = "flex";
    } else {
        footer.style.display = "none";
    }
}

// ✅ 스타일 기반 캠핑장 검색 (날짜도 함께 전달)
function handleStyleSearch() {
    if (selectedStyles.length === 0) return;
    const checkIn  = document.getElementById("mainCheckIn")  ? document.getElementById("mainCheckIn").value  : "";
    const checkOut = document.getElementById("mainCheckOut") ? document.getElementById("mainCheckOut").value : "";

    let url = contextPath + "/campList?styles=" + encodeURIComponent(selectedStyles.join(","));
    if (checkIn)  url += "&checkIn="  + encodeURIComponent(checkIn);
    if (checkOut) url += "&checkOut=" + encodeURIComponent(checkOut);
    location.href = url;
}
</script>

</body>
</html>
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
                    String imgPath = (imgFile != null && !imgFile.trim().isEmpty())
                            ? ctx + "/assets/img/" + imgFile
                            : ctx + "/assets/img/default.jpg";
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
</script>

</body>
</html>
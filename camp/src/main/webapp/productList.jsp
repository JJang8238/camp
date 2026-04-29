<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="dao.UserDAO, dao.ProductDAO, dto.Product" %>

<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    UserDAO uDao = new UserDAO();
    String userName = uDao.getNameByUserId(userId);
    session.setAttribute("userName", userName);

    final String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    final String selectedCategories = request.getParameter("category") != null ? request.getParameter("category") : "";

    final List<String> selectedCategoryList =
            !selectedCategories.trim().isEmpty()
            ? Arrays.asList(selectedCategories.split("\\s*,\\s*"))
            : Collections.emptyList();

    List<Product> list = ProductDAO.getAllProducts();

    if (!keyword.isEmpty()) {
        list = list.stream()
                .filter(p -> p.getName() != null && p.getName().contains(keyword))
                .collect(Collectors.toList());
    }

    if (!selectedCategoryList.isEmpty()) {
        list = list.stream()
                .filter(p -> {
                    if (p.getCategory() == null) return false;
                    for (String cat : selectedCategoryList) {
                        if (p.getCategory().equals(cat)) return true;
                    }
                    return false;
                })
                .collect(Collectors.toList());
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | 스토어</title>

    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/product.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="content-wrapper">
    <aside class="sidebar">
        <div class="sidebar-sticky">

            <div class="filter-card">
                <h3 class="filter-title">상품 검색</h3>

                <div class="filter-group">
                    <label class="filter-label" for="sidebarKeyword">검색어</label>
                    <input
                        type="text"
                        id="sidebarKeyword"
                        class="filter-input"
                        placeholder="상품명을 입력하세요"
                        value="<%= keyword %>"
                        onkeyup="if(window.event.keyCode==13){searchProducts();}"
                    >
                </div>

                <div class="filter-group">
                    <label class="filter-label">상품 유형</label>
                    <div class="common-tag-list">
                        <span class="common-tag" onclick="selectCategory('텐트')">텐트</span>
                        <span class="common-tag" onclick="selectCategory('의자')">의자</span>
                        <span class="common-tag" onclick="selectCategory('테이블')">테이블</span>
                        <span class="common-tag" onclick="selectCategory('랜턴')">랜턴</span>
                        <span class="common-tag" onclick="selectCategory('버너')">버너</span>
                        <span class="common-tag" onclick="selectCategory('침낭')">침낭</span>
                        <span class="common-tag" onclick="selectCategory('기타')">기타</span>
                    </div>
                    <input type="hidden" id="categoryInput" value="<%= selectedCategories %>">
                </div>

                <div class="filter-group">
                    <button type="button" class="btn btn-primary w-100" onclick="searchProducts()">검색하기</button>
                </div>
            </div>

            <div class="filter-card">
                <h3 class="filter-title">빠른 메뉴</h3>
                <ul class="side-menu">
                    <li><a href="<%=ctx%>/productList.jsp" class="active">전체 상품</a></li>
                    <li><a href="<%=ctx%>/productWrite.jsp">상품 등록</a></li>
                    <li><a href="<%=ctx%>/mypage.jsp">내 거래 보기</a></li>
                </ul>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <h2 class="page-section-title">캠핑용품</h2>
        <p class="section-sub-title">원하는 장비를 찾아보고 안전하게 거래해보세요.</p>

        <div class="product-count">
            총 <strong><%= list.size() %></strong>개의 상품이 검색되었습니다.
        </div>

        <% if (list == null || list.isEmpty()) { %>
            <div class="empty-box">
                검색된 상품이 없습니다.
            </div>
        <% } else {
            for (Product p : list) {
                String imgFile = p.getImage();
                String imgPath = (imgFile != null && !imgFile.trim().isEmpty())
                        ? ctx + imgFile
                        : ctx + "/assets/img/default.jpg";

                String status = p.getStatus();
                boolean isSoldOut = "soldout".equals(status);

                String desc = p.getDescription();
                if (desc != null && desc.length() > 80) {
                    desc = desc.substring(0, 80) + "...";
                }
        %>
            <div class="horizontal-card <%= isSoldOut ? "soldout-card" : "" %>">
                <div class="img-box">
                    <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="product-thumb-link">
                        <img src="<%=imgPath%>" alt="<%=p.getName()%>" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                    </a>
                </div>

                <div class="info-box">
                    <div>
                        <div class="card-top-line">
                            <div class="product-name-link">
                                <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>">
                                    <h3 class="card-main-title"><%= p.getName() %></h3>
                                </a>
                                <div class="card-sub-text">Camp Mate 중고거래</div>
                            </div>

                            <span class="badge-soft <%= isSoldOut ? "soldout-badge" : "" %>">
                                <%= isSoldOut ? "판매완료" : "중고거래" %>
                            </span>
                        </div>

                        <div class="card-desc">
                            <%= (desc != null && !desc.isEmpty()) ? desc : "상품 설명이 없습니다." %>
                        </div>

                        <div class="card-meta">
                            <% if (p.getCategory() != null) { %>
                                <span class="meta-chip"><%= p.getCategory() %></span>
                            <% } %>

                            <% if (isSoldOut) { %>
                                <span class="meta-chip soldout-chip">거래불가</span>
                            <% } else { %>
                                <span class="meta-chip green">직거래 가능</span>
                            <% } %>

                            <span class="meta-chip point">인기 상품</span>

                            <% if (p.isRecent()) { %>
                                <span class="meta-chip point">최근 등록</span>
                            <% } %>
                        </div>
                    </div>

                    <div class="card-bottom-line">
                        <div>
                            <p class="card-price"><%= String.format("%,d", p.getPrice()) %>원</p>
                            <div class="card-extra">
                                <%= isSoldOut ? "판매가 완료된 상품입니다." : "상세 페이지에서 상품 정보를 확인하세요." %>
                            </div>
                        </div>

                        <div class="card-action-group">
                            <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="btn btn-outline">상세보기</a>

                            <% if (isSoldOut) { %>
                                <button type="button" class="btn btn-outline" disabled>거래불가</button>
                            <% } else { %>
                                <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="btn btn-point">거래하기</a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        <%  }
           } %>
    </main>
</div>

<jsp:include page="/include/footer.jsp" />

<script>
const ctx = "<%=ctx%>";

function getSelectedCategories() {
    const value = document.getElementById("categoryInput").value.trim();
    if (!value) return [];
    return value.split(",").map(v => v.trim()).filter(v => v !== "");
}

function setSelectedCategories(categories) {
    document.getElementById("categoryInput").value = categories.join(",");
}

function updateTagStyle() {
    const selected = getSelectedCategories();
    const tags = document.querySelectorAll(".common-tag");

    tags.forEach(tag => {
        const text = tag.textContent.trim();
        if (selected.includes(text)) {
            tag.classList.add("active");
        } else {
            tag.classList.remove("active");
        }
    });
}

function selectCategory(category) {
    let selected = getSelectedCategories();

    if (selected.includes(category)) {
        selected = selected.filter(c => c !== category);
    } else {
        selected.push(category);
    }

    setSelectedCategories(selected);
    updateTagStyle();
}

function searchProducts() {
    const keyword = document.getElementById("sidebarKeyword").value.trim();
    const categories = document.getElementById("categoryInput").value.trim();

    let url = ctx + "/productList.jsp?keyword=" + encodeURIComponent(keyword);

    if (categories) {
        url += "&category=" + encodeURIComponent(categories);
    }

    location.href = url;
}

document.addEventListener("DOMContentLoaded", function () {
    updateTagStyle();
});
</script>

</body>
</html>
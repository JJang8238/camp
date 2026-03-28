<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ProductDAO, dto.Product, dao.UserDAO, dto.User, java.util.List" %>

<%
String ctx = request.getContextPath();

String idStr = request.getParameter("id");
if (idStr == null) {
    out.println("상품 id 없음");
    return;
}

int id = Integer.parseInt(idStr);

ProductDAO dao = new ProductDAO();
Product p = dao.getProductById(id);

if (p == null) {
    out.println("상품 없음");
    return;
}

UserDAO userDao = new UserDAO();
User seller = userDao.getUserById(p.getSellerId());

List<Product> sellerProducts = dao.getProductsBySeller(p.getSellerId());
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title><%= p.getName() %></title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/product.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="product-main">

    <!-- 상품 이미지 -->
    <div class="product-left">
        <img 
            src="<%=ctx%>/assets/img/<%= (p.getImage() != null) ? p.getImage() : "product-default.png" %>" 
            class="product-main-img">
    </div>

    <!-- 상품 상세 카드 -->
    <div class="product-right-card">
        <div class="product-info-top">
            <h1><%= p.getName() %></h1>
        </div>

        <div class="product-summary-desc">
            <%= (p.getDescription() != null && !p.getDescription().trim().isEmpty())
                ? p.getDescription()
                : "등록된 설명이 없습니다." %>
        </div>

        <div class="product-info-bottom">
            <div class="price-box">₩ <%= p.getPrice() %></div>
            <button class="btn-submit-common">구매하기</button>
        </div>
    </div>

</div>

<!-- 판매자 정보 카드 -->
<div class="product-detail-wrap product-section-wrap">
    <div class="detail-section-card seller-info-card">
        <h3 class="detail-card-title">판매자 정보</h3>

        <div class="seller-info-row">
            <span class="seller-label">이름</span>
            <span class="seller-value"><%= (seller != null) ? seller.getName() : "알 수 없음" %></span>
        </div>
    </div>
</div>

<!-- 판매자의 다른 상품 카드 -->
<div class="product-detail-wrap product-section-wrap">
    <div class="detail-section-card seller-products-card">
        <h3 class="detail-card-title">판매자의 다른 상품</h3>

        <div class="product-list-grid">
            <%
            boolean hasOtherProduct = false;
            if (sellerProducts != null) {
                for (Product sp : sellerProducts) {
                    if (sp.getId() == p.getId()) continue;
                    hasOtherProduct = true;
            %>
                <div class="product-card" onclick="location.href='<%=ctx%>/productDetail.jsp?id=<%=sp.getId()%>'">
                    <img src="<%=ctx%>/assets/img/<%= (sp.getImage() != null) ? sp.getImage() : "product-default.png" %>">
                    <div class="product-card-body">
                        <div class="product-title"><%= sp.getName() %></div>
                        <div class="product-price">₩ <%= sp.getPrice() %></div>
                    </div>
                </div>
            <%
                }
            }

            if (!hasOtherProduct) {
            %>
                <div class="empty-box product-other-empty">
                    판매자의 다른 상품이 없습니다.
                </div>
            <%
            }
            %>
        </div>
    </div>
</div>

<jsp:include page="/include/footer.jsp" />

</body>
</html>
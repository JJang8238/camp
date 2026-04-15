<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="util.DBUtil" %>

<%
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/productList.jsp';</script>");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(idStr);
    } catch (Exception e) {
        out.println("<script>alert('잘못된 상품 번호입니다.'); location.href='" + ctx + "/productList.jsp';</script>");
        return;
    }

    String productName = "";
    int productPrice = 0;
    String productDescription = "";
    String productCategory = "";
    String productLocation = "";
    String sellerName = "";
    String sellerUsername = "";
    String mainImage = "";
    String productStatus = "";
    int sellerId = 0;

    List<String> imageList = new ArrayList<>();

    class OtherProduct {
        int id;
        String name;
        int price;
        String image;
        String status;
    }

    List<OtherProduct> otherProducts = new ArrayList<>();

    Connection conn = null;
    PreparedStatement psProduct = null;
    PreparedStatement psImage = null;
    PreparedStatement psOther = null;
    ResultSet rsProduct = null;
    ResultSet rsImage = null;
    ResultSet rsOther = null;

    try {
        conn = DBUtil.getConnection();

        String productSql =
            "SELECT p.id, p.name, p.price, p.image, p.description, p.category, p.location, p.status, p.seller_id, " +
            "       u.name AS seller_name, u.username AS seller_username " +
            "FROM product p " +
            "LEFT JOIN users u ON p.seller_id = u.id " +
            "WHERE p.id = ? AND (p.status IS NULL OR p.status <> 'hidden')";

        psProduct = conn.prepareStatement(productSql);
        psProduct.setInt(1, productId);
        rsProduct = psProduct.executeQuery();

        if (!rsProduct.next()) {
            out.println("<script>alert('존재하지 않거나 숨김 처리된 상품입니다.'); location.href='" + ctx + "/productList.jsp';</script>");
            return;
        }

        productName = rsProduct.getString("name");
        productPrice = rsProduct.getInt("price");
        mainImage = rsProduct.getString("image");
        productDescription = rsProduct.getString("description");
        productCategory = rsProduct.getString("category");
        productLocation = rsProduct.getString("location");
        productStatus = rsProduct.getString("status");
        sellerId = rsProduct.getInt("seller_id");
        sellerName = rsProduct.getString("seller_name");
        sellerUsername = rsProduct.getString("seller_username");

        if (productDescription == null) productDescription = "";
        if (productCategory == null) productCategory = "";
        if (productLocation == null) productLocation = "";
        if (sellerName == null) sellerName = "";
        if (sellerUsername == null) sellerUsername = "";
        if (mainImage == null) mainImage = "";
        if (productStatus == null) productStatus = "";

        String imageSql =
            "SELECT image_path " +
            "FROM product_image " +
            "WHERE product_id = ? " +
            "ORDER BY sort_order ASC, id ASC";

        psImage = conn.prepareStatement(imageSql);
        psImage.setInt(1, productId);
        rsImage = psImage.executeQuery();

        while (rsImage.next()) {
            String path = rsImage.getString("image_path");
            if (path != null && !path.trim().isEmpty()) {
                imageList.add(path);
            }
        }

        if (imageList.isEmpty()) {
            if (!mainImage.isEmpty()) {
                imageList.add(mainImage);
            } else {
                imageList.add("/assets/img/default.jpg");
            }
        }

        String otherSql =
        	    "SELECT id, name, price, image, status " +
        	    "FROM product " +
        	    "WHERE seller_id = ? AND id <> ? AND (status IS NULL OR status <> 'hidden') " +
        	    "ORDER BY id DESC " +
        	    "LIMIT 4";

        psOther = conn.prepareStatement(otherSql);
        psOther.setInt(1, sellerId);
        psOther.setInt(2, productId);
        rsOther = psOther.executeQuery();

        while (rsOther.next()) {
            OtherProduct op = new OtherProduct();
            op.id = rsOther.getInt("id");
            op.name = rsOther.getString("name");
            op.price = rsOther.getInt("price");
            op.image = rsOther.getString("image");
            op.status = rsOther.getString("status");

            if (op.image == null || op.image.trim().isEmpty()) {
                op.image = "/assets/img/default.jpg";
            }

            otherProducts.add(op);
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('상품 정보를 불러오는 중 오류가 발생했습니다.'); history.back();</script>");
        return;
    } finally {
        try { if (rsOther != null) rsOther.close(); } catch (Exception ignore) {}
        try { if (rsImage != null) rsImage.close(); } catch (Exception ignore) {}
        try { if (rsProduct != null) rsProduct.close(); } catch (Exception ignore) {}
        try { if (psOther != null) psOther.close(); } catch (Exception ignore) {}
        try { if (psImage != null) psImage.close(); } catch (Exception ignore) {}
        try { if (psProduct != null) psProduct.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }

    boolean isSoldOut = "soldout".equals(productStatus);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= productName %> | 캠프 메이트</title>

    <jsp:include page="/include/head.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/product.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="product-detail-wrap">
    <div class="product-main">
        <div class="product-left">
            <div class="product-gallery-card">
                <div class="product-slider-wrap">
                    <div class="product-slider-main" id="productSlider">
                        <% for (int i = 0; i < imageList.size(); i++) {
                            String imgPath = imageList.get(i);
                            String finalPath = imgPath.startsWith("/") ? (ctx + imgPath) : (ctx + "/assets/img/" + imgPath);
                        %>
                            <div class="product-slide <%= (i == 0) ? "active" : "" %>">
                                <img src="<%= finalPath %>" alt="상품 이미지 <%= i + 1 %>"
                                     onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                            </div>
                        <% } %>

                        <% if (imageList.size() > 1) { %>
                            <button type="button" class="product-slider-btn prev" id="prevBtn">‹</button>
                            <button type="button" class="product-slider-btn next" id="nextBtn">›</button>
                        <% } %>
                    </div>

                    <% if (imageList.size() > 1) { %>
                        <div class="product-thumb-row" id="thumbRow">
                            <% for (int i = 0; i < imageList.size(); i++) {
                                String imgPath = imageList.get(i);
                                String finalPath = imgPath.startsWith("/") ? (ctx + imgPath) : (ctx + "/assets/img/" + imgPath);
                            %>
                                <button type="button"
                                        class="product-thumb-btn <%= (i == 0) ? "active" : "" %>"
                                        data-index="<%= i %>">
                                    <img src="<%= finalPath %>" alt="썸네일 <%= i + 1 %>"
                                         onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                                </button>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="product-right-card">
            <div class="product-info-top">
                <h1><%= productName %></h1>
            </div>

            <div class="product-meta-list">
                <% if (!productCategory.isEmpty()) { %>
                    <span class="product-meta-chip">카테고리 · <%= productCategory %></span>
                <% } %>
                <% if (!productLocation.isEmpty()) { %>
                    <span class="product-meta-chip">거래지역 · <%= productLocation %></span>
                <% } %>
                <% if (isSoldOut) { %>
                    <span class="product-meta-chip soldout-chip">판매완료</span>
                <% } %>
            </div>

            <div class="price-box"><%= String.format("%,d", productPrice) %>원</div>

            <div class="product-summary-desc">
                <%= productDescription.isEmpty() ? "등록된 상품 설명이 없습니다." : productDescription %>
            </div>

            <div class="product-action-group">
                <button type="button" class="btn-soft" onclick="history.back()">목록으로</button>

                <% if (isSoldOut) { %>
                    <button type="button" class="btn-point disabled" disabled>거래불가</button>
                <% } else { %>
                    <button type="button" class="btn-point">채팅하기</button>
                <% } %>
            </div>
        </div>
    </div>

    <div class="product-section-wrap">
        <div class="detail-section-card">
            <h3 class="detail-card-title">상품 설명</h3>
            <div class="product-detail-text">
                <%= productDescription.isEmpty() ? "등록된 상품 설명이 없습니다." : productDescription %>
            </div>
        </div>
    </div>

    <div class="product-section-wrap">
        <div class="detail-section-card">
            <h3 class="detail-card-title">판매자 정보</h3>

            <div class="seller-info-row">
                <span class="seller-label">판매자 이름</span>
                <span class="seller-value"><%= sellerName.isEmpty() ? "-" : sellerName %></span>
            </div>

            <div class="seller-info-row">
                <span class="seller-label">판매자 아이디</span>
                <span class="seller-value"><%= sellerUsername.isEmpty() ? "-" : sellerUsername %></span>
            </div>

            <div class="seller-info-row">
                <span class="seller-label">거래 지역</span>
                <span class="seller-value"><%= productLocation.isEmpty() ? "-" : productLocation %></span>
            </div>
        </div>
    </div>

    <div class="product-section-wrap">
        <div class="detail-section-card">
            <h3 class="detail-card-title">판매자의 다른 상품</h3>

            <div class="product-list-grid">
                <%
                    if (otherProducts != null && !otherProducts.isEmpty()) {
                        for (OtherProduct op : otherProducts) {
                            String otherImg = op.image;
                            String otherImgPath = otherImg.startsWith("/") ? (ctx + otherImg) : (ctx + "/assets/img/" + otherImg);
                %>
                    <%
    boolean otherSoldOut = "soldout".equals(op.status);
%>
<a href="<%=ctx%>/productDetail.jsp?id=<%=op.id%>" class="seller-product-link">
    <div class="product-card <%= otherSoldOut ? "soldout-other-card" : "" %>">
        <div class="seller-other-thumb-wrap">
            <img src="<%=otherImgPath%>" alt="<%=op.name%>"
                 onerror="this.src='<%=ctx%>/assets/img/default.jpg'">

            <% if (otherSoldOut) { %>
                <span class="seller-other-badge soldout">판매완료</span>
            <% } %>
        </div>

        <div class="product-card-body">
            <div class="product-title"><%=op.name%></div>
            <div class="product-price"><%=String.format("%,d", op.price)%>원</div>
        </div>
    </div>
</a>
                <%
                        }
                    } else {
                %>
                    <div class="common-empty-box product-other-empty">
                        판매자의 다른 상품이 없습니다.
                    </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/include/footer.jsp" />

<script>
    (function () {
        const slides = document.querySelectorAll(".product-slide");
        const thumbs = document.querySelectorAll(".product-thumb-btn");
        const prevBtn = document.getElementById("prevBtn");
        const nextBtn = document.getElementById("nextBtn");

        if (!slides.length) return;

        let currentIndex = 0;

        function showSlide(index) {
            if (index < 0) index = slides.length - 1;
            if (index >= slides.length) index = 0;

            slides.forEach((slide, i) => {
                slide.classList.toggle("active", i === index);
            });

            thumbs.forEach((thumb, i) => {
                thumb.classList.toggle("active", i === index);
            });

            currentIndex = index;
        }

        if (prevBtn) {
            prevBtn.addEventListener("click", function () {
                showSlide(currentIndex - 1);
            });
        }

        if (nextBtn) {
            nextBtn.addEventListener("click", function () {
                showSlide(currentIndex + 1);
            });
        }

        thumbs.forEach((thumb, i) => {
            thumb.addEventListener("click", function () {
                showSlide(i);
            });
        });
    })();
</script>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.AdminProductDAO" %>
<%@ page import="dto.Product" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    AdminProductDAO dao = new AdminProductDAO();
    List<Product> productList = dao.getAllProductsForAdmin();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 상품 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>
<body class="admin-body">

    <jsp:include page="/admin/include/adminHeader.jsp" />

    <div class="admin-layout">
        <jsp:include page="/admin/include/adminSidebar.jsp" />

        <main class="admin-content">
            <div class="admin-page-head">
                <div>
                    <h1 class="admin-page-title">상품 관리</h1>
                    <p class="admin-page-desc">중고거래 게시글 상태를 관리합니다.</p>
                </div>
            </div>

            <% if (success != null) { %>
                <div class="admin-alert success"><%= success %></div>
            <% } %>

            <% if (error != null) { %>
                <div class="admin-alert error"><%= error %></div>
            <% } %>

            <section class="admin-table-wrap product-manage-wrap">
                <div class="admin-table-top">
                    <div class="admin-table-title">상품 목록</div>
                    <div class="admin-table-count">총 <%= productList != null ? productList.size() : 0 %>개</div>
                </div>

                <div class="admin-table-scroll">
                    <table class="admin-table product-manage-table">
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>이미지</th>
                                <th>상품명</th>
                                <th>카테고리</th>
                                <th>판매자ID</th>
                                <th>가격</th>
                                <th>현재 상태</th>
                                <th>상태 변경</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            if (productList == null || productList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="9" class="admin-empty-inline">등록된 상품이 없습니다.</td>
                            </tr>
                        <%
                            } else {
                                for (Product p : productList) {
                                    String img = p.getImage();
                                    String imagePath;
                                    if (img == null || img.trim().isEmpty()) {
                                        imagePath = ctx + "/assets/img/default.jpg";
                                    } else if (img.startsWith("http://") || img.startsWith("https://")) {
                                        imagePath = img;
                                    } else {
                                        imagePath = ctx + "/assets/img/" + img;
                                    }

                                    String status = p.getStatus();
                                    if (status == null || status.trim().isEmpty()) {
                                        status = "selling";
                                    }

                                    String statusText;
                                    if ("selling".equals(status)) {
                                        statusText = "판매중";
                                    } else if ("hidden".equals(status)) {
                                        statusText = "숨김";
                                    } else if ("soldout".equals(status)) {
                                        statusText = "판매완료";
                                    } else {
                                        statusText = status;
                                    }
                        %>
                            <tr>
                                <td><%= p.getId() %></td>
                                <td>
                                    <img src="<%= imagePath %>" alt="상품 이미지" class="admin-thumb">
                                </td>
                                <td class="admin-title-cell">
                                    <div class="admin-title-main"><%= p.getName() %></div>
                                    <div class="admin-title-sub"><%= p.getLocation() != null ? p.getLocation() : "-" %></div>
                                </td>
                                <td><%= p.getCategory() != null ? p.getCategory() : "-" %></td>
                                <td><%= p.getSellerId() %></td>
                                <td><%= String.format("%,d원", p.getPrice()) %></td>
                                <td>
                                    <span class="admin-status-badge
                                        <%= "selling".equals(status) ? "is-selling" : "" %>
                                        <%= "hidden".equals(status) ? "is-hidden" : "" %>
                                        <%= "soldout".equals(status) ? "is-soldout" : "" %>">
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td colspan="2">
                                    <form action="<%=ctx%>/admin/productStatusUpdate.jsp" method="post" class="admin-inline-form product-manage-form">
                                        <input type="hidden" name="productId" value="<%= p.getId() %>">

                                        <select name="status" class="admin-mini-select product-manage-select">
                                            <option value="selling" <%= "selling".equals(status) ? "selected" : "" %>>판매중</option>
                                            <option value="hidden" <%= "hidden".equals(status) ? "selected" : "" %>>숨김</option>
                                            <option value="soldout" <%= "soldout".equals(status) ? "selected" : "" %>>판매완료</option>
                                        </select>

                                        <button type="submit" class="admin-save-btn">저장</button>
                                    </form>
                                </td>
                            </tr>
                        <%
                                }
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

</body>
</html>

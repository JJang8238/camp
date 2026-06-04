<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ProductDAO, dto.Product, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;

    // 내 상품 목록
    ProductDAO productDAO = new ProductDAO();
    List<Product> myProducts = productDAO.getProductsBySeller(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 관리 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <style>
        body { background: #f5f4f0; }

        .page-wrapper {
            max-width: 960px;
            margin: 48px auto 80px;
            padding: 0 24px;
        }

        .page-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
        }
        .page-top-left { display: flex; align-items: center; gap: 12px; }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            border: 1.5px solid #dee2e6;
            border-radius: 20px;
            font-size: 13px;
            color: #555;
            text-decoration: none;
            background: white;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-back:hover { border-color: #2d5a27; color: #2d5a27; text-decoration: none; }
        .page-title { font-size: 22px; font-weight: 700; color: #1a1a1a; margin: 0; }

        .btn-register {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #2d5a27;
            color: white;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-register:hover { background: #1e3d1b; color: white; text-decoration: none; }

        /* 요약 */
        .summary-bar {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 10px;
            padding: 12px 20px;
            margin-bottom: 18px;
            font-size: 13px;
            color: #555;
            display: flex;
            gap: 24px;
        }
        .summary-bar strong { color: #2d5a27; }

        /* 상품 카드 */
        .product-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 18px 22px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 18px;
            transition: box-shadow 0.2s, border-color 0.2s;
        }
        .product-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.07);
            border-color: #2d5a27;
        }

        .product-thumb {
            width: 80px; height: 80px;
            border-radius: 10px; object-fit: cover;
            flex-shrink: 0; background: #f1f3f5;
        }
        .product-thumb-placeholder {
            width: 80px; height: 80px;
            border-radius: 10px; background: #f0f7ee;
            display: flex; align-items: center;
            justify-content: center; font-size: 28px; flex-shrink: 0;
        }

        .product-info { flex: 1; min-width: 0; }

        .product-name {
            font-size: 15px; font-weight: 700;
            color: #1a1a1a; margin-bottom: 6px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .product-meta {
            display: flex; flex-wrap: wrap;
            gap: 12px; font-size: 12px; color: #888;
        }

        .product-price {
            font-size: 16px; font-weight: 700;
            color: #2d5a27; white-space: nowrap;
        }

        /* 상태 배지 */
        .badge {
            display: inline-block;
            padding: 3px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 600;
        }
        .badge-selling  { background: #e8f5e9; color: #2d5a27; }
        .badge-sold     { background: #f1f3f5; color: #777; }
        .badge-reserved { background: #fff8e1; color: #f57c00; }
        .badge-hidden   { background: #fdecea; color: #c0392b; }

        .product-actions {
            display: flex; flex-direction: column;
            gap: 8px; flex-shrink: 0;
        }

        .btn-edit {
            padding: 7px 18px;
            border: 1.5px solid #2d5a27; border-radius: 8px;
            font-size: 12px; font-weight: 600;
            color: #2d5a27; background: white;
            text-decoration: none; text-align: center;
            transition: background 0.2s, color 0.2s;
        }
        .btn-edit:hover { background: #2d5a27; color: white; text-decoration: none; }

        .btn-view {
            padding: 7px 18px;
            border: 1.5px solid #888; border-radius: 8px;
            font-size: 12px; font-weight: 600;
            color: #555; background: white;
            text-decoration: none; text-align: center;
            transition: background 0.2s, color 0.2s;
        }
        .btn-view:hover { background: #555; color: white; text-decoration: none; }

        /* 삭제 버튼 */
        .btn-delete {
            width: 100%;
            padding: 7px 18px;
            border: 1.5px solid #c0392b; border-radius: 8px;
            font-size: 12px; font-weight: 600;
            color: #c0392b; background: white;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-delete:hover { background: #c0392b; color: white; }

        /* 삭제 폼 기본 마진 제거 */
        .form-delete { margin: 0; padding: 0; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
        }
        .empty-icon { font-size: 52px; margin-bottom: 16px; }
        .empty-box p { font-size: 15px; color: #aaa; margin: 0 0 20px; }

        @media (max-width: 600px) {
            .product-card { flex-wrap: wrap; }
            .product-actions { flex-direction: row; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <div class="page-top-left">
            <a href="<%=ctx%>/owner/dashboard.jsp" class="btn-back">← 대시보드</a>
            <h2 class="page-title">📦 상품 관리</h2>
        </div>
        <a href="<%=ctx%>/productWrite.jsp" class="btn-register">+ 새 상품 등록</a>
    </div>

    <% if (!myProducts.isEmpty()) {
        long selling  = myProducts.stream().filter(p -> "SELLING".equalsIgnoreCase(p.getStatus())).count();
        long sold     = myProducts.stream().filter(p -> "SOLD".equalsIgnoreCase(p.getStatus())).count();
    %>
    <div class="summary-bar">
        <span>전체 <strong><%=myProducts.size()%></strong>개</span>
        <span>판매중 <strong><%=selling%></strong>개</span>
        <span>판매완료 <strong><%=sold%></strong>개</span>
    </div>
    <% } %>

    <% if (myProducts == null || myProducts.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">📦</div>
        <p>등록한 상품이 없습니다.</p>
        <a href="<%=ctx%>/productWrite.jsp" class="btn-register">첫 상품 등록하기</a>
    </div>

    <% } else {
        for (Product p : myProducts) {
            String imgFile = p.getImage();
            String imgPath = null;
            if (imgFile != null && !imgFile.trim().isEmpty()) {
                imgFile = imgFile.trim();
                if (imgFile.startsWith("http://") || imgFile.startsWith("https://")) {
                    imgPath = imgFile;
                } else if (imgFile.startsWith("/")) {
                    imgPath = ctx + imgFile;
                } else {
                    imgPath = ctx + "/assets/img/" + imgFile;
                }
            }

            String status = p.getStatus() != null ? p.getStatus().toUpperCase() : "";
            String badgeClass, badgeLabel;
            switch (status) {
                case "SELLING":  badgeClass = "badge-selling";  badgeLabel = "판매중";   break;
                case "SOLD":     badgeClass = "badge-sold";     badgeLabel = "판매완료"; break;
                case "RESERVED": badgeClass = "badge-reserved"; badgeLabel = "예약중";   break;
                case "HIDDEN":   badgeClass = "badge-hidden";   badgeLabel = "숨김";     break;
                default:         badgeClass = "badge-selling";  badgeLabel = status;
            }
    %>
    <div class="product-card">

        <% if (imgPath != null) { %>
        <img src="<%=imgPath%>" class="product-thumb"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
             alt="상품이미지">
        <div class="product-thumb-placeholder" style="display:none">🛒</div>
        <% } else { %>
        <div class="product-thumb-placeholder">🛒</div>
        <% } %>

        <div class="product-info">
            <div class="product-name"><%=p.getName()%></div>
            <div class="product-meta">
                <% if (p.getCategory() != null) { %><span>🏷️ <%=p.getCategory()%></span><% } %>
                <% if (p.getLocation() != null) { %><span>📍 <%=p.getLocation()%></span><% } %>
                <% if (p.getCreatedAt() != null && p.getCreatedAt().length() >= 10) { %>
                    <span>🕐 <%=p.getCreatedAt().substring(0, 10)%></span>
                <% } %>
                <span class="badge <%=badgeClass%>"><%=badgeLabel%></span>
            </div>
        </div>

        <div style="text-align:right; flex-shrink:0;">
            <div class="product-price" style="margin-bottom:10px;">
                <%=String.format("%,d", p.getPrice())%>원
            </div>
            <div class="product-actions">
                <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="btn-view">상세보기</a>
                <a href="<%=ctx%>/productEdit.jsp?id=<%=p.getId()%>" class="btn-edit">✏️ 수정</a>
                <form method="post" action="<%=ctx%>/product/delete" class="form-delete"
                      onsubmit="return confirm('정말 삭제하시겠습니까?\n삭제된 상품은 목록에서 숨겨집니다.');">
                    <input type="hidden" name="productId" value="<%=p.getId()%>">
                    <button type="submit" class="btn-delete">🗑 삭제</button>
                </form>
            </div>
        </div>

    </div>
    <%
        }
    } %>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.TradeHistoryDAO, dto.Product, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;

    List<Product> sellList = TradeHistoryDAO.getSellList(userId);
    List<Product> buyList  = TradeHistoryDAO.getBuyList(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>용품 거래 내역 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .page-wrapper {
            max-width: 860px;
            margin: 60px auto;
            padding: 0 20px 80px;
        }

        /* 상단 */
        .page-top {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 28px;
        }
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

        /* 탭 */
        .tab-bar {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 0;
        }
        .tab-btn {
            padding: 10px 24px;
            border: none;
            background: none;
            font-size: 15px;
            font-weight: 600;
            color: #aaa;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
            transition: color 0.2s, border-color 0.2s;
        }
        .tab-btn.active { color: #2d5a27; border-bottom-color: #2d5a27; }
        .tab-btn:hover  { color: #2d5a27; }

        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

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
            text-decoration: none;
            color: inherit;
            transition: box-shadow 0.2s, border-color 0.2s;
        }
        .product-card:hover {
            box-shadow: 0 6px 20px rgba(0,0,0,0.07);
            border-color: #2d5a27;
            text-decoration: none;
            color: inherit;
        }

        .product-thumb {
            width: 72px;
            height: 72px;
            border-radius: 10px;
            object-fit: cover;
            background: #f1f3f5;
            flex-shrink: 0;
        }
        .product-thumb-placeholder {
            width: 72px;
            height: 72px;
            border-radius: 10px;
            background: #f1f3f5;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            flex-shrink: 0;
        }

        .product-info { flex: 1; }
        .product-name {
            font-size: 15px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 6px;
        }
        .product-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            font-size: 12px;
            color: #888;
        }

        .product-right { text-align: right; flex-shrink: 0; }
        .product-price {
            font-size: 17px;
            font-weight: 700;
            color: #2d5a27;
            margin-bottom: 6px;
        }

        /* 상태 배지 */
        .badge-status {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-selling  { background: #e8f5e9; color: #2d5a27; }
        .badge-sold     { background: #f1f3f5; color: #777; }
        .badge-reserved { background: #fff8e1; color: #f57c00; }
        .badge-hidden   { background: #fdecea; color: #c0392b; }
        .badge-bought   { background: #e3f2fd; color: #1565c0; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 60px 20px;
            color: #bbb;
        }
        .empty-box .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty-box p { font-size: 14px; margin: 0 0 18px; }
        .btn-go-market {
            display: inline-block;
            padding: 9px 22px;
            background: #2d5a27;
            color: white;
            border-radius: 24px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
        }
        .btn-go-market:hover { background: #1e3d1b; color: white; text-decoration: none; }

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

        @media (max-width: 560px) {
            .product-card { flex-wrap: wrap; }
            .product-right { text-align: left; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/user_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">🛒 용품 거래 내역</h2>
    </div>

    <!-- 탭 -->
    <div class="tab-bar">
        <button class="tab-btn active" onclick="switchTab('sell', this)">
            📦 판매 내역 (<%=sellList.size()%>)
        </button>
        <button class="tab-btn" onclick="switchTab('buy', this)">
            🛍️ 구매 내역 (<%=buyList.size()%>)
        </button>
    </div>

    <%-- ===================== 판매 탭 ===================== --%>
    <div id="tab-sell" class="tab-panel active">

        <% if (sellList.isEmpty()) { %>
        <div class="empty-box">
            <div class="empty-icon">📦</div>
            <p>아직 판매 등록한 용품이 없어요</p>
            <a href="<%=ctx%>/productList.jsp" class="btn-go-market">용품 마켓 보러가기</a>
        </div>
        <% } else { %>

        <div class="summary-bar">
            <span>전체 <strong><%=sellList.size()%></strong>건</span>
            <%
                long selling = sellList.stream().filter(p -> "SELLING".equalsIgnoreCase(p.getStatus()) || "selling".equalsIgnoreCase(p.getStatus())).count();
                long sold    = sellList.stream().filter(p -> "SOLD".equalsIgnoreCase(p.getStatus()) || "sold".equalsIgnoreCase(p.getStatus())).count();
            %>
            <span>판매중 <strong><%=selling%></strong>건</span>
            <span>판매완료 <strong><%=sold%></strong>건</span>
        </div>

        <%
            for (Product p : sellList) {
                String status = p.getStatus() != null ? p.getStatus().toUpperCase() : "";
                String badgeClass, badgeLabel;
                switch (status) {
                    case "SELLING": badgeClass = "badge-selling";  badgeLabel = "판매중";   break;
                    case "SOLD":    badgeClass = "badge-sold";     badgeLabel = "판매완료"; break;
                    case "RESERVED":badgeClass = "badge-reserved"; badgeLabel = "예약중";   break;
                    case "HIDDEN":  badgeClass = "badge-hidden";   badgeLabel = "숨김";     break;
                    default:        badgeClass = "badge-sold";     badgeLabel = status;
                }

                String imgPath;
                String imgFile = p.getImage();
                if (imgFile != null && !imgFile.trim().isEmpty()) {
                    imgPath = imgFile.startsWith("http") ? imgFile : ctx + "/assets/img/" + imgFile;
                } else {
                    imgPath = null;
                }
        %>
        <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="product-card">
            <% if (imgPath != null) { %>
            <img src="<%=imgPath%>" class="product-thumb"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                 alt="상품이미지">
            <div class="product-thumb-placeholder" style="display:none">🏕️</div>
            <% } else { %>
            <div class="product-thumb-placeholder">🏕️</div>
            <% } %>

            <div class="product-info">
                <div class="product-name"><%=p.getName()%></div>
                <div class="product-meta">
                    <% if (p.getCategory() != null) { %><span>🏷️ <%=p.getCategory()%></span><% } %>
                    <% if (p.getLocation() != null) { %><span>📍 <%=p.getLocation()%></span><% } %>
                    <% if (p.getCreatedAt() != null) { %><span>🕐 <%=p.getCreatedAt().substring(0, 10)%></span><% } %>
                </div>
            </div>

            <div class="product-right">
                <div class="product-price"><%=String.format("%,d", p.getPrice())%>원</div>
                <span class="badge-status <%=badgeClass%>"><%=badgeLabel%></span>
            </div>
        </a>
        <% } %>
        <% } %>
    </div>

    <%-- ===================== 구매 탭 ===================== --%>
    <div id="tab-buy" class="tab-panel">

        <% if (buyList.isEmpty()) { %>
        <div class="empty-box">
            <div class="empty-icon">🛍️</div>
            <p>아직 구매한 용품이 없어요</p>
            <a href="<%=ctx%>/productList.jsp" class="btn-go-market">용품 구경하러 가기</a>
        </div>
        <% } else { %>

        <div class="summary-bar">
            <span>전체 <strong><%=buyList.size()%></strong>건</span>
        </div>

        <%
            for (Product p : buyList) {
                String imgFile = p.getImage();
                String imgPath;
                if (imgFile != null && !imgFile.trim().isEmpty()) {
                    imgPath = imgFile.startsWith("http") ? imgFile : ctx + "/assets/img/" + imgFile;
                } else {
                    imgPath = null;
                }
        %>
        <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>" class="product-card">
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
                    <% if (p.getCreatedAt() != null) { %><span>🕐 <%=p.getCreatedAt().substring(0, 10)%></span><% } %>
                </div>
            </div>

            <div class="product-right">
                <div class="product-price"><%=String.format("%,d", p.getPrice())%>원</div>
                <span class="badge-status badge-bought">구매완료</span>
            </div>
        </a>
        <% } %>
        <% } %>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function switchTab(tab, btn) {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + tab).classList.add('active');
    btn.classList.add('active');
}
</script>
</body>
</html>

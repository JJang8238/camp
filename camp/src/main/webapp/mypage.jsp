<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ChatDAO" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dto.ChatRoom" %>
<%@ page import="dto.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");

    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;

    ChatDAO chatDAO = new ChatDAO();
    List<ChatRoom> chatRooms = chatDAO.getMyChatRooms(userId);

    // 내가 판매 중인 상품 목록
    ProductDAO productDAO = new ProductDAO();
    List<Product> myProducts = productDAO.getProductsBySeller(userId);

    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 거래 보기 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">

    <style>
        body { background: #f8f9fa; }

        .trade-page {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 20px 80px;
        }

        .trade-page-title {
            font-size: 28px;
            font-weight: 800;
            color: #1b4d3e;
            margin-bottom: 6px;
        }

        .trade-page-sub {
            font-size: 15px;
            color: #888;
            margin-bottom: 32px;
        }

        /* 탭 */
        .trade-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            border-bottom: 2px solid #eee;
            padding-bottom: 0;
        }

        .trade-tab-btn {
            padding: 10px 22px;
            border: none;
            background: none;
            font-size: 15px;
            font-weight: 700;
            color: #aaa;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
            transition: 0.15s;
        }

        .trade-tab-btn.active {
            color: #1b4d3e;
            border-bottom: 3px solid #1b4d3e;
        }

        .trade-tab-content { display: none; }
        .trade-tab-content.active { display: block; }

        /* 채팅 목록 */
        .trade-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.07);
            overflow: hidden;
        }

        .trade-room-link {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 18px 22px;
            border-bottom: 1px solid #f0f0f0;
            text-decoration: none;
            color: inherit;
            transition: background 0.15s;
        }

        .trade-room-link:last-child { border-bottom: none; }

        .trade-room-link:hover {
            background: #f8faf8;
            color: inherit;
            text-decoration: none;
        }

        .trade-room-img {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            object-fit: cover;
            background: #eee;
            flex-shrink: 0;
        }

        .trade-room-info { flex: 1; min-width: 0; }

        .trade-room-name {
            font-size: 15px;
            font-weight: 700;
            color: #222;
            margin-bottom: 3px;
        }

        .trade-room-meta {
            font-size: 13px;
            color: #999;
            margin-bottom: 3px;
        }

        .trade-room-last {
            font-size: 13px;
            color: #666;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .trade-room-right {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 5px;
            flex-shrink: 0;
        }

        .trade-room-time {
            font-size: 12px;
            color: #bbb;
        }

        .trade-unread-badge {
            min-width: 22px;
            height: 22px;
            border-radius: 999px;
            background: #ff6b35;
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 6px;
        }

        /* 내 상품 목록 */
        .my-product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 16px;
        }

        .my-product-card {
            background: #fff;
            border-radius: 14px;
            border: 1.5px solid #eee;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
            transition: box-shadow 0.2s, transform 0.2s;
            display: block;
        }

        .my-product-card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            transform: translateY(-2px);
            color: inherit;
            text-decoration: none;
        }

        .my-product-img {
            width: 100%;
            height: 140px;
            object-fit: cover;
            background: #eee;
            display: block;
        }

        .my-product-body {
            padding: 12px 14px;
        }

        .my-product-name {
            font-size: 14px;
            font-weight: 700;
            color: #222;
            margin-bottom: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .my-product-price {
            font-size: 15px;
            font-weight: 800;
            color: #1b4d3e;
            margin-bottom: 6px;
        }

        .my-product-status {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
        }

        .status-selling { background: #e7f1ec; color: #1b4d3e; }
        .status-soldout { background: #f1f1f1; color: #999; }
        .status-hidden  { background: #fff3cd; color: #9a6700; }

        .my-product-chat-link {
            display: block;
            text-align: center;
            padding: 8px;
            background: #f8faf8;
            border-top: 1px solid #eee;
            font-size: 13px;
            font-weight: 700;
            color: #1b4d3e;
            text-decoration: none;
        }

        .my-product-chat-link:hover {
            background: #e7f1ec;
            color: #1b4d3e;
            text-decoration: none;
        }

        .trade-empty {
            padding: 60px 20px;
            text-align: center;
            color: #999;
            font-size: 15px;
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.07);
        }

        .trade-empty strong {
            display: block;
            font-size: 17px;
            color: #555;
            margin-bottom: 8px;
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<main class="trade-page">

    <h1 class="trade-page-title">내 거래 보기</h1>
    <p class="trade-page-sub">진행 중인 채팅과 내가 등록한 상품을 확인하세요.</p>

    <div class="trade-tabs">
        <button class="trade-tab-btn active" onclick="switchTab('chat', this)">💬 거래 채팅</button>
        <button class="trade-tab-btn" onclick="switchTab('products', this)">📦 내 상품</button>
    </div>

    <%-- 탭 1: 거래 채팅 --%>
    <div class="trade-tab-content active" id="tab-chat">
        <%
            if (chatRooms == null || chatRooms.isEmpty()) {
        %>
            <div class="trade-empty">
                <strong>진행 중인 채팅이 없습니다.</strong>
                상품 상세 페이지에서 채팅하기를 눌러보세요.
            </div>
        <%
            } else {
        %>
        <div class="trade-card">
            <%
                for (ChatRoom room : chatRooms) {
                    String img = room.getProductImage();
                    if (img == null || img.trim().isEmpty()) {
                        img = ctx + "/assets/img/default.jpg";
                    } else if (img.startsWith("http://") || img.startsWith("https://")) {
                        // 그대로
                    } else if (img.startsWith("/")) {
                        img = ctx + img;
                    } else {
                        img = ctx + "/assets/img/products/" + img;
                    }

                    String opponentName = (userId == room.getSellerId())
                        ? room.getBuyerName()
                        : room.getSellerName();

                    String myRole = (userId == room.getSellerId()) ? "판매자" : "구매자";

                    String lastMsg = room.getLastMessage();
                    if (lastMsg == null || lastMsg.trim().isEmpty()) {
                        lastMsg = "아직 메시지가 없습니다.";
                    }

                    String timeStr = "";
                    if (room.getLastMessageAt() != null) {
                        timeStr = room.getLastMessageAt().toString().substring(0, 16);
                    } else if (room.getCreatedAt() != null) {
                        timeStr = room.getCreatedAt().toString().substring(0, 16);
                    }
            %>
            <a href="<%=ctx%>/chat/room?roomId=<%=room.getId()%>" class="trade-room-link">
                <img src="<%=img%>" class="trade-room-img" alt="상품 이미지"
                     onerror="this.src='<%=ctx%>/assets/img/default.jpg'">

                <div class="trade-room-info">
                    <div class="trade-room-name"><%=room.getProductName()%></div>
                    <div class="trade-room-meta">
                        <%=myRole%> · 상대: <%=opponentName%> · <%=df.format(room.getProductPrice())%>원
                    </div>
                    <div class="trade-room-last"><%=lastMsg%></div>
                </div>

                <div class="trade-room-right">
                    <span class="trade-room-time"><%=timeStr%></span>
                    <% if (room.getUnreadCount() > 0) { %>
                        <span class="trade-unread-badge"><%=room.getUnreadCount()%></span>
                    <% } %>
                </div>
            </a>
            <%
                }
            %>
        </div>
        <%
            }
        %>
    </div>

    <%-- 탭 2: 내 상품 --%>
    <div class="trade-tab-content" id="tab-products">
        <%
            if (myProducts == null || myProducts.isEmpty()) {
        %>
            <div class="trade-empty">
                <strong>등록한 상품이 없습니다.</strong>
                <a href="<%=ctx%>/productWrite.jsp" style="color:#1b4d3e; font-weight:700;">상품 등록하러 가기 →</a>
            </div>
        <%
            } else {
        %>
        <div class="my-product-grid">
            <%
                for (Product p : myProducts) {
                    String pImg = p.getImage();
                    String pImgPath;
                    if (pImg == null || pImg.trim().isEmpty()) {
                        pImgPath = ctx + "/assets/img/default.jpg";
                    } else if (pImg.startsWith("http://") || pImg.startsWith("https://")) {
                        pImgPath = pImg;
                    } else if (pImg.startsWith("/")) {
                        pImgPath = ctx + pImg;
                    } else {
                        pImgPath = ctx + "/assets/img/products/" + pImg;
                    }

                    String pStatus = p.getStatus();
                    if (pStatus == null) pStatus = "selling";

                    String statusLabel = "selling".equals(pStatus) ? "판매중"
                                       : "soldout".equals(pStatus) ? "판매완료"
                                       : "숨김";
                    String statusClass = "selling".equals(pStatus) ? "status-selling"
                                       : "soldout".equals(pStatus) ? "status-soldout"
                                       : "status-hidden";
            %>
            <div class="my-product-card">
                <a href="<%=ctx%>/productDetail.jsp?id=<%=p.getId()%>">
                    <img src="<%=pImgPath%>" class="my-product-img" alt="<%=p.getName()%>"
                         onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                    <div class="my-product-body">
                        <div class="my-product-name"><%=p.getName()%></div>
                        <div class="my-product-price"><%=df.format(p.getPrice())%>원</div>
                        <span class="my-product-status <%=statusClass%>"><%=statusLabel%></span>
                    </div>
                </a>
                <a href="<%=ctx%>/chat/productRooms?productId=<%=p.getId()%>" class="my-product-chat-link">
                    💬 문의 채팅 보기
                </a>
            </div>
            <%
                }
            %>
        </div>
        <%
            }
        %>
    </div>

</main>

<jsp:include page="/include/footer.jsp" />

<script>
function switchTab(tabName, btn) {
    document.querySelectorAll(".trade-tab-content").forEach(el => el.classList.remove("active"));
    document.querySelectorAll(".trade-tab-btn").forEach(el => el.classList.remove("active"));
    document.getElementById("tab-" + tabName).classList.add("active");
    btn.classList.add("active");
}
</script>

</body>
</html>

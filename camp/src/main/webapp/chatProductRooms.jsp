<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dto.ChatRoom" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    List<ChatRoom> chatRooms = (List<ChatRoom>) request.getAttribute("chatRooms");
    String productName = (String) request.getAttribute("productName");
    Integer productId  = (Integer) request.getAttribute("productId");

    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 문의 채팅 | Camp Mate</title>

    <jsp:include page="/include/head.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">

    <style>
        body { background: #f8f9fa; }

        .product-rooms-page {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 20px 80px;
        }

        .product-rooms-back {
            display: inline-block;
            margin-bottom: 18px;
            color: var(--main-green, #1b4d3e);
            font-weight: 700;
            text-decoration: none;
        }

        .product-rooms-back:hover {
            text-decoration: underline;
            color: var(--main-green, #1b4d3e);
        }

        .product-rooms-title {
            font-size: 26px;
            font-weight: 800;
            color: var(--main-green, #1b4d3e);
            margin-bottom: 6px;
        }

        .product-rooms-sub {
            font-size: 15px;
            color: #777;
            margin-bottom: 24px;
        }

        .product-rooms-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: var(--card-shadow, 0 6px 20px rgba(0,0,0,0.08));
            overflow: hidden;
        }

        .product-rooms-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 18px 24px;
            border-bottom: 1px solid #eee;
            background: #fafafa;
        }

        .product-rooms-header-title {
            font-size: 16px;
            font-weight: 700;
            color: #333;
        }

        .product-rooms-count {
            font-size: 14px;
            color: #777;
        }

        .product-rooms-count strong {
            color: var(--main-green, #1b4d3e);
        }

        .room-link {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 18px 24px;
            border-bottom: 1px solid #f0f0f0;
            text-decoration: none;
            color: inherit;
            transition: background 0.15s;
        }

        .room-link:last-child { border-bottom: none; }

        .room-link:hover {
            background: #f8faf8;
            color: inherit;
            text-decoration: none;
        }

        .room-avatar {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            background: var(--main-green, #1b4d3e);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 800;
            flex-shrink: 0;
        }

        .room-info { flex: 1; min-width: 0; }

        .room-buyer-name {
            font-size: 16px;
            font-weight: 700;
            color: #222;
            margin-bottom: 4px;
        }

        .room-last-msg {
            font-size: 13px;
            color: #888;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .room-right {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 6px;
            flex-shrink: 0;
        }

        .room-time {
            font-size: 12px;
            color: #bbb;
        }

        .room-unread {
            min-width: 22px;
            height: 22px;
            border-radius: 999px;
            background: var(--point-orange, #ff6b35);
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 6px;
        }

        .product-rooms-empty {
            padding: 70px 20px;
            text-align: center;
            color: #999;
            font-size: 15px;
            line-height: 1.8;
        }

        .product-rooms-empty strong {
            display: block;
            font-size: 17px;
            color: #555;
            margin-bottom: 8px;
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<main class="product-rooms-page">

    <a href="<%=ctx%>/productDetail.jsp?id=<%=productId%>" class="product-rooms-back">← 상품으로 돌아가기</a>

    <h1 class="product-rooms-title">상품 문의 채팅</h1>
    <p class="product-rooms-sub">
        <strong><%=productName != null ? productName : ""%></strong> 에 들어온 구매자 문의 목록입니다.
    </p>

    <div class="product-rooms-card">

        <div class="product-rooms-header">
            <span class="product-rooms-header-title">구매 문의 목록</span>
            <span class="product-rooms-count">
                총 <strong><%=chatRooms != null ? chatRooms.size() : 0%></strong>건
            </span>
        </div>

        <%
            if (chatRooms == null || chatRooms.isEmpty()) {
        %>
            <div class="product-rooms-empty">
                <strong>아직 문의가 없습니다.</strong>
                구매자가 채팅하기 버튼을 누르면 여기에 표시됩니다.
            </div>
        <%
            } else {
                for (ChatRoom room : chatRooms) {

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

                    String firstChar = (room.getBuyerName() != null && !room.getBuyerName().isEmpty())
                        ? String.valueOf(room.getBuyerName().charAt(0))
                        : "?";
        %>
            <a href="<%=ctx%>/chat/room?roomId=<%=room.getId()%>" class="room-link">

                <div class="room-avatar"><%=firstChar%></div>

                <div class="room-info">
                    <div class="room-buyer-name"><%=room.getBuyerName()%></div>
                    <div class="room-last-msg"><%=lastMsg%></div>
                </div>

                <div class="room-right">
                    <span class="room-time"><%=timeStr%></span>
                    <% if (room.getUnreadCount() > 0) { %>
                        <span class="room-unread"><%=room.getUnreadCount()%></span>
                    <% } %>
                </div>

            </a>
        <%
                }
            }
        %>

    </div>

</main>

<jsp:include page="/include/footer.jsp" />

</body>
</html>

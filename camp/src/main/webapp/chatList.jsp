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
    DecimalFormat df = new DecimalFormat("#,###");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>거래 채팅 | Camp Mate</title>

    <jsp:include page="/include/head.jsp" />

    <style>
        body {
            background: #f8f9fa;
        }

        .chat-list-page {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 20px 80px;
        }

        .chat-list-title {
            font-size: 28px;
            font-weight: 800;
            color: var(--main-green, #1b4d3e);
            margin-bottom: 24px;
        }

        .chat-list-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: var(--card-shadow, 0 6px 20px rgba(0,0,0,0.08));
            overflow: hidden;
        }

        .chat-list-room-link {
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 20px;
            border-bottom: 1px solid #eee;
            text-decoration: none;
            color: inherit;
            transition: 0.2s;
        }

        .chat-list-room-link:hover {
            background: #f8faf8;
            color: inherit;
            text-decoration: none;
        }

        .chat-list-room-link:last-child {
            border-bottom: none;
        }

        .chat-list-product-img {
            width: 78px;
            height: 78px;
            border-radius: 16px;
            object-fit: cover;
            background: #f1f1f1;
            flex-shrink: 0;
        }

        .chat-list-info {
            flex: 1;
            min-width: 0;
        }

        .chat-list-product-name {
            font-size: 17px;
            font-weight: 700;
            color: #222;
            margin-bottom: 6px;
        }

        .chat-list-meta {
            font-size: 14px;
            color: #777;
            margin-bottom: 6px;
        }

        .chat-list-last-message {
            font-size: 14px;
            color: #555;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .chat-list-unread-badge {
            min-width: 24px;
            height: 24px;
            border-radius: 999px;
            background: var(--point-orange, #ff6b35);
            color: white;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
        }

        .chat-list-empty {
            padding: 60px 20px;
            text-align: center;
            color: #777;
            font-size: 15px;
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<main class="chat-list-page">
    <h1 class="chat-list-title">거래 채팅</h1>

    <div class="chat-list-card">
        <%
            if (chatRooms == null || chatRooms.isEmpty()) {
        %>
            <div class="chat-list-empty">
                아직 거래 채팅이 없습니다.
            </div>
        <%
            } else {
                for (ChatRoom room : chatRooms) {
                    String img = room.getProductImage();

                    if (img == null || img.trim().isEmpty()) {
                        img = ctx + "/assets/img/default.jpg";
                    } else if (img.startsWith("http://") || img.startsWith("https://")) {
                        // 그대로 사용
                    } else if (img.startsWith(ctx + "/")) {
                        // 그대로 사용
                    } else if (img.startsWith("/")) {
                        img = ctx + img;
                    } else {
                        img = ctx + "/assets/img/products/" + img;
                    }

                    String opponentName = userId == room.getSellerId()
                            ? room.getBuyerName()
                            : room.getSellerName();

                    String lastMessage = room.getLastMessage();
                    if (lastMessage == null || lastMessage.trim().isEmpty()) {
                        lastMessage = "아직 메시지가 없습니다.";
                    }
        %>
            <a href="<%=ctx%>/chat/room?roomId=<%=room.getId()%>" class="chat-list-room-link">
                <img src="<%=img%>" class="chat-list-product-img" alt="상품 이미지"
                     onerror="this.src='<%=ctx%>/assets/img/default.jpg'">

                <div class="chat-list-info">
                    <div class="chat-list-product-name"><%=room.getProductName()%></div>
                    <div class="chat-list-meta">
                        상대: <%=opponentName%> · <%=df.format(room.getProductPrice())%>원
                    </div>
                    <div class="chat-list-last-message"><%=lastMessage%></div>
                </div>

                <% if (room.getUnreadCount() > 0) { %>
                    <span class="chat-list-unread-badge"><%=room.getUnreadCount()%></span>
                <% } %>
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
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dto.ChatRoom" %>
<%@ page import="dto.ChatMessage" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    ChatRoom room = (ChatRoom) request.getAttribute("room");
    List<ChatMessage> messages = (List<ChatMessage>) request.getAttribute("messages");

    if (room == null) {
        response.sendRedirect(ctx + "/chat/list");
        return;
    }

    DecimalFormat df = new DecimalFormat("#,###");

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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>채팅방 | Camp Mate</title>

    <jsp:include page="/include/head.jsp" />

    <style>
        body {
            background: #f8f9fa;
        }

        .chat-room-page {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px 80px;
        }

        .chat-room-top-actions {
            margin-bottom: 16px;
        }

        .chat-room-back-link {
            color: var(--main-green, #1b4d3e);
            text-decoration: none;
            font-weight: 700;
        }

        .chat-room-back-link:hover {
            color: var(--main-green, #1b4d3e);
            text-decoration: underline;
        }

        .chat-room-card {
            background: #fff;
            border-radius: 24px;
            box-shadow: var(--card-shadow, 0 6px 20px rgba(0,0,0,0.08));
            overflow: hidden;
        }

        .chat-room-product-header {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 20px;
            border-bottom: 1px solid #eee;
            background: #fafafa;
        }

        .chat-room-product-img {
            width: 72px;
            height: 72px;
            border-radius: 16px;
            object-fit: cover;
            background: #f1f1f1;
            flex-shrink: 0;
        }

        .chat-room-product-info {
            flex: 1;
            min-width: 0;
        }

        .chat-room-product-title {
            font-size: 18px;
            font-weight: 800;
            color: #222;
            margin-bottom: 5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .chat-room-product-meta {
            font-size: 14px;
            color: #666;
        }

        .chat-room-product-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 38px;
            padding: 8px 16px;
            border-radius: 999px;
            background: var(--main-green, #1b4d3e);
            color: white;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            white-space: nowrap;
        }

        .chat-room-product-link:hover {
            color: white;
            text-decoration: none;
            opacity: 0.9;
        }

        .chat-room-messages {
            height: 520px;
            overflow-y: auto;
            padding: 24px;
            background: #f6f7f5;
        }

        .chat-room-message-row {
            display: flex;
            margin-bottom: 14px;
        }

        .chat-room-message-row.mine {
            justify-content: flex-end;
        }

        .chat-room-message-row.other {
            justify-content: flex-start;
        }

        .chat-room-message-wrap {
            max-width: 70%;
        }

        .chat-room-sender {
            font-size: 12px;
            color: #777;
            margin-bottom: 4px;
        }

        .chat-room-message-bubble {
            padding: 12px 15px;
            border-radius: 18px;
            font-size: 15px;
            line-height: 1.5;
            word-break: break-word;
        }

        .chat-room-message-row.mine .chat-room-message-bubble {
            background: var(--main-green, #1b4d3e);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .chat-room-message-row.other .chat-room-message-bubble {
            background: white;
            color: #333;
            border-bottom-left-radius: 4px;
            border: 1px solid #eee;
        }

        .chat-room-message-time {
            font-size: 11px;
            color: #999;
            margin-top: 4px;
            text-align: right;
        }

        .chat-room-form {
            display: flex;
            gap: 10px;
            padding: 18px;
            border-top: 1px solid #eee;
            background: white;
        }

        .chat-room-form textarea {
            flex: 1;
            height: 48px;
            resize: none;
            border: 1px solid #ddd;
            border-radius: 14px;
            padding: 12px 14px;
            font-size: 14px;
            outline: none;
        }

        .chat-room-form textarea:focus {
            border-color: var(--main-green, #1b4d3e);
        }

        .chat-room-send-btn {
            border: none;
            border-radius: 14px;
            padding: 0 22px;
            background: var(--main-green, #1b4d3e);
            color: white;
            font-weight: 700;
            cursor: pointer;
            white-space: nowrap;
        }

        .chat-room-send-btn:hover {
            opacity: 0.9;
        }

        .chat-room-empty-message {
            text-align: center;
            color: #777;
            padding: 80px 0;
            font-size: 15px;
            line-height: 1.7;
        }

        @media (max-width: 600px) {
            .chat-room-product-header {
                align-items: flex-start;
            }

            .chat-room-product-link {
                padding: 8px 12px;
                font-size: 13px;
            }

            .chat-room-message-wrap {
                max-width: 82%;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<main class="chat-room-page">

    <div class="chat-room-top-actions">
        <a href="<%=ctx%>/chat/list" class="chat-room-back-link">← 채팅 목록으로</a>
    </div>

    <section class="chat-room-card">

        <div class="chat-room-product-header">
            <img src="<%=img%>" class="chat-room-product-img" alt="상품 이미지"
                 onerror="this.src='<%=ctx%>/assets/img/default.jpg'">

            <div class="chat-room-product-info">
                <div class="chat-room-product-title"><%=room.getProductName()%></div>
                <div class="chat-room-product-meta">
                    <%=df.format(room.getProductPrice())%>원 · 상대: <%=opponentName%>
                </div>
            </div>

            <a href="<%=ctx%>/productDetail.jsp?id=<%=room.getProductId()%>" class="chat-room-product-link">
                상품 보기
            </a>
        </div>

        <div class="chat-room-messages" id="chatRoomMessages">
            <%
                if (messages == null || messages.isEmpty()) {
            %>
                <div class="chat-room-empty-message">
                    아직 메시지가 없습니다.<br>
                    거래 문의를 시작해보세요.
                </div>
            <%
                } else {
                    for (ChatMessage msg : messages) {
                        boolean mine = msg.getSenderId() == userId;

                        String safeMessage = msg.getMessage();
                        if (safeMessage == null) safeMessage = "";

                        safeMessage = safeMessage
                                .replace("&", "&amp;")
                                .replace("<", "&lt;")
                                .replace(">", "&gt;")
                                .replace("\"", "&quot;")
                                .replace("\n", "<br>");
            %>
                <div class="chat-room-message-row <%=mine ? "mine" : "other"%>">
                    <div class="chat-room-message-wrap">
                        <% if (!mine) { %>
                            <div class="chat-room-sender"><%=msg.getSenderName()%></div>
                        <% } %>

                        <div class="chat-room-message-bubble">
                            <%=safeMessage%>
                        </div>

                        <div class="chat-room-message-time">
                            <%=msg.getCreatedAt()%>
                        </div>
                    </div>
                </div>
            <%
                    }
                }
            %>
        </div>

        <form id="chatRoomForm" class="chat-room-form">
    		<input type="hidden" id="roomId" name="roomId" value="<%=room.getId()%>">
    		<textarea id="messageInput" name="message" placeholder="메시지를 입력하세요." required></textarea>
    		<button type="submit" class="chat-room-send-btn">전송</button>
		</form>

    </section>
</main>

<jsp:include page="/include/footer.jsp" />

<script>
    const ctx = "<%=ctx%>";
    const roomId = document.getElementById("roomId").value;
    const chatRoomMessages = document.getElementById("chatRoomMessages");
    const chatRoomForm = document.getElementById("chatRoomForm");
    const messageInput = document.getElementById("messageInput");

    let lastMessageId = 0;

    function escapeHtml(text) {
        if (!text) return "";

        return text
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    function renderMessages(data) {
        if (!data.success) return;

        const messages = data.messages || [];
        const currentUserId = data.userId;

        if (messages.length === 0) {
            chatRoomMessages.innerHTML =
                '<div class="chat-room-empty-message">' +
                '아직 메시지가 없습니다.<br>거래 문의를 시작해보세요.' +
                '</div>';
            return;
        }

        const latestId = messages[messages.length - 1].id;

        if (latestId === lastMessageId) {
            return;
        }

        lastMessageId = latestId;

        let html = "";

        messages.forEach(function (msg) {
            const mine = msg.senderId === currentUserId;
            const rowClass = mine ? "mine" : "other";

            html += '<div class="chat-room-message-row ' + rowClass + '">';
            html += '  <div class="chat-room-message-wrap">';

            if (!mine) {
                html += '<div class="chat-room-sender">' + escapeHtml(msg.senderName) + '</div>';
            }

            html += '    <div class="chat-room-message-bubble">';
            html +=          escapeHtml(msg.message).replaceAll("\\n", "<br>");
            html += '    </div>';

            html += '    <div class="chat-room-message-time">';
            html +=          escapeHtml(msg.createdAt);
            html += '    </div>';

            html += '  </div>';
            html += '</div>';
        });

        chatRoomMessages.innerHTML = html;
        chatRoomMessages.scrollTop = chatRoomMessages.scrollHeight;
    }

    function loadMessages() {
        fetch(ctx + "/chat/messages?roomId=" + encodeURIComponent(roomId))
            .then(response => response.json())
            .then(data => {
                renderMessages(data);
            })
            .catch(error => {
                console.error("메시지 불러오기 실패:", error);
            });
    }

    chatRoomForm.addEventListener("submit", function (e) {
        e.preventDefault();

        const message = messageInput.value.trim();

        if (!message) {
            return;
        }

        const formData = new URLSearchParams();
        formData.append("roomId", roomId);
        formData.append("message", message);

        fetch(ctx + "/chat/sendAjax", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
            },
            body: formData.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                messageInput.value = "";
                loadMessages();
            } else {
                alert("메시지 전송에 실패했습니다.");
            }
        })
        .catch(error => {
            console.error("메시지 전송 실패:", error);
            alert("메시지 전송 중 오류가 발생했습니다.");
        });
    });

    messageInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            chatRoomForm.requestSubmit();
        }
    });

    loadMessages();
    setInterval(loadMessages, 2000);
</script>

</body>
</html>
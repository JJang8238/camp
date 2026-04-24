<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx     = request.getContextPath();
    String message = request.getParameter("message");
    if (message == null) message = "결제가 취소되었습니다.";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>결제 실패 | Camp Mate</title>
    <jsp:include page="/include/head.jsp" />
    <style>
        .fail-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 65vh;
            text-align: center;
            gap: 16px;
        }
        .fail-icon { font-size: 72px; }
        .fail-title {
            font-size: 26px;
            font-weight: 700;
            color: #c0392b;
            margin: 0;
        }
        .fail-msg {
            color: #666;
            font-size: 15px;
            background: #fff5f5;
            padding: 16px 32px;
            border-radius: 12px;
        }
        .btn-retry {
            padding: 12px 36px;
            background: #2D5A27;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
        }
    </style>
</head>
<body>
<jsp:include page="/include/header.jsp" />

<div class="fail-wrap">
    <div class="fail-icon">❌</div>
    <h2 class="fail-title">결제에 실패했습니다.</h2>
    <p class="fail-msg"><%=message%></p>
    <a href="javascript:history.back()" class="btn-retry">다시 시도하기</a>
</div>

<jsp:include page="/include/footer.jsp" />
</body>
</html>

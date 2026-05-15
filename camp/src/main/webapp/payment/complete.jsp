<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx       = request.getContextPath();
    String orderName = request.getParameter("orderName");
    String amount    = request.getParameter("amount");
    String checkIn   = request.getParameter("checkIn");
    String checkOut  = request.getParameter("checkOut");

    if (orderName == null) orderName = "";
    if (amount == null) amount = "";
    if (checkIn == null) checkIn = "";
    if (checkOut == null) checkOut = "";

    String formattedAmount = amount;

    try {
        long amt = Long.parseLong(amount);
        formattedAmount = String.format("%,d", amt);
    } catch (Exception e) {}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>예약 완료 | Camp Mate</title>

    <jsp:include page="/include/head.jsp" />

    <style>
        html,
        body {
            height: 100%;
            margin: 0;
        }

        body.complete-page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .complete-main {
            flex: 1;
        }

        .complete-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 65vh;
            text-align: center;
            gap: 16px;
        }

        .complete-icon {
            font-size: 72px;
            animation: pop 0.4s ease;
        }

        @keyframes pop {
            0% {
                transform: scale(0.5);
                opacity: 0;
            }

            100% {
                transform: scale(1);
                opacity: 1;
            }
        }

        .complete-title {
            font-size: 28px;
            font-weight: 700;
            color: #2D5A27;
            margin: 0;
        }

        .complete-info {
            background: #f4f8f3;
            border-radius: 16px;
            padding: 24px 40px;
            margin-top: 8px;
            min-width: 360px;
        }

        .complete-info p {
            margin: 6px 0;
            font-size: 16px;
            color: #444;
        }

        .complete-info strong {
            color: #2D5A27;
        }

        .btn-group-complete {
            display: flex;
            gap: 12px;
            margin-top: 12px;
        }

        .btn-go-main {
            padding: 12px 32px;
            background: #2D5A27;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-go-camp {
            padding: 12px 32px;
            background: #fff;
            color: #2D5A27;
            border: 2px solid #2D5A27;
            border-radius: 10px;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
        }
    </style>
</head>

<body class="complete-page">

<jsp:include page="/include/header.jsp" />

<main class="complete-main">

    <div class="complete-wrap">

        <div class="complete-icon">✅</div>

        <h2 class="complete-title">
            예약이 완료되었습니다!
        </h2>

        <div class="complete-info">

            <p>
                캠핑장:
                <strong><%=orderName%></strong>
            </p>

            <% if (!checkIn.isEmpty() && !checkOut.isEmpty()) { %>
                <p>
                    예약 기간:
                    <strong><%=checkIn%> ~ <%=checkOut%></strong>
                </p>
            <% } %>

            <p>
                결제 금액:
                <strong>₩ <%=formattedAmount%>원</strong>
            </p>

            <p style="color:#888; font-size:14px; margin-top:12px;">
                예약 내역은 마이페이지에서 확인할 수 있습니다.
            </p>

        </div>

        <div class="btn-group-complete">

            <a href="<%=ctx%>/main.jsp" class="btn-go-main">
                메인으로
            </a>

            <a href="<%=ctx%>/campList" class="btn-go-camp">
                다른 캠핑장 보기
            </a>

        </div>

    </div>

</main>

<jsp:include page="/include/footer.jsp" />

</body>
</html>
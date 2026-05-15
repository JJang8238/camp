<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();

    String paymentKey  = request.getParameter("paymentKey");
    String orderId     = request.getParameter("orderId");
    String amount      = request.getParameter("amount");

    String checkIn     = request.getParameter("checkIn");
    String checkOut    = request.getParameter("checkOut");

    String peopleCount = request.getParameter("peopleCount");
    String campId      = request.getParameter("campId");

    if (checkIn == null) checkIn = "";
    if (checkOut == null) checkOut = "";
    if (peopleCount == null) peopleCount = "1";
    if (campId == null) campId = "0";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>결제 처리 중 | Camp Mate</title>

    <jsp:include page="/include/head.jsp" />

    <style>
        .loading-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 60vh;
            gap: 20px;
        }

        .loading-wrap p {
            font-size: 18px;
            color: #555;
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<div class="loading-wrap">
    <div class="spinner-border text-success" role="status" style="width:3rem;height:3rem;"></div>
    <p>결제를 처리하고 있습니다. 잠시만 기다려주세요...</p>
</div>

<script>
fetch("<%=ctx%>/payment/confirm", {
    method: "POST",
    headers: {
        "Content-Type": "application/json"
    },
    body: JSON.stringify({
        paymentKey:  "<%=paymentKey%>",
        orderId:     "<%=orderId%>",
        amount:      Number("<%=amount%>"),
        checkIn:     "<%=checkIn%>",
        checkOut:    "<%=checkOut%>",
        peopleCount: "<%=peopleCount%>",
        campId:      "<%=campId%>"
    })
})
.then(function(res) {
    return res.json();
})
.then(function(data) {
    if (data.success) {
        location.href = "<%=ctx%>/payment/complete.jsp"
            + "?orderName=" + encodeURIComponent(data.orderName)
            + "&amount=" + encodeURIComponent(data.amount)
            + "&checkIn=" + encodeURIComponent("<%=checkIn%>")
            + "&checkOut=" + encodeURIComponent("<%=checkOut%>");
    } else {
        alert("결제 승인 실패: " + data.message);
        location.href = "<%=ctx%>/main.jsp";
    }
})
.catch(function(err) {
    alert("오류가 발생했습니다. 다시 시도해주세요.");
    location.href = "<%=ctx%>/main.jsp";
});
</script>

</body>
</html>
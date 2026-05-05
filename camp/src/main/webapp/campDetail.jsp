<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, dao.CampDAO, dao.MatchDAO, dao.PlaceReviewDAO, dto.Camp, dto.Match" %>

<%
String ctx = request.getContextPath();

String idStr = request.getParameter("id");

if (idStr == null || idStr.trim().isEmpty()) {
    out.println("id 없음");
    return;
}

int id = 0;
try {
    id = Integer.parseInt(idStr);
} catch (NumberFormatException e) {
    out.println("id 형식 오류");
    return;
}

CampDAO campDao = new CampDAO();
Camp camp = campDao.getCampById(id);

if (camp == null) {
    out.println("캠핑장 없음");
    return;
}

String name = (camp.getName() != null) ? camp.getName() : "";
String description = (camp.getDescription() != null) ? camp.getDescription() : "";

MatchDAO matchDao = new MatchDAO();
List<Match> matches = matchDao.getTodayMatchesByPlace(name);
if (matches == null) matches = new ArrayList<>();

PlaceReviewDAO reviewDao = new PlaceReviewDAO();
List<Map<String, Object>> reviews = reviewDao.listByPlace(name, "latest");
if (reviews == null) reviews = new ArrayList<>();

// 로그인 유저 정보
Integer userId = (Integer) session.getAttribute("userId");
String userName = (String) session.getAttribute("userName");
if (userName == null) userName = "";
%>
<%
String imgPath = (camp.getImage() != null && !camp.getImage().trim().isEmpty())
        ? ctx + camp.getImage()
        : ctx + "/assets/img/default.jpg";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title><%=name%> 상세</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/camp.css">

    <!-- 토스페이먼츠 SDK -->
    <script src="https://js.tosspayments.com/v1"></script>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<div class="container py-5">
    <div class="camp-detail-wrap">

        <div class="camp-main">

            <div class="camp-left">
                <img 
    				src="<%=imgPath%>"
    				class="camp-main-img"
    				alt="<%=name%>"
    				onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
            </div>

            <div class="camp-right-card">
                <div class="camp-info-top">
                    <h1><%=name%></h1>

                    <p class="location">📍 <%=camp.getAddress()%></p>

                    <div class="tag-box">
                        <span><%=camp.getType()%></span>
                        <span><%=camp.getTags()%></span>
                    </div>
                </div>

                <div class="camp-info-bottom">
                    <div class="price-box">
                        ₩ <%=camp.getPrice()%>
                    </div>

                    <!-- 기존 버튼에 id 추가 -->
                    <button class="btn-main-lg" id="pay-btn">예약하기</button>
                </div>
            </div>
        </div>

        <div class="camp-desc-card card-box">
            <h3>캠핑장 소개</h3>

            <% if (!description.trim().isEmpty()) { %>
                <p><%=description.replace("\n", "<br>")%></p>
            <% } else { %>
                <p class="empty">등록된 상세 설명이 없습니다.</p>
            <% } %>
        </div>

        <div class="review-section card-box">
            <h3>후기</h3>

            <% if (reviews != null && !reviews.isEmpty()) { %>
                <% for (Map<String, Object> r : reviews) { %>
                    <div class="review-card">
                        <div class="review-top">
                            <span class="user"><%=r.get("user")%></span>
                            <span class="rating">⭐ <%=r.get("rating")%></span>
                        </div>
                        <p><%=r.get("content")%></p>
                    </div>
                <% } %>
            <% } else { %>
                <p class="empty">아직 후기가 없습니다.</p>
            <% } %>

            <form action="<%=ctx%>/review" method="post" class="review-form">
                <input type="hidden" name="place" value="<%=name%>">

                <textarea name="content" placeholder="후기를 작성하세요"></textarea>

                <div class="review-bottom">
                    <select name="rating">
                        <option value="5">⭐⭐⭐⭐⭐</option>
                        <option value="4">⭐⭐⭐⭐</option>
                        <option value="3">⭐⭐⭐</option>
                        <option value="2">⭐⭐</option>
                        <option value="1">⭐</option>
                    </select>

                    <button class="btn-submit-sm">작성</button>
                </div>
            </form>
        </div>

    </div>
</div>

<jsp:include page="/include/footer.jsp" />

<!-- 토스페이먼츠 결제 스크립트 -->
<script>
const clientKey = "test_ck_6bJXmgo28e4dxgEbwWKArLAnGKWx"; // ← 본인 클라이언트 키로 교체
const tossPayments = TossPayments(clientKey);

document.getElementById("pay-btn").addEventListener("click", function () {
    <% if (userId == null) { %>
        alert("로그인 후 이용해주세요.");
        location.href = "<%=ctx%>/login.jsp";
        return;
    <% } %>

    const orderId = "ORDER-<%=id%>-" + Date.now();

    tossPayments.requestPayment("카드", {
        amount: <%=camp.getPrice()%>,
        orderId: orderId,
        orderName: "<%=name%>",
        successUrl: window.location.origin + "<%=ctx%>/payment/success.jsp",
        failUrl:    window.location.origin + "<%=ctx%>/payment/fail.jsp",
        customerName: "<%=userName%>"
    });
});
</script>

</body>
</html>
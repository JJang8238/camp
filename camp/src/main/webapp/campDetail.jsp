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

// 이름
String name = (camp.getName() != null) ? camp.getName() : "";

// 매치
MatchDAO matchDao = new MatchDAO();
List<Match> matches = matchDao.getTodayMatchesByPlace(name);
if (matches == null) matches = new ArrayList<>();

// 리뷰
PlaceReviewDAO reviewDao = new PlaceReviewDAO();
List<Map<String, Object>> reviews = reviewDao.listByPlace(name, "latest");
if (reviews == null) reviews = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title><%=name%> 상세</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/camp.css">
</head>

<body>

<jsp:include page="/include/header.jsp" />

<div class="container py-5">

 <div class="camp-main">

    <!-- 왼쪽 -->
    <div class="camp-left">
        <img 
            src="<%=ctx%>/assets/img/<%=camp.getImage()%>" 
            class="camp-main-img">
    </div>

    <!-- 🔥 오른쪽 카드 -->
    <div class="camp-right-card">

    <!-- 🔥 위쪽 -->
    <div class="camp-info-top">
        <h1><%=name%></h1>

        <p class="location">📍 <%=camp.getAddress()%></p>

        <div class="tag-box">
            <span><%=camp.getType()%></span>
            <span><%=camp.getTags()%></span>
        </div>
    </div>

    <!-- 🔥 아래 고정 -->
    <div class="camp-info-bottom">
        <div class="price-box">
            ₩ <%=camp.getPrice()%>
        </div>

        <button class="btn-main-lg">예약하기</button>
    </div>

</div>

</div>

    <!-- 🔥 리뷰 -->
    <div class="review-section">
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

        <!-- 리뷰 작성 -->
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
<jsp:include page="/include/footer.jsp" />

</body>
</html>
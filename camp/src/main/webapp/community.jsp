<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/include/head.jsp" %>
    <title>캠프 메이트 | 커뮤니티</title>
  <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
  <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

<jsp:include page="/include/header.jsp" />

    <main class="community-container">
        <section class="community-hero">
            <h2>커뮤니티 광장 🌲</h2>
            <p>캠퍼들과 소통하고 실시간 캠핑 정보를 확인하세요.</p>
        </section>

        <section class="row g-4">
            <div class="col-md-4">
                <a href="<%=ctx%>/review.jsp" class="card-box community-card">
                    <span class="community-icon">📸</span>
                    <div class="community-title">캠핑 후기</div>
                    <p class="community-desc">
                        직접 다녀온 캠핑장의 생생한 리뷰와 별점을 확인하고 공유하세요.
                    </p>
                </a>
            </div>

            <div class="col-md-4">
                <a href="<%=ctx%>/newsList.jsp" class="card-box community-card">
                    <span class="community-icon">📰</span>
                    <div class="community-title">캠핑 소식 <span class="community-badge">NEW</span></div>
                    <p class="community-desc">
                        새로운 캠핑장 소식과 캠핑 트렌드, 유용한 팁을 확인해 보세요.
                    </p>
                </a>
            </div>

            <div class="col-md-4">
                <a href="<%=ctx%>/eventList.jsp" class="card-box community-card">
                    <span class="community-icon">🎁</span>
                    <div class="community-title">이벤트</div>
                    <p class="community-desc">
                        캠프 메이트에서 준비한 다양한 이벤트와 특별한 혜택을 만나보세요.
                    </p>
                </a>
            </div>
        </section>

        <section class="card-box community-help">
            <h5>궁금한 점이 있으신가요?</h5>
            <p>커뮤니티 이용 중 문의가 있다면 고객센터를 이용해 주세요.</p>
            <a href="<%=ctx%>/cs.jsp" class="btn-outline-custom">고객센터 바로가기</a>
        </section>
    </main>

<jsp:include page="/include/footer.jsp" />

</body>
</html>
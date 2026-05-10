<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    // 비로그인 또는 권한 없으면 로그인 페이지로
    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .mypage-wrapper {
            max-width: 960px;
            margin: 60px auto;
            padding: 0 20px 80px;
        }

        .mypage-header {
            background: linear-gradient(135deg, #2d5a27 0%, #4a8c3f 100%);
            border-radius: 16px;
            padding: 36px 40px;
            color: white;
            margin-bottom: 32px;
        }

        .mypage-header h2 {
            font-size: 24px;
            font-weight: 700;
            margin: 0 0 6px;
        }

        .mypage-header p {
            margin: 0;
            opacity: 0.85;
            font-size: 14px;
        }

        .mypage-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        @media (max-width: 600px) {
            .mypage-grid { grid-template-columns: 1fr; }
        }

        .mypage-card {
            background: white;
            border-radius: 14px;
            padding: 28px;
            display: flex;
            align-items: center;
            gap: 20px;
            text-decoration: none;
            color: inherit;
            border: 1.5px solid #e9ecef;
            transition: box-shadow 0.2s, transform 0.2s, border-color 0.2s;
        }

        .mypage-card:hover {
            box-shadow: 0 8px 24px rgba(45,90,39,0.12);
            transform: translateY(-2px);
            border-color: #2d5a27;
            color: inherit;
            text-decoration: none;
        }

        .card-icon {
            font-size: 36px;
            width: 60px;
            height: 60px;
            background: #f0f7ee;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .card-info h4 {
            font-size: 16px;
            font-weight: 700;
            margin: 0 0 4px;
            color: #1a1a1a;
        }

        .card-info p {
            font-size: 13px;
            color: #888;
            margin: 0;
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="mypage-wrapper">

    <div class="mypage-header">
        <h2>👤 <%= displayName %>님의 마이페이지</h2>
        <p>캠핑 생활을 더 편리하게 관리하세요</p>
    </div>

    <div class="mypage-grid">

        <a href="<%=ctx%>/mypage/reservation_list.jsp" class="mypage-card">
            <div class="card-icon">📋</div>
            <div class="card-info">
                <h4>예약 내역 조회</h4>
                <p>나의 캠핑장 예약 현황을 확인하세요</p>
            </div>
        </a>

        <a href="<%=ctx%>/mypage/wishlist.jsp" class="mypage-card">
            <div class="card-icon">❤️</div>
            <div class="card-info">
                <h4>찜한 캠핑장</h4>
                <p>저장해둔 캠핑장 목록을 확인하세요</p>
            </div>
        </a>

        <a href="<%=ctx%>/mypage/trade_history.jsp" class="mypage-card">
            <div class="card-icon">🛒</div>
            <div class="card-info">
                <h4>용품 거래 내역</h4>
                <p>구매 · 판매 거래 내역을 확인하세요</p>
            </div>
        </a>

		<a href="<%=ctx%>/chat/list" class="mypage-card">
    		<div class="card-icon">💬</div>
    		<div class="card-info">
        		<h4>거래 채팅</h4>
        		<p>캠핑용품 구매 · 판매 채팅을 확인하세요</p>
    		</div>
		</a>

        <a href="<%=ctx%>/mypage/my_reviews.jsp" class="mypage-card">
            <div class="card-icon">⭐</div>
            <div class="card-info">
                <h4>리뷰 관리</h4>
                <p>내가 작성한 리뷰를 관리하세요</p>
            </div>
        </a>

		<a href="<%=ctx%>/mypage/myInquiryList.jsp" class="mypage-card">
    		<div class="card-icon">❓</div>
    		<div class="card-info">
        		<h4>내 문의 내역</h4>
        		<p>1:1 문의 답변 확인</p>
   		 	</div>
		</a>

        <a href="<%=ctx%>/mypage/edit_profile.jsp" class="mypage-card">
            <div class="card-icon">⚙️</div>
            <div class="card-info">
                <h4>회원정보 수정</h4>
                <p>비밀번호 · 닉네임 등을 수정하세요</p>
            </div>
        </a>

    </div>
</div>

<jsp:include page="/include/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
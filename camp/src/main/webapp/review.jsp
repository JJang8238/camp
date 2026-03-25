<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.MatchDAO" %>
<%@ page import="dao.PlaceReviewDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.Match" %>
<%@ page import="dto.User" %>
<%@ page import="java.util.*" %>

<%
    // 🔥 세션 및 기본 정보 설정 (main.jsp와 동일 스타일)
    String userId = (String) session.getAttribute("userId");
    String userName = "";
    
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO uDao = new UserDAO();
    userName = uDao.getNameByUsername(userId);
    int loginUserId = 1; // 실제 환경에선 Integer.parseInt(session.getAttribute("userNo").toString()) 등으로 처리 필요

    String ctx = request.getContextPath();

    // 🔥 요청 장소 및 정렬 옵션 수신
    String place = request.getParameter("place");
    if (place == null) place = "";
    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) sort = "newest";

    // DAO 객체 생성 및 데이터 조회 로직 (기존과 동일 유지)
    MatchDAO matchDAO = new MatchDAO();
    PlaceReviewDAO reviewDAO = new PlaceReviewDAO();

    List<Map<String, Object>> reviewList = null;
    double avg = 0;
    int count = 0;
    int[] ratingCounts = new int[6];

    if (!place.isEmpty()) {
        reviewList = reviewDAO.listByPlace(place, sort);
        if (reviewList != null) {
            for (Map<String, Object> r : reviewList) {
                int rating = Integer.parseInt(String.valueOf(r.get("rating")));
                avg += rating;
                if (rating >= 1 && rating <= 5) ratingCounts[rating]++;
            }
            count = reviewList.size();
            if (count > 0) avg /= count;
        }
    }

    Set<String> allPlaces = new HashSet<String>();
    List<Match> todayMatches = matchDAO.getTodayMatches();
    if(todayMatches != null) {
        for (Match m : todayMatches) {
            allPlaces.add(m.getLocation());
        }
    }

    boolean canWrite = false;
    if (!place.isEmpty()) {
        List<Match> matchesAtPlace = matchDAO.getTodayMatchesByPlace(place);
        if(matchesAtPlace != null) {
            for (Match m : matchesAtPlace) {
                if (matchDAO.isUserReserved(loginUserId, m.getId())) {
                    canWrite = true;
                    break;
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | 리뷰</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        :root { 
            --main-green: #1b4d3e; 
            --point-orange: #ff6b35; 
            --dark-text: #2d3436; 
            --bg-light: #ffffff;
            --bg-beige: #f4f1ea; /* 🔥 따뜻한 느낌을 주는 연한 베이지색 */
            --card-radius: 30px; /* main.jsp의 카드 둥글기와 통일 */
        }
        
        body { background: var(--bg-beige); font-family: 'Noto Sans KR', sans-serif; color: var(--dark-text); }
        
        /* 🔥 HEADER - main.jsp와 완벽 동일 */
        .main-header { width: 100%; background: white; border-bottom: 1px solid #eee; position: sticky; top: 0; z-index: 999; }
        .logo a { text-decoration: none; display: flex; align-items: center; }
        .logo-icon { font-size: 24px; margin-right: 8px; }
        .logo-text { font-size: 22px; font-weight: bold; color: var(--main-green); }

        .nav-menu { display: flex; align-items: center; }
        .nav-menu > a, .nav-menu > .dropdown > .dropbtn { 
            margin: 0 25px; text-decoration: none; color: #444; font-weight: 500; transition: 0.2s; border: none; background: none; cursor: pointer; display: inline-block; padding: 10px 0;
        }
        .nav-menu a:hover, .nav-menu .dropdown:hover .dropbtn { color: var(--main-green); }
        .arrow-small { font-size: 11px; margin-left: 3px; vertical-align: middle; }

        .dropdown { position: relative; display: inline-block; }
        .dropdown-content {
            display: none; position: absolute; top: 100%; left: 50%; transform: translateX(-50%);
            background-color: white; min-width: 140px; box-shadow: 0px 8px 16px rgba(0,0,0,0.1);
            border-radius: 12px; padding: 10px 0; z-index: 1000; border: 1px solid #eee; margin-top: 0; 
        }
        .dropdown::after { content: ""; position: absolute; top: 100%; left: 0; width: 100%; height: 15px; }
        .dropdown-content a { color: #555; padding: 10px 20px; text-decoration: none; display: block; font-size: 14px; text-align: center; }
        .dropdown-content a:hover { background-color: #f8f9fa; color: var(--main-green); }
        .dropdown:hover .dropdown-content { display: block; }
        
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .welcome-msg { font-weight: bold; color: var(--main-green); margin-right: 8px; font-size: 15px; }
        .btn-logout { padding: 6px 16px; border: 1px solid var(--point-orange); color: var(--point-orange); border-radius: 20px; text-decoration: none; font-size: 14px; transition: 0.2s; }
        .btn-logout:hover { background: var(--point-orange); color: white; }

        /* 🔥 리뷰 영역 전용 스타일 (메인 카드로 만듦) */
        .review-main { 
            max-width: 1000px; /* main.jsp의 container 넓이와 비슷하게 */
            margin: 60px auto; 
            background: white; 
            border-radius: var(--card-radius); 
            box-shadow: 0 10px 40px rgba(0,0,0,0.06); /* 은은한 그림자 */
            padding: 50px; 
        }
        
        .page-title { font-weight: 700; color: var(--main-green); margin-bottom: 10px; font-size: 32px; }
        .page-subtitle { color: #888; margin-bottom: 40px; font-size: 16px; font-weight: 400; }
        
        /* 🔥 검색 바 디자인 변경 (main.jsp의 알약 모양 차용) */
        .filter-row { 
            display: flex; gap: 10px; margin-bottom: 40px; padding: 20px;
            background: #f8f9fa; border-radius: 50px; border: 1px solid #eee;
        }
        .form-select-camp { 
            border-radius: 30px; border: none; padding: 12px 25px; flex-grow: 1; 
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
            background-repeat: no-repeat; background-position: right 1.5rem center; background-size: 16px 12px;
        }
        .form-select-sort { border-radius: 30px; border: 1px solid #ddd; padding: 12px 20px; width: 140px; font-size: 14px; }
       .btn-search { border-radius: 30px; background-color: #1b4d3e; color: white; : none; padding: 10px 22px; /* ⬅️ 좌우 여백을 줄여서 글자가 칸에 딱 맞게 조절 */font-weight: 700; font-size: 15px;    /* ⬅️ 글자 크기도 살짝 조절하여 균형을 맞춤 */transition: all 0.3s ease; box-shadow: 0 4px 10px rgba(27, 77, 62, 0.2); white-space: nowrap; cursor: pointer; line-height: 1.2;    /* ⬅️ 버튼 내 글자 높이 중앙 정렬 */}

.btn-search:hover { 
    background-color: #2a6352; 
    transform: translateY(-1px); /* 살짝만 떠오르게 */
    box-shadow: 0 5px 12px rgba(27, 77, 62, 0.3);
}
        
        /* 🔥 통계 카드 및 리뷰 카드 디자인 개선 (main.jsp 카드 느낌) */
        .stats-card { background: #fdfdfd; border-radius: 20px; border: 1px solid #eee; padding: 30px; margin-bottom: 30px; }
        .rating-avg { font-size: 54px; font-weight: 800; color: var(--main-green); line-height: 1; }
        .star-active { color: #FFC107; font-size: 22px; }
        .progress { height: 10px; border-radius: 10px; background-color: #eee; }
        .progress-bar { background-color: var(--main-green); border-radius: 10px; }

        .review-card { background: white; border-radius: 15px; border: 1px solid #f1f1f1; padding: 25px; margin-bottom: 20px; transition: 0.3s; }
        .review-card:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.06); border-color: #e0e0e0; }
        .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .user-info { font-weight: 600; font-size: 16px; display: flex; align-items: center; gap: 8px; }
        .review-date { color: #999; font-size: 13px; }
        .review-content { line-height: 1.7; color: #555; font-size: 15px; }
        
        .btn-write { background: var(--main-green); color: white; border-radius: var(--card-radius); padding: 18px; width: 100%; border: none; font-weight: 600; font-size: 17px; transition: 0.2s; }
        .btn-write:hover { background: #143a2e; transform: scale(1.01); }
        .btn-write:disabled { background: #ccc; color: #888; }
        
        .btn-edit-tool { padding: 4px 12px; border-radius: 8px; font-size: 12px; text-decoration: none; margin-left: 5px; }
    </style>
</head>

<body>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">
        <div class="logo">
            <a href="<%=ctx%>/main.jsp">
                <span class="logo-icon">⛺</span>
                <span class="logo-text">Camp Mate</span>
            </a>
        </div>
        <nav class="nav-menu">
            <a href="<%=ctx%>/productList.jsp">캠핑용품</a>
            <div class="dropdown">
                <a href="<%=ctx%>/community.jsp" class="dropbtn">커뮤니티 <span class="arrow-small">▼</span></a>
                <div class="dropdown-content">
                    <a href="<%=ctx%>/review.jsp">후기</a>
                    <a href="<%=ctx%>/news.jsp">캠핑소식</a>
                    <a href="<%=ctx%>/event.jsp">이벤트</a>
                </div>
            </div>
            <a href="<%=ctx%>/cs.jsp">고객센터</a>
        </nav>
        <div class="nav-right">
            <span class="welcome-msg">👋 <%= userName %>님 환영합니다!</span>
            <a href="<%=ctx%>/logout.jsp" class="btn-logout">로그아웃</a>
        </div>
    </div>
</header>

<div class="review-main">
    <h2 class="page-title text-center">리얼 캠핑 후기 🏕️</h2>
    <p class="page-subtitle text-center">캠퍼들이 직접 남긴 생생한 캠핑장 리뷰를 확인해 보세요.</p>

    <form method="get" class="filter-row">
        <select name="place" class="form-select form-select-camp flex-grow-1">
            <option value="">📍 방문하신 캠핑장을 선택하세요</option>
            <% for (String p : allPlaces) { %>
                <option value="<%=p%>" <%= p.equals(place) ? "selected" : "" %>><%=p%></option>
            <% } %>
        </select>
        <select name="sort" class="form-select form-select-sort">
            <option value="newest" <%= "newest".equals(sort)?"selected":"" %>>최신순</option>
            <option value="high"   <%= "high".equals(sort)  ?"selected":"" %>>별점 높은순</option>
        </select>
        <button class="btn btn-search px-4 rounded-5">조회</button>
    </form>

    <% if (!place.isEmpty()) { %>
        <div class="stats-card shadow-sm">
            <div class="row align-items-center">
                <div class="col-md-4 text-center border-end">
                    <div class="rating-avg"><%=count>0 ? String.format("%.1f", avg) : "0.0"%></div>
                    <div class="star-active">
                        <% for(int i=0; i<5; i++) { out.print(i < (int)avg ? "★" : "☆"); } %>
                    </div>
                    <p class="text-muted mt-2 small">전체 리뷰 <%=count%>개</p>
                </div>
                <div class="col-md-8 ps-md-5">
                    <% for (int r = 5; r >= 1; r--) { 
                        int rc = ratingCounts[r];
                        int percent = (count > 0) ? (int)Math.round(rc * 100.0 / count) : 0;
                    %>
                    <div class="d-flex align-items-center mb-2">
                        <span style="width: 50px;" class="small"><%=r%>점</span>
                        <div class="progress flex-grow-1 mx-3">
                            <div class="progress-bar" style="width: <%=percent%>%"></div>
                        </div>
                        <span style="width: 40px;" class="small text-muted text-end"><%=rc%></span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <% if (reviewList != null && !reviewList.isEmpty()) { %>
            <% for (Map<String, Object> r : reviewList) {
                int rating = Integer.parseInt(String.valueOf(r.get("rating")));
                int writerId = Integer.parseInt(String.valueOf(r.get("userId")));
                String stars = "";
                for(int i=0; i<rating; i++) stars += "★";
            %>
            <div class="review-card shadow-sm">
                <div class="review-header">
                    <div class="user-info">
                        <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" width="30">
                        <span><%=r.get("user")%> 캠퍼님</span>
                        <span class="ms-1 star-active"><%= stars %></span>
                    </div>
                    <span class="review-date"><%=r.get("created_at")%></span>
                </div>
                <div class="review-content"><%=r.get("content")%></div>
                
                <% if (writerId == loginUserId) { %>
                <div class="mt-3 text-end">
                    <button class="btn btn-sm btn-outline-secondary btn-edit-tool" onclick="openEditModal(<%=r.get("id")%>, '<%=r.get("content")%>', <%=rating%>)">수정</button>
                    <button class="btn btn-sm btn-outline-danger btn-edit-tool" onclick="deleteReview(<%=r.get("id")%>)">삭제</button>
                </div>
                <% } %>
            </div>
            <% } %>
        <% } %>

        <div class="mt-5">
            <% if (canWrite) { %>
                <button class="btn-write shadow" onclick="openWriteModal()">✏️ 소중한 캠핑 후기 들려주기</button>
            <% } else { %>
                <button class="btn-write shadow" disabled style="background:#ddd; color:#888;">🏕️ 이용 내역이 확인되어야 작성 가능합니다.</button>
            <% } %>
        </div>
    <% } else { %>
        <div class="text-center py-5 bg-light rounded-4 my-5 shadow-inner">
            <img src="https://cdn-icons-png.flaticon.com/512/2591/2591158.png" width="120" class="mb-4 opacity-50">
            <h5 class="text-muted fw-bold">캠핑장을 선택하시면 생생한 후기들을 볼 수 있어요!</h5>
            <p class="text-muted small mt-2">📍 방문하신 캠핑장을 검색창에서 선택하고 '조회' 버튼을 눌러보세요.</p>
        </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<%-- 여기에 기존의 openWriteModal, deleteReview 등 JS 함수를 그대로 넣으시면 됩니다 --%>
</body>
</html>
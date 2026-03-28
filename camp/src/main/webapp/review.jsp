<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.MatchDAO" %>
<%@ page import="dao.PlaceReviewDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.Match" %>
<%@ page import="java.util.*" %>

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String ctx = request.getContextPath();

    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        UserDAO uDao = new UserDAO();
        userName = uDao.getNameByUsername(userId);
        if (userName != null) {
            session.setAttribute("userName", userName);
        }
    }

    int loginUserId = 1; // 실제 환경에서는 세션의 userNo 등으로 교체

    String place = request.getParameter("place");
    if (place == null) place = "";

    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) sort = "newest";

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
                if (rating >= 1 && rating <= 5) {
                    ratingCounts[rating]++;
                }
            }
            count = reviewList.size();
            if (count > 0) avg /= count;
        }
    }

    Set<String> allPlaces = new LinkedHashSet<String>();
    List<Match> todayMatches = matchDAO.getTodayMatches();
    if (todayMatches != null) {
        for (Match m : todayMatches) {
            allPlaces.add(m.getLocation());
        }
    }

    boolean canWrite = false;
    if (!place.isEmpty()) {
        List<Match> matchesAtPlace = matchDAO.getTodayMatchesByPlace(place);
        if (matchesAtPlace != null) {
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
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 리뷰</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/community.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="community-page review-page">
        <div class="community-container">

            <section class="community-hero">
                <h2>
                    리얼 캠핑 후기
                    <span class="community-badge">REVIEW</span>
                </h2>
                <p>캠퍼들이 직접 남긴 생생한 후기를 확인해 보세요.</p>
            </section>

            <section class="card-box review-filter-box">
                <form method="get" class="review-filter-row">
                    <div class="review-filter-main">
                        <label class="filter-label" for="place">캠핑장 선택</label>
                        <select name="place" id="place" class="common-select">
                            <option value="">방문하신 캠핑장을 선택하세요</option>
                            <% for (String p : allPlaces) { %>
                                <option value="<%=p%>" <%= p.equals(place) ? "selected" : "" %>>
                                    <%=p%>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="review-filter-sort">
                        <label class="filter-label" for="sort">정렬</label>
                        <select name="sort" id="sort" class="common-select">
                            <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>최신순</option>
                            <option value="high" <%= "high".equals(sort) ? "selected" : "" %>>별점 높은순</option>
                        </select>
                    </div>

                    <div class="review-filter-action">
                        <label class="filter-label review-hidden-label">조회</label>
                        <button type="submit" class="btn-main-custom review-search-btn">조회</button>
                    </div>
                </form>
            </section>

            <% if (!place.isEmpty()) { %>

                <section class="card-box review-summary-box">
                    <div class="review-summary-left">
                        <div class="review-score">
                            <%= count > 0 ? String.format("%.1f", avg) : "0.0" %>
                        </div>
                        <div class="review-stars">
                            <%
                                int roundedAvg = (int)Math.round(avg);
                                for (int i = 1; i <= 5; i++) {
                                    out.print(i <= roundedAvg ? "★" : "☆");
                                }
                            %>
                        </div>
                        <p class="review-summary-text">전체 리뷰 <strong><%=count%></strong>개</p>
                    </div>

                    <div class="review-summary-right">
                        <% for (int r = 5; r >= 1; r--) {
                            int rc = ratingCounts[r];
                            int percent = (count > 0) ? (int)Math.round(rc * 100.0 / count) : 0;
                        %>
                            <div class="review-bar-row">
                                <span class="review-bar-label"><%=r%>점</span>
                                <div class="review-bar-track">
                                    <div class="review-bar-fill" style="width: <%=percent%>%;"></div>
                                </div>
                                <span class="review-bar-count"><%=rc%></span>
                            </div>
                        <% } %>
                    </div>
                </section>

                <% if (reviewList != null && !reviewList.isEmpty()) { %>
                    <section class="review-list">
                        <% for (Map<String, Object> r : reviewList) {
                            int rating = Integer.parseInt(String.valueOf(r.get("rating")));
                            int writerId = Integer.parseInt(String.valueOf(r.get("userId")));
                            StringBuilder stars = new StringBuilder();
                            for (int i = 0; i < rating; i++) stars.append("★");
                        %>
                            <article class="card-box review-item">
                                <div class="review-item-top">
                                    <div class="review-user-block">
                                        <div class="review-user-avatar">🏕️</div>
                                        <div class="review-user-meta">
                                            <div class="review-user-name">
                                                <%=r.get("user")%> 캠퍼님
                                            </div>
                                            <div class="review-user-rating"><%=stars.toString()%></div>
                                        </div>
                                    </div>
                                    <div class="review-date"><%=r.get("created_at")%></div>
                                </div>

                                <div class="review-content-text">
                                    <%=r.get("content")%>
                                </div>

                                <% if (writerId == loginUserId) { %>
                                    <div class="review-item-actions">
                                        <button type="button"
                                                class="btn-soft"
                                                onclick="openEditModal(<%=r.get("id")%>, '<%=String.valueOf(r.get("content")).replace("'", "\\'")%>', <%=rating%>)">
                                            수정
                                        </button>
                                        <button type="button"
                                                class="btn-point"
                                                onclick="deleteReview(<%=r.get("id")%>)">
                                            삭제
                                        </button>
                                    </div>
                                <% } %>
                            </article>
                        <% } %>
                    </section>
                <% } else { %>
                    <section class="common-empty-box review-empty-box">
                        <p class="review-empty-title">아직 등록된 후기가 없어요.</p>
                        <p class="review-empty-desc">이 캠핑장의 첫 후기를 남겨보세요.</p>
                    </section>
                <% } %>

                <section class="review-write-box">
                    <% if (canWrite) { %>
                        <button type="button" class="btn-main-custom review-write-btn" onclick="openWriteModal()">
                            소중한 캠핑 후기 작성하기
                        </button>
                    <% } else { %>
                        <button type="button" class="btn-main-custom review-write-btn" disabled>
                            이용 내역이 확인되어야 작성 가능합니다
                        </button>
                    <% } %>
                </section>

            <% } else { %>

                <section class="common-empty-box review-empty-box">
                    <p class="review-empty-title">캠핑장을 선택하면 후기를 볼 수 있어요.</p>
                    <p class="review-empty-desc">상단에서 방문한 캠핑장을 선택한 뒤 조회해 주세요.</p>
                </section>

            <% } %>

        </div>
    </main>

    <jsp:include page="/include/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <%-- 기존 openWriteModal, openEditModal, deleteReview JS는 그대로 아래에 붙이면 됨 --%>
</body>
</html>
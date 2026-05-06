<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.MatchDAO" %>
<%@ page import="dao.PlaceReviewDAO" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.Match" %>
<%@ page import="java.util.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String ctx = request.getContextPath();

    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        UserDAO uDao = new UserDAO();
        userName = uDao.getNameByUserId(userId);
        if (userName != null) {
            session.setAttribute("userName", userName);
        }
    }

    int loginUserId = userId;

    String place = request.getParameter("place");
    if (place == null) place = "";

    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) sort = "newest";

    MatchDAO matchDAO = new MatchDAO();
    PlaceReviewDAO reviewDAO = new PlaceReviewDAO();

    // ✅ 수정/삭제 AJAX 처리
    String action = request.getParameter("action");
    if ("write".equals(action)) {
        String content = request.getParameter("content");
        int rating = 5;
        try { rating = Integer.parseInt(request.getParameter("rating")); } catch (Exception e) {}
        reviewDAO.insertReview(loginUserId, place, content, rating);
        response.sendRedirect(ctx + "/review.jsp?place=" + java.net.URLEncoder.encode(place, "UTF-8") + "&sort=" + sort);
        return;
    }
    if ("edit".equals(action)) {
        int postId = 0;
        int rating = 5;
        String content = request.getParameter("content");
        try { postId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
        try { rating = Integer.parseInt(request.getParameter("rating")); } catch (Exception e) {}
        reviewDAO.updateReview(postId, loginUserId, content, rating);
        response.sendRedirect(ctx + "/review.jsp?place=" + java.net.URLEncoder.encode(place, "UTF-8") + "&sort=" + sort);
        return;
    }
    if ("delete".equals(action)) {
        int postId = 0;
        try { postId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
        reviewDAO.deleteReview(postId, loginUserId);
        response.sendRedirect(ctx + "/review.jsp?place=" + java.net.URLEncoder.encode(place, "UTF-8") + "&sort=" + sort);
        return;
    }

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

    // ✅ 수정: reservations + camps 기준으로 전체 캠핑장 목록 가져오기
    Set<String> allPlaces = new LinkedHashSet<String>();
    List<Match> todayMatches = matchDAO.getTodayMatches();
    if (todayMatches != null) {
        for (Match m : todayMatches) {
            allPlaces.add(m.getLocation());
        }
    }

    // ✅ 수정: 해당 캠핑장을 실제로 예약했는지 reservations 테이블로 확인
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

    <style>
        /* 모달 */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.active { display: flex; }
        .modal-box {
            background: white;
            border-radius: 16px;
            padding: 32px 28px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.15);
        }
        .modal-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #1a1a1a;
        }
        .modal-label {
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
            display: block;
        }
        .modal-textarea {
            width: 100%;
            height: 120px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 14px;
            resize: vertical;
            box-sizing: border-box;
            outline: none;
        }
        .modal-textarea:focus { border-color: #2d5a27; }
        .star-selector { display: flex; gap: 6px; margin-bottom: 16px; }
        .star-selector span {
            font-size: 28px;
            cursor: pointer;
            color: #ddd;
            transition: color 0.15s;
        }
        .star-selector span.on { color: #f5a623; }
        .modal-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        .modal-btn-cancel {
            flex: 1;
            padding: 10px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            background: white;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            color: #555;
        }
        .modal-btn-submit {
            flex: 2;
            padding: 10px;
            border: none;
            border-radius: 8px;
            background: #2d5a27;
            color: white;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }
        .modal-btn-submit:hover { background: #1e3d1b; }
    </style>
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

    <%-- 리뷰 작성 모달 --%>
    <div class="modal-overlay" id="writeModal">
        <div class="modal-box">
            <div class="modal-title">✍️ 후기 작성</div>
            <form method="post" action="<%=ctx%>/review.jsp?place=<%=java.net.URLEncoder.encode(place, "UTF-8")%>&sort=<%=sort%>&action=write">
                <label class="modal-label">별점</label>
                <div class="star-selector" id="writeStars">
                    <span data-v="1">★</span>
                    <span data-v="2">★</span>
                    <span data-v="3">★</span>
                    <span data-v="4">★</span>
                    <span data-v="5">★</span>
                </div>
                <input type="hidden" name="rating" id="writeRating" value="5">

                <label class="modal-label">후기 내용</label>
                <textarea class="modal-textarea" name="content" placeholder="솔직한 캠핑 후기를 남겨주세요." required></textarea>

                <div class="modal-actions">
                    <button type="button" class="modal-btn-cancel" onclick="closeModal('writeModal')">취소</button>
                    <button type="submit" class="modal-btn-submit">작성 완료</button>
                </div>
            </form>
        </div>
    </div>

    <%-- 리뷰 수정 모달 --%>
    <div class="modal-overlay" id="editModal">
        <div class="modal-box">
            <div class="modal-title">✏️ 후기 수정</div>
            <form method="post" action="<%=ctx%>/review.jsp?place=<%=java.net.URLEncoder.encode(place, "UTF-8")%>&sort=<%=sort%>&action=edit">
                <input type="hidden" name="id" id="editPostId">

                <label class="modal-label">별점</label>
                <div class="star-selector" id="editStars">
                    <span data-v="1">★</span>
                    <span data-v="2">★</span>
                    <span data-v="3">★</span>
                    <span data-v="4">★</span>
                    <span data-v="5">★</span>
                </div>
                <input type="hidden" name="rating" id="editRating" value="5">

                <label class="modal-label">후기 내용</label>
                <textarea class="modal-textarea" name="content" id="editContent" required></textarea>

                <div class="modal-actions">
                    <button type="button" class="modal-btn-cancel" onclick="closeModal('editModal')">취소</button>
                    <button type="submit" class="modal-btn-submit">수정 완료</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 모달 열기/닫기
        function openWriteModal() {
            setStars('writeStars', 'writeRating', 5);
            document.getElementById('writeModal').classList.add('active');
        }
        function openEditModal(id, content, rating) {
            document.getElementById('editPostId').value = id;
            document.getElementById('editContent').value = content;
            setStars('editStars', 'editRating', rating);
            document.getElementById('editModal').classList.add('active');
        }
        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }

        // 별점 선택
        function setStars(containerId, inputId, value) {
            const stars = document.querySelectorAll('#' + containerId + ' span');
            document.getElementById(inputId).value = value;
            stars.forEach(s => {
                s.classList.toggle('on', parseInt(s.dataset.v) <= value);
            });
        }

        // 별점 클릭 이벤트 등록
        ['writeStars', 'editStars'].forEach(containerId => {
            const inputId = containerId === 'writeStars' ? 'writeRating' : 'editRating';
            document.querySelectorAll('#' + containerId + ' span').forEach(star => {
                star.addEventListener('click', () => {
                    setStars(containerId, inputId, parseInt(star.dataset.v));
                });
                star.addEventListener('mouseover', () => {
                    document.querySelectorAll('#' + containerId + ' span').forEach(s => {
                        s.classList.toggle('on', parseInt(s.dataset.v) <= parseInt(star.dataset.v));
                    });
                });
                star.addEventListener('mouseout', () => {
                    const cur = parseInt(document.getElementById(inputId).value);
                    setStars(containerId, inputId, cur);
                });
            });
        });

        // 삭제
        function deleteReview(id) {
            if (!confirm('이 후기를 삭제할까요?')) return;
            const form = document.createElement('form');
            form.method = 'post';
            form.action = '<%=ctx%>/review.jsp?place=<%=java.net.URLEncoder.encode(place, "UTF-8")%>&sort=<%=sort%>&action=delete';
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'id';
            input.value = id;
            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        }

        // 모달 외부 클릭 시 닫기
        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', function(e) {
                if (e.target === this) this.classList.remove('active');
            });
        });
    </script>
</body>
</html>

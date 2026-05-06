<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ReviewDAO, dto.ReviewDTO, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 삭제 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        String deleteIdStr = request.getParameter("deleteId");
        if (deleteIdStr != null && !deleteIdStr.isEmpty()) {
            try {
                int deleteId = Integer.parseInt(deleteIdStr);
                boolean ok = ReviewDAO.deleteReview(deleteId, userId);
                if (ok) successMsg = "리뷰가 삭제되었습니다.";
                else    errorMsg   = "삭제 중 오류가 발생했습니다.";
            } catch (NumberFormatException e) {
                errorMsg = "잘못된 요청입니다.";
            }
        }
    }

    List<ReviewDTO> reviews = ReviewDAO.getMyReviews(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>리뷰 관리 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .page-wrapper {
            max-width: 860px;
            margin: 60px auto;
            padding: 0 20px 80px;
        }

        .page-top {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 28px;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            border: 1.5px solid #dee2e6;
            border-radius: 20px;
            font-size: 13px;
            color: #555;
            text-decoration: none;
            background: white;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-back:hover { border-color: #2d5a27; color: #2d5a27; text-decoration: none; }
        .page-title { font-size: 22px; font-weight: 700; color: #1a1a1a; margin: 0; }

        .alert-success {
            background: #e8f5e9; color: #2d5a27;
            border: 1px solid #c8e6c9; border-radius: 10px;
            padding: 12px 18px; margin-bottom: 20px; font-size: 14px;
        }
        .alert-error {
            background: #fdecea; color: #c0392b;
            border: 1px solid #f5c6cb; border-radius: 10px;
            padding: 12px 18px; margin-bottom: 20px; font-size: 14px;
        }

        .summary-bar {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 10px;
            padding: 12px 20px;
            margin-bottom: 18px;
            font-size: 13px;
            color: #555;
        }
        .summary-bar strong { color: #2d5a27; }

        .review-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 14px;
            display: flex;
            gap: 18px;
            align-items: flex-start;
            transition: box-shadow 0.2s, border-color 0.2s;
        }
        .review-card:hover {
            box-shadow: 0 6px 20px rgba(0,0,0,0.07);
            border-color: #2d5a27;
        }

        .review-thumb {
            width: 80px; height: 80px;
            border-radius: 10px; object-fit: cover;
            flex-shrink: 0; background: #f1f3f5;
        }
        .review-thumb-placeholder {
            width: 80px; height: 80px;
            border-radius: 10px; background: #f0f7ee;
            display: flex; align-items: center;
            justify-content: center; font-size: 28px; flex-shrink: 0;
        }

        .review-body { flex: 1; min-width: 0; }

        .review-title {
            font-size: 15px; font-weight: 700; color: #1a1a1a;
            margin-bottom: 6px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .review-meta {
            display: flex; flex-wrap: wrap;
            gap: 12px; font-size: 12px; color: #aaa;
        }

        .review-actions {
            display: flex; flex-direction: column;
            gap: 8px; flex-shrink: 0;
        }

        /* ✅ 내용 보기 버튼 */
        .btn-view {
            padding: 6px 16px;
            border: 1.5px solid #888;
            border-radius: 20px;
            font-size: 12px; font-weight: 600;
            color: #555; background: white;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-view:hover { background: #555; color: white; }

        .btn-edit {
            padding: 6px 16px;
            border: 1.5px solid #2d5a27;
            border-radius: 20px;
            font-size: 12px; font-weight: 600;
            color: #2d5a27; background: white;
            text-decoration: none; text-align: center;
            transition: background 0.2s, color 0.2s; cursor: pointer;
        }
        .btn-edit:hover { background: #2d5a27; color: white; text-decoration: none; }

        .btn-delete {
            padding: 6px 16px;
            border: 1.5px solid #e74c3c;
            border-radius: 20px;
            font-size: 12px; font-weight: 600;
            color: #e74c3c; background: white;
            cursor: pointer; transition: background 0.2s, color 0.2s;
        }
        .btn-delete:hover { background: #e74c3c; color: white; }

        .badge-status {
            display: inline-block; padding: 2px 10px;
            border-radius: 20px; font-size: 11px; font-weight: 600;
        }
        .badge-published { background: #e8f5e9; color: #2d5a27; }
        .badge-draft     { background: #f1f3f5; color: #777; }

        .empty-box { text-align: center; padding: 70px 20px; color: #bbb; }
        .empty-box .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty-box p { font-size: 14px; margin: 0 0 18px; }
        .btn-write {
            display: inline-block; padding: 9px 22px;
            background: #2d5a27; color: white;
            border-radius: 24px; font-size: 13px; font-weight: 600; text-decoration: none;
        }
        .btn-write:hover { background: #1e3d1b; color: white; text-decoration: none; }

        @media (max-width: 560px) {
            .review-card { flex-wrap: wrap; }
            .review-actions { flex-direction: row; }
        }

        /* ✅ 내용 보기 모달 */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.active { display: flex; }

        .modal-box {
            background: white; border-radius: 16px;
            padding: 36px 32px; width: 100%; max-width: 520px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.15);
            position: relative; max-height: 80vh; overflow-y: auto;
        }

        .modal-close {
            position: absolute; top: 16px; right: 20px;
            font-size: 20px; color: #aaa; cursor: pointer;
            background: none; border: none; line-height: 1;
        }
        .modal-close:hover { color: #333; }

        .modal-camp-name {
            font-size: 12px; color: #2d5a27; font-weight: 600; margin-bottom: 6px;
        }
        .modal-review-title {
            font-size: 18px; font-weight: 700; color: #1a1a1a; margin-bottom: 8px;
        }
        .modal-stars {
            font-size: 22px; color: #f5a623; margin-bottom: 16px; letter-spacing: 2px;
        }
        .modal-divider {
            border: none; border-top: 1px solid #f1f3f5; margin-bottom: 16px;
        }
        .modal-content-text {
            font-size: 14px; color: #333; line-height: 1.8;
            white-space: pre-wrap; word-break: break-word;
        }
        .modal-date {
            margin-top: 20px; font-size: 12px; color: #bbb; text-align: right;
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/user_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">⭐ 리뷰 관리</h2>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <% if (!reviews.isEmpty()) { %>
    <div class="summary-bar">
        내가 작성한 리뷰 <strong><%=reviews.size()%></strong>개
    </div>
    <% } %>

    <% if (reviews.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">✍️</div>
        <p>아직 작성한 리뷰가 없어요</p>
        <a href="<%=ctx%>/review.jsp" class="btn-write">리뷰 작성하러 가기</a>
    </div>

    <% } else {
        for (ReviewDTO r : reviews) {
            String statusBadge = "published".equals(r.getStatus())
                ? "<span class='badge-status badge-published'>공개</span>"
                : "<span class='badge-status badge-draft'>임시저장</span>";

            String createdDate = r.getCreatedAt() != null && r.getCreatedAt().length() >= 10
                ? r.getCreatedAt().substring(0, 10) : "";

            String thumbPath = null;
            if (r.getThumbnail() != null && !r.getThumbnail().trim().isEmpty()) {
                String t = r.getThumbnail().trim();
                thumbPath = t.startsWith("http") ? t : ctx + "/assets/img/" + t;
            }

            // 별점: summary에 숫자로 저장
            int starCount = 5;
            try { starCount = Integer.parseInt(r.getSummary()); } catch (Exception ignored) {}
            starCount = Math.max(1, Math.min(5, starCount));
            String stars = "★★★★★☆☆☆☆☆".substring(5 - starCount, 10 - starCount);

            // JS 전달용 이스케이프
            String contentEsc  = r.getContent()  != null ? r.getContent().replace("\\","\\\\").replace("'","\\'").replace("\n","\\n").replace("\r","") : "";
            String titleEsc    = r.getTitle()     != null ? r.getTitle().replace("'","\\'") : "";
            String categoryEsc = r.getCategory()  != null ? r.getCategory().replace("'","\\'") : "";
    %>
    <div class="review-card">

        <% if (thumbPath != null) { %>
        <img src="<%=thumbPath%>" class="review-thumb"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" alt="썸네일">
        <div class="review-thumb-placeholder" style="display:none">⭐</div>
        <% } else { %>
        <div class="review-thumb-placeholder">⭐</div>
        <% } %>

        <div class="review-body">
            <div class="review-title"><%=r.getTitle()%></div>
            <div class="review-meta">
                <% if (r.getCategory() != null) { %><span>🏕️ <%=r.getCategory()%></span><% } %>
                <span>👁️ <%=r.getViewCount()%></span>
                <span>📅 <%=createdDate%></span>
                <%=statusBadge%>
            </div>
        </div>

        <div class="review-actions">
            <%-- ✅ 내용 보기 버튼 --%>
            <button type="button" class="btn-view"
                onclick="openViewModal('<%=titleEsc%>', '<%=categoryEsc%>', '<%=stars%>', '<%=contentEsc%>', '<%=createdDate%>')">
                👁 내용 보기
            </button>
            <a href="<%=ctx%>/review_edit.jsp?id=<%=r.getId()%>" class="btn-edit">수정</a>
            <form method="post" action="" onsubmit="return confirm('이 리뷰를 삭제할까요?');">
                <input type="hidden" name="deleteId" value="<%=r.getId()%>">
                <button type="submit" class="btn-delete">삭제</button>
            </form>
        </div>

    </div>
    <%
        }
    } %>

</div>

<%-- ✅ 내용 보기 모달 --%>
<div class="modal-overlay" id="viewModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeViewModal()">✕</button>
        <div class="modal-camp-name" id="modalCampName"></div>
        <div class="modal-review-title" id="modalTitle"></div>
        <div class="modal-stars" id="modalStars"></div>
        <hr class="modal-divider">
        <div class="modal-content-text" id="modalContent"></div>
        <div class="modal-date" id="modalDate"></div>
    </div>
</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openViewModal(title, campName, stars, content, date) {
        document.getElementById('modalCampName').textContent = '🏕️ ' + campName;
        document.getElementById('modalTitle').textContent    = title;
        document.getElementById('modalStars').textContent    = stars;
        document.getElementById('modalContent').textContent  = content;
        document.getElementById('modalDate').textContent     = '작성일: ' + date;
        document.getElementById('viewModal').classList.add('active');
    }

    function closeViewModal() {
        document.getElementById('viewModal').classList.remove('active');
    }

    // 모달 외부 클릭 시 닫기
    document.getElementById('viewModal').addEventListener('click', function(e) {
        if (e.target === this) closeViewModal();
    });
</script>
</body>
</html>

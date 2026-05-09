<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.WishlistDAO, dto.WishlistDTO, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 찜 삭제 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        String campIdStr = request.getParameter("removeCampId");
        if (campIdStr != null && !campIdStr.isEmpty()) {
            try {
                int campId = Integer.parseInt(campIdStr);
                boolean ok = WishlistDAO.removeWishlist(userId, campId);
                if (ok) successMsg = "찜 목록에서 삭제되었습니다.";
                else    errorMsg   = "삭제 중 오류가 발생했습니다.";
            } catch (NumberFormatException e) {
                errorMsg = "잘못된 요청입니다.";
            }
        }
    }

    List<WishlistDTO> wishlist = WishlistDAO.getWishlistByUserId(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>찜한 캠핑장 | Camp Mate</title>
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

        /* 캠핑장 카드 */
        .camp-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            margin-bottom: 16px;
            overflow: hidden;
            display: flex;
            transition: box-shadow 0.2s, border-color 0.2s;
        }
        .camp-card:hover {
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
            border-color: #2d5a27;
        }

        .camp-img {
            width: 140px;
            flex-shrink: 0;
            object-fit: cover;
            background: #f0f7ee;
        }
        .camp-img-placeholder {
            width: 140px;
            flex-shrink: 0;
            background: #f0f7ee;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
        }

        .camp-body {
            flex: 1;
            padding: 20px 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
        }

        .camp-info { flex: 1; min-width: 0; }

        .camp-name {
            font-size: 16px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 6px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .camp-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            font-size: 12px;
            color: #888;
            margin-bottom: 8px;
        }

        .camp-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .tag-pill {
            background: #f0f7ee;
            color: #2d5a27;
            font-size: 11px;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 20px;
        }

        .camp-price {
            font-size: 16px;
            font-weight: 700;
            color: #2d5a27;
            white-space: nowrap;
        }

        .camp-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-shrink: 0;
        }

        .btn-goto {
            padding: 7px 18px;
            background: #2d5a27;
            color: white;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            text-align: center;
            transition: background 0.2s;
        }
        .btn-goto:hover { background: #1e3d1b; color: white; text-decoration: none; }

        .btn-remove {
            padding: 7px 18px;
            border: 1.5px solid #e74c3c;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            color: #e74c3c;
            background: white;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-remove:hover { background: #e74c3c; color: white; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 70px 20px;
            color: #bbb;
        }
        .empty-box .empty-icon { font-size: 52px; margin-bottom: 16px; }
        .empty-box p { font-size: 14px; margin: 0 0 20px; }
        .btn-go-camp {
            display: inline-block;
            padding: 10px 24px;
            background: #2d5a27;
            color: white;
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
        }
        .btn-go-camp:hover { background: #1e3d1b; color: white; text-decoration: none; }

        .badge-open   { background: #e8f5e9; color: #2d5a27; padding: 2px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .badge-closed { background: #fdecea; color: #c0392b; padding: 2px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }

        @media (max-width: 600px) {
            .camp-card { flex-direction: column; }
            .camp-img, .camp-img-placeholder { width: 100%; height: 140px; }
            .camp-body { flex-direction: column; align-items: flex-start; }
            .camp-actions { flex-direction: row; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/user_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">❤️ 찜한 캠핑장</h2>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <% if (!wishlist.isEmpty()) { %>
    <div class="summary-bar">
        찜한 캠핑장 <strong><%=wishlist.size()%></strong>개
    </div>
    <% } %>

    <% if (wishlist.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">🏕️</div>
        <p>아직 찜한 캠핑장이 없어요</p>
        <a href="<%=ctx%>/campList" class="btn-go-camp">캠핑장 둘러보기</a>
    </div>

    <% } else {
        for (WishlistDTO w : wishlist) {

            String imgPath = null;
            if (w.getCampImage() != null && !w.getCampImage().trim().isEmpty()) {
                String img = w.getCampImage().trim();
                imgPath = img.startsWith("http") ? img : ctx + "/assets/img/" + img;
            }

            String statusBadge = "open".equalsIgnoreCase(w.getCampStatus())
                ? "<span class='badge-open'>운영중</span>"
                : "<span class='badge-closed'>운영종료</span>";

            String wishedDate = w.getCreatedAt() != null && w.getCreatedAt().length() >= 10
                ? w.getCreatedAt().substring(0, 10) : "";
    %>
    <div class="camp-card">

        <% if (imgPath != null) { %>
        <img src="<%=imgPath%>" class="camp-img"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
             alt="캠핑장 이미지">
        <div class="camp-img-placeholder" style="display:none">🏕️</div>
        <% } else { %>
        <div class="camp-img-placeholder">🏕️</div>
        <% } %>

        <div class="camp-body">
            <div class="camp-info">
                <div class="camp-name"><%=w.getCampName()%></div>
                <div class="camp-meta">
                    <% if (w.getCampAddress() != null) { %><span>📍 <%=w.getCampAddress()%></span><% } %>
                    <% if (w.getCampType() != null) { %><span>🏠 <%=w.getCampType()%></span><% } %>
                    <span>❤️ <%=wishedDate%> 찜</span>
                    <%=statusBadge%>
                </div>
                <% if (w.getCampTags() != null && !w.getCampTags().isEmpty()) { %>
                <div class="camp-tags">
                    <%
                        String[] tags = w.getCampTags().split(",");
                        for (String tag : tags) {
                            if (!tag.trim().isEmpty()) {
                    %>
                    <span class="tag-pill">#<%=tag.trim()%></span>
                    <%      }
                        }
                    %>
                </div>
                <% } %>
            </div>

            <div style="text-align:right;">
                <div class="camp-price" style="margin-bottom:12px;">
                    <%=w.getCampPrice() > 0 ? String.format("%,d원", w.getCampPrice()) : "가격 미정"%>
                </div>
                <div class="camp-actions">
                    <a href="<%=ctx%>/campDetail?id=<%=w.getCampId()%>" class="btn-goto">예약하러 가기</a>
                    <form method="post" action="" onsubmit="return confirm('찜 목록에서 삭제할까요?');" style="margin:0;">
                        <input type="hidden" name="removeCampId" value="<%=w.getCampId()%>">
                        <button type="submit" class="btn-remove">❤️ 찜 해제</button>
                    </form>
                </div>
            </div>
        </div>

    </div>
    <%
        }
    } %>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ReviewReplyDAO, java.util.*" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String successMsg = "";
    String errorMsg   = "";

    // POST 처리 (답글 등록/수정/삭제)
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String action  = request.getParameter("action");
        String postIdStr = request.getParameter("postId");

        if (postIdStr != null && !postIdStr.isEmpty()) {
            try {
                int postId = Integer.parseInt(postIdStr);

                if ("reply".equals(action)) {
                    String content = request.getParameter("replyContent");
                    if (content != null && !content.trim().isEmpty()) {
                        boolean ok = ReviewReplyDAO.saveReply(postId, userId, content.trim());
                        successMsg = ok ? "답글이 등록되었습니다." : "답글 등록 중 오류가 발생했습니다.";
                    } else {
                        errorMsg = "답글 내용을 입력해주세요.";
                    }
                } else if ("deleteReply".equals(action)) {
                    boolean ok = ReviewReplyDAO.deleteReply(postId, userId);
                    successMsg = ok ? "답글이 삭제되었습니다." : "삭제 중 오류가 발생했습니다.";
                }
            } catch (NumberFormatException e) {
                errorMsg = "잘못된 요청입니다.";
            }
        }
    }

    List<Map<String, Object>> reviews = ReviewReplyDAO.getReviewsByOwnerId(userId);
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
            max-width: 900px;
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
        .btn-back:hover { border-color: #1a3a5c; color: #1a3a5c; text-decoration: none; }
        .page-title { font-size: 22px; font-weight: 700; color: #1a1a1a; margin: 0; }

        .alert-success {
            background: #e8f0fb; color: #1a3a5c;
            border: 1px solid #c5d8f5; border-radius: 10px;
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
        .summary-bar strong { color: #1a3a5c; }

        /* 리뷰 카드 */
        .review-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 22px 26px;
            margin-bottom: 16px;
            transition: box-shadow 0.2s;
        }
        .review-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.07); }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }
        .review-guest {
            font-size: 14px;
            font-weight: 700;
            color: #1a1a1a;
        }
        .review-camp {
            font-size: 12px;
            color: #2d5a27;
            font-weight: 600;
            margin-top: 2px;
        }
        .review-date { font-size: 12px; color: #bbb; }

        .review-stars { color: #f5a623; font-size: 16px; margin-bottom: 8px; }

        .review-content {
            font-size: 14px;
            color: #444;
            line-height: 1.7;
            padding: 12px 14px;
            background: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 14px;
        }

        /* 답글 영역 */
        .reply-area {
            border-top: 1px solid #f1f3f5;
            padding-top: 14px;
        }
        .reply-label {
            font-size: 12px;
            font-weight: 700;
            color: #1a3a5c;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* 기존 답글 */
        .existing-reply {
            background: #eef4fb;
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 10px;
        }
        .existing-reply-text {
            font-size: 13px;
            color: #333;
            line-height: 1.7;
            margin-bottom: 6px;
        }
        .existing-reply-date {
            font-size: 11px;
            color: #aaa;
        }

        /* 답글 입력 폼 */
        .reply-form { display: flex; flex-direction: column; gap: 8px; }
        .reply-textarea {
            width: 100%;
            height: 80px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            padding: 10px 12px;
            font-size: 13px;
            resize: none;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }
        .reply-textarea:focus { border-color: #1a3a5c; }

        .reply-actions { display: flex; justify-content: flex-end; gap: 8px; }

        .btn-reply-submit {
            padding: 7px 20px;
            background: #1a3a5c;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-reply-submit:hover { background: #122840; }

        .btn-reply-delete {
            padding: 7px 16px;
            background: white;
            color: #e74c3c;
            border: 1.5px solid #e74c3c;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-reply-delete:hover { background: #e74c3c; color: white; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 70px 20px;
            color: #bbb;
            background: white;
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
        }
        .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty-box p { font-size: 14px; margin: 0; }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/owner_mypage.jsp" class="btn-back">← 마이페이지</a>
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
        내 캠핑장 리뷰 <strong><%=reviews.size()%></strong>개
    </div>
    <% } %>

    <% if (reviews.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">⭐</div>
        <p>아직 등록된 리뷰가 없습니다.</p>
    </div>

    <% } else {
        for (Map<String, Object> r : reviews) {
            int postId = (int) r.get("id");
            String guestName   = r.get("guest_name")  != null ? (String) r.get("guest_name")  : "손님";
            String campName    = r.get("camp_name")   != null ? (String) r.get("camp_name")   : "";
            String content     = r.get("content")     != null ? (String) r.get("content")     : "";
            String ratingStr   = r.get("rating")      != null ? (String) r.get("rating")      : "5";
            String createdAt   = r.get("created_at")  != null ? ((String) r.get("created_at")).substring(0, 10) : "";
            String replyContent = r.get("reply_content") != null ? (String) r.get("reply_content") : null;
            String replyAt      = r.get("reply_at")      != null ? (String) r.get("reply_at")      : null;

            int rating = 5;
            try { rating = Integer.parseInt(ratingStr); } catch (Exception ignored) {}
            rating = Math.max(1, Math.min(5, rating));
            String stars = "★★★★★☆☆☆☆☆".substring(5 - rating, 10 - rating);

            String replyAtShort = replyAt != null && replyAt.length() >= 10 ? replyAt.substring(0, 10) : "";
            String contentEsc = content.replace("'", "\\'").replace("\n", "\\n").replace("\r", "");
            String replyEsc = replyContent != null ? replyContent.replace("'", "\\'").replace("\n", "\\n").replace("\r", "") : "";
    %>
    <div class="review-card">
        <div class="review-header">
            <div>
                <div class="review-guest">🏕️ <%=guestName%> 캠퍼님</div>
                <div class="review-camp"><%=campName%></div>
            </div>
            <div class="review-date"><%=createdAt%></div>
        </div>

        <div class="review-stars"><%=stars%></div>
        <div class="review-content"><%=content%></div>

        <%-- 답글 영역 --%>
        <div class="reply-area">
            <div class="reply-label">💬 사장님 답글</div>

            <% if (replyContent != null) { %>
            <%-- 기존 답글 표시 --%>
            <div class="existing-reply" id="reply-show-<%=postId%>">
                <div class="existing-reply-text"><%=replyContent%></div>
                <div class="existing-reply-date">답글 작성일: <%=replyAtShort%></div>
            </div>
            <div class="reply-actions" style="margin-bottom:8px;">
                <button type="button" class="btn-reply-submit"
                        onclick="openEditReply(<%=postId%>, '<%=replyEsc%>')">
                    ✏️ 수정
                </button>
                <form method="post" action="" style="margin:0;"
                      onsubmit="return confirm('답글을 삭제할까요?');">
                    <input type="hidden" name="action" value="deleteReply">
                    <input type="hidden" name="postId" value="<%=postId%>">
                    <button type="submit" class="btn-reply-delete">삭제</button>
                </form>
            </div>
            <% } %>

            <%-- 답글 작성/수정 폼 --%>
            <div id="reply-form-<%=postId%>" style="<%=replyContent != null ? "display:none;" : ""%>">
                <form method="post" action="" class="reply-form">
                    <input type="hidden" name="action" value="reply">
                    <input type="hidden" name="postId" value="<%=postId%>">
                    <textarea name="replyContent" class="reply-textarea"
                              id="textarea-<%=postId%>"
                              placeholder="손님 리뷰에 답글을 작성해주세요."><%=replyContent != null ? replyContent : ""%></textarea>
                    <div class="reply-actions">
                        <% if (replyContent != null) { %>
                        <button type="button" class="btn-reply-delete"
                                onclick="closeEditReply(<%=postId%>)">취소</button>
                        <% } %>
                        <button type="submit" class="btn-reply-submit">
                            <%=replyContent != null ? "수정 완료" : "답글 등록"%>
                        </button>
                    </div>
                </form>
            </div>

            <% if (replyContent == null) { %>
            <button type="button" class="btn-reply-submit"
                    style="margin-top:4px;"
                    onclick="openWriteReply(<%=postId%>)"
                    id="btn-write-<%=postId%>">
                + 답글 작성
            </button>
            <% } %>
        </div>
    </div>
    <%
        }
    } %>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 답글 작성 폼 열기
    function openWriteReply(postId) {
        document.getElementById('reply-form-' + postId).style.display = 'block';
        document.getElementById('btn-write-' + postId).style.display = 'none';
    }

    // 답글 수정 폼 열기
    function openEditReply(postId, content) {
        document.getElementById('reply-show-' + postId).style.display = 'none';
        document.getElementById('reply-form-' + postId).style.display = 'block';
        document.getElementById('textarea-' + postId).value = content.replace(/\\n/g, '\n');
    }

    // 답글 수정 폼 닫기
    function closeEditReply(postId) {
        document.getElementById('reply-show-' + postId).style.display = 'block';
        document.getElementById('reply-form-' + postId).style.display = 'none';
    }
</script>
</body>
</html>

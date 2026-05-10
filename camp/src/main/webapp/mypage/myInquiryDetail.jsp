<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");

    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/mypage/myInquiryList.jsp");
        return;
    }

    int inquiryId = 0;

    try {
        inquiryId = Integer.parseInt(idStr);
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/mypage/myInquiryList.jsp");
        return;
    }

    InquiryDAO dao = new InquiryDAO();
    Map<String, String> inquiry = dao.getMyInquiryDetail(inquiryId, userId);

    if (inquiry == null || inquiry.isEmpty()) {
        response.sendRedirect(ctx + "/mypage/myInquiryList.jsp");
        return;
    }

    String title = inquiry.get("title");
    String content = inquiry.get("content");
    String reply = inquiry.get("reply");
    String status = inquiry.get("status");
    String createdAt = inquiry.get("created_at");
    String repliedAt = inquiry.get("replied_at");

    boolean isDone = "완료".equals(status) && reply != null && !reply.trim().isEmpty();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>문의 답변 보기 | Camp Mate</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">

    <style>
        .inquiry-detail-page {
            background: #f7f8f6;
            min-height: calc(100vh - 80px);
            padding: 50px 0 80px;
        }

        .inquiry-detail-wrap {
            max-width: 920px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .detail-head {
            margin-bottom: 28px;
        }

        .detail-eyebrow {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 999px;
            background: #e7f1ec;
            color: #1b4d3e;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .detail-title {
            font-size: 32px;
            font-weight: 800;
            color: #1f2d28;
            margin: 0 0 8px;
        }

        .detail-desc {
            color: #6c757d;
            margin: 0;
            font-size: 15px;
        }

        .detail-card {
            background: #fff;
            border-radius: 22px;
            border: 1px solid #edf0ed;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
            overflow: hidden;
        }

        .detail-card-header {
            padding: 26px 30px;
            border-bottom: 1px solid #eef0ee;
        }

        .title-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
        }

        .inquiry-title {
            font-size: 24px;
            font-weight: 800;
            color: #1f2d28;
            margin: 0;
            line-height: 1.4;
        }

        .status-badge {
            flex-shrink: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 84px;
            padding: 7px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 800;
        }

        .status-done {
            background: #e7f1ec;
            color: #1b4d3e;
        }

        .status-wait {
            background: #fff3cd;
            color: #9a6700;
        }

        .meta-line {
            margin-top: 14px;
            color: #868e96;
            font-size: 14px;
        }

        .detail-section {
            padding: 30px;
            border-bottom: 1px solid #f1f3f5;
        }

        .detail-section:last-child {
            border-bottom: none;
        }

        .section-label {
            display: block;
            font-size: 14px;
            font-weight: 800;
            color: #1b4d3e;
            margin-bottom: 14px;
        }

        .content-box {
            background: #f8f9fa;
            border: 1px solid #edf0ed;
            border-radius: 16px;
            padding: 20px;
            color: #343a40;
            font-size: 15px;
            line-height: 1.8;
            white-space: pre-wrap;
            word-break: keep-all;
        }

        .reply-box {
            background: #f4faf6;
            border: 1px solid #d8e5df;
            border-radius: 16px;
            padding: 20px;
            color: #2d3436;
            font-size: 15px;
            line-height: 1.8;
            white-space: pre-wrap;
            word-break: keep-all;
        }

        .wait-box {
            background: #fffaf0;
            border: 1px solid #ffe8a3;
            border-radius: 16px;
            padding: 22px;
            color: #7a5a00;
            font-size: 15px;
            line-height: 1.7;
        }

        .reply-date {
            margin-top: 14px;
            color: #868e96;
            font-size: 13px;
        }

        .btn-area {
            margin-top: 24px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

        .page-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 20px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 800;
            text-decoration: none;
            transition: 0.2s;
        }

        .btn-primary-custom {
            background: #1b4d3e;
            color: #fff;
            border: 1px solid #1b4d3e;
        }

        .btn-primary-custom:hover {
            background: #14382d;
            color: #fff;
        }

        .btn-light-custom {
            background: #fff;
            color: #1b4d3e;
            border: 1px solid #d8e5df;
        }

        .btn-light-custom:hover {
            background: #e7f1ec;
            color: #1b4d3e;
        }

        @media (max-width: 768px) {
            .title-row {
                flex-direction: column;
            }

            .detail-title {
                font-size: 26px;
            }

            .inquiry-title {
                font-size: 21px;
            }

            .detail-card-header,
            .detail-section {
                padding: 22px;
            }

            .btn-area {
                flex-direction: column;
            }

            .page-btn {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<main class="inquiry-detail-page">
    <div class="inquiry-detail-wrap">

        <section class="detail-head">
            <div class="detail-eyebrow">My Support</div>
            <h1 class="detail-title">문의 답변 보기</h1>
            <p class="detail-desc">접수한 문의 내용과 관리자 답변을 확인할 수 있습니다.</p>
        </section>

        <section class="detail-card">
            <div class="detail-card-header">
                <div class="title-row">
                    <h2 class="inquiry-title"><%= title %></h2>

                    <span class="status-badge <%= isDone ? "status-done" : "status-wait" %>">
                        <%= isDone ? "답변완료" : "답변대기" %>
                    </span>
                </div>

                <div class="meta-line">
                    문의일: <%= createdAt != null ? createdAt : "-" %>
                </div>
            </div>

            <div class="detail-section">
                <span class="section-label">문의 내용</span>
                <div class="content-box"><%= content %></div>
            </div>

            <div class="detail-section">
                <span class="section-label">관리자 답변</span>

                <% if (isDone) { %>
                    <div class="reply-box"><%= reply %></div>
                    <div class="reply-date">
                        답변일: <%= repliedAt != null ? repliedAt : "-" %>
                    </div>
                <% } else { %>
                    <div class="wait-box">
                        아직 답변이 등록되지 않았습니다.<br>
                        문의량에 따라 답변까지 시간이 걸릴 수 있습니다.
                    </div>
                <% } %>
            </div>
        </section>

        <div class="btn-area">
            <a href="<%=ctx%>/mypage/myInquiryList.jsp" class="page-btn btn-light-custom">목록으로 돌아가기</a>
            <a href="<%=ctx%>/cs.jsp" class="page-btn btn-primary-custom">새 문의 작성</a>
        </div>

    </div>
</main>

<jsp:include page="/include/footer.jsp" />

</body>
</html>
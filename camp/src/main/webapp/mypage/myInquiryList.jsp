<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String userName = (String) session.getAttribute("userName");

    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    InquiryDAO dao = new InquiryDAO();
    List<Map<String, String>> list = dao.getInquiryByUserId(userId);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>내 문의 내역 | Camp Mate</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">

    <style>
        .my-inquiry-page {
            background: #f7f8f6;
            min-height: calc(100vh - 80px);
            padding: 50px 0 80px;
        }

        .my-inquiry-wrap {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .my-page-head {
            margin-bottom: 28px;
        }

        .my-page-eyebrow {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 999px;
            background: #e7f1ec;
            color: #1b4d3e;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .my-page-title {
            font-size: 32px;
            font-weight: 800;
            color: #1f2d28;
            margin: 0 0 8px;
        }

        .my-page-desc {
            color: #6c757d;
            margin: 0;
            font-size: 15px;
        }

        .inquiry-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
            border: 1px solid #edf0ed;
            overflow: hidden;
        }

        .inquiry-card-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 22px 26px;
            border-bottom: 1px solid #eef0ee;
        }

        .inquiry-card-title {
            font-size: 19px;
            font-weight: 800;
            color: #1f2d28;
            margin: 0;
        }

        .inquiry-count {
            font-size: 14px;
            color: #6c757d;
        }

        .inquiry-count strong {
            color: #1b4d3e;
        }

        .inquiry-table {
            width: 100%;
            border-collapse: collapse;
        }

        .inquiry-table th {
            background: #fafafa;
            color: #495057;
            font-size: 14px;
            font-weight: 700;
            padding: 15px 14px;
            border-bottom: 1px solid #eef0ee;
            text-align: center;
        }

        .inquiry-table td {
            padding: 16px 14px;
            border-bottom: 1px solid #f1f3f5;
            font-size: 14px;
            color: #343a40;
            text-align: center;
            vertical-align: middle;
        }

        .inquiry-table tr:last-child td {
            border-bottom: none;
        }

        .text-left {
            text-align: left !important;
        }

        .inquiry-title-link {
            color: #2d3436;
            text-decoration: none;
            font-weight: 700;
        }

        .inquiry-title-link:hover {
            color: #1b4d3e;
            text-decoration: underline;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 64px;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
        }

        .status-done {
            background: #e7f1ec;
            color: #1b4d3e;
        }

        .status-wait {
            background: #fff3cd;
            color: #9a6700;
        }

        .detail-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 15px;
            border-radius: 999px;
            background: #1b4d3e;
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            transition: 0.2s;
        }

        .detail-btn:hover {
            background: #14382d;
            color: #fff;
        }

        .empty-box {
            padding: 70px 20px;
            text-align: center;
            color: #868e96;
        }

        .empty-title {
            font-size: 18px;
            font-weight: 800;
            color: #495057;
            margin-bottom: 8px;
        }

        .empty-desc {
            font-size: 14px;
            margin-bottom: 22px;
        }

        .back-area {
            margin-top: 24px;
            display: flex;
            justify-content: flex-start;
            gap: 10px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 11px 18px;
            border-radius: 999px;
            background: #fff;
            color: #1b4d3e;
            border: 1px solid #d8e5df;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
        }

        .back-btn:hover {
            background: #e7f1ec;
            color: #1b4d3e;
        }

        @media (max-width: 768px) {
            .inquiry-card-top {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }

            .inquiry-table th:nth-child(1),
            .inquiry-table td:nth-child(1),
            .inquiry-table th:nth-child(4),
            .inquiry-table td:nth-child(4) {
                display: none;
            }

            .my-page-title {
                font-size: 26px;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<main class="my-inquiry-page">
    <div class="my-inquiry-wrap">

        <section class="my-page-head">
            <div class="my-page-eyebrow">My Support</div>
            <h1 class="my-page-title">내 문의 내역</h1>
            <p class="my-page-desc">고객센터에 접수한 1:1 문의와 관리자 답변을 확인할 수 있습니다.</p>
        </section>

        <section class="inquiry-card">
            <div class="inquiry-card-top">
                <h2 class="inquiry-card-title">문의 목록</h2>
                <div class="inquiry-count">총 <strong><%= list != null ? list.size() : 0 %></strong>건</div>
            </div>

            <% if (list == null || list.isEmpty()) { %>
                <div class="empty-box">
                    <div class="empty-title">접수한 문의가 없습니다.</div>
                    <div class="empty-desc">고객센터에서 1:1 문의를 남기면 이곳에서 답변 상태를 확인할 수 있습니다.</div>
                    <a href="<%=ctx%>/cs.jsp" class="detail-btn">고객센터로 이동</a>
                </div>
            <% } else { %>
                <table class="inquiry-table">
                    <thead>
                        <tr>
                            <th style="width: 80px;">번호</th>
                            <th>문의 제목</th>
                            <th style="width: 120px;">상태</th>
                            <th style="width: 180px;">문의일</th>
                            <th style="width: 120px;">확인</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (Map<String, String> item : list) {
                            String id = item.get("id");
                            String title = item.get("title");
                            String status = item.get("status");
                            String createdAt = item.get("created_at");

                            boolean isDone = "완료".equals(status);
                    %>
                        <tr>
                            <td><%= id %></td>
                            <td class="text-left">
                                <a href="<%=ctx%>/mypage/myInquiryDetail.jsp?id=<%=id%>" class="inquiry-title-link">
                                    <%= title %>
                                </a>
                            </td>
                            <td>
                                <span class="status-badge <%= isDone ? "status-done" : "status-wait" %>">
                                    <%= isDone ? "답변완료" : "답변대기" %>
                                </span>
                            </td>
                            <td><%= createdAt != null ? createdAt : "-" %></td>
                            <td>
                                <a href="<%=ctx%>/mypage/myInquiryDetail.jsp?id=<%=id%>" class="detail-btn">답변보기</a>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>

        <div class="back-area">
            <a href="<%=ctx%>/mypage/user_mypage.jsp" class="back-btn">마이페이지로 돌아가기</a>
            <a href="<%=ctx%>/cs.jsp" class="back-btn">새 문의 작성</a>
        </div>

    </div>
</main>

<jsp:include page="/include/footer.jsp" />

</body>
</html>
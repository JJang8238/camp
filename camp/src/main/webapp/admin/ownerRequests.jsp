<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";

    String result = request.getParameter("result");
    String error = request.getParameter("error");

    UserDAO dao = new UserDAO();
    List<User> ownerList = dao.getPendingOwnerList(keyword);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 사업자 승인 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    <style>
        .owner-req-table td,
        .owner-req-table th {
            vertical-align: middle;
            white-space: nowrap;
        }

        .owner-req-table .owner-col-camp,
        .owner-req-table .owner-col-bizname,
        .owner-req-table .owner-col-bizno,
        .owner-req-table .owner-col-email {
            white-space: normal;
            min-width: 150px;
        }

        .owner-req-actions {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-width: 160px;
        }

        .owner-req-info {
            line-height: 1.45;
        }

        .owner-req-info strong {
            display: inline-block;
            min-width: 72px;
            color: #1b4d3e;
        }

        .admin-result-msg {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 14px;
            font-size: 14px;
            font-weight: 700;
        }

        .admin-result-success {
            background: #eef8f2;
            color: #1b6b46;
            border: 1px solid #cfe9d8;
        }

        .admin-result-error {
            background: #fff3f3;
            color: #c03d3d;
            border: 1px solid #f2cccc;
        }

        .admin-btn-danger {
            background: #fff1f1;
            border: 1px solid #e38a8a;
            color: #c53d3d;
        }

        .admin-btn-danger:hover {
            background: #ffe3e3;
        }
    </style>
</head>

<body class="admin-body">

    <jsp:include page="/admin/include/adminHeader.jsp" />
    <div class="admin-layout">
        <jsp:include page="/admin/include/adminSidebar.jsp" />

        <main class="admin-content">
            <div class="admin-page-head">
                <div>
                    <h1 class="admin-page-title">사업자 승인 관리</h1>
                    <p class="admin-page-desc">사업자등록번호와 사업자 정보를 확인한 뒤 승인 또는 반려할 수 있습니다.</p>
                </div>
            </div>

            <% if ("approved".equals(result)) { %>
                <div class="admin-result-msg admin-result-success">사업자 계정을 승인했습니다.</div>
            <% } else if ("rejected".equals(result)) { %>
                <div class="admin-result-msg admin-result-success">사업자 계정을 반려했습니다.</div>
            <% } else if ("fail".equals(error)) { %>
                <div class="admin-result-msg admin-result-error">처리에 실패했습니다. 다시 시도해주세요.</div>
            <% } else if ("invalid".equals(error)) { %>
                <div class="admin-result-msg admin-result-error">잘못된 요청입니다.</div>
            <% } %>

            <section class="admin-filter-card">
                <form method="get" action="<%=ctx%>/admin/ownerRequests.jsp" class="admin-search-form">
                    <div class="admin-form-row">
                        <div class="admin-form-group" style="flex:1;">
                            <label>검색어</label>
                            <input type="text" name="keyword" value="<%=keyword%>" class="admin-input"
                                   placeholder="아이디, 이름, 이메일, 사업자명, 사업자번호, 캠핑장명 검색">
                        </div>

                        <div class="admin-form-group admin-form-btn-group">
                            <label>&nbsp;</label>
                            <button type="submit" class="admin-btn admin-btn-primary">검색</button>
                        </div>
                    </div>
                </form>
            </section>

            <section class="admin-table-wrap">
                <div class="admin-table-top">
                    <div class="admin-table-title">승인 대기 사업자 목록</div>
                    <div class="admin-table-count">총 <strong><%= ownerList.size() %></strong>명</div>
                </div>

                <div class="admin-table-scroll">
                    <table class="admin-table owner-req-table">
                        <thead>
                            <tr>
                                <th>번호</th>
                                <th>아이디</th>
                                <th>이름</th>
                                <th class="owner-col-email">이메일</th>
                                <th class="owner-col-camp">캠핑장명</th>
                                <th class="owner-col-bizname">사업자명</th>
                                <th class="owner-col-bizno">사업자등록번호</th>
                                <th>상태</th>
                                <th>가입일</th>
                                <th>처리</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (ownerList == null || ownerList.isEmpty()) { %>
                            <tr>
                                <td colspan="10">
                                    <div class="admin-empty-inline">승인 대기 중인 사업자 계정이 없습니다.</div>
                                </td>
                            </tr>
                        <% } else {
                            for (User u : ownerList) {
                        %>
                            <tr>
                                <td><%= u.getId() %></td>
                                <td><%= u.getUserId() %></td>
                                <td><%= u.getName() %></td>
                                <td class="owner-col-email"><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                                <td class="owner-col-camp"><%= u.getCampName() != null && !u.getCampName().trim().isEmpty() ? u.getCampName() : "-" %></td>
                                <td class="owner-col-bizname"><%= u.getBusinessName() != null && !u.getBusinessName().trim().isEmpty() ? u.getBusinessName() : "-" %></td>
                                <td class="owner-col-bizno"><strong><%= u.getBusinessNumber() != null && !u.getBusinessNumber().trim().isEmpty() ? u.getBusinessNumber() : "-" %></strong></td>
                                <td>
                                    <span class="admin-badge admin-badge-warn"><%= u.getStatus() %></span>
                                </td>
                                <td><%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0, 10) : "-" %></td>
                                <td>
                                    <div class="owner-req-actions">
                                        <form method="post" action="<%=ctx%>/admin/ownerRequestAction.jsp" style="display:inline;">
                                            <input type="hidden" name="id" value="<%=u.getId()%>">
                                            <input type="hidden" name="actionType" value="approve">
                                            <button type="submit" class="admin-btn admin-btn-sm admin-btn-primary"
                                                    onclick="return confirm('이 사업자 계정을 승인하시겠습니까?');">승인</button>
                                        </form>

                                        <form method="post" action="<%=ctx%>/admin/ownerRequestAction.jsp" style="display:inline;">
                                            <input type="hidden" name="id" value="<%=u.getId()%>">
                                            <input type="hidden" name="actionType" value="reject">
                                            <button type="submit" class="admin-btn admin-btn-sm admin-btn-danger"
                                                    onclick="return confirm('이 사업자 계정을 반려하시겠습니까?');">반려</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 상태 필터 (all / pending / approved / rejected)
    String statusFilter = request.getParameter("status");
    if (statusFilter == null || statusFilter.trim().isEmpty()) statusFilter = "all";

    // 처리 결과 메시지
    String result = request.getParameter("result");

    // 신고 목록 조회
    List<Map<String, Object>> reportList = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.id, ")
           .append("       COALESCE(u.username, r.reporter_username, '탈퇴회원') AS reporter_name, ")
           .append("       r.target_type, r.target_id, r.reason, r.status, r.created_at, ")
           .append("       (SELECT COUNT(*) FROM reports r2 ")
           .append("        WHERE r2.target_type = r.target_type AND r2.target_id = r.target_id) AS report_count ")
           .append("FROM reports r ")
           .append("LEFT JOIN users u ON r.reporter_id = u.id ");

        if (!"all".equals(statusFilter)) {
            sql.append("WHERE r.status = ? ");
        }

        sql.append("ORDER BY r.id DESC");

        pstmt = conn.prepareStatement(sql.toString());
        if (!"all".equals(statusFilter)) {
            pstmt.setString(1, statusFilter);
        }

        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",           rs.getInt("id"));
            row.put("reporter",     rs.getString("reporter_name"));
            row.put("targetType",   rs.getString("target_type"));
            row.put("targetId",     rs.getInt("target_id"));
            row.put("reason",       rs.getString("reason"));
            row.put("status",       rs.getString("status"));
            row.put("createdAt",    rs.getString("created_at"));
            row.put("reportCount",  rs.getInt("report_count"));
            reportList.add(row);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs    != null) rs.close();    } catch (Exception ignore) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn  != null) conn.close();  } catch (Exception ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 신고 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>

<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">

        <div class="admin-page-header">
            <div>
                <h1 class="admin-page-title">🚨 신고 관리</h1>
                <p class="admin-page-desc">누적 신고 5건 이상 시 자동 숨김 처리됩니다.</p>
            </div>
        </div>

        <%-- 처리 결과 알림 --%>
        <% if ("approved".equals(result)) { %>
            <div class="admin-alert admin-alert-success">✅ 신고가 승인되었습니다. 대상 콘텐츠가 숨김 처리되었습니다.</div>
        <% } else if ("rejected".equals(result)) { %>
            <div class="admin-alert admin-alert-info">❎ 신고가 기각되었습니다.</div>
        <% } else if ("unhidden".equals(result)) { %>
            <div class="admin-alert admin-alert-success">🔓 숨김이 해제되었습니다.</div>
        <% } else if ("error".equals(result)) { %>
            <div class="admin-alert admin-alert-danger">⚠️ 처리 중 오류가 발생했습니다.</div>
        <% } %>

        <%-- 상태 필터 탭 --%>
        <div style="display:flex; gap:8px; margin-bottom:20px;">
            <a href="<%=ctx%>/admin/reports.jsp?status=all"
               class="admin-btn <%="all".equals(statusFilter) ? "admin-btn-primary" : "admin-btn-outline"%>">
                전체
            </a>
            <a href="<%=ctx%>/admin/reports.jsp?status=pending"
               class="admin-btn <%="pending".equals(statusFilter) ? "admin-btn-primary" : "admin-btn-outline"%>">
                대기중
            </a>
            <a href="<%=ctx%>/admin/reports.jsp?status=approved"
               class="admin-btn <%="approved".equals(statusFilter) ? "admin-btn-primary" : "admin-btn-outline"%>">
                승인됨
            </a>
            <a href="<%=ctx%>/admin/reports.jsp?status=rejected"
               class="admin-btn <%="rejected".equals(statusFilter) ? "admin-btn-primary" : "admin-btn-outline"%>">
                기각됨
            </a>
        </div>

        <div class="admin-card">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>신고자</th>
                        <th>대상 유형</th>
                        <th>대상 ID</th>
                        <th>사유</th>
                        <th>누적 신고</th>
                        <th>상태</th>
                        <th>신고일</th>
                        <th>처리</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (reportList.isEmpty()) {
                %>
                    <tr>
                        <td colspan="9" class="admin-empty">신고 내역이 없습니다.</td>
                    </tr>
                <%
                    } else {
                        for (Map<String, Object> r : reportList) {
                            String rStatus     = (String) r.get("status");
                            int    reportCount = (Integer) r.get("reportCount");
                            int    rId         = (Integer) r.get("id");
                            int    targetId    = (Integer) r.get("targetId");
                            String targetType  = (String) r.get("targetType");

                            String statusLabel = "pending".equals(rStatus)  ? "대기중"
                                               : "approved".equals(rStatus) ? "승인"
                                               : "rejected".equals(rStatus) ? "기각"
                                               : rStatus;
                            String statusBadge = "pending".equals(rStatus)  ? "badge-yellow"
                                               : "approved".equals(rStatus) ? "badge-green"
                                               : "badge-red";

                            String countBadge  = (reportCount >= 5) ? "badge-red" : "badge-pink";
                %>
                    <tr>
                        <td><%= rId %></td>
                        <td><%= r.get("reporter") %></td>
                        <td>
                            <span class="admin-badge badge-blue"><%= r.get("targetType") %></span>
                        </td>
                        <td><%= targetId %></td>
                        <td><%= r.get("reason") %></td>
                        <td>
                            <span class="admin-badge <%= countBadge %>"><%= reportCount %>건</span>
                        </td>
                        <td>
                            <span class="admin-badge <%= statusBadge %>"><%= statusLabel %></span>
                        </td>
                        <td><%= r.get("createdAt") %></td>
                        <td class="admin-actions" style="white-space:nowrap;">
                            <%-- 대기중: 승인 / 기각 버튼 --%>
                            <% if ("pending".equals(rStatus)) { %>
                                <a href="<%=ctx%>/admin/reportAction.jsp?id=<%=rId%>&action=approve&targetType=<%=targetType%>&targetId=<%=targetId%>"
                                   class="admin-btn admin-btn-sm admin-btn-danger"
                                   onclick="return confirm('신고를 승인하고 콘텐츠를 숨김 처리하시겠습니까?');">
                                    승인(숨김)
                                </a>
                                <a href="<%=ctx%>/admin/reportAction.jsp?id=<%=rId%>&action=reject"
                                   class="admin-btn admin-btn-sm admin-btn-outline"
                                   onclick="return confirm('이 신고를 기각하시겠습니까?');">
                                    기각
                                </a>

                            <%-- 승인됨: 숨김해제 버튼 --%>
                            <% } else if ("approved".equals(rStatus)) { %>
                                <a href="<%=ctx%>/admin/reportAction.jsp?id=<%=rId%>&action=unhide&targetType=<%=targetType%>&targetId=<%=targetId%>"
                                   class="admin-btn admin-btn-sm"
                                   style="background:#e67e22;color:#fff;border:none;"
                                   onclick="return confirm('숨김을 해제하고 콘텐츠를 복원하시겠습니까?');">
                                    숨김해제
                                </a>

                            <%-- 기각됨: 재검토(승인) 버튼 --%>
                            <% } else { %>
                                <a href="<%=ctx%>/admin/reportAction.jsp?id=<%=rId%>&action=approve&targetType=<%=targetType%>&targetId=<%=targetId%>"
                                   class="admin-btn admin-btn-sm admin-btn-danger"
                                   onclick="return confirm('신고를 승인하고 콘텐츠를 숨김 처리하시겠습니까?');">
                                    재검토(승인)
                                </a>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>

    </main>
</div>

<style>
.admin-alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
    font-weight: 500;
}
.admin-alert-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
.admin-alert-info    { background: #dbeafe; color: #1e40af; border: 1px solid #93c5fd; }
.admin-alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
.badge-blue   { background: #dbeafe; color: #1e40af; }
.badge-yellow { background: #fef9c3; color: #854d0e; }
.badge-green  { background: #d1fae5; color: #065f46; }
.badge-red    { background: #fee2e2; color: #991b1b; }
.badge-pink   { background: #fce7f3; color: #9d174d; }
</style>

</body>
</html>

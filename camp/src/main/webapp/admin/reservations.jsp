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

    String statusFilter = request.getParameter("status");
    String keyword = request.getParameter("keyword");
    if (statusFilter == null) statusFilter = "all";
    if (keyword == null) keyword = "";
    keyword = keyword.trim();

    String result = request.getParameter("result");

    List<Map<String, Object>> reservationList = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.id, r.reserve_date, r.people_count, r.amount, r.status, r.order_id, r.created_at, ")
           .append("       u.username, u.name AS user_name, ")
           .append("       c.name AS camp_name ")
           .append("FROM reservations r ")
           .append("LEFT JOIN users u ON r.user_id = u.id ")
           .append("LEFT JOIN camps c ON r.camp_id = c.id ")
           .append("WHERE 1=1 ");

        if ("reserved".equals(statusFilter)) {
            sql.append("AND LOWER(r.status) IN ('reserved', 'pending') ");
        } else if (!"all".equals(statusFilter)) {
            sql.append("AND LOWER(r.status) = ? ");
        }
        if (!keyword.isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.name LIKE ? OR c.name LIKE ?) ");
        }
        sql.append("ORDER BY r.id DESC");

        pstmt = conn.prepareStatement(sql.toString());
        int idx = 1;
        if (!"all".equals(statusFilter) && !"reserved".equals(statusFilter)) {
            pstmt.setString(idx++, statusFilter);
        }
        if (!keyword.isEmpty()) {
            String kw = "%" + keyword + "%";
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
            pstmt.setString(idx++, kw);
        }

        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",          rs.getInt("id"));
            row.put("username",    rs.getString("username"));
            row.put("userName",    rs.getString("user_name"));
            row.put("campName",    rs.getString("camp_name"));
            row.put("reserveDate", rs.getString("reserve_date"));
            row.put("peopleCount", rs.getInt("people_count"));
            row.put("amount",      rs.getLong("amount"));
            row.put("status",      rs.getString("status"));
            row.put("orderId",     rs.getString("order_id"));
            row.put("createdAt",   rs.getString("created_at"));
            reservationList.add(row);
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
    <title>캠프 메이트 관리자 | 예약 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>
<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">

        <div class="admin-page-head">
            <div>
                <h1 class="admin-page-title">예약 관리</h1>
                <p class="admin-page-desc">전체 예약 내역을 조회하고 관리합니다.</p>
            </div>
        </div>

        <!-- 처리 결과 알림 -->
        <% if ("cancelled".equals(result)) { %>
            <div class="admin-alert admin-alert-success">✅ 예약이 취소 처리되었습니다.</div>
        <% } else if ("error".equals(result)) { %>
            <div class="admin-alert admin-alert-danger">⚠️ 처리 중 오류가 발생했습니다.</div>
        <% } %>

        <!-- 검색 -->
        <section class="admin-filter-card">
            <form method="get" action="<%=ctx%>/admin/reservations.jsp" class="admin-search-form">
                <div class="admin-form-row">
                    <div class="admin-form-group">
                        <label>검색어</label>
                        <input type="text" name="keyword" value="<%=keyword%>" class="admin-input"
                               placeholder="아이디, 이름, 캠핑장명 검색">
                    </div>
                    <div class="admin-form-group">
                        <label>예약 상태</label>
                        <select name="status" class="admin-select">
                            <option value="all"       <%= "all".equals(statusFilter)       ? "selected" : "" %>>전체</option>
                            <option value="reserved"  <%= "reserved".equals(statusFilter)  ? "selected" : "" %>>승인 대기</option>
                            <option value="approved"  <%= "approved".equals(statusFilter)  ? "selected" : "" %>>예약 확정</option>
                            <option value="cancelled" <%= "cancelled".equals(statusFilter) ? "selected" : "" %>>취소됨</option>
                            <option value="completed" <%= "completed".equals(statusFilter) ? "selected" : "" %>>이용 완료</option>
                        </select>
                    </div>
                    <div class="admin-form-group admin-form-btn-group">
                        <label>&nbsp;</label>
                        <button type="submit" class="admin-btn admin-btn-primary">검색</button>
                    </div>
                </div>
            </form>
        </section>

        <!-- 상태 탭 -->
        <div style="display:flex; gap:8px; margin-bottom:20px;">
            <a href="<%=ctx%>/admin/reservations.jsp?status=all"
               class="admin-btn <% if("all".equals(statusFilter)) out.print("admin-btn-primary"); else out.print("admin-btn-outline"); %>">전체</a>
            <a href="<%=ctx%>/admin/reservations.jsp?status=reserved"
               class="admin-btn <% if("reserved".equals(statusFilter)) out.print("admin-btn-primary"); else out.print("admin-btn-outline"); %>">승인 대기</a>
            <a href="<%=ctx%>/admin/reservations.jsp?status=approved"
               class="admin-btn <% if("approved".equals(statusFilter)) out.print("admin-btn-primary"); else out.print("admin-btn-outline"); %>">예약 확정</a>
            <a href="<%=ctx%>/admin/reservations.jsp?status=cancelled"
               class="admin-btn <% if("cancelled".equals(statusFilter)) out.print("admin-btn-primary"); else out.print("admin-btn-outline"); %>">취소됨</a>
            <a href="<%=ctx%>/admin/reservations.jsp?status=completed"
               class="admin-btn <% if("completed".equals(statusFilter)) out.print("admin-btn-primary"); else out.print("admin-btn-outline"); %>">이용 완료</a>
        </div>

        <!-- 테이블 -->
        <section class="admin-table-wrap">
            <div class="admin-table-top">
                <div class="admin-table-title">예약 목록</div>
                <div class="admin-table-count">총 <strong><%= reservationList.size() %></strong>건</div>
            </div>

            <div class="admin-table-scroll">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <th>예약자</th>
                            <th>캠핑장</th>
                            <th>예약일</th>
                            <th>인원</th>
                            <th>결제금액</th>
                            <th>상태</th>
                            <th>주문번호</th>
                            <th>등록일</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (reservationList.isEmpty()) { %>
                        <tr>
                            <td colspan="10">
                                <div class="admin-empty-inline">조회된 예약이 없습니다.</div>
                            </td>
                        </tr>
                    <% } else {
                        for (Map<String, Object> r : reservationList) {
                            String st = String.valueOf(r.get("status"));
                            String statusLabel = ("reserved".equals(st) || "pending".equalsIgnoreCase(st)) ? "승인 대기"
                                               : "approved".equals(st)  ? "예약 확정"
                                               : "cancelled".equals(st) ? "취소됨"
                                               : "completed".equals(st) ? "이용 완료"
                                               : st;
                            String statusBadge = ("reserved".equals(st) || "pending".equalsIgnoreCase(st)) ? "admin-badge-warn"
                                               : "approved".equals(st)  ? "admin-badge-active"
                                               : "cancelled".equals(st) ? "admin-badge-danger"
                                               : "completed".equals(st) ? "admin-badge-role"
                                               : "";
                            String orderId = r.get("orderId") != null ? String.valueOf(r.get("orderId")) : "-";
                            String campName = r.get("campName") != null ? String.valueOf(r.get("campName")) : "-";
                            long amount = r.get("amount") != null ? (Long) r.get("amount") : 0L;
                    %>
                        <tr>
                            <td><%= r.get("id") %></td>
                            <td>
                                <%= r.get("userName") %><br>
                                <span style="font-size:12px; color:#888;">(<%= r.get("username") %>)</span>
                            </td>
                            <td><%= campName %></td>
                            <td><%= r.get("reserveDate") %></td>
                            <td><%= r.get("peopleCount") %>명</td>
                            <td><%= String.format("%,d", amount) %>원</td>
                            <td>
                                <span class="admin-badge <%= statusBadge %>"><%= statusLabel %></span>
                            </td>
                            <td style="font-size:12px; color:#888;"><%= orderId %></td>
                            <td style="font-size:12px;">
                                <%= r.get("createdAt") != null ? String.valueOf(r.get("createdAt")).substring(0, 10) : "-" %>
                            </td>
                            <td>
                                <% if (!"cancelled".equalsIgnoreCase(st) && !"completed".equalsIgnoreCase(st)) { %>
                                <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=r.get("id")%>&action=cancel"
                                   class="admin-btn admin-btn-sm admin-btn-danger"
                                   onclick="return confirm('이 예약을 취소 처리하시겠습니까?\n취소 후 되돌릴 수 없습니다.');">
                                    취소 처리
                                </a>
                                <% } else { %>
                                <span style="font-size:12px; color:#bbb;">-</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </section>

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
.admin-alert-danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
</style>

</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.OwnerReservationDAO, dto.ReservationDTO, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;

    // 승인/거절 POST 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        String action  = request.getParameter("action");
        String ridStr  = request.getParameter("reservationId");

        if (ridStr != null && !ridStr.isEmpty()) {
            try {
                int rid = Integer.parseInt(ridStr);
                boolean ok;

                if ("approve".equals(action)) {
                    ok = OwnerReservationDAO.approveReservation(rid, userId);
                    successMsg = ok ? "예약을 승인했습니다." : "승인 처리에 실패했습니다.";
                } else if ("reject".equals(action)) {
                    ok = OwnerReservationDAO.rejectReservation(rid, userId);
                    successMsg = ok ? "예약을 거절했습니다." : "거절 처리에 실패했습니다.";
                }
            } catch (NumberFormatException e) {
                errorMsg = "잘못된 요청입니다.";
            }
        }
    }

    // 상태 필터
    String filterStatus = request.getParameter("status");
    if (filterStatus == null || filterStatus.isEmpty()) filterStatus = "all";

    List<ReservationDTO> reservations =
        OwnerReservationDAO.getReservationsByOwnerIdAndStatus(userId, filterStatus);

    // 건수 집계
    int totalCount    = OwnerReservationDAO.getReservationsByOwnerId(userId).size();
    int waitingCount  = OwnerReservationDAO.countByStatus(userId, "reserved");
    int approvedCount = OwnerReservationDAO.countByStatus(userId, "approved");
    int rejectedCount = OwnerReservationDAO.countByStatus(userId, "rejected");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>예약 현황 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .page-wrapper {
            max-width: 1000px;
            margin: 60px auto;
            padding: 0 20px 80px;
        }

        /* 상단 */
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

        /* 알림 */
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

        /* 통계 카드 */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 18px 20px;
            border: 1.5px solid #e9ecef;
            text-align: center;
            cursor: pointer;
            text-decoration: none;
            transition: box-shadow 0.2s, border-color 0.2s;
            display: block;
        }
        .stat-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.08); text-decoration: none; }
        .stat-card.active { border-color: #1a3a5c; }
        .stat-label { font-size: 12px; color: #aaa; margin-bottom: 6px; }
        .stat-value { font-size: 26px; font-weight: 800; color: #1a1a1a; }
        .stat-card.active .stat-value { color: #1a3a5c; }

        /* 탭 필터 */
        .tab-bar {
            display: flex;
            gap: 6px;
            margin-bottom: 18px;
        }
        .tab-btn {
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            border: 1.5px solid #dee2e6;
            background: white;
            color: #666;
            text-decoration: none;
            transition: all 0.2s;
        }
        .tab-btn:hover { border-color: #1a3a5c; color: #1a3a5c; text-decoration: none; }
        .tab-btn.active { background: #1a3a5c; color: white; border-color: #1a3a5c; }

        /* 예약 카드 */
        .reservation-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: box-shadow 0.2s;
        }
        .reservation-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.07); }

        .card-main { flex: 1; }

        .card-camp-name {
            font-size: 15px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 6px;
        }

        .card-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            font-size: 13px;
            color: #777;
        }

        .card-amount {
            text-align: right;
            min-width: 110px;
        }
        .amount-label { font-size: 11px; color: #aaa; margin-bottom: 2px; }
        .amount-value { font-size: 17px; font-weight: 700; color: #1a3a5c; }

        /* 상태 배지 */
        .badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-reserved  { background: #fff8e1; color: #f57c00; }
        .badge-approved  { background: #e8f5e9; color: #2d5a27; }
        .badge-rejected  { background: #fdecea; color: #c0392b; }
        .badge-cancelled { background: #f1f3f5; color: #777; }

        /* 승인/거절 버튼 */
        .action-buttons { display: flex; flex-direction: column; gap: 7px; flex-shrink: 0; }

        .btn-approve {
            padding: 7px 18px;
            background: #2d5a27;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-approve:hover { background: #1e3d1b; }

        .btn-reject {
            padding: 7px 18px;
            background: white;
            color: #e74c3c;
            border: 1.5px solid #e74c3c;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-reject:hover { background: #e74c3c; color: white; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 60px 20px;
            color: #bbb;
        }
        .empty-box .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty-box p { font-size: 14px; margin: 0; }

        @media (max-width: 680px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .reservation-card { flex-wrap: wrap; }
            .action-buttons { flex-direction: row; }
            .card-amount { text-align: left; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/owner_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">📅 예약 현황</h2>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <%-- 통계 카드 --%>
    <div class="stats-grid">
        <a href="?status=all" class="stat-card <%= "all".equals(filterStatus) ? "active" : "" %>">
            <div class="stat-label">전체 예약</div>
            <div class="stat-value"><%=totalCount%></div>
        </a>
        <a href="?status=reserved" class="stat-card <%= "reserved".equals(filterStatus) ? "active" : "" %>">
            <div class="stat-label">⏳ 대기</div>
            <div class="stat-value"><%=waitingCount%></div>
        </a>
        <a href="?status=approved" class="stat-card <%= "approved".equals(filterStatus) ? "active" : "" %>">
            <div class="stat-label">✅ 승인</div>
            <div class="stat-value"><%=approvedCount%></div>
        </a>
        <a href="?status=rejected" class="stat-card <%= "rejected".equals(filterStatus) ? "active" : "" %>">
            <div class="stat-label">❌ 거절</div>
            <div class="stat-value"><%=rejectedCount%></div>
        </a>
    </div>

    <%-- 탭 필터 --%>
    <div class="tab-bar">
        <a href="?status=all"      class="tab-btn <%= "all".equals(filterStatus)      ? "active" : "" %>">전체</a>
        <a href="?status=reserved" class="tab-btn <%= "reserved".equals(filterStatus) ? "active" : "" %>">⏳ 대기</a>
        <a href="?status=approved" class="tab-btn <%= "approved".equals(filterStatus) ? "active" : "" %>">✅ 승인</a>
        <a href="?status=rejected" class="tab-btn <%= "rejected".equals(filterStatus) ? "active" : "" %>">❌ 거절</a>
    </div>

    <%-- 예약 목록 --%>
    <% if (reservations == null || reservations.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">📭</div>
        <p>해당 조건의 예약 내역이 없습니다.</p>
    </div>

    <% } else {
        for (ReservationDTO r : reservations) {
            String status = r.getStatus() != null ? r.getStatus() : "";
            String badgeClass, badgeLabel;

            switch (status.toLowerCase()) {
                case "pending":
                case "reserved":  badgeClass = "badge-reserved";  badgeLabel = "⏳ 대기중";   break;
                case "approved":  badgeClass = "badge-approved";  badgeLabel = "✅ 승인됨";   break;
                case "rejected":  badgeClass = "badge-rejected";  badgeLabel = "❌ 거절됨";   break;
                case "cancelled": badgeClass = "badge-cancelled"; badgeLabel = "🚫 취소됨";   break;
                default:          badgeClass = "badge-cancelled"; badgeLabel = status;
            }

            String amountStr = r.getAmount() > 0
                ? String.format("%,d원", r.getAmount()) : "-";
            String guestName = r.getGuestName() != null ? r.getGuestName() : "예약자";
    %>
    <div class="reservation-card">
        <div class="card-main">
            <div class="card-camp-name">🏕️ <%=r.getCampName()%></div>
            <div class="card-meta">
                <span>👤 <%=guestName%> 님</span>
                <span>📅 <%=r.getReserveDate()%></span>
                <span>👥 <%=r.getPeopleCount()%>명</span>
                <% if (r.getOrderId() != null && !r.getOrderId().isEmpty()) { %>
                <span>🔖 <%=r.getOrderId()%></span>
                <% } %>
                <span class="badge <%=badgeClass%>"><%=badgeLabel%></span>
            </div>
        </div>

        <div class="card-amount">
            <div class="amount-label">결제금액</div>
            <div class="amount-value"><%=amountStr%></div>
        </div>

        <%-- 대기 상태일 때만 승인/거절 버튼 표시 --%>
        <% if ("reserved".equalsIgnoreCase(status) || "pending".equalsIgnoreCase(status)) { %>
        <div class="action-buttons">
            <form method="post" action="" style="margin:0;" onsubmit="return confirm('이 예약을 승인할까요?');">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="reservationId" value="<%=r.getId()%>">
                <input type="hidden" name="status" value="<%=filterStatus%>">
                <button type="submit" class="btn-approve">✅ 승인</button>
            </form>
            <form method="post" action="" style="margin:0;" onsubmit="return confirm('이 예약을 거절할까요?');">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="reservationId" value="<%=r.getId()%>">
                <input type="hidden" name="status" value="<%=filterStatus%>">
                <button type="submit" class="btn-reject">❌ 거절</button>
            </form>
        </div>
        <% } %>
    </div>
    <%
        }
    } %>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

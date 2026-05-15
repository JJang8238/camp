<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ReservationDAO, dto.ReservationDTO, java.util.List" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    if (userId == null || !"user".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;
    List<ReservationDTO> reservations = ReservationDAO.getReservationsByUserId(userId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>예약 내역 | Camp Mate</title>

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

        .btn-back:hover {
            border-color: #2d5a27;
            color: #2d5a27;
            text-decoration: none;
        }

        .page-title {
            font-size: 22px;
            font-weight: 700;
            color: #1a1a1a;
            margin: 0;
        }

        .reservation-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 24px 28px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            transition: box-shadow 0.2s, border-color 0.2s;
        }

        .reservation-card:hover {
            box-shadow: 0 6px 20px rgba(0,0,0,0.07);
            border-color: #2d5a27;
        }

        .card-left { flex: 1; }

        .camp-name {
            font-size: 17px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 8px;
        }

        .card-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            font-size: 13px;
            color: #666;
        }

        .card-meta span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .badge-status {
            display: inline-block;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }

        .badge-reserved  { background: #e8f5e9; color: #2d5a27; }
        .badge-cancelled { background: #fdecea; color: #c0392b; }
        .badge-completed { background: #e3f2fd; color: #1565c0; }
        .badge-pending   { background: #fff8e1; color: #f57f17; }
        .badge-paid      { background: #e8f5e9; color: #2d5a27; }
        .badge-default   { background: #f1f3f5; color: #555; }

        .card-amount {
            text-align: right;
            min-width: 100px;
        }

        .amount-label {
            font-size: 11px;
            color: #aaa;
            margin-bottom: 2px;
        }

        .amount-value {
            font-size: 18px;
            font-weight: 700;
            color: #2d5a27;
        }

        .empty-box {
            text-align: center;
            padding: 80px 20px;
            color: #aaa;
        }

        .empty-box .empty-icon {
            font-size: 52px;
            margin-bottom: 16px;
        }

        .empty-box p {
            font-size: 15px;
            margin: 0 0 20px;
        }

        .btn-go-camp {
            display: inline-block;
            padding: 10px 24px;
            background: #2d5a27;
            color: white;
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s;
        }

        .btn-go-camp:hover {
            background: #1e3d1b;
            color: white;
            text-decoration: none;
        }

        .summary-bar {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 12px;
            padding: 16px 24px;
            margin-bottom: 24px;
            display: flex;
            gap: 32px;
            font-size: 13px;
            color: #555;
        }

        .summary-bar strong {
            color: #2d5a27;
            font-size: 15px;
        }

        @media (max-width: 600px) {
            .reservation-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .card-amount {
                text-align: left;
            }

            .summary-bar {
                flex-wrap: wrap;
                gap: 12px;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/user_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">📋 예약 내역</h2>
    </div>

    <%
        int totalCount = (reservations != null) ? reservations.size() : 0;

        long reservedCount = 0;
        long cancelledCount = 0;

        if (reservations != null) {
            reservedCount = reservations.stream()
                    .filter(r -> {
                        String s = r.getStatus();
                        return "reserved".equalsIgnoreCase(s)
                            || "approved".equalsIgnoreCase(s)
                            || "paid".equalsIgnoreCase(s)
                            || "pending".equalsIgnoreCase(s);
                    })
                    .count();

            cancelledCount = reservations.stream()
                    .filter(r -> "cancelled".equalsIgnoreCase(r.getStatus()))
                    .count();
        }
    %>

    <% if (totalCount > 0) { %>
        <div class="summary-bar">
            <span>전체 <strong><%=totalCount%></strong>건</span>
            <span>예약중 <strong><%=reservedCount%></strong>건</span>
            <span>취소 <strong><%=cancelledCount%></strong>건</span>
        </div>
    <% } %>

    <% if (reservations == null || reservations.isEmpty()) { %>

        <div class="empty-box">
            <div class="empty-icon">🏕️</div>
            <p>아직 예약 내역이 없어요</p>
            <a href="<%=ctx%>/campList" class="btn-go-camp">캠핑장 둘러보기</a>
        </div>

    <% } else {
        for (ReservationDTO r : reservations) {
            String status = r.getStatus() != null ? r.getStatus() : "";

            String badgeClass;
            String badgeLabel;

            switch (status.toLowerCase()) {
                case "reserved":
                case "approved":
                    badgeClass = "badge-reserved";
                    badgeLabel = "✅ 예약 완료";
                    break;

                case "paid":
                    badgeClass = "badge-paid";
                    badgeLabel = "✅ 결제 완료";
                    break;

                case "pending":
                    badgeClass = "badge-pending";
                    badgeLabel = "⏳ 예약 대기";
                    break;

                case "cancelled":
                    badgeClass = "badge-cancelled";
                    badgeLabel = "❌ 취소됨";
                    break;

                case "completed":
                    badgeClass = "badge-completed";
                    badgeLabel = "🏁 이용 완료";
                    break;

                default:
                    badgeClass = "badge-default";
                    badgeLabel = status.isEmpty() ? "상태 없음" : status;
            }

            String campName = r.getCampName() != null ? r.getCampName() : "캠핑장 정보 없음";

            String amountStr = r.getAmount() > 0
                    ? String.format("%,d원", r.getAmount())
                    : "결제 정보 없음";

            String checkIn = r.getCheckIn() != null ? r.getCheckIn() : "";
            String checkOut = r.getCheckOut() != null ? r.getCheckOut() : "";
            String reserveDate = r.getReserveDate() != null ? r.getReserveDate() : "";
    %>

        <div class="reservation-card">
            <div class="card-left">
                <div class="camp-name">⛺ <%=campName%></div>

                <div class="card-meta">
                    <% if (!checkIn.isEmpty() && !checkOut.isEmpty()) { %>
                        <span>📅 <%=checkIn%> ~ <%=checkOut%></span>
                    <% } else { %>
                        <span>📅 <%=reserveDate%></span>
                    <% } %>

                    <span>👥 <%=r.getPeopleCount()%>명</span>

                    <% if (r.getOrderId() != null && !r.getOrderId().isEmpty()) { %>
                        <span>🔖 주문번호: <%=r.getOrderId()%></span>
                    <% } %>
                </div>
            </div>

            <div style="display:flex; flex-direction:column; align-items:flex-end; gap:10px;">
                <span class="badge-status <%=badgeClass%>"><%=badgeLabel%></span>

                <div class="card-amount">
                    <div class="amount-label">결제금액</div>
                    <div class="amount-value"><%=amountStr%></div>
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
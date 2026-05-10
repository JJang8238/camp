<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.OwnerReservationDAO, dto.ReservationDTO, java.util.*, java.time.*" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 전체 예약 목록
    List<ReservationDTO> all = OwnerReservationDAO.getReservationsByOwnerId(userId);

    // 이번 달 기준
    LocalDate now = LocalDate.now();
    String thisMonth = now.getYear() + "-" + String.format("%02d", now.getMonthValue());

    // 통계 계산
    int totalCount    = 0;
    int approvedCount = 0;
    int pendingCount  = 0;
    long totalRevenue = 0;
    long monthRevenue = 0;
    int  monthCount   = 0;

    // 월별 매출 집계 (최근 6개월)
    Map<String, Long> monthlyRevenue = new LinkedHashMap<>();
    Map<String, Integer> monthlyCount = new LinkedHashMap<>();

    // 최근 6개월 키 미리 세팅
    for (int i = 5; i >= 0; i--) {
        LocalDate d = now.minusMonths(i);
        String key = d.getYear() + "-" + String.format("%02d", d.getMonthValue());
        monthlyRevenue.put(key, 0L);
        monthlyCount.put(key, 0);
    }

    // 캠핑장별 예약 수
    Map<String, Integer> campReservCount = new LinkedHashMap<>();

    for (ReservationDTO r : all) {
        totalCount++;
        String status = r.getStatus() != null ? r.getStatus().toLowerCase() : "";

        if ("approved".equals(status) || "reserved".equals(status)) {
            approvedCount++;
            totalRevenue += r.getAmount();

            // 월별 집계
            String rMonth = r.getReserveDate() != null && r.getReserveDate().length() >= 7
                ? r.getReserveDate().substring(0, 7) : "";

            if (monthlyRevenue.containsKey(rMonth)) {
                monthlyRevenue.put(rMonth, monthlyRevenue.get(rMonth) + r.getAmount());
                monthlyCount.put(rMonth, monthlyCount.get(rMonth) + 1);
            }

            if (rMonth.equals(thisMonth)) {
                monthRevenue += r.getAmount();
                monthCount++;
            }
        }
        if ("reserved".equals(status)) pendingCount++;

        // 캠핑장별
        String campName = r.getCampName() != null ? r.getCampName() : "미확인";
        campReservCount.merge(campName, 1, Integer::sum);
    }

    // 월별 최대값 (차트 비율용)
    long maxMonthRevenue = monthlyRevenue.values().stream().mapToLong(v -> v).max().orElse(1L);
    if (maxMonthRevenue == 0) maxMonthRevenue = 1;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>매출 통계 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .page-wrapper {
            max-width: 960px;
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

        /* 상단 통계 카드 */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }
        .stat-card {
            background: white;
            border-radius: 14px;
            padding: 20px;
            border: 1.5px solid #e9ecef;
            text-align: center;
        }
        .stat-label { font-size: 12px; color: #aaa; margin-bottom: 8px; }
        .stat-value { font-size: 24px; font-weight: 800; color: #1a3a5c; }
        .stat-sub { font-size: 11px; color: #bbb; margin-top: 4px; }

        /* 섹션 */
        .section {
            background: white;
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
            padding: 24px 28px;
            margin-bottom: 20px;
        }
        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: #1a1a1a;
            margin: 0 0 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f3f5;
        }

        /* 막대 차트 */
        .bar-chart {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            height: 160px;
            padding-bottom: 8px;
        }
        .bar-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            height: 100%;
            justify-content: flex-end;
        }
        .bar-amount {
            font-size: 10px;
            color: #888;
            text-align: center;
            white-space: nowrap;
        }
        .bar-fill {
            width: 100%;
            background: linear-gradient(180deg, #2e6da4, #1a3a5c);
            border-radius: 6px 6px 0 0;
            min-height: 4px;
            transition: height 0.3s;
        }
        .bar-label {
            font-size: 11px;
            color: #888;
            text-align: center;
            margin-top: 6px;
        }

        /* 캠핑장별 테이블 */
        .camp-table {
            width: 100%;
            border-collapse: collapse;
        }
        .camp-table th {
            font-size: 12px;
            color: #aaa;
            font-weight: 600;
            padding: 8px 12px;
            text-align: left;
            border-bottom: 1px solid #f1f3f5;
        }
        .camp-table td {
            font-size: 14px;
            color: #333;
            padding: 12px 12px;
            border-bottom: 1px solid #f9f9f9;
        }
        .camp-table tr:last-child td { border-bottom: none; }

        /* 최근 예약 */
        .reserv-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 13px;
        }
        .reserv-item:last-child { border-bottom: none; }
        .reserv-camp { font-weight: 600; color: #1a1a1a; }
        .reserv-meta { color: #888; font-size: 12px; margin-top: 3px; }
        .reserv-amount { font-weight: 700; color: #1a3a5c; }

        .badge-r {
            display: inline-block;
            padding: 2px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 600;
        }
        .badge-reserved  { background: #fff8e1; color: #f57c00; }
        .badge-approved  { background: #e8f5e9; color: #2d5a27; }
        .badge-rejected  { background: #fdecea; color: #c0392b; }
        .badge-cancelled { background: #f1f3f5; color: #777; }

        .empty-msg { color: #bbb; font-size: 14px; text-align: center; padding: 30px 0; }

        @media (max-width: 680px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .bar-chart { gap: 6px; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/owner_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">📊 매출 통계</h2>
    </div>

    <%-- 상단 요약 카드 --%>
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label">전체 예약</div>
            <div class="stat-value"><%=totalCount%></div>
            <div class="stat-sub">건</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">⏳ 대기중</div>
            <div class="stat-value"><%=pendingCount%></div>
            <div class="stat-sub">건</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">이번 달 예약</div>
            <div class="stat-value"><%=monthCount%></div>
            <div class="stat-sub"><%=thisMonth%></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">이번 달 매출</div>
            <div class="stat-value"><%=String.format("%,d", monthRevenue)%></div>
            <div class="stat-sub">원</div>
        </div>
    </div>

    <%-- 월별 매출 차트 --%>
    <div class="section">
        <div class="section-title">📅 월별 매출 (최근 6개월)</div>
        <% if (totalRevenue == 0) { %>
            <div class="empty-msg">아직 매출 데이터가 없습니다.</div>
        <% } else { %>
        <div class="bar-chart">
            <%
                for (Map.Entry<String, Long> entry : monthlyRevenue.entrySet()) {
                    String month = entry.getKey();
                    long revenue = entry.getValue();
                    int heightPct = (int)(revenue * 100 / maxMonthRevenue);
                    if (heightPct < 2 && revenue > 0) heightPct = 2;
                    String shortMonth = month.substring(5); // MM 부분만
                    String amountStr = revenue > 0 ? String.format("%,d", revenue/10000) + "만" : "-";
            %>
            <div class="bar-item">
                <div class="bar-amount"><%=amountStr%></div>
                <div class="bar-fill" style="height: <%=heightPct%>%;"></div>
                <div class="bar-label"><%=shortMonth%>월</div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <%-- 캠핑장별 예약 현황 --%>
    <div class="section">
        <div class="section-title">🏕️ 캠핑장별 예약 현황</div>
        <% if (campReservCount.isEmpty()) { %>
            <div class="empty-msg">예약 데이터가 없습니다.</div>
        <% } else { %>
        <table class="camp-table">
            <thead>
                <tr>
                    <th>캠핑장명</th>
                    <th>예약 건수</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map.Entry<String, Integer> entry : campReservCount.entrySet()) {
                %>
                <tr>
                    <td>⛺ <%=entry.getKey()%></td>
                    <td><strong><%=entry.getValue()%></strong>건</td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <%-- 최근 예약 5건 --%>
    <div class="section">
        <div class="section-title">🕐 최근 예약 내역</div>
        <% if (all.isEmpty()) { %>
            <div class="empty-msg">예약 내역이 없습니다.</div>
        <% } else {
            int showCount = Math.min(all.size(), 5);
            for (int i = 0; i < showCount; i++) {
                ReservationDTO r = all.get(i);
                String status = r.getStatus() != null ? r.getStatus().toLowerCase() : "";
                String badgeClass, badgeLabel;
                switch (status) {
                    case "reserved":  badgeClass = "badge-reserved";  badgeLabel = "⏳ 대기"; break;
                    case "approved":  badgeClass = "badge-approved";  badgeLabel = "✅ 승인"; break;
                    case "rejected":  badgeClass = "badge-rejected";  badgeLabel = "❌ 거절"; break;
                    case "cancelled": badgeClass = "badge-cancelled"; badgeLabel = "🚫 취소"; break;
                    default:          badgeClass = "badge-cancelled"; badgeLabel = status;
                }
        %>
        <div class="reserv-item">
            <div>
                <div class="reserv-camp">🏕️ <%=r.getCampName()%></div>
                <div class="reserv-meta">
                    👤 <%=r.getGuestName() != null ? r.getGuestName() : "-"%> ·
                    📅 <%=r.getReserveDate()%> ·
                    👥 <%=r.getPeopleCount()%>명
                    <span class="badge-r <%=badgeClass%>" style="margin-left:6px;"><%=badgeLabel%></span>
                </div>
            </div>
            <div class="reserv-amount">
                <%=r.getAmount() > 0 ? String.format("%,d원", r.getAmount()) : "-"%>
            </div>
        </div>
        <% } } %>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.ReservationDAO, dto.ReservationDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 필터 파라미터
    String statusFilter = request.getParameter("status");
    String keyword      = request.getParameter("keyword");
    String sortBy       = request.getParameter("sort");
    if (statusFilter == null) statusFilter = "all";
    if (keyword == null)      keyword = "";
    if (sortBy == null)       sortBy = "id";
    keyword = keyword.trim();

    // 페이징
    int pageSize = 15;
    int currentPage = 1;
    try { currentPage = Integer.parseInt(request.getParameter("page")); if (currentPage < 1) currentPage = 1; }
    catch (Exception ignored) {}

    // 결과 메시지
    String result = request.getParameter("result");

    // 데이터 조회
    Map<String, Object> stats     = ReservationDAO.getStats();
    List<Map<String, Object>> monthly  = ReservationDAO.getMonthlyRevenue();
    List<Map<String, Object>> topCamps = ReservationDAO.getTopCamps();
    List<ReservationDTO> reservationList =
        ReservationDAO.getAllReservations(keyword, statusFilter, sortBy, currentPage, pageSize);
    int totalCount = ReservationDAO.getTotalCount(keyword, statusFilter);
    int totalPage  = (int) Math.ceil((double) totalCount / pageSize);
    if (totalPage < 1) totalPage = 1;

    // 통계 값 꺼내기
    long totalRevenue = stats.get("totalRevenue") != null ? ((Number)stats.get("totalRevenue")).longValue() : 0L;
    long monthRevenue = stats.get("monthRevenue") != null ? ((Number)stats.get("monthRevenue")).longValue() : 0L;
    int  totalRes     = stats.get("total")    != null ? ((Number)stats.get("total")).intValue()    : 0;
    int  waitingRes   = stats.get("waiting")  != null ? ((Number)stats.get("waiting")).intValue()  : 0;
    int  approvedRes  = stats.get("approved") != null ? ((Number)stats.get("approved")).intValue() : 0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>예약 관리 | 캠프 메이트 관리자</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    <style>
        /* ── 통계 카드 ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }

        .stat-card {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 22px;
        }
        .stat-label {
            font-size: 12px;
            font-weight: 600;
            color: #aaa;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .stat-value {
            font-size: 26px;
            font-weight: 800;
            color: #1a1a1a;
            line-height: 1;
        }
        .stat-sub {
            font-size: 12px;
            color: #aaa;
            margin-top: 6px;
        }
        .stat-card.green  { border-left: 4px solid #2d5a27; }
        .stat-card.orange { border-left: 4px solid #f57f17; }
        .stat-card.blue   { border-left: 4px solid #1565c0; }
        .stat-card.purple { border-left: 4px solid #6d28d9; }

        /* ── 차트 영역 ── */
        .charts-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 900px) { .charts-grid { grid-template-columns: 1fr; } }

        .chart-card {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 22px;
        }
        .chart-card h3 {
            font-size: 14px;
            font-weight: 700;
            color: #555;
            margin: 0 0 16px;
        }

        /* 막대 차트 (CSS only) */
        .bar-chart { display: flex; align-items: flex-end; gap: 8px; height: 120px; }
        .bar-wrap { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; height: 100%; justify-content: flex-end; }
        .bar {
            width: 100%;
            background: #c8e6c9;
            border-radius: 4px 4px 0 0;
            min-height: 4px;
            transition: background 0.2s;
            position: relative;
        }
        .bar:hover { background: #2d5a27; }
        .bar-label { font-size: 10px; color: #aaa; text-align: center; white-space: nowrap; }
        .bar-val   { font-size: 10px; color: #555; font-weight: 600; }

        /* TOP 캠핑장 */
        .top-camp-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 13px;
        }
        .top-camp-row:last-child { border-bottom: none; }
        .top-camp-rank {
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: #e8f5e9;
            color: #2d5a27;
            font-weight: 800;
            font-size: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .top-camp-name { flex: 1; font-weight: 600; color: #1a1a1a; }
        .top-camp-cnt  { color: #2d5a27; font-weight: 700; }
        .top-camp-rev  { color: #aaa; font-size: 12px; }

        /* ── 알림 ── */
        .alert-box {
            padding: 12px 18px;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 14px;
            font-weight: 500;
        }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
        .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        /* ── 상태 탭 ── */
        .tab-bar {
            display: flex;
            gap: 6px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .tab-link {
            padding: 7px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            border: 1.5px solid #dee2e6;
            color: #555;
            background: #fff;
            transition: all 0.15s;
        }
        .tab-link:hover, .tab-link.active {
            background: #2d5a27;
            color: #fff;
            border-color: #2d5a27;
            text-decoration: none;
        }

        /* ── 페이징 ── */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 6px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .page-btn {
            padding: 6px 14px;
            border-radius: 8px;
            border: 1.5px solid #dee2e6;
            font-size: 13px;
            color: #555;
            text-decoration: none;
            transition: all 0.15s;
        }
        .page-btn:hover, .page-btn.active {
            background: #2d5a27;
            color: #fff;
            border-color: #2d5a27;
            text-decoration: none;
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
                <h1 class="admin-page-title">예약 관리</h1>
                <p class="admin-page-desc">전체 예약 내역을 조회하고 승인/거절/취소 처리를 합니다.</p>
            </div>
        </div>

        <!-- 처리 결과 알림 -->
        <% if ("approve".equals(result)) { %>
            <div class="alert-box alert-success">✅ 예약이 승인되었습니다.</div>
        <% } else if ("reject".equals(result)) { %>
            <div class="alert-box alert-success">🚫 예약이 거절되었습니다.</div>
        <% } else if ("cancel".equals(result)) { %>
            <div class="alert-box alert-success">❌ 예약이 취소 처리되었습니다.</div>
        <% } else if ("complete".equals(result)) { %>
            <div class="alert-box alert-success">🎉 이용 완료 처리되었습니다.</div>
        <% } else if ("error".equals(result)) { %>
            <div class="alert-box alert-error">⚠️ 처리 중 오류가 발생했습니다.</div>
        <% } %>

        <!-- ✅ 매출 통계 카드 -->
        <div class="stats-grid">
            <div class="stat-card green">
                <div class="stat-label">전체 매출</div>
                <div class="stat-value"><%= String.format("%,d", totalRevenue / 10000) %>만</div>
                <div class="stat-sub"><%= String.format("%,d", totalRevenue) %>원</div>
            </div>
            <div class="stat-card purple">
                <div class="stat-label">이번 달 매출</div>
                <div class="stat-value"><%= String.format("%,d", monthRevenue / 10000) %>만</div>
                <div class="stat-sub"><%= String.format("%,d", monthRevenue) %>원</div>
            </div>
            <div class="stat-card orange">
                <div class="stat-label">승인 대기</div>
                <div class="stat-value"><%= waitingRes %></div>
                <div class="stat-sub">즉시 처리 필요</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-label">전체 예약</div>
                <div class="stat-value"><%= totalRes %></div>
                <div class="stat-sub">확정 <%= approvedRes %>건 포함</div>
            </div>
        </div>

        <!-- ✅ 차트 영역 -->
        <div class="charts-grid">

            <!-- 월별 매출 막대 차트 -->
            <div class="chart-card">
                <h3>📊 월별 매출 (최근 6개월)</h3>
                <div class="bar-chart" id="barChart">
                    <%
                        // 최대값 계산
                        long maxRev = 1L;
                        for (Map<String, Object> m : monthly) {
                            long rev = ((Number)m.get("revenue")).longValue();
                            if (rev > maxRev) maxRev = rev;
                        }
                        if (monthly.isEmpty()) {
                    %>
                        <p style="color:#aaa; font-size:13px; margin:auto;">데이터 없음</p>
                    <%  } else {
                            for (Map<String, Object> m : monthly) {
                                long rev = ((Number)m.get("revenue")).longValue();
                                int cnt  = ((Number)m.get("cnt")).intValue();
                                int barH = (int)(((double)rev / maxRev) * 100);
                                String mon = String.valueOf(m.get("month"));
                                String monLabel = mon.length() >= 7 ? mon.substring(5) + "월" : mon;
                    %>
                        <div class="bar-wrap">
                            <span class="bar-val"><%= cnt %>건</span>
                            <div class="bar" style="height:<%=barH%>%;"
                                 title="<%=mon%>: <%=String.format("%,d",rev)%>원 / <%=cnt%>건"></div>
                            <span class="bar-label"><%= monLabel %></span>
                        </div>
                    <%      }
                        }
                    %>
                </div>
            </div>

            <!-- TOP 캠핑장 -->
            <div class="chart-card">
                <h3>🏕️ 예약 TOP 캠핑장</h3>
                <%
                    if (topCamps.isEmpty()) {
                %>
                    <p style="color:#aaa; font-size:13px;">데이터 없음</p>
                <%  } else {
                        int rank = 1;
                        for (Map<String, Object> tc : topCamps) {
                            long rev = ((Number)tc.get("revenue")).longValue();
                            int cnt  = ((Number)tc.get("cnt")).intValue();
                %>
                    <div class="top-camp-row">
                        <div class="top-camp-rank"><%= rank++ %></div>
                        <div class="top-camp-name"><%= tc.get("campName") %></div>
                        <div class="top-camp-cnt"><%= cnt %>건</div>
                        <div class="top-camp-rev"><%= String.format("%,d", rev/10000) %>만</div>
                    </div>
                <%      }
                    }
                %>
            </div>
        </div>

        <!-- 검색 -->
        <section class="admin-filter-card">
            <form method="get" action="<%=ctx%>/admin/reservations.jsp" class="admin-search-form">
                <div class="admin-form-row">
                    <div class="admin-form-group">
                        <label>검색어</label>
                        <input type="text" name="keyword" value="<%=keyword%>" class="admin-input"
                               placeholder="아이디, 이름, 캠핑장명, 주문번호">
                    </div>
                    <div class="admin-form-group">
                        <label>정렬</label>
                        <select name="sort" class="admin-select">
                            <option value="id"      <%= "id".equals(sortBy)      ? "selected" : "" %>>최신 등록순</option>
                            <option value="checkIn" <%= "checkIn".equals(sortBy) ? "selected" : "" %>>체크인 순</option>
                            <option value="amount"  <%= "amount".equals(sortBy)  ? "selected" : "" %>>결제금액 순</option>
                        </select>
                    </div>
                    <input type="hidden" name="status" value="<%=statusFilter%>">
                    <div class="admin-form-group admin-form-btn-group">
                        <label>&nbsp;</label>
                        <button type="submit" class="admin-btn admin-btn-primary">검색</button>
                    </div>
                </div>
            </form>
        </section>

        <!-- 상태 탭 -->
        <div class="tab-bar">
            <%
                String[][] tabs = {
                    {"all","전체"},{"reserved","승인 대기"},{"approved","예약 확정"},
                    {"cancelled","취소됨"},{"completed","이용 완료"}
                };
                for (String[] tab : tabs) {
                    String tabActive = tab[0].equals(statusFilter) ? " active" : "";
            %>
                <a href="<%=ctx%>/admin/reservations.jsp?status=<%=tab[0]%>&keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&sort=<%=sortBy%>"
                   class="tab-link<%=tabActive%>"><%=tab[1]%></a>
            <% } %>
        </div>

        <!-- 예약 테이블 -->
        <section class="admin-table-wrap">
            <div class="admin-table-top">
                <div class="admin-table-title">예약 목록</div>
                <div class="admin-table-count">총 <strong><%= totalCount %></strong>건 (<%=currentPage%>/<%=totalPage%>페이지)</div>
            </div>

            <div class="admin-table-scroll">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <th>예약자</th>
                            <th>캠핑장</th>
                            <th>체크인</th>
                            <th>체크아웃</th>
                            <th>인원</th>
                            <th>결제금액</th>
                            <th>상태</th>
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
                        for (ReservationDTO r : reservationList) {
                            String st = r.getStatus() != null ? r.getStatus() : "";
                            String statusLabel = "reserved".equals(st) || "pending".equals(st) ? "승인 대기"
                                               : "approved".equals(st)  ? "예약 확정"
                                               : "rejected".equals(st)  ? "거절됨"
                                               : "cancelled".equals(st) ? "취소됨"
                                               : "completed".equals(st) ? "이용 완료"
                                               : st;
                            String statusBadge = "reserved".equals(st) || "pending".equals(st) ? "admin-badge-warn"
                                               : "approved".equals(st)  ? "admin-badge-active"
                                               : "rejected".equals(st)  ? "admin-badge-danger"
                                               : "cancelled".equals(st) ? "admin-badge-danger"
                                               : "completed".equals(st) ? "admin-badge-role"
                                               : "";
                            String checkInStr  = r.getCheckIn()  != null && !r.getCheckIn().isEmpty()  ? r.getCheckIn()  : (r.getReserveDate() != null ? r.getReserveDate() : "-");
                            String checkOutStr = r.getCheckOut() != null && !r.getCheckOut().isEmpty() ? r.getCheckOut() : "-";
                            boolean isWaiting  = "reserved".equals(st) || "pending".equals(st);
                            boolean canAct     = !"cancelled".equals(st) && !"completed".equals(st) && !"rejected".equals(st);
                    %>
                        <tr style="<%= isWaiting ? "background:#fffde7;" : "" %>">
                            <td>
                                <a href="<%=ctx%>/admin/reservationDetail.jsp?id=<%=r.getId()%>"
                                   style="color:#2d5a27; font-weight:700; text-decoration:none;">
                                    #<%= r.getId() %>
                                </a>
                            </td>
                            <td>
                                <%= r.getGuestName() != null ? r.getGuestName() : "-" %>
                            </td>
                            <td><%= r.getCampName() != null ? r.getCampName() : "-" %></td>
                            <td><%= checkInStr %></td>
                            <td><%= checkOutStr %></td>
                            <td><%= r.getPeopleCount() %>명</td>
                            <td><%= r.getAmount() > 0 ? String.format("%,d", r.getAmount()) + "원" : "-" %></td>
                            <td>
                                <span class="admin-badge <%=statusBadge%>"><%=statusLabel%></span>
                            </td>
                            <td style="font-size:12px; color:#888;">
                                <%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 10) : "-" %>
                            </td>
                            <td>
                                <div style="display:flex; gap:4px; flex-wrap:wrap;">
                                    <!-- 상세 보기 -->
                                    <a href="<%=ctx%>/admin/reservationDetail.jsp?id=<%=r.getId()%>"
                                       class="admin-btn admin-btn-sm admin-btn-outline">상세</a>

                                    <% if (isWaiting) { %>
                                    <!-- 승인 -->
                                    <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=r.getId()%>&action=approve"
                                       class="admin-btn admin-btn-sm admin-btn-primary"
                                       onclick="return confirm('승인하시겠습니까?')">승인</a>
                                    <!-- 거절 -->
                                    <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=r.getId()%>&action=reject"
                                       class="admin-btn admin-btn-sm admin-btn-danger"
                                       onclick="return confirm('거절하시겠습니까?')">거절</a>
                                    <% } else if (canAct) { %>
                                    <!-- 취소 -->
                                    <a href="<%=ctx%>/admin/reservationAction.jsp?id=<%=r.getId()%>&action=cancel"
                                       class="admin-btn admin-btn-sm admin-btn-danger"
                                       onclick="return confirm('취소 처리하시겠습니까?')">취소</a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- 페이징 -->
        <% if (totalPage > 1) { %>
        <div class="pagination">
            <% if (currentPage > 1) { %>
                <a class="page-btn"
                   href="?status=<%=statusFilter%>&keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&sort=<%=sortBy%>&page=<%=currentPage-1%>">이전</a>
            <% }
               int startP = Math.max(1, currentPage - 2);
               int endP   = Math.min(totalPage, currentPage + 2);
               for (int i = startP; i <= endP; i++) {
            %>
                <a class="page-btn<%= i == currentPage ? " active" : "" %>"
                   href="?status=<%=statusFilter%>&keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&sort=<%=sortBy%>&page=<%=i%>"><%=i%></a>
            <% }
               if (currentPage < totalPage) {
            %>
                <a class="page-btn"
                   href="?status=<%=statusFilter%>&keyword=<%=java.net.URLEncoder.encode(keyword,"UTF-8")%>&sort=<%=sortBy%>&page=<%=currentPage+1%>">다음</a>
            <% } %>
        </div>
        <% } %>

    </main>
</div>

</body>
</html>

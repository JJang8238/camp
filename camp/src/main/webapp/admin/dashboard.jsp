<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.DashboardDAO, dao.InquiryDAO" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String  role        = (String)  session.getAttribute("role");

    if (adminUserId == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // ✅ 통계 데이터 전부 조회
    Map<String, Integer>      counts       = DashboardDAO.getCounts();
    Map<String, Long>         revenue      = DashboardDAO.getRevenue();
    Map<String, Integer>      todayStats   = DashboardDAO.getTodayStats();
    List<Map<String, Object>> topCamps     = DashboardDAO.getTopCamps();
    List<Map<String, Object>> topProducts  = DashboardDAO.getTopProducts();
    List<Map<String, Object>> adminLogs    = DashboardDAO.getRecentAdminLogs();
    List<Map<String, Object>> recentRes    = DashboardDAO.getRecentReservations();
    List<Map<String, Object>> weeklyUsers  = DashboardDAO.getWeeklyNewUsers();

    // 기존 문의 (InquiryDAO 유지)
    InquiryDAO inquiryDAO = new InquiryDAO();
    List<Map<String,String>> inquiryList = inquiryDAO.getAllInquiry();

    // 값 꺼내기 (null 안전)
    int  userCount        = counts.getOrDefault("userCount",        0);
    int  campCount        = counts.getOrDefault("campCount",        0);
    int  reservationCount = counts.getOrDefault("reservationCount", 0);
    int  waitingCount     = counts.getOrDefault("waitingCount",     0);
    int  productCount     = counts.getOrDefault("productCount",     0);
    int  reportCount      = counts.getOrDefault("reportCount",      0);
    int  inquiryCount     = counts.getOrDefault("inquiryCount",     0);
    long totalRevenue     = revenue.getOrDefault("totalRevenue",    0L);
    long monthRevenue     = revenue.getOrDefault("monthRevenue",    0L);
    long todayRevenue     = revenue.getOrDefault("todayRevenue",    0L);
    int  newUsers         = todayStats.getOrDefault("newUsers",        0);
    int  newReservations  = todayStats.getOrDefault("newReservations", 0);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 대시보드</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    <style>
        /* ── 오늘 현황 배너 ── */
        .today-banner {
            background: linear-gradient(135deg, #1e3d1b 0%, #2d5a27 100%);
            border-radius: 16px;
            padding: 20px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
            color: #fff;
        }
        .today-banner-left h2 { font-size: 18px; font-weight: 700; margin: 0 0 4px; }
        .today-banner-left p  { font-size: 13px; color: rgba(255,255,255,0.7); margin: 0; }
        .today-chips { display: flex; gap: 10px; flex-wrap: wrap; }
        .today-chip {
            background: rgba(255,255,255,0.15);
            border-radius: 10px;
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            color: #fff;
            white-space: nowrap;
        }
        .today-chip span { font-size: 20px; font-weight: 800; display: block; }

        /* ── 메인 통계 카드 ── */
        .stats-grid-6 {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
            margin-bottom: 22px;
        }
        @media (max-width: 1100px) { .stats-grid-6 { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 600px)  { .stats-grid-6 { grid-template-columns: repeat(2, 1fr); } }

        .dash-stat-card {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 18px 16px;
            position: relative;
            overflow: hidden;
            transition: box-shadow 0.2s;
        }
        .dash-stat-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
        .dash-stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0;
            width: 4px; height: 100%;
            border-radius: 2px;
        }
        .dash-stat-card.green::before  { background: #2d5a27; }
        .dash-stat-card.blue::before   { background: #1565c0; }
        .dash-stat-card.orange::before { background: #f57f17; }
        .dash-stat-card.red::before    { background: #c62828; }
        .dash-stat-card.purple::before { background: #6d28d9; }
        .dash-stat-card.teal::before   { background: #00695c; }

        .dash-stat-label { font-size: 11px; font-weight: 700; color: #aaa; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
        .dash-stat-value { font-size: 28px; font-weight: 800; color: #1a1a1a; line-height: 1; margin-bottom: 6px; }
        .dash-stat-sub   { font-size: 11px; color: #aaa; }
        .dash-stat-badge {
            display: inline-block;
            font-size: 10px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 20px;
            margin-left: 4px;
        }
        .badge-warn   { background: #fff3e0; color: #f57f17; }
        .badge-danger { background: #fdecea; color: #c62828; }
        .dash-stat-link {
            display: block;
            margin-top: 10px;
            font-size: 11px;
            color: #aaa;
            text-decoration: none;
        }
        .dash-stat-link:hover { color: #2d5a27; }

        /* ── 매출 카드 ── */
        .revenue-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 22px;
        }
        @media (max-width: 768px) { .revenue-grid { grid-template-columns: 1fr; } }

        .revenue-card {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 22px;
        }
        .revenue-label { font-size: 12px; font-weight: 700; color: #aaa; text-transform: uppercase; margin-bottom: 8px; }
        .revenue-value { font-size: 24px; font-weight: 800; color: #2d5a27; }
        .revenue-sub   { font-size: 12px; color: #aaa; margin-top: 4px; }

        /* ── 2단 패널 ── */
        .panel-row-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        @media (max-width: 900px) { .panel-row-2 { grid-template-columns: 1fr; } }

        .panel-row-3 {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        @media (max-width: 1100px) { .panel-row-3 { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 700px)  { .panel-row-3 { grid-template-columns: 1fr; } }

        .dash-panel {
            background: #fff;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 20px 22px;
        }
        .dash-panel h3 {
            font-size: 14px;
            font-weight: 700;
            color: #333;
            margin: 0 0 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .dash-panel h3 a {
            font-size: 12px;
            color: #aaa;
            text-decoration: none;
            font-weight: 500;
        }
        .dash-panel h3 a:hover { color: #2d5a27; }

        /* ── 인기 캠핑장 / 상품 ── */
        .rank-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 13px;
        }
        .rank-row:last-child { border-bottom: none; }
        .rank-num {
            width: 24px; height: 24px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 800; flex-shrink: 0;
        }
        .rank-1 { background: #fff3cd; color: #856404; }
        .rank-2 { background: #e9ecef; color: #495057; }
        .rank-3 { background: #fde8d8; color: #7d3c0a; }
        .rank-n { background: #f8f9fa; color: #aaa; }
        .rank-name { flex: 1; font-weight: 600; color: #1a1a1a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .rank-sub  { font-size: 11px; color: #aaa; }
        .rank-cnt  { font-weight: 700; color: #2d5a27; white-space: nowrap; }

        /* ── 최근 예약 ── */
        .res-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 13px;
        }
        .res-row:last-child { border-bottom: none; }
        .res-id { font-size: 11px; color: #aaa; width: 36px; flex-shrink: 0; }
        .res-info { flex: 1; min-width: 0; }
        .res-camp { font-weight: 600; color: #1a1a1a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .res-guest { font-size: 11px; color: #aaa; }
        .res-amount { font-size: 12px; font-weight: 700; color: #2d5a27; white-space: nowrap; }

        /* ── 관리자 로그 ── */
        .log-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 9px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 12px;
        }
        .log-row:last-child { border-bottom: none; }
        .log-icon {
            width: 28px; height: 28px;
            border-radius: 50%;
            background: #f0f8f2;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; flex-shrink: 0;
        }
        .log-content { flex: 1; min-width: 0; }
        .log-action { font-weight: 600; color: #1a1a1a; }
        .log-detail { color: #888; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .log-time   { font-size: 11px; color: #bbb; white-space: nowrap; flex-shrink: 0; }

        /* ── 신규 가입자 미니 차트 ── */
        .mini-bar-chart {
            display: flex;
            align-items: flex-end;
            gap: 6px;
            height: 80px;
            margin-top: 8px;
        }
        .mini-bar-wrap { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 3px; height: 100%; justify-content: flex-end; }
        .mini-bar {
            width: 100%;
            background: #c8e6c9;
            border-radius: 3px 3px 0 0;
            min-height: 3px;
            transition: background 0.2s;
        }
        .mini-bar:hover { background: #2d5a27; }
        .mini-bar-label { font-size: 9px; color: #bbb; }

        /* ── 상태 배지 ── */
        .status-sm {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: 700;
            white-space: nowrap;
        }
        .status-waiting  { background: #fff3e0; color: #f57f17; }
        .status-approved { background: #e8f5e9; color: #2d5a27; }
        .status-cancelled{ background: #fdecea; color: #c62828; }
        .status-completed{ background: #e3f2fd; color: #1565c0; }

        /* ── 빠른 작업 ── */
        .quick-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
        }
        .quick-btn {
            padding: 10px 8px;
            background: #f8f9fa;
            border: 1.5px solid #e9ecef;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 600;
            color: #444;
            text-decoration: none;
            text-align: center;
            transition: all 0.15s;
            display: block;
        }
        .quick-btn:hover {
            background: #e8f5e9;
            border-color: #2d5a27;
            color: #2d5a27;
            text-decoration: none;
        }
        .quick-btn .q-icon { display: block; font-size: 18px; margin-bottom: 3px; }
    </style>
</head>
<body class="admin-body">

<jsp:include page="/admin/include/adminHeader.jsp" />

<div class="admin-layout">
    <jsp:include page="/admin/include/adminSidebar.jsp" />

    <main class="admin-content">

        <div class="admin-page-head">
            <div>
                <h1 class="admin-page-title">대시보드</h1>
                <p class="admin-page-desc">캠프 메이트 운영 현황을 한눈에 확인하세요.</p>
            </div>
        </div>

        <!-- ✅ 오늘 현황 배너 -->
        <div class="today-banner">
            <div class="today-banner-left">
                <h2>오늘의 현황 📊</h2>
                <p>실시간 운영 지표</p>
            </div>
            <div class="today-chips">
                <div class="today-chip">
                    <span><%= newUsers %></span>
                    신규 가입
                </div>
                <div class="today-chip">
                    <span><%= newReservations %></span>
                    신규 예약
                </div>
                <div class="today-chip">
                    <span><%= String.format("%,d", todayRevenue / 10000) %>만</span>
                    오늘 매출
                </div>
                <div class="today-chip">
                    <span><%= waitingCount %></span>
                    승인 대기
                </div>
                <div class="today-chip">
                    <span><%= reportCount + inquiryCount %></span>
                    처리 필요
                </div>
            </div>
        </div>

        <!-- ✅ 핵심 수치 카드 6개 -->
        <div class="stats-grid-6">
            <div class="dash-stat-card green">
                <div class="dash-stat-label">전체 회원</div>
                <div class="dash-stat-value"><%= userCount %></div>
                <div class="dash-stat-sub">오늘 +<%= newUsers %>명</div>
                <a href="<%=ctx%>/admin/users.jsp" class="dash-stat-link">회원 관리 →</a>
            </div>
            <div class="dash-stat-card blue">
                <div class="dash-stat-label">활성 캠핑장</div>
                <div class="dash-stat-value"><%= campCount %></div>
                <div class="dash-stat-sub">등록 캠핑장 수</div>
                <a href="<%=ctx%>/admin/camps.jsp" class="dash-stat-link">캠핑장 관리 →</a>
            </div>
            <div class="dash-stat-card orange">
                <div class="dash-stat-label">전체 예약</div>
                <div class="dash-stat-value">
                    <%= reservationCount %>
                    <% if (waitingCount > 0) { %>
                    <span class="dash-stat-badge badge-warn"><%= waitingCount %> 대기</span>
                    <% } %>
                </div>
                <div class="dash-stat-sub">오늘 +<%= newReservations %>건</div>
                <a href="<%=ctx%>/admin/reservations.jsp" class="dash-stat-link">예약 관리 →</a>
            </div>
            <div class="dash-stat-card teal">
                <div class="dash-stat-label">중고거래 상품</div>
                <div class="dash-stat-value"><%= productCount %></div>
                <div class="dash-stat-sub">판매 중 상품</div>
                <a href="<%=ctx%>/admin/products.jsp" class="dash-stat-link">상품 관리 →</a>
            </div>
            <div class="dash-stat-card red">
                <div class="dash-stat-label">미처리 신고</div>
                <div class="dash-stat-value">
                    <%= reportCount %>
                    <% if (reportCount > 0) { %>
                    <span class="dash-stat-badge badge-danger">처리 필요</span>
                    <% } %>
                </div>
                <div class="dash-stat-sub">즉시 확인 필요</div>
                <a href="<%=ctx%>/admin/reports.jsp" class="dash-stat-link">신고 관리 →</a>
            </div>
            <div class="dash-stat-card purple">
                <div class="dash-stat-label">미처리 문의</div>
                <div class="dash-stat-value">
                    <%= inquiryCount %>
                    <% if (inquiryCount > 0) { %>
                    <span class="dash-stat-badge badge-warn">대기 중</span>
                    <% } %>
                </div>
                <div class="dash-stat-sub">답변 대기 문의</div>
                <a href="<%=ctx%>/admin/inquiry.jsp" class="dash-stat-link">문의 관리 →</a>
            </div>
        </div>

        <!-- ✅ 매출 카드 3개 -->
        <div class="revenue-grid">
            <div class="revenue-card">
                <div class="revenue-label">💰 전체 누적 매출</div>
                <div class="revenue-value"><%= String.format("%,d", totalRevenue) %>원</div>
                <div class="revenue-sub">승인 + 완료 기준</div>
            </div>
            <div class="revenue-card">
                <div class="revenue-label">📅 이번 달 매출</div>
                <div class="revenue-value"><%= String.format("%,d", monthRevenue) %>원</div>
                <div class="revenue-sub"><%= new java.util.Date().getMonth() + 1 %>월 기준</div>
            </div>
            <div class="revenue-card">
                <div class="revenue-label">☀️ 오늘 매출</div>
                <div class="revenue-value"><%= String.format("%,d", todayRevenue) %>원</div>
                <div class="revenue-sub">오늘 승인된 예약 기준</div>
            </div>
        </div>

        <!-- ✅ 인기 캠핑장 + 인기 상품 + 빠른 작업 -->
        <div class="panel-row-3">

            <!-- 인기 캠핑장 TOP 5 -->
            <div class="dash-panel">
                <h3>🏕️ 인기 캠핑장 TOP 5 <a href="<%=ctx%>/admin/camps.jsp">전체보기</a></h3>
                <% if (topCamps.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">데이터 없음</p>
                <% } else {
                    int campRank = 1;
                    for (Map<String, Object> tc : topCamps) {
                        int cnt = ((Number)tc.get("reservationCnt")).intValue();
                        long rev = ((Number)tc.get("totalRevenue")).longValue();
                        String rankCls = campRank == 1 ? "rank-1" : campRank == 2 ? "rank-2" : campRank == 3 ? "rank-3" : "rank-n";
                %>
                    <div class="rank-row">
                        <div class="rank-num <%= rankCls %>"><%= campRank %></div>
                        <div class="rank-name" title="<%= tc.get("name") %>"><%= tc.get("name") %></div>
                        <div style="text-align:right;">
                            <div class="rank-cnt"><%= cnt %>건</div>
                            <div class="rank-sub"><%= String.format("%,d", rev/10000) %>만원</div>
                        </div>
                    </div>
                <%      campRank++;
                    }
                } %>
            </div>

            <!-- 인기 상품 TOP 5 -->
            <div class="dash-panel">
                <h3>🛒 인기 상품 TOP 5 <a href="<%=ctx%>/admin/products.jsp">전체보기</a></h3>
                <% if (topProducts.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">데이터 없음</p>
                <% } else {
                    int prodRank = 1;
                    for (Map<String, Object> tp : topProducts) {
                        int price = ((Number)tp.get("price")).intValue();
                        int cnt   = ((Number)tp.get("purchaseCnt")).intValue();
                        String rankCls = prodRank == 1 ? "rank-1" : prodRank == 2 ? "rank-2" : prodRank == 3 ? "rank-3" : "rank-n";
                %>
                    <div class="rank-row">
                        <div class="rank-num <%= rankCls %>"><%= prodRank %></div>
                        <div class="rank-name" title="<%= tp.get("name") %>"><%= tp.get("name") %></div>
                        <div style="text-align:right;">
                            <div class="rank-cnt"><%= cnt %>건</div>
                            <div class="rank-sub"><%= String.format("%,d", price) %>원</div>
                        </div>
                    </div>
                <%      prodRank++;
                    }
                } %>
            </div>

            <!-- 빠른 작업 -->
            <div class="dash-panel">
                <h3>⚡ 빠른 작업</h3>
                <div class="quick-grid">
                    <a href="<%=ctx%>/admin/reservations.jsp?status=reserved" class="quick-btn">
                        <span class="q-icon">📋</span>예약 승인
                    </a>
                    <a href="<%=ctx%>/admin/reports.jsp" class="quick-btn">
                        <span class="q-icon">🚨</span>신고 처리
                    </a>
                    <a href="<%=ctx%>/admin/inquiry.jsp" class="quick-btn">
                        <span class="q-icon">💬</span>문의 답변
                    </a>
                    <a href="<%=ctx%>/admin/postWrite.jsp?type=news" class="quick-btn">
                        <span class="q-icon">📢</span>소식 작성
                    </a>
                    <a href="<%=ctx%>/admin/postWrite.jsp?type=event" class="quick-btn">
                        <span class="q-icon">🎉</span>이벤트
                    </a>
                    <a href="<%=ctx%>/admin/users.jsp" class="quick-btn">
                        <span class="q-icon">👤</span>회원 관리
                    </a>
                    <a href="<%=ctx%>/admin/camps.jsp" class="quick-btn">
                        <span class="q-icon">🏕️</span>캠핑장
                    </a>
                    <a href="<%=ctx%>/admin/products.jsp" class="quick-btn">
                        <span class="q-icon">🛒</span>상품 관리
                    </a>
                    <a href="<%=ctx%>/admin/posts.jsp" class="quick-btn">
                        <span class="q-icon">📝</span>게시글
                    </a>
                </div>
            </div>
        </div>

        <!-- ✅ 최근 예약 + 최근 관리자 로그 -->
        <div class="panel-row-2">

            <!-- 최근 예약 (대기 우선) -->
            <div class="dash-panel">
                <h3>📅 최근 예약 (대기 우선) <a href="<%=ctx%>/admin/reservations.jsp">전체보기</a></h3>
                <% if (recentRes.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">예약 없음</p>
                <% } else {
                    for (Map<String, Object> rr : recentRes) {
                        String st = String.valueOf(rr.get("status"));
                        String statusLabel = "reserved".equals(st) || "pending".equals(st) ? "승인 대기"
                                           : "approved".equals(st)  ? "예약 확정"
                                           : "cancelled".equals(st) ? "취소됨"
                                           : "completed".equals(st) ? "이용 완료" : st;
                        String statusCls = "reserved".equals(st) || "pending".equals(st) ? "status-waiting"
                                         : "approved".equals(st)  ? "status-approved"
                                         : "cancelled".equals(st) ? "status-cancelled"
                                         : "completed".equals(st) ? "status-completed" : "";
                        int amt = ((Number)rr.get("amount")).intValue();
                %>
                    <div class="res-row">
                        <div class="res-id">#<%= rr.get("id") %></div>
                        <div class="res-info">
                            <div class="res-camp"><%= rr.get("campName") != null ? rr.get("campName") : "-" %></div>
                            <div class="res-guest"><%= rr.get("guestName") != null ? rr.get("guestName") : "-" %> | <%= rr.get("checkIn") != null ? rr.get("checkIn") : "-" %></div>
                        </div>
                        <div style="text-align:right;">
                            <span class="status-sm <%= statusCls %>"><%= statusLabel %></span>
                            <div class="res-amount" style="margin-top:3px;"><%= amt > 0 ? String.format("%,d", amt) + "원" : "-" %></div>
                        </div>
                    </div>
                <% } } %>
            </div>

            <!-- 최근 관리자 로그 -->
            <div class="dash-panel">
                <h3>🔐 최근 관리자 로그</h3>
                <% if (adminLogs.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">로그 없음</p>
                <% } else {
                    int logShown = 0;
                    for (Map<String, Object> log : adminLogs) {
                        if (logShown++ >= 8) break;
                        String action = String.valueOf(log.get("action"));
                        String logIcon = action.contains("approve") ? "✅"
                                       : action.contains("reject")  ? "🚫"
                                       : action.contains("cancel")  ? "❌"
                                       : action.contains("delete")  ? "🗑️"
                                       : action.contains("ban")     ? "🔒"
                                       : action.contains("user")    ? "👤"
                                       : "📋";
                        String adminName = log.get("adminName") != null ? String.valueOf(log.get("adminName")) : "관리자";
                        String detail    = log.get("detail")    != null ? String.valueOf(log.get("detail"))    : "";
                        Object createdAt = log.get("createdAt");
                        String timeStr   = createdAt != null ? createdAt.toString().substring(5, 16) : "";
                %>
                    <div class="log-row">
                        <div class="log-icon"><%= logIcon %></div>
                        <div class="log-content">
                            <div class="log-action"><%= adminName %> · <%= action %></div>
                            <div class="log-detail"><%= detail %></div>
                        </div>
                        <div class="log-time"><%= timeStr %></div>
                    </div>
                <% } } %>
            </div>
        </div>

        <!-- ✅ 신규 가입 미니 차트 + 최근 문의 -->
        <div class="panel-row-2" style="margin-bottom: 0;">

            <!-- 최근 7일 신규 가입 차트 -->
            <div class="dash-panel">
                <h3>👥 최근 7일 신규 가입</h3>
                <%
                    long maxCnt = 1L;
                    for (Map<String, Object> wu : weeklyUsers) {
                        int c = ((Number)wu.get("cnt")).intValue();
                        if (c > maxCnt) maxCnt = c;
                    }
                %>
                <% if (weeklyUsers.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">데이터 없음</p>
                <% } else { %>
                <div class="mini-bar-chart">
                    <% for (Map<String, Object> wu : weeklyUsers) {
                        int c = ((Number)wu.get("cnt")).intValue();
                        int barH = (int)(((double)c / maxCnt) * 100);
                    %>
                    <div class="mini-bar-wrap">
                        <div class="mini-bar" style="height:<%=barH%>%;"
                             title="<%= wu.get("day") %>: <%= c %>명"></div>
                        <div class="mini-bar-label"><%= wu.get("day") %></div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- 최근 문의 -->
            <div class="dash-panel">
                <h3>💬 최근 문의 <a href="<%=ctx%>/admin/inquiry.jsp">전체보기</a></h3>
                <% if (inquiryList.isEmpty()) { %>
                    <p style="color:#bbb; font-size:13px; text-align:center; padding:20px 0;">문의 없음</p>
                <% } else {
                    int shown = 0;
                    for (Map<String,String> inq : inquiryList) {
                        if (shown++ >= 5) break;
                        String inqStatus = inq.get("status");
                        boolean isPending = "대기".equals(inqStatus);
                %>
                    <div style="padding:9px 0; border-bottom:1px solid #f5f5f5; font-size:13px;">
                        <div style="display:flex; align-items:center; gap:6px;">
                            <% if (isPending) { %><span style="width:6px;height:6px;border-radius:50%;background:#f57f17;flex-shrink:0;display:inline-block;"></span><% } %>
                            <strong style="flex:1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><%= inq.get("title") %></strong>
                            <% if (isPending) { %><span style="font-size:10px;background:#fff3e0;color:#f57f17;padding:2px 7px;border-radius:10px;font-weight:700;">대기</span><% } %>
                        </div>
                        <div style="color:#aaa; font-size:11px; margin-top:3px;">
                            <%= inq.get("username") %> | <%= inq.get("created_at") %>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>

    </main>
</div>

</body>
</html>

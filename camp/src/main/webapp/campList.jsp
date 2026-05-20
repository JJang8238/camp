<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*, java.util.LinkedHashMap, java.net.URLEncoder, dto.Product, dao.WishlistDAO" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");

    String checkIn = request.getParameter("checkIn");
    String checkOut = request.getParameter("checkOut");

    if (checkIn == null) checkIn = "";
    if (checkOut == null) checkOut = "";

    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) {
        sort = "recommend";
    }

    String[] selectedTypes = request.getParameterValues("type");
    List<String> typeList = new ArrayList<>();
    if (selectedTypes != null) {
        for (String v : selectedTypes) {
            if (v != null && !v.trim().isEmpty()) {
                typeList.addAll(Arrays.asList(v.split(",")));
            }
        }
    }

    String[] selectedLocs = request.getParameterValues("loc");
    List<String> locList = new ArrayList<>();
    if (selectedLocs != null) {
        for (String v : selectedLocs) {
            if (v != null && !v.trim().isEmpty()) {
                locList.addAll(Arrays.asList(v.split(",")));
            }
        }
    }

    String[] selectedFacilities = request.getParameterValues("facility");
    List<String> facilityList = new ArrayList<>();
    if (selectedFacilities != null) {
        for (String v : selectedFacilities) {
            if (v != null && !v.trim().isEmpty()) {
                facilityList.addAll(Arrays.asList(v.split(",")));
            }
        }
    }

    // ✅ 메인 AI 스타일 파라미터 수신
    String styles = request.getParameter("styles");
    if (styles == null) styles = "";

    // 스타일 → 라벨 매핑 (화면 표시용)
    Map<String, String> styleLabelMap = new LinkedHashMap<>();
    styleLabelMap.put("감성힐링", "🌙 감성 힐링");
    styleLabelMap.put("액티브",   "🏊 액티브");
    styleLabelMap.put("반려동물", "🐾 반려동물과");
    styleLabelMap.put("럭셔리",   "👑 럭셔리");
    styleLabelMap.put("자연탐험", "🏕️ 자연 탐험");
    styleLabelMap.put("가족여행", "👨‍👩‍👧‍👦 가족 여행");
    styleLabelMap.put("로맨틱",   "🌹 로맨틱");
    styleLabelMap.put("당일치기", "☀️ 당일치기");

    // 선택된 스타일 목록
    List<String> styleList = new ArrayList<>();
    if (!styles.isEmpty()) {
        for (String s : styles.split(",")) {
            if (!s.trim().isEmpty()) styleList.add(s.trim());
        }
    }

    List<Product> campList = (List<Product>) request.getAttribute("campList");

    Integer totalCountObj  = (Integer) request.getAttribute("totalCount");
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPageObj   = (Integer) request.getAttribute("totalPage");

    int totalCount  = (totalCountObj  != null) ? totalCountObj  : 0;
    int currentPage = (currentPageObj != null) ? currentPageObj : 1;
    int totalPage   = (totalPageObj   != null) ? totalPageObj   : 1;

    boolean hasDate = !checkIn.isEmpty() && !checkOut.isEmpty();
    boolean hasStyles = !styleList.isEmpty();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>캠프 메이트 | 캠핑장 예약</title>

    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/camp.css">

    <style>
        .filter-group { margin-bottom: 20px; }

        .filter-subtitle {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            display: block;
        }

        .collapsible-content {
            display: none;
            overflow: hidden;
            border-top: 1px solid #eee;
            padding-top: 15px;
            margin-top: 10px;
        }

        .btn-toggle-filter {
            width: 100%;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 14px;
            padding: 10px 12px;
            font-size: 13px;
            font-weight: 700;
            color: #666;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            transition: 0.2s ease;
            margin-bottom: 15px;
        }

        .btn-toggle-filter:hover {
            background-color: #f8f9fa;
            color: var(--main-green);
        }

        .btn-toggle-filter.active {
            background-color: #eef4f1;
            color: var(--main-green);
            border-color: var(--main-green);
        }

        .toggle-icon { transition: transform 0.3s; }

        .btn-toggle-filter.active .toggle-icon {
            transform: rotate(180deg);
        }

        .date-row {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .date-row .filter-group {
            margin-bottom: 0;
            width: 100%;
        }

        .date-row .filter-input[type="date"] {
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
        }

        .filter-input[type="date"] {
            width: 100%;
        }

        /* ✅ 날짜 미선택 시 날짜 필드 강조 스타일 */
        .date-highlight-box {
            background: #fff8f0;
            border: 2px solid #ff6b35;
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 16px;
            animation: pulseBorder 2s infinite;
        }

        .date-highlight-box .date-notice {
            font-size: 12px;
            color: #ff6b35;
            font-weight: 600;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        @keyframes pulseBorder {
            0%, 100% { border-color: #ff6b35; box-shadow: 0 0 0 0 rgba(255,107,53,0.15); }
            50%       { border-color: #ff8c5a; box-shadow: 0 0 0 4px rgba(255,107,53,0.1); }
        }

        /* ✅ 날짜 선택 완료 시 스타일 */
        .date-done-box {
            background: #f0f8f2;
            border: 2px solid var(--main-green);
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 16px;
        }

        .date-done-box .date-notice {
            font-size: 12px;
            color: var(--main-green);
            font-weight: 600;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .btn-wish {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 24px;
            line-height: 1;
            padding: 0 4px;
            transition: transform 0.15s;
            flex-shrink: 0;
        }

        .btn-wish:hover { transform: scale(1.25); }
        .btn-wish:disabled { cursor: not-allowed; opacity: 0.5; }

        /* ✅ AI 스타일 결과 배너 */
        .style-result-banner {
            display: flex;
            align-items: center;
            gap: 12px;
            background: linear-gradient(135deg, #f0f8f2, #fafff7);
            border: 1.5px solid #c8e6c9;
            border-radius: 14px;
            padding: 14px 18px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .style-result-icon { font-size: 20px; flex-shrink: 0; }
        .style-result-text { flex: 1; font-size: 14px; color: #333; line-height: 1.6; }
        .style-result-text strong { color: #1a5e30; }
        .style-result-chip {
            display: inline-block;
            background: #e8f5e9;
            color: #2c7846;
            font-size: 12px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
            margin: 2px 3px;
            border: 1px solid #c8e6c9;
        }
        .style-result-change {
            font-size: 13px;
            color: #888;
            text-decoration: none;
            white-space: nowrap;
            padding: 6px 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            transition: 0.2s;
        }
        .style-result-change:hover { background: #f5f5f5; color: #555; }

        /* ✅ 날짜 선택 모달 */
        .date-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .date-modal-overlay.show {
            display: flex;
        }

        .date-modal {
            background: #fff;
            border-radius: 20px;
            padding: 32px 28px;
            width: 420px;
            max-width: 92vw;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            position: relative;
        }

        .date-modal h3 {
            font-size: 18px;
            font-weight: 700;
            color: #222;
            margin-bottom: 6px;
        }

        .date-modal .modal-sub {
            font-size: 13px;
            color: #888;
            margin-bottom: 24px;
        }

        .date-modal .modal-field {
            margin-bottom: 16px;
        }

        .date-modal .modal-field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }

        .date-modal .modal-field input[type="date"] {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid #ddd;
            border-radius: 10px;
            font-size: 14px;
            color: #333;
            outline: none;
            box-sizing: border-box;
            transition: border-color 0.2s;
        }

        .date-modal .modal-field input[type="date"]:focus {
            border-color: var(--main-green);
        }

        .date-modal .modal-btn-row {
            display: flex;
            gap: 10px;
            margin-top: 24px;
        }

        .date-modal .btn-modal-cancel {
            flex: 1;
            padding: 12px;
            border: 1.5px solid #ddd;
            border-radius: 10px;
            background: #fff;
            font-size: 14px;
            font-weight: 600;
            color: #666;
            cursor: pointer;
            transition: 0.2s;
        }

        .date-modal .btn-modal-cancel:hover {
            background: #f5f5f5;
        }

        .date-modal .btn-modal-confirm {
            flex: 2;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: var(--main-green);
            font-size: 14px;
            font-weight: 700;
            color: #fff;
            cursor: pointer;
            transition: 0.2s;
        }

        .date-modal .btn-modal-confirm:hover {
            background: #225e38;
        }

        .date-modal .btn-modal-close {
            position: absolute;
            top: 16px;
            right: 18px;
            background: none;
            border: none;
            font-size: 20px;
            color: #aaa;
            cursor: pointer;
        }

        /* 예약하기 버튼 날짜 없을때 표시 */
        .btn-point-nodate {
            background: #ccc !important;
            cursor: default !important;
            pointer-events: none;
        }
    </style>
</head>

<body>

<jsp:include page="/include/header.jsp" />

<!-- ✅ 날짜 선택 모달 -->
<div class="date-modal-overlay" id="dateModalOverlay">
    <div class="date-modal">
        <button class="btn-modal-close" onclick="closeDateModal()">✕</button>
        <h3>📅 날짜를 선택해주세요</h3>
        <p class="modal-sub">예약하기 전에 체크인 · 체크아웃 날짜를 먼저 선택해주세요.</p>

        <div class="modal-field">
            <label for="modalCheckIn">체크인</label>
            <input type="date" id="modalCheckIn">
        </div>
        <div class="modal-field">
            <label for="modalCheckOut">체크아웃</label>
            <input type="date" id="modalCheckOut">
        </div>

        <div class="date-modal-camp-info" id="modalCampInfo" style="margin-top:12px; font-size:13px; color:#555;"></div>

        <div class="modal-btn-row">
            <button class="btn-modal-cancel" onclick="closeDateModal()">취소</button>
            <button class="btn-modal-confirm" onclick="confirmDateModal()">이 날짜로 예약하기</button>
        </div>
    </div>
</div>

<div class="content-wrapper">

    <aside class="sidebar">
        <div class="sidebar-sticky">

            <div class="filter-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="filter-title m-0">필터</h3>
                    <a href="<%=ctx%>/campList" class="text-decoration-none text-muted small">🔄 초기화</a>
                </div>

                <form action="<%=ctx%>/campList" method="get" id="campFilterForm">

                    <input type="hidden" name="sort" id="sortInput" value="<%= sort %>">

                    <div class="filter-group">
                        <label class="filter-label">검색어</label>
                        <input type="text"
                               name="keyword"
                               class="filter-input"
                               placeholder="캠핑장명, 지역, 키워드 검색"
                               value="<%= (keyword != null) ? keyword : "" %>">
                    </div>

                    <%-- ✅ 날짜 선택 영역: 미선택 시 강조, 선택 시 초록 --%>
                    <% if (hasDate) { %>
                    <div class="date-done-box">
                        <div class="date-notice">✅ 날짜 선택 완료</div>
                        <div class="date-row">
                    <% } else { %>
                    <div class="date-highlight-box">
                        <div class="date-notice">📅 날짜를 선택하면 예약 가능 여부를 확인할 수 있어요!</div>
                        <div class="date-row">
                    <% } %>
                            <div class="filter-group">
                                <label class="filter-label" for="checkIn">체크인</label>
                                <input type="date"
                                       id="checkIn"
                                       name="checkIn"
                                       class="filter-input"
                                       value="<%= checkIn %>">
                            </div>

                            <div class="filter-group">
                                <label class="filter-label" for="checkOut">체크아웃</label>
                                <input type="date"
                                       id="checkOut"
                                       name="checkOut"
                                       class="filter-input"
                                       value="<%= checkOut %>">
                            </div>
                        </div>
                    </div>

                    <div class="filter-group" id="typeTagGroup">
                        <label class="filter-label">숙소유형</label>
                        <div class="common-tag-list">
                            <%
                                String[] types = {"펜션", "카라반", "글램핑", "풀빌라", "Pool캠핑", "애견동반", "당일캠프닉", "차박/캠핑"};
                                for (String t : types) {
                                    boolean selected = typeList.contains(t);
                            %>
                                <span class="common-tag <%= selected ? "active" : "" %>" data-value="<%=t%>"><%=t%></span>
                            <% } %>
                        </div>
                        <input type="hidden" name="type" id="typeInput"
                               value="<%= (selectedTypes != null) ? String.join(",", selectedTypes) : "" %>">
                    </div>

                    <div class="filter-group" id="locTagGroup">
                        <label class="filter-label">지역</label>
                        <div class="common-tag-list">
                            <%
                                String[] locs = {"강원도", "충청도", "경상도", "전라도", "춘천/홍천", "제주", "안면도/태안", "거제/남해/통영", "대부도/선재도/영흥도", "인천/강화도", "서울/경기"};
                                for (String l : locs) {
                                    boolean selected = locList.contains(l);
                            %>
                                <span class="common-tag <%= selected ? "active" : "" %>" data-value="<%=l%>"><%=l%></span>
                            <% } %>
                        </div>
                        <input type="hidden" name="loc" id="locInput"
                               value="<%= (selectedLocs != null) ? String.join(",", selectedLocs) : "" %>">
                    </div>

                    <button type="button" class="btn-toggle-filter" id="filterToggleBtn">
                        <span id="toggleText">상세 시설 필터 펼치기</span>
                        <span class="toggle-icon">▼</span>
                    </button>

                    <div class="collapsible-content" id="detailFilterArea">
                        <div id="facilityTagGroup">

                            <div class="filter-group">
                                <span class="filter-subtitle">공용시설</span>
                                <div class="common-tag-list">
                                    <%
                                        String[] commonFaci = {"골프연습장", "공용개수대/화장실", "캠프파이어", "산책로", "카페", "찜질방", "족구장", "노래방", "세미나실", "포토존", "매점"};
                                        for (String f : commonFaci) {
                                    %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">바베큐장</span>
                                <div class="common-tag-list">
                                    <%
                                        String[] bbqFaci = {"개별바베큐장", "공용바베큐장", "단체바베큐장"};
                                        for (String f : bbqFaci) {
                                    %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">스파/수영장</span>
                                <div class="common-tag-list">
                                    <%
                                        String[] poolFaci = {"스파", "야외수영장", "개별수영장", "실내수영장", "사계절수영장", "어린이수영장", "애견수영장"};
                                        for (String f : poolFaci) {
                                    %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">키즈/반려견시설</span>
                                <div class="common-tag-list">
                                    <%
                                        String[] extraFaci = {"어린이놀이터", "애견놀이터"};
                                        for (String f : extraFaci) {
                                    %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <input type="hidden" name="facility" id="facilityInput"
                                   value="<%= (selectedFacilities != null) ? String.join(",", selectedFacilities) : "" %>">
                        </div>
                    </div>

                    <div class="filter-group mt-3">
                        <button type="submit" class="btn btn-primary w-100">검색하기</button>
                    </div>
                </form>
            </div>

            <div class="filter-card">
                <h3 class="filter-title">빠른 메뉴</h3>
                <ul class="side-menu">
                    <li><a href="<%=ctx%>/campList" class="active">전체 캠핑장</a></li>
                    <li><a href="<%=ctx%>/main.jsp">메인으로</a></li>
                    <li><a href="<%=ctx%>/mypage/reservation_list.jsp">내 예약 보기</a></li>
                </ul>
            </div>

        </div>
    </aside>

    <main class="main-content">
        <h2 class="page-section-title">캠핑장 예약</h2>

        <%-- ✅ AI 스타일 배너 --%>
        <% if (hasStyles) { %>
        <div class="style-result-banner">
            <span class="style-result-icon">✨</span>
            <div class="style-result-text">
                <strong>추천 스타일:</strong>
                <% for (int si = 0; si < styleList.size(); si++) {
                       String sl = styleList.get(si);
                       String slLabel = styleLabelMap.getOrDefault(sl, sl);
                %>
                    <span class="style-result-chip"><%= slLabel %></span>
                <% } %>
                에 맞는 캠핑장을 추천 순으로 보여드립니다.
            </div>
            <a href="<%=ctx%>/main.jsp" class="style-result-change">스타일 변경</a>
        </div>
        <% } %>

        <% if (hasDate) { %>
            <p class="section-sub-title">
                <%= checkIn %> ~ <%= checkOut %> 기간에 예약 가능한 캠핑장을 찾아보세요.
            </p>
        <% } else if (!hasStyles) { %>
            <p class="section-sub-title">원하는 숙소 유형과 지역을 골라 캠핑장을 찾아보세요.</p>
        <% } %>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="camp-count small text-muted">
                <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                    "<%= keyword %>" ·
                <% } %>
                <% if (hasStyles) { %>
                    <% for (String sl : styleList) { %><%= styleLabelMap.getOrDefault(sl, sl) %> <% } %>·
                <% } %>
                <% if (hasDate) { %>
                    <%= checkIn %> ~ <%= checkOut %> ·
                <% } %>
                <%= totalCount %>개
            </div>

            <select class="form-select camp-sort" style="width: 150px;">
                <option value="recommend" <%= "recommend".equals(sort) ? "selected" : "" %>>추천순</option>
                <option value="priceAsc"  <%= "priceAsc".equals(sort)  ? "selected" : "" %>>가격 낮은순</option>
                <option value="priceDesc" <%= "priceDesc".equals(sort) ? "selected" : "" %>>가격 높은순</option>
            </select>
        </div>

        <%
            if (campList != null && !campList.isEmpty()) {
                for (Product p : campList) {
                    String img = p.getImageUrl();
                    String imgPath;

                    if (img == null || img.trim().isEmpty()) {
                        imgPath = ctx + "/assets/img/default.jpg";
                    } else if (img.startsWith("http://") || img.startsWith("https://")) {
                        imgPath = img;
                    } else if (img.startsWith("/")) {
                        imgPath = img;
                    } else {
                        imgPath = ctx + "/assets/img/" + img;
                    }

                    boolean isWished = WishlistDAO.isWished(userId, p.getId());
        %>
            <div class="horizontal-card">
                <div class="img-box">
                    <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="camp-thumb-link">
                        <img src="<%=imgPath%>"
                             alt="<%= p.getName() %>"
                             onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                    </a>
                </div>

                <div class="info-box">
                    <div>
                        <div class="card-top-line">
                            <div class="camp-name-link">
                                <h3 class="card-main-title"><%= p.getName() %></h3>
                                <div class="camp-location">📍 <%= p.getAddress() %></div>
                            </div>

                            <div style="display:flex; align-items:center; gap:8px;">
                                <button type="button"
                                        class="btn-wish"
                                        data-camp-id="<%= p.getId() %>"
                                        data-wished="<%= isWished %>"
                                        onclick="toggleWish(this)"
                                        title="<%= isWished ? "찜 해제" : "찜하기" %>">
                                    <%= isWished ? "❤️" : "🤍" %>
                                </button>
                                <span class="badge-soft">예약 가능</span>
                            </div>
                        </div>

                        <div class="card-desc">
                            자연 속에서 편하게 머물 수 있는 캠핑장입니다. 상세 페이지에서 시설과 예약 가능 일정을 확인해보세요.
                        </div>

                        <div class="camp-tag-wrap">
                            <%
                                String typeValue = p.getType();
                                String typeTag = "";

                                if (typeValue != null && !typeValue.trim().isEmpty()) {
                                    typeTag = "#" + typeValue.trim().replace("#", "");
                            %>
                                <span class="meta-chip"><%= typeTag %></span>
                            <%
                                }

                                String cTags = p.getTags();
                                if (cTags != null && !cTags.trim().isEmpty()) {
                                    String[] tagArr = cTags.trim().split("\\s+");
                                    for (String t : tagArr) {
                                        if (t == null || t.trim().isEmpty()) continue;
                                        String cleanTag = t.trim();
                                        if (!cleanTag.startsWith("#")) cleanTag = "#" + cleanTag;
                                        if (cleanTag.equals(typeTag)) continue;
                            %>
                                <span class="meta-chip green"><%= cleanTag %></span>
                            <%
                                    }
                                }
                            %>
                        </div>
                    </div>

                    <div class="card-bottom-line">
                        <div>
                            <p class="card-price"><%= String.format("%,d", p.getPrice()) %>원~</p>
                            <div class="card-extra">1박 기준 시작가</div>
                        </div>

                        <div class="card-action-group">
                            <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="btn btn-outline">상세보기</a>

                            <% if (hasDate) { %>
                                <%-- 날짜 있으면 바로 예약 페이지로 이동 --%>
                                <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>&checkIn=<%= URLEncoder.encode(checkIn, "UTF-8") %>&checkOut=<%= URLEncoder.encode(checkOut, "UTF-8") %>"
                                   class="btn btn-point">예약하기</a>
                            <% } else { %>
                                <%-- 날짜 없으면 모달 팝업으로 날짜 선택 유도 --%>
                                <button type="button"
                                        class="btn btn-point"
                                        onclick="openDateModal('<%= p.getId() %>', '<%= p.getName().replace("'", "\\'") %>')"
                                        title="날짜를 선택하고 예약하세요">
                                    📅 날짜 선택 후 예약
                                </button>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <div class="camp-empty-box">
                검색 조건에 맞는 캠핑장이 없습니다. 🏕️
            </div>
        <% } %>

        <%
            StringBuilder pageQuery = new StringBuilder();
            String pageKeywordParam  = request.getParameter("keyword");
            String pageTypeParam     = request.getParameter("type");
            String pageLocParam      = request.getParameter("loc");
            String pageFacilityParam = request.getParameter("facility");
            String pageSortParam     = request.getParameter("sort");
            String pageCheckInParam  = request.getParameter("checkIn");
            String pageCheckOutParam = request.getParameter("checkOut");
            String pageStylesParam   = request.getParameter("styles"); // ✅ styles 추가

            if (pageKeywordParam != null && !pageKeywordParam.trim().isEmpty())
                pageQuery.append("&keyword=").append(URLEncoder.encode(pageKeywordParam, "UTF-8"));
            if (pageTypeParam != null && !pageTypeParam.trim().isEmpty())
                pageQuery.append("&type=").append(URLEncoder.encode(pageTypeParam, "UTF-8"));
            if (pageLocParam != null && !pageLocParam.trim().isEmpty())
                pageQuery.append("&loc=").append(URLEncoder.encode(pageLocParam, "UTF-8"));
            if (pageFacilityParam != null && !pageFacilityParam.trim().isEmpty())
                pageQuery.append("&facility=").append(URLEncoder.encode(pageFacilityParam, "UTF-8"));
            if (pageSortParam != null && !pageSortParam.trim().isEmpty())
                pageQuery.append("&sort=").append(URLEncoder.encode(pageSortParam, "UTF-8"));
            if (pageCheckInParam != null && !pageCheckInParam.trim().isEmpty())
                pageQuery.append("&checkIn=").append(URLEncoder.encode(pageCheckInParam, "UTF-8"));
            if (pageCheckOutParam != null && !pageCheckOutParam.trim().isEmpty())
                pageQuery.append("&checkOut=").append(URLEncoder.encode(pageCheckOutParam, "UTF-8"));
            if (pageStylesParam != null && !pageStylesParam.trim().isEmpty())  // ✅
                pageQuery.append("&styles=").append(URLEncoder.encode(pageStylesParam, "UTF-8"));
        %>

        <% if (totalPage > 1) { %>
            <div class="pagination-wrap">
                <% if (currentPage > 1) { %>
                    <a class="page-btn" href="<%=ctx%>/campList?page=<%= currentPage - 1 %><%= pageQuery.toString() %>">이전</a>
                <% } %>

                <%
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage   = Math.min(totalPage, currentPage + 2);
                    for (int i = startPage; i <= endPage; i++) {
                %>
                    <a class="page-btn <%= (i == currentPage) ? "active" : "" %>"
                       href="<%=ctx%>/campList?page=<%= i %><%= pageQuery.toString() %>"><%= i %></a>
                <%  } %>

                <% if (currentPage < totalPage) { %>
                    <a class="page-btn" href="<%=ctx%>/campList?page=<%= currentPage + 1 %><%= pageQuery.toString() %>">다음</a>
                <% } %>
            </div>
        <% } %>
    </main>
</div>

<jsp:include page="/include/footer.jsp" />

<script>
    const ctx = '<%=ctx%>';

    /* ──────────────────────────────────────────
       필터 토글
    ────────────────────────────────────────── */
    const toggleBtn   = document.getElementById('filterToggleBtn');
    const filterArea  = document.getElementById('detailFilterArea');
    const toggleText  = document.getElementById('toggleText');

    toggleBtn.addEventListener('click', () => {
        const isOpen = filterArea.style.display === 'block';
        filterArea.style.display = isOpen ? 'none' : 'block';
        toggleBtn.classList.toggle('active');
        toggleText.innerText = isOpen ? '상세 시설 필터 펼치기' : '상세 시설 필터 접기';
    });

    if (document.getElementById('facilityInput').value !== "") {
        filterArea.style.display = 'block';
        toggleBtn.classList.add('active');
        toggleText.innerText = '상세 시설 필터 접기';
    }

    /* ──────────────────────────────────────────
       태그 그룹 설정
    ────────────────────────────────────────── */
    function setupTagGroup(groupId, inputId) {
        const group = document.getElementById(groupId);
        const input = document.getElementById(inputId);
        if (!group || !input) return;

        const tags = group.querySelectorAll(".common-tag");
        const selected = new Set();

        if (input.value && input.value.trim() !== "") {
            input.value.split(",").forEach(v => {
                const value = v.trim();
                if (value) selected.add(value);
            });
        }

        tags.forEach(tag => {
            const value = tag.dataset.value;

            if (selected.has(value)) {
                tag.classList.add("active");
            }

            tag.addEventListener("click", function () {
                if (selected.has(value)) {
                    selected.delete(value);
                    tag.classList.remove("active");
                } else {
                    selected.add(value);
                    tag.classList.add("active");
                }
                input.value = Array.from(selected).join(",");
            });
        });
    }

    setupTagGroup("typeTagGroup",     "typeInput");
    setupTagGroup("locTagGroup",      "locInput");
    setupTagGroup("facilityTagGroup", "facilityInput");

    /* ──────────────────────────────────────────
       정렬 변경 시 폼 자동 제출
    ────────────────────────────────────────── */
    const sortSelect     = document.querySelector(".camp-sort");
    const sortInput      = document.getElementById("sortInput");
    const campFilterForm = document.getElementById("campFilterForm");

    if (sortSelect && sortInput && campFilterForm) {
        sortSelect.addEventListener("change", function () {
            sortInput.value = this.value;
            campFilterForm.submit();
        });
    }

    /* ──────────────────────────────────────────
       날짜 입력 유효성: 체크인 변경 시 체크아웃 최솟값 자동 설정
    ────────────────────────────────────────── */
    const checkInEl  = document.getElementById('checkIn');
    const checkOutEl = document.getElementById('checkOut');

    const todayStr = new Date().toISOString().split('T')[0];
    if (checkInEl)  checkInEl.min  = todayStr;
    if (checkOutEl) checkOutEl.min = todayStr;

    if (checkInEl) {
        checkInEl.addEventListener('change', function () {
            if (this.value) {
                const next = new Date(this.value);
                next.setDate(next.getDate() + 1);
                checkOutEl.min = next.toISOString().split('T')[0];
                if (checkOutEl.value && checkOutEl.value <= this.value) {
                    checkOutEl.value = '';
                }
            }
        });
    }

    /* ──────────────────────────────────────────
       ✅ 날짜 선택 모달
    ────────────────────────────────────────── */
    let pendingCampId   = null;
    let pendingCampName = null;

    function openDateModal(campId, campName) {
        pendingCampId   = campId;
        pendingCampName = campName;

        // 모달 안 날짜 최솟값 설정
        const mIn  = document.getElementById('modalCheckIn');
        const mOut = document.getElementById('modalCheckOut');
        mIn.min  = todayStr;
        mOut.min = todayStr;
        mIn.value  = '';
        mOut.value = '';

        // 캠핑장 이름 표시
        document.getElementById('modalCampInfo').textContent = '🏕️ ' + campName;

        document.getElementById('dateModalOverlay').classList.add('show');
    }

    function closeDateModal() {
        document.getElementById('dateModalOverlay').classList.remove('show');
        pendingCampId   = null;
        pendingCampName = null;
    }

    // 모달 안 체크인 변경 시 체크아웃 최솟값 업데이트
    document.getElementById('modalCheckIn').addEventListener('change', function () {
        const mOut = document.getElementById('modalCheckOut');
        if (this.value) {
            const next = new Date(this.value);
            next.setDate(next.getDate() + 1);
            mOut.min = next.toISOString().split('T')[0];
            if (mOut.value && mOut.value <= this.value) {
                mOut.value = '';
            }
        }
    });

    function confirmDateModal() {
        const mIn  = document.getElementById('modalCheckIn').value;
        const mOut = document.getElementById('modalCheckOut').value;

        if (!mIn) {
            alert('체크인 날짜를 선택해주세요.');
            return;
        }
        if (!mOut) {
            alert('체크아웃 날짜를 선택해주세요.');
            return;
        }

        // 선택된 날짜로 campDetail 이동
        location.href = ctx + '/campDetail.jsp?id=' + pendingCampId
                      + '&checkIn='  + encodeURIComponent(mIn)
                      + '&checkOut=' + encodeURIComponent(mOut);
    }

    // 오버레이 바깥 클릭 시 모달 닫기
    document.getElementById('dateModalOverlay').addEventListener('click', function (e) {
        if (e.target === this) closeDateModal();
    });

    /* ──────────────────────────────────────────
       찜하기 토글
    ────────────────────────────────────────── */
    function toggleWish(btn) {
        const campId = btn.dataset.campId;
        const wished = btn.dataset.wished === 'true';
        const action = wished ? 'remove' : 'add';

        btn.disabled = true;

        fetch('<%=ctx%>/wishToggle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'campId=' + campId + '&action=' + action
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                const nowWished = !wished;
                btn.dataset.wished  = nowWished;
                btn.textContent     = nowWished ? '❤️' : '🤍';
                btn.title           = nowWished ? '찜 해제' : '찜하기';
            }
        })
        .catch(err => console.error('찜 처리 오류:', err))
        .finally(() => { btn.disabled = false; });
    }
</script>

</body>
</html>
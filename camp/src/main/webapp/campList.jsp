<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*, dto.Product, dao.UserDAO" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");
    String tags = request.getParameter("tags");

    // 필터 파라미터 수집
    String[] selectedTypes = request.getParameterValues("type");
    List<String> typeList = (selectedTypes != null) ? Arrays.asList(selectedTypes) : new ArrayList<>();

    String[] selectedLocs = request.getParameterValues("loc");
    List<String> locList = (selectedLocs != null) ? Arrays.asList(selectedLocs) : new ArrayList<>();

    String[] selectedFacilities = request.getParameterValues("facility");
    List<String> facilityList = (selectedFacilities != null) ? Arrays.asList(selectedFacilities) : new ArrayList<>();

    List<Product> campList = (List<Product>) request.getAttribute("campList");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | 캠핑장 예약</title>

    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/camp.css">
    <style>
        .filter-group { margin-bottom: 20px; }
        .filter-subtitle { font-size: 14px; font-weight: 600; color: #333; margin-bottom: 10px; display: block; }
        
        /* 접고 펴기 스타일 */
        .collapsible-content {
            display: none; /* 기본적으로 닫힘 */
            overflow: hidden;
            border-top: 1px solid #eee;
            padding-top: 15px;
            margin-top: 10px;
        }
        .btn-toggle-filter {
            width: 100%;
            background: none;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 8px;
            font-size: 13px;
            color: #666;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
            margin-bottom: 15px;
        }
        .btn-toggle-filter:hover { background-color: #f9f9f9; }
        .btn-toggle-filter.active { background-color: #f1f3f1; color: #2d5a27; border-color: #2d5a27; }
        .toggle-icon { transition: transform 0.3s; }
        .btn-toggle-filter.active .toggle-icon { transform: rotate(180deg); }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="content-wrapper">
    <aside class="sidebar">
        <div class="sidebar-sticky">
            <div class="filter-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="filter-title m-0">필터</h3>
                    <a href="<%=ctx%>/campList" class="text-decoration-none text-muted small">🔄 초기화</a>
                </div>

                <form action="<%=ctx%>/campList" method="get">
                    <input type="hidden" name="tags" value="<%= (tags != null) ? tags : "" %>">

                    <div class="filter-group">
                        <label class="filter-label">검색어</label>
                        <input type="text" name="keyword" class="filter-input" placeholder="캠핑장명, 지역, 키워드 검색" value="<%= (keyword != null) ? keyword : "" %>">
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
                        <input type="hidden" name="type" id="typeInput" value="<%= (selectedTypes != null) ? String.join(",", selectedTypes) : "" %>">
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
                        <input type="hidden" name="loc" id="locInput" value="<%= (selectedLocs != null) ? String.join(",", selectedLocs) : "" %>">
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
                                    <% String[] commonFaci = {"골프연습장", "공용개수대/화장실", "캠프파이어", "산책로", "카페", "찜질방", "족구장", "노래방", "세미나실", "포토존", "매점"};
                                       for(String f : commonFaci) { %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">바베큐장</span>
                                <div class="common-tag-list">
                                    <% String[] bbqFaci = {"개별바베큐장", "공용바베큐장", "단체바베큐장"};
                                       for(String f : bbqFaci) { %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">스파/수영장</span>
                                <div class="common-tag-list">
                                    <% String[] poolFaci = {"스파", "야외수영장", "개별수영장", "실내수영장", "사계절수영장", "어린이수영장", "애견수영장"};
                                       for(String f : poolFaci) { %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>

                            <div class="filter-group">
                                <span class="filter-subtitle">키즈/반려견시설</span>
                                <div class="common-tag-list">
                                    <% String[] extraFaci = {"어린이놀이터", "애견놀이터"};
                                       for(String f : extraFaci) { %>
                                        <span class="common-tag <%= facilityList.contains(f) ? "active" : "" %>" data-value="<%=f%>"><%=f%></span>
                                    <% } %>
                                </div>
                            </div>
                            <input type="hidden" name="facility" id="facilityInput" value="<%= (selectedFacilities != null) ? String.join(",", selectedFacilities) : "" %>">
                        </div>
                    </div>

                    <div class="filter-group mt-3">
                        <button type="submit" class="btn-search">검색하기</button>
                    </div>
                </form>
            </div>

            <div class="filter-card">
                <h3 class="filter-title">빠른 메뉴</h3>
                <ul class="side-menu">
                    <li><a href="<%=ctx%>/campList" class="active">전체 캠핑장</a></li>
                    <li><a href="<%=ctx%>/main.jsp">메인으로</a></li>
                    <li><a href="<%=ctx%>/mypage.jsp">내 예약 보기</a></li>
                </ul>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <h2 class="page-section-title">캠핑장 예약</h2>
        <p class="section-sub-title">원하는 숙소 유형과 지역을 골라 캠핑장을 찾아보세요.</p>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="camp-count small text-muted">
                <% if (keyword != null && !keyword.isEmpty()) { %>
                    "<%= keyword %>" · 
                <% } %>
                <%= (campList != null) ? campList.size() : 0 %>개
            </div>

            <select class="form-select camp-sort" style="width: 140px;">
                <option>추천순</option>
                <option>가격낮은순</option>
                <option>평점순</option>
            </select>
        </div>

        <%
            if (campList != null && !campList.isEmpty()) {
                for (Product p : campList) {
                    String img = p.getImageUrl();
                    if (img == null || img.isEmpty()) img = "default.jpg";
        %>
            <div class="horizontal-card">
                <div class="img-box">
                    <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="camp-thumb-link">
                        <img src="<%=ctx%>/assets/img/<%= img %>" alt="<%= p.getName() %>"
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
                            <span class="badge-soft">예약 가능</span>
                        </div>

                        <div class="card-desc">
                            자연 속에서 편하게 머물 수 있는 캠핑장입니다. 상세 페이지에서 시설과 예약 가능 일정을 확인해보세요.
                        </div>

                        <div class="camp-tag-wrap">
                            <span class="meta-chip">#<%= p.getType() %></span>
                            <%
                                String cTags = p.getTags();
                                if (cTags != null && !cTags.trim().isEmpty()) {
                                    for (String t : cTags.split(",")) {
                            %>
                                <span class="meta-chip green">#<%= t.trim().replace("#", "") %></span>
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
                            <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="btn-soft">상세보기</a>
                            <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="btn-point">예약하기</a>
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
    </main>
</div>

<jsp:include page="/include/footer.jsp" />

<script>
    // 필터 펼치기/접기 로직
    const toggleBtn = document.getElementById('filterToggleBtn');
    const filterArea = document.getElementById('detailFilterArea');
    const toggleText = document.getElementById('toggleText');

    toggleBtn.addEventListener('click', () => {
        const isOpen = filterArea.style.display === 'block';
        filterArea.style.display = isOpen ? 'none' : 'block';
        toggleBtn.classList.toggle('active');
        toggleText.innerText = isOpen ? '상세 시설 필터 펼치기' : '상세 시설 필터 접기';
    });

    // 만약 상세 시설이 이미 선택되어 있다면 자동으로 펼쳐두기
    if (document.getElementById('facilityInput').value !== "") {
        filterArea.style.display = 'block';
        toggleBtn.classList.add('active');
        toggleText.innerText = '상세 시설 필터 접기';
    }

    // 태그 선택 로직
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
            if (selected.has(value)) tag.classList.add("active");

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

    setupTagGroup("typeTagGroup", "typeInput");
    setupTagGroup("locTagGroup", "locInput");
    setupTagGroup("facilityTagGroup", "facilityInput");
</script>

</body>
</html>
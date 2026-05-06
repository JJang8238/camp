<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*, java.net.URLEncoder, dto.Product, dao.WishlistDAO" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");

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

    List<Product> campList = (List<Product>) request.getAttribute("campList");

    Integer totalCountObj  = (Integer) request.getAttribute("totalCount");
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPageObj   = (Integer) request.getAttribute("totalPage");

    int totalCount  = (totalCountObj  != null) ? totalCountObj  : 0;
    int currentPage = (currentPageObj != null) ? currentPageObj : 1;
    int totalPage   = (totalPageObj   != null) ? totalPageObj   : 1;
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
            font-size: 14px; font-weight: 600; color: #333;
            margin-bottom: 10px; display: block;
        }

        .collapsible-content {
            display: none; overflow: hidden;
            border-top: 1px solid #eee;
            padding-top: 15px; margin-top: 10px;
        }

        .btn-toggle-filter {
            width: 100%; background: #fff;
            border: 1px solid #ddd; border-radius: 14px;
            padding: 10px 12px; font-size: 13px; font-weight: 700;
            color: #666; cursor: pointer;
            display: flex; justify-content: center;
            align-items: center; gap: 6px;
            transition: 0.2s ease; margin-bottom: 15px;
        }
        .btn-toggle-filter:hover { background-color: #f8f9fa; color: var(--main-green); }
        .btn-toggle-filter.active { background-color: #eef4f1; color: var(--main-green); border-color: var(--main-green); }
        .toggle-icon { transition: transform 0.3s; }
        .btn-toggle-filter.active .toggle-icon { transform: rotate(180deg); }

        /* ✅ 찜 버튼 */
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
        <p class="section-sub-title">원하는 숙소 유형과 지역을 골라 캠핑장을 찾아보세요.</p>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="camp-count small text-muted">
                <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                    "<%= keyword %>" ·
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
                    String imgPath = (img != null && !img.trim().isEmpty())
                            ? ctx + img
                            : ctx + "/assets/img/default.jpg";

                    // ✅ 찜 여부 확인
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
                                <%-- ✅ 찜 버튼: AJAX 방식 (/wishToggle 서블릿으로 요청) --%>
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
                            <a href="<%=ctx%>/campDetail.jsp?id=<%= p.getId() %>" class="btn btn-point">예약하기</a>
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

    setupTagGroup("typeTagGroup",     "typeInput");
    setupTagGroup("locTagGroup",      "locInput");
    setupTagGroup("facilityTagGroup", "facilityInput");

    const sortSelect     = document.querySelector(".camp-sort");
    const sortInput      = document.getElementById("sortInput");
    const campFilterForm = document.getElementById("campFilterForm");

    if (sortSelect && sortInput && campFilterForm) {
        sortSelect.addEventListener("change", function () {
            sortInput.value = this.value;
            campFilterForm.submit();
        });
    }

    // ✅ 찜 AJAX 토글 → /wishToggle 서블릿으로 요청
    function toggleWish(btn) {
        const campId = btn.dataset.campId;
        const wished = btn.dataset.wished === 'true';
        const action = wished ? 'remove' : 'add';

        btn.disabled = true; // 중복 클릭 방지

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

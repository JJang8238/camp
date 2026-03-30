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

    String[] selectedTypes = request.getParameterValues("type");
    List<String> typeList = (selectedTypes != null)
            ? Arrays.asList(selectedTypes)
            : new ArrayList<>();

    String[] selectedLocs = request.getParameterValues("loc");
    List<String> locList = (selectedLocs != null)
            ? Arrays.asList(selectedLocs)
            : new ArrayList<>();

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

    
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="content-wrapper">
    <aside class="sidebar">
        <div class="sidebar-sticky">
            <div class="filter-card">
                <h3 class="filter-title">캠핑장 검색</h3>

                <form action="<%=ctx%>/campList" method="get">
                    <input type="hidden" name="tags" value="<%= (tags != null) ? tags : "" %>">

                    <div class="filter-group">
                        <label class="filter-label" for="campKeyword">검색어</label>
                        <input
                            type="text"
                            id="campKeyword"
                            name="keyword"
                            class="filter-input"
                            placeholder="캠핑장명, 지역, 키워드 검색"
                            value="<%= (keyword != null) ? keyword : "" %>">
                    </div>

                    <div class="filter-group" id="typeTagGroup">
                        <label class="filter-label">숙소유형</label>
                        <div class="common-tag-list">
                            <%
                                String[] types = {"펜션", "카라반", "글램핑", "풀빌라", "애견동반", "차박/캠핑"};
                                for (String t : types) {
                                    boolean selected = typeList.contains(t);
                            %>
                                <span class="common-tag <%= selected ? "active" : "" %>" data-value="<%=t%>"><%=t%></span>
                            <% } %>
                        </div>
                        <input
                            type="hidden"
                            name="type"
                            id="typeInput"
                            value="<%= (selectedTypes != null) ? String.join(",", selectedTypes) : "" %>">
                    </div>

                    <div class="filter-group" id="locTagGroup">
                        <label class="filter-label">지역</label>
                        <div class="common-tag-list">
                            <%
                                String[] locs = {"서울/경기", "강원도", "충청도", "경상도", "전라도", "제주"};
                                for (String l : locs) {
                                    boolean selected = locList.contains(l);
                            %>
                                <span class="common-tag <%= selected ? "active" : "" %>" data-value="<%=l%>"><%=l%></span>
                            <% } %>
                        </div>
                        <input
                            type="hidden"
                            name="loc"
                            id="locInput"
                            value="<%= (selectedLocs != null) ? String.join(",", selectedLocs) : "" %>">
                    </div>

                    <div class="filter-group">
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

    setupTagGroup("typeTagGroup", "typeInput");
    setupTagGroup("locTagGroup", "locInput");
</script>

</body>
</html>s
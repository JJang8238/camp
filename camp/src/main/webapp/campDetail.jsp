<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*, dto.Product, dao.UserDAO" %>
<%
    // 1. 세션 및 기본 정보 설정
    String userId = (String) session.getAttribute("userId");
    String ctx = request.getContextPath();
    
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO uDao = new UserDAO();
    String userName = uDao.getNameByUsername(userId);

    // 2. 서블릿에서 보낸 검색 결과(Product 객체 리스트) 및 파라미터 가져오기
    List<Product> campList = (List<Product>) request.getAttribute("campList");
    String keyword = request.getParameter("keyword");
    String tags = request.getParameter("tags");
    
    // 현재 선택된 필터값들 (체크박스 유지용)
    String[] selectedTypes = request.getParameterValues("type");
    List<String> typeList = (selectedTypes != null) ? Arrays.asList(selectedTypes) : new ArrayList<>();
    
    String[] selectedLocs = request.getParameterValues("loc");
    List<String> locList = (selectedLocs != null) ? Arrays.asList(selectedLocs) : new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠프 메이트 | 캠핑장 예약</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --main-green: #1b4d3e; --point-orange: #ff6b35; --bg-beige: #f4f1ea; }
        body { background: var(--bg-beige); font-family: 'Noto Sans KR', sans-serif; color: #2d3436; margin: 0; }
        
        /* 헤더 스타일 */
        .main-header { width: 100%; background: white; border-bottom: 1px solid #eee; position: sticky; top: 0; z-index: 999; }
        .logo a { text-decoration: none; display: flex; align-items: center; }
        .logo-text { font-size: 22px; font-weight: bold; color: var(--main-green); }
        .nav-menu a { margin: 0 20px; text-decoration: none; color: #444; font-weight: 500; }
        .btn-logout { padding: 6px 16px; border: 1px solid var(--point-orange); color: var(--point-orange); border-radius: 20px; text-decoration: none; font-size: 14px; transition: 0.2s; }
        .btn-logout:hover { background: var(--point-orange); color: white; }

        /* 레이아웃 */
        .content-wrapper { max-width: 1300px; margin: 40px auto; display: flex; gap: 30px; padding: 0 20px; align-items: flex-start; }
        
        /* 왼쪽 사이드 필터 */
        .filter-sidebar { width: 320px; background: white; border-radius: 25px; padding: 25px; position: sticky; top: 100px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .filter-title { font-weight: 700; font-size: 20px; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center; }
        
        .accordion-item { border: none !important; border-bottom: 1px solid #f0f0f0 !important; }
        .accordion-button { font-weight: 700; background-color: transparent !important; box-shadow: none !important; padding: 20px 5px; color: #333; }
        .accordion-button:not(.collapsed) { color: var(--main-green); }
        .accordion-body { padding: 0px 5px 20px 5px; }

        .filter-tags { display: flex; flex-wrap: wrap; gap: 8px; }
        .filter-check { display: none; }
        .filter-label { padding: 8px 15px; border: 1px solid #eee; border-radius: 10px; font-size: 13px; cursor: pointer; transition: 0.2s; background: white; color: #666; }
        .filter-label:hover { border-color: var(--main-green); color: var(--main-green); }
        .filter-check:checked + .filter-label { background: var(--main-green); color: white; border-color: var(--main-green); font-weight: 500; }

        /* 오른쪽 리스트 */
        .camp-list-area { flex: 1; }
        .list-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
        .list-count { font-size: 18px; font-weight: 600; }

        .camp-card { background: white; border-radius: 20px; overflow: hidden; display: flex; margin-bottom: 25px; transition: 0.3s; box-shadow: 0 4px 15px rgba(0,0,0,0.05); text-decoration: none; color: inherit; }
        .camp-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); color: inherit; }
        .camp-img { width: 340px; height: 220px; object-fit: cover; }
        .camp-info { padding: 25px; flex: 1; display: flex; flex-direction: column; justify-content: space-between; }
        .camp-name { font-size: 22px; font-weight: 700; color: #333; }
        .camp-loc { color: #888; font-size: 14px; }
        .badge-container { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
        .badge-tag { background: #f8f9fa; color: #777; padding: 4px 10px; border-radius: 6px; font-size: 12px; border: 1px solid #eee; }
        .price-val { font-size: 24px; font-weight: 800; color: var(--main-green); text-align: right; }
    </style>
</head>
<body>

<header class="main-header">
    <div class="container-fluid px-5 d-flex justify-content-between align-items-center py-3">
        <div class="logo"><a href="main.jsp"><span class="logo-text">⛺ Camp Mate</span></a></div>
        <nav class="nav-menu">
            <a href="campList" style="color: var(--main-green);">예약하기</a>
            <a href="productList.jsp">캠핑용품</a>
            <a href="community.jsp">커뮤니티</a>
            <a href="cs.jsp">고객센터</a>
        </nav>
        <div class="nav-right">
            <span class="fw-bold me-3">👋 <%= userName %>님</span>
            <a href="logout.jsp" class="btn-logout">로그아웃</a>
        </div>
    </div>
</header>

<div class="content-wrapper">
    <aside class="filter-sidebar">
        <div class="filter-title">
            필터 🔍 
            <span onclick="location.href='campList'" style="font-size: 12px; color: #999; cursor: pointer; font-weight: 400;">🔄 초기화</span>
        </div>
        
        <form action="campList" method="get">
            <input type="hidden" name="keyword" value="<%= (keyword != null) ? keyword : "" %>">
            <input type="hidden" name="tags" value="<%= (tags != null) ? tags : "" %>">

            <div class="accordion accordion-flush" id="filterAccordion">
                
                <div class="accordion-item">
                    <h2 class="accordion-header">
                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#typeCollapse">숙소유형</button>
                    </h2>
                    <div id="typeCollapse" class="accordion-collapse collapse show">
                        <div class="accordion-body filter-tags">
                            <% String[] types = {"펜션", "카라반", "글램핑", "풀빌라", "애견동반", "차박/캠핑"};
                               for(int i=0; i<types.length; i++) { 
                                   String t = types[i]; %>
                                <input type="checkbox" id="t<%=i%>" name="type" value="<%=t%>" class="filter-check" <%= typeList.contains(t) ? "checked" : "" %>>
                                <label for="t<%=i%>" class="filter-label"><%=t%></label>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="accordion-item">
                    <h2 class="accordion-header">
                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#locCollapse">지역</button>
                    </h2>
                    <div id="locCollapse" class="accordion-collapse collapse">
                        <div class="accordion-body filter-tags">
                            <% String[] locs = {"서울/경기", "강원도", "충청도", "경상도", "전라도", "제주"};
                               for(int i=0; i<locs.length; i++) { 
                                   String l = locs[i]; %>
                                <input type="checkbox" id="l<%=i%>" name="loc" value="<%=l%>" class="filter-check" <%= locList.contains(l) ? "checked" : "" %>>
                                <label for="l<%=i%>" class="filter-label"><%=l%></label>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <button type="submit" class="btn w-100 mt-4 text-white" style="background: var(--main-green); border-radius: 12px; height: 50px; font-weight: 700;">조건 검색하기</button>
        </form>
    </aside>

    <main class="camp-list-area">
        <div class="list-header">
            <div class="list-count">
                <% if(keyword != null && !keyword.isEmpty()) { %>
                    "<span style="color: var(--main-green);"><%= keyword %></span>" 검색 결과 
                <% } %>
                총 <span style="color: var(--point-orange);"><%= (campList != null) ? campList.size() : 0 %></span>건
            </div>
            <select class="form-select shadow-sm" style="width: 140px; border-radius: 10px; font-size: 14px; border: 1px solid #eee;">
                <option>추천순</option>
                <option>낮은가격순</option>
                <option>평점높은순</option>
            </select>
        </div>

        <% 
        if (campList != null && !campList.isEmpty()) {
            for (Product p : campList) { // Map 대신 Product 객체 사용
                String img = p.getImageUrl();
                if(img == null || img.isEmpty()) img = "default.jpg";
        %>
            <a href="campDetail.jsp?id=<%= p.getId() %>" class="camp-card">
                <img src="<%=ctx%>/assets/img/<%= img %>" class="camp-img" alt="캠핑장" onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                <div class="camp-info">
                    <div>
                        <div class="camp-name"><%= p.getName() %></div>
                        <div class="camp-loc">📍 <%= p.getAddress() %></div>
                        <div class="badge-container">
                            <span class="badge-tag">#<%= p.getType() %></span>
                            <% 
                                String cTags = p.getTags();
                                if(cTags != null) {
                                    for(String t : cTags.split(",")) { %>
                                        <span class="badge-tag">#<%= t.trim().replace("#", "") %></span>
                            <%      }
                                } 
                            %>
                        </div>
                    </div>
                    <div class="price-val"><%= String.format("%,d", p.getPrice()) %>원~</div>
                </div>
            </a>
        <% 
            } 
        } else { 
        %>
            <div class="text-center py-5 bg-white rounded-4 shadow-sm">
                <p class="fs-5 text-muted mb-0">검색 조건에 맞는 캠핑장이 없습니다. 🏕️</p>
            </div>
        <% } %>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
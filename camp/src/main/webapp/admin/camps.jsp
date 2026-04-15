<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.CampDAO" %>
<%@ page import="dto.Camp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");
    String type = request.getParameter("type");

    if (keyword == null) keyword = "";
    if (type == null) type = "";

    keyword = keyword.trim();
    type = type.trim();

    CampDAO campDAO = new CampDAO();
    List<Camp> allList = campDAO.getAllCamps();
    List<Camp> campList = new ArrayList<>();

    for (Camp c : allList) {
        boolean matchesKeyword = true;
        boolean matchesType = true;

        if (!keyword.isEmpty()) {
            String lowerKeyword = keyword.toLowerCase();
            String name = c.getName() != null ? c.getName().toLowerCase() : "";
            String address = c.getAddress() != null ? c.getAddress().toLowerCase() : "";
            String tags = c.getTags() != null ? c.getTags().toLowerCase() : "";

            matchesKeyword = name.contains(lowerKeyword)
                    || address.contains(lowerKeyword)
                    || tags.contains(lowerKeyword);
        }

        if (!type.isEmpty()) {
            String campType = c.getType() != null ? c.getType().trim() : "";
            matchesType = type.equalsIgnoreCase(campType);
        }

        if (matchesKeyword && matchesType) {
            campList.add(c);
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 캠핑장 관리</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
</head>
<body class="admin-body">

    <jsp:include page="/admin/include/adminHeader.jsp" />

    <div class="admin-layout">
        <jsp:include page="/admin/include/adminSidebar.jsp" />

        <main class="admin-content">
            <div class="admin-page-head">
                <div>
                    <h1 class="admin-page-title">캠핑장 관리</h1>
                    <p class="admin-page-desc">등록된 캠핑장 정보를 조회하고 관리할 수 있습니다.</p>
                </div>
                <a href="<%=ctx%>/admin/campWrite.jsp" class="admin-btn admin-btn-primary">+ 캠핑장 등록</a>
            </div>

            <section class="admin-filter-card camp-manage-filter-card">
                <form method="get" action="<%=ctx%>/admin/camps.jsp" class="camp-manage-filter-form">
                    <input type="text" name="keyword" value="<%=keyword%>" placeholder="캠핑장명, 주소, 태그 검색" />
                    <select name="type">
                        <option value="">전체 유형</option>
                        <option value="오토캠핑" <%= "오토캠핑".equals(type) ? "selected" : "" %>>오토캠핑</option>
                        <option value="차박" <%= "차박".equals(type) ? "selected" : "" %>>차박</option>
                        <option value="글램핑" <%= "글램핑".equals(type) ? "selected" : "" %>>글램핑</option>
                        <option value="카라반" <%= "카라반".equals(type) ? "selected" : "" %>>카라반</option>
                        <option value="펜션" <%= "펜션".equals(type) ? "selected" : "" %>>펜션</option>
                        <option value="백패킹" <%= "백패킹".equals(type) ? "selected" : "" %>>백패킹</option>
                    </select>
                    <button type="submit" class="camp-manage-search-btn">검색</button>
                    <a href="<%=ctx%>/admin/camps.jsp" class="camp-manage-reset-btn">초기화</a>
                </form>
            </section>

            <div class="camp-manage-count">
                총 <strong><%=campList.size()%></strong>개의 캠핑장이 검색되었습니다.
            </div>

            <% if (campList == null || campList.isEmpty()) { %>
                <div class="camp-manage-empty">
                    등록된 캠핑장이 없거나 검색 결과가 없습니다.
                </div>
            <% } else { %>
                <div class="camp-manage-grid">
                    <%
                        for (Camp c : campList) {
                            String img = c.getImage();
                            String imgPath = ctx + "/assets/img/default.jpg";

                            if (img != null && !img.trim().isEmpty()) {
                                img = img.trim();

                                if (img.startsWith("http://") || img.startsWith("https://")) {
                                    imgPath = img;
                                } else if (img.startsWith("/")) {
                                    imgPath = ctx + img;
                                } else {
                                    imgPath = ctx + "/assets/img/" + img;
                                }
                            }
                    %>
                        <div class="camp-manage-card">
                            <img src="<%=imgPath%>" alt="캠핑장 이미지" class="camp-manage-thumb">

                            <div class="camp-manage-body">
                                <h3 class="camp-manage-name"><%=c.getName()%></h3>

                                <div class="camp-manage-meta">
                                    <div><strong>주소</strong> : <%=c.getAddress() == null ? "-" : c.getAddress()%></div>
                                    <div><strong>유형</strong> : <%=c.getType() == null ? "-" : c.getType()%></div>
                                    <div><strong>상태</strong> : <%=c.getStatus() == null ? "-" : c.getStatus()%></div>
                                </div>

                                <div class="camp-manage-tags">
                                    <%
                                        String tags = c.getTags();
                                        if (tags != null && !tags.trim().isEmpty()) {
                                            String[] arr = tags.split(",");
                                            for (String t : arr) {
                                    %>
                                        <span class="camp-manage-tag"><%=t.trim()%></span>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <span class="camp-manage-tag">태그 없음</span>
                                    <%
                                        }
                                    %>
                                </div>

                                <div class="camp-manage-price">
                                    <%=c.getPrice()%>원
                                </div>

                                <div class="camp-manage-actions">
                                    <a href="<%=ctx%>/camp/campDetail.jsp?id=<%=c.getId()%>" class="camp-manage-detail-btn">상세</a>
                                    <a href="<%=ctx%>/admin/campEdit.jsp?id=<%=c.getId()%>" class="camp-manage-edit-btn">수정</a>
                                    <a href="<%=ctx%>/admin/campDelete.jsp?id=<%=c.getId()%>"
                                       class="camp-manage-delete-btn"
                                       onclick="return confirm('이 캠핑장을 삭제하시겠습니까?');">삭제</a>
                                </div>
                            </div>
                        </div>
                    <%
                        }
                    %>
                </div>
            <% } %>
        </main>
    </div>
</body>
</html>
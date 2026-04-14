<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String currentUri = request.getRequestURI();

    boolean isDashboard = currentUri.contains("/admin/dashboard.jsp");
    boolean isUsers = currentUri.contains("/admin/users.jsp");
    boolean isOwner = currentUri.contains("/admin/ownerRequests.jsp");
    boolean isCamps = currentUri.contains("/admin/camps.jsp");
    boolean isReservations = currentUri.contains("/admin/reservations.jsp");
    boolean isProducts = currentUri.contains("/admin/products.jsp");
    boolean isReviews = currentUri.contains("/admin/reviews.jsp");
    boolean isPosts = currentUri.contains("/admin/posts.jsp");
    boolean isPostWrite = currentUri.contains("/admin/postWrite.jsp");
    boolean isReports = currentUri.contains("/admin/reports.jsp");
    boolean isLogs = currentUri.contains("/admin/logs.jsp");
%>

<aside class="admin-sidebar">
    <div class="admin-sidebar-title">관리 메뉴</div>

    <nav class="admin-nav">
        <a href="<%=ctx%>/admin/dashboard.jsp" class="admin-nav-link <%= isDashboard ? "active" : "" %>">
            대시보드
        </a>

        <a href="<%=ctx%>/admin/users.jsp" class="admin-nav-link <%= isUsers ? "active" : "" %>">
            회원 관리
        </a>
        
         <a href="<%=ctx%>/admin/ownerRequests.jsp" class="admin-nav-link <%= isOwner ? "active" : "" %>">
            캠핑장 오너 관리
        </a>

        <a href="<%=ctx%>/admin/camps.jsp" class="admin-nav-link <%= isCamps ? "active" : "" %>">
            캠핑장 관리
        </a>

        <a href="<%=ctx%>/admin/reservations.jsp" class="admin-nav-link <%= isReservations ? "active" : "" %>">
            예약 관리
        </a>

        <a href="<%=ctx%>/admin/products.jsp" class="admin-nav-link <%= isProducts ? "active" : "" %>">
            중고거래 관리
        </a>

        <a href="<%=ctx%>/admin/reviews.jsp" class="admin-nav-link <%= isReviews ? "active" : "" %>">
            후기 관리
        </a>

        <a href="<%=ctx%>/admin/posts.jsp?type=news" class="admin-nav-link <%= (isPosts || isPostWrite) ? "active" : "" %>">
            소식 / 이벤트 관리
        </a>

        <a href="<%=ctx%>/admin/reports.jsp" class="admin-nav-link <%= isReports ? "active" : "" %>">
            신고 관리
        </a>

        <a href="<%=ctx%>/admin/logs.jsp" class="admin-nav-link <%= isLogs ? "active" : "" %>">
            관리자 로그
        </a>
    </nav>
</aside>
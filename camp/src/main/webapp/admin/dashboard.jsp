<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.InquiryDAO" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    int userCount = 0;
    int campCount = 0;
    int reservationCount = 0;
    int productCount = 0;
    int postCount = 0;
    int reportCount = 0;

    userCount = UserDAO.getTotalCount();

    // 🔥 문의 데이터 가져오기
    InquiryDAO inquiryDAO = new InquiryDAO();
    List<Map<String,String>> inquiryList = inquiryDAO.getAllInquiry();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 관리자 | 대시보드</title>
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
                    <h1 class="admin-page-title">대시보드</h1>
                    <p class="admin-page-desc">캠프 메이트 운영 현황을 한눈에 확인하세요.</p>
                </div>
            </div>

            <!-- 기존 카드 그대로 유지 -->
            <section class="admin-card-grid">
                <div class="admin-stat-card">
                    <div class="admin-stat-label">전체 회원</div>
                    <div class="admin-stat-value"><%= userCount %></div>
                    <a href="<%=ctx%>/admin/users.jsp" class="admin-stat-link">회원 관리로 이동</a>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">캠핑장</div>
                    <div class="admin-stat-value"><%= campCount %></div>
                    <a href="<%=ctx%>/admin/camps.jsp" class="admin-stat-link">캠핑장 관리로 이동</a>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">예약</div>
                    <div class="admin-stat-value"><%= reservationCount %></div>
                    <a href="<%=ctx%>/admin/reservations.jsp" class="admin-stat-link">예약 관리로 이동</a>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">중고거래 글</div>
                    <div class="admin-stat-value"><%= productCount %></div>
                    <a href="<%=ctx%>/admin/products.jsp" class="admin-stat-link">중고거래 관리로 이동</a>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">소식 / 이벤트</div>
                    <div class="admin-stat-value"><%= postCount %></div>
                    <a href="<%=ctx%>/admin/posts.jsp?type=news" class="admin-stat-link">게시글 관리로 이동</a>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-label">미처리 신고</div>
                    <div class="admin-stat-value"><%= reportCount %></div>
                    <a href="<%=ctx%>/admin/reports.jsp" class="admin-stat-link">신고 관리로 이동</a>
                </div>
            </section>

            <section class="admin-panel-row">

                <!-- 빠른 작업 그대로 유지 -->
                <div class="admin-panel">
                    <div class="admin-panel-header">
                        <h2>빠른 작업</h2>
                    </div>
                    <div class="admin-quick-grid">
                        <a href="<%=ctx%>/admin/postWrite.jsp?type=news" class="admin-quick-btn">소식 작성</a>
                        <a href="<%=ctx%>/admin/postWrite.jsp?type=event" class="admin-quick-btn">이벤트 작성</a>
                        <a href="<%=ctx%>/admin/users.jsp" class="admin-quick-btn">회원 상태 변경</a>
                        <a href="<%=ctx%>/admin/products.jsp" class="admin-quick-btn">거래글 숨김 처리</a>
                        <a href="<%=ctx%>/admin/camps.jsp" class="admin-quick-btn">캠핑장 등록/수정</a>
                        <a href="<%=ctx%>/admin/reports.jsp" class="admin-quick-btn">신고 확인</a>
                    </div>
                </div>

                <!-- 🔥 운영 메모 → 문의 목록으로 변경 -->
                <div class="admin-panel">
                    <div class="admin-panel-header">
                        <h2>최근 문의</h2>
                    </div>

                    <div style="max-height:300px; overflow-y:auto;">

                    <% if(inquiryList.size() == 0) { %>
                        <div class="admin-empty-box">
                            등록된 문의가 없습니다.
                        </div>
                    <% } else { %>

                        <% for(Map<String,String> i : inquiryList) { %>
                        <div style="padding:10px; border-bottom:1px solid #eee;">
                            <strong><%=i.get("title")%></strong><br>
                            <span style="color:#666; font-size:13px;">
                                <%=i.get("username")%> | <%=i.get("created_at")%>
                            </span><br>
                            <div style="margin-top:5px;">
                                <%=i.get("content")%>
                            </div>
                        </div>
                        <% } %>

                    <% } %>

                    </div>
                </div>

            </section>

            <!-- 기존 그대로 -->
            <section class="admin-panel">
                <div class="admin-panel-header">
                    <h2>확장 예정 메뉴</h2>
                </div>
                <div class="admin-chip-wrap">
                    <span class="admin-chip">문의 관리</span>
                    <span class="admin-chip">배너 관리</span>
                    <span class="admin-chip">쿠폰 관리</span>
                    <span class="admin-chip">정산 관리</span>
                    <span class="admin-chip">통계 리포트</span>
                    <span class="admin-chip">공지 팝업</span>
                </div>
            </section>

        </main>
    </div>
</body>
</html>
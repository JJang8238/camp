<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer loginUserId = (Integer) session.getAttribute("userId");
    if (loginUserId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    User loginUser = userDAO.getUserById(loginUserId);

    if (loginUser == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String role = loginUser.getRole();
    if (role == null || !"owner".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/main.jsp");
        return;
    }

    String userName = loginUser.getName();
    String email = loginUser.getEmail();
    String campName = loginUser.getCampName();
    String businessName = loginUser.getBusinessName();
    String businessNumber = loginUser.getBusinessNumber();
    String status = loginUser.getStatus();

    if (userName == null) userName = "";
    if (email == null) email = "";
    if (campName == null) campName = "";
    if (businessName == null) businessName = "";
    if (businessNumber == null) businessNumber = "";
    if (status == null) status = "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>Camp Mate | 사장님 대시보드</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/owner.css">
    <style>
        .owner-dashboard-page {
            background: #f8f9fa;
            min-height: calc(100vh - 80px);
            padding: 40px 0 60px;
        }

        .owner-dashboard-wrap {
            max-width: 1280px;
        }

        .owner-top-hero {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            padding: 34px 36px;
            margin-bottom: 24px;
            border-radius: 24px;
            background: #ffffff;
            border: 1px solid #eeeeee;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .owner-top-badge {
            display: inline-block;
            margin-bottom: 10px;
            padding: 7px 12px;
            border-radius: 999px;
            background: #eef4f1;
            color: var(--main-green);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.8px;
        }

        .owner-top-title {
            margin: 0 0 10px;
            font-size: 30px;
            font-weight: 800;
            color: var(--dark-text);
        }

        .owner-top-desc {
            margin: 0;
            font-size: 15px;
            color: #666;
            line-height: 1.6;
        }

        .owner-top-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .owner-dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }

        .owner-main-column,
        .owner-side-column {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .owner-card {
            background: #fff;
            border: 1px solid #eeeeee;
            border-radius: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            padding: 28px;
        }

        .owner-card-title {
            margin: 0 0 18px;
            font-size: 22px;
            font-weight: 800;
            color: var(--dark-text);
        }

        .owner-summary-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .owner-summary-box {
            border: 1px solid #eeeeee;
            border-radius: 20px;
            padding: 20px;
            background: #fafafa;
        }

        .owner-summary-label {
            font-size: 13px;
            color: #777;
            margin-bottom: 8px;
            font-weight: 700;
        }

        .owner-summary-value {
            font-size: 24px;
            color: var(--dark-text);
            font-weight: 800;
        }

        .owner-summary-sub {
            margin-top: 6px;
            font-size: 13px;
            color: #888;
        }

        .owner-info-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .owner-info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            padding-bottom: 14px;
            border-bottom: 1px solid #eeeeee;
        }

        .owner-info-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .owner-info-label {
            min-width: 120px;
            font-size: 14px;
            font-weight: 700;
            color: #777;
        }

        .owner-info-value {
            flex: 1;
            text-align: right;
            font-size: 15px;
            font-weight: 600;
            color: #333;
            word-break: break-all;
        }

        .owner-status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 88px;
            height: 34px;
            padding: 0 12px;
            border-radius: 999px;
            background: #eef4f1;
            color: var(--main-green);
            font-size: 13px;
            font-weight: 800;
        }

        .owner-menu-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .owner-menu-item {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            padding: 18px;
            border: 1px solid #eeeeee;
            border-radius: 20px;
            text-decoration: none;
            background: #fff;
            transition: all 0.2s ease;
        }

        .owner-menu-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 22px rgba(0,0,0,0.06);
            border-color: #dbe6e0;
        }

        .owner-menu-icon {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            background: #f4f8f6;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }

        .owner-menu-text {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .owner-menu-text strong {
            font-size: 16px;
            color: var(--dark-text);
        }

        .owner-menu-text span {
            font-size: 13px;
            color: #777;
            line-height: 1.5;
        }

        .owner-notice-list {
            margin: 0;
            padding-left: 18px;
            font-size: 14px;
            color: #555;
            line-height: 1.7;
        }

        .owner-notice-list li + li {
            margin-top: 10px;
        }

        .owner-link-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .owner-link-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 46px;
            border-radius: 14px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            color: var(--main-green);
            background: #f4f8f6;
            border: 1px solid #dce8e2;
            transition: all 0.2s ease;
        }

        .owner-link-btn:hover {
            background: #eaf3ef;
        }

        @media (max-width: 991px) {
            .owner-dashboard-grid {
                grid-template-columns: 1fr;
            }

            .owner-top-hero {
                flex-direction: column;
                align-items: flex-start;
            }

            .owner-summary-grid,
            .owner-menu-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 767px) {
            .owner-dashboard-page {
                padding: 24px 0 40px;
            }

            .owner-top-hero,
            .owner-card {
                padding: 20px;
            }

            .owner-top-title {
                font-size: 24px;
            }

            .owner-info-row {
                flex-direction: column;
                align-items: flex-start;
            }

            .owner-info-value {
                text-align: left;
            }
        }
    </style>
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="owner-dashboard-page">
        <div class="container owner-dashboard-wrap">

            <section class="owner-top-hero">
                <div>
                    <span class="owner-top-badge">OWNER DASHBOARD</span>
                    <h1 class="owner-top-title"><%= userName %> 사장님, 환영합니다</h1>
                    <p class="owner-top-desc">
                        캠핑장 운영 정보와 예약, 판매 관리를 한 곳에서 확인할 수 있습니다.
                    </p>
                </div>

                <div class="owner-top-actions">
    				<a href="<%=ctx%>/owner/editOwnerInfo.jsp" class="btn btn-outline">
       				 사업자 정보 수정
    				</a>

    				<a href="<%=ctx%>/owner/campForm.jsp" class="btn btn-primary">
        				캠핑장 등록
    				</a>
				</div>
            </section>

            <div class="owner-dashboard-grid">

                <section class="owner-main-column">

                    <div class="owner-card">
                        <h2 class="owner-card-title">운영 요약</h2>

                        <div class="owner-summary-grid">
                            <div class="owner-summary-box">
                                <div class="owner-summary-label">등록 캠핑장</div>
                                <div class="owner-summary-value">1</div>
                                <div class="owner-summary-sub">추후 DB 연동 가능</div>
                            </div>

                            <div class="owner-summary-box">
                                <div class="owner-summary-label">오늘 예약</div>
                                <div class="owner-summary-value">0</div>
                                <div class="owner-summary-sub">예약 관리 페이지와 연동</div>
                            </div>

                            <div class="owner-summary-box">
                                <div class="owner-summary-label">판매 상품</div>
                                <div class="owner-summary-value">0</div>
                                <div class="owner-summary-sub">상품 관리와 연동</div>
                            </div>
                        </div>
                    </div>

                    <div class="owner-card">
                        <h2 class="owner-card-title">사업자 정보</h2>

                        <div class="owner-info-list">
                            <div class="owner-info-row">
                                <span class="owner-info-label">이름</span>
                                <span class="owner-info-value"><%= userName.isEmpty() ? "미등록" : userName %></span>
                            </div>

                            <div class="owner-info-row">
                                <span class="owner-info-label">이메일</span>
                                <span class="owner-info-value"><%= email.isEmpty() ? "미등록" : email %></span>
                            </div>

                            <div class="owner-info-row">
                                <span class="owner-info-label">캠핑장명</span>
                                <span class="owner-info-value"><%= campName.isEmpty() ? "미등록" : campName %></span>
                            </div>

                            <div class="owner-info-row">
                                <span class="owner-info-label">상호명</span>
                                <span class="owner-info-value"><%= businessName.isEmpty() ? "미등록" : businessName %></span>
                            </div>

                            <div class="owner-info-row">
                                <span class="owner-info-label">사업자번호</span>
                                <span class="owner-info-value"><%= businessNumber.isEmpty() ? "미등록" : businessNumber %></span>
                            </div>

                            <div class="owner-info-row">
                                <span class="owner-info-label">상태</span>
                                <span class="owner-info-value">
                                    <span class="owner-status-badge"><%= status.isEmpty() ? "active" : status %></span>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="owner-card">
                        <h2 class="owner-card-title">빠른 메뉴</h2>

                        <div class="owner-menu-grid">
                            <a href="<%=ctx%>/owner/campManage.jsp" class="owner-menu-item">
                                <div class="owner-menu-icon">🏕</div>
                                <div class="owner-menu-text">
                                    <strong>내 캠핑장 관리</strong>
                                    <span>캠핑장 정보 수정과 운영 상태를 관리합니다.</span>
                                </div>
                            </a>

                            <a href="<%=ctx%>/owner/reservationList.jsp" class="owner-menu-item">
                                <div class="owner-menu-icon">📅</div>
                                <div class="owner-menu-text">
                                    <strong>예약 관리</strong>
                                    <span>예약 현황을 확인하고 상태를 변경합니다.</span>
                                </div>
                            </a>

                            <a href="<%=ctx%>/productWrite.jsp" class="owner-menu-item">
                                <div class="owner-menu-icon">🛒</div>
                                <div class="owner-menu-text">
                                    <strong>상품 등록</strong>
                                    <span>캠핑용품 판매 글을 새로 작성합니다.</span>
                                </div>
                            </a>

                            <a href="<%=ctx%>/owner/productManage.jsp" class="owner-menu-item">
                                <div class="owner-menu-icon">📦</div>
                                <div class="owner-menu-text">
                                    <strong>상품 관리</strong>
                                    <span>내가 등록한 상품 목록과 상태를 관리합니다.</span>
                                </div>
                            </a>
                        </div>
                    </div>

                </section>

                <aside class="owner-side-column">

                    <div class="owner-card">
                        <h2 class="owner-card-title">운영 안내</h2>
                        <ul class="owner-notice-list">
                            <li>캠핑장 정보가 비어 있으면 먼저 사업자 정보를 입력하세요.</li>
                            <li>예약 기능 연동 전까지는 요약 카드 수치가 고정값으로 표시됩니다.</li>
                            <li>상품 등록은 기존 중고거래 페이지와 연결해서 사용할 수 있습니다.</li>
                            <li>사장님 계정은 owner 권한일 때만 이 페이지에 접근할 수 있습니다.</li>
                        </ul>
                    </div>

                    <div class="owner-card">
                        <h2 class="owner-card-title">바로가기</h2>
                        <div class="owner-link-list">
                            <a href="<%=ctx%>/main.jsp" class="owner-link-btn">사용자 메인으로</a>
                            <a href="<%=ctx%>/campList.jsp" class="owner-link-btn">캠핑장 목록 보기</a>
                            <a href="<%=ctx%>/productList.jsp" class="owner-link-btn">상품 목록 보기</a>
                        </div>
                    </div>

                </aside>

            </div>
        </div>
    </main>

</body>
</html>
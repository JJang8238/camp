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

    if (!"owner".equalsIgnoreCase(loginUser.getRole())) {
        response.sendRedirect(ctx + "/main.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>Camp Mate | 캠핑장 등록</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <style>
        .camp-form-page {
            padding: 40px 0 60px;
            background: var(--bg-soft);
            min-height: calc(100vh - 80px);
        }

        .camp-form-wrap {
            max-width: 900px;
        }

        .camp-form-header {
            margin-bottom: 24px;
        }

        .camp-form-title {
            margin: 0 0 8px;
            font-size: 30px;
            font-weight: 800;
            color: var(--main-green);
        }

        .camp-form-desc {
            margin: 0;
            font-size: 15px;
            color: #666;
        }

        .camp-form-card {
            padding: 30px;
        }

        .camp-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        .camp-form-group.full {
            grid-column: 1 / -1;
        }

        .camp-textarea {
            width: 100%;
            min-height: 120px;
            padding: 14px;
            border: 1px solid #ddd;
            border-radius: 14px;
            background: #fff;
            font-size: 14px;
            resize: vertical;
            outline: none;
            transition: var(--transition-fast);
        }

        .camp-textarea:focus {
            border-color: var(--main-green);
            box-shadow: 0 0 0 3px rgba(27, 77, 62, 0.08);
        }

        .camp-form-help {
            margin-top: 8px;
            font-size: 12px;
            color: #888;
        }

        .camp-form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 26px;
        }

        @media (max-width: 768px) {
            .camp-form-page {
                padding: 24px 0 40px;
            }

            .camp-form-grid {
                grid-template-columns: 1fr;
            }

            .camp-form-card {
                padding: 20px;
            }

            .camp-form-title {
                font-size: 24px;
            }

            .camp-form-actions {
                flex-direction: column;
            }

            .camp-form-actions a,
            .camp-form-actions button {
                width: 100%;
            }
        }
    </style>
</head>
<body>

    <jsp:include page="/include/header.jsp" />

    <main class="camp-form-page">
        <div class="container container-box camp-form-wrap">

            <div class="camp-form-header">
                <h1 class="camp-form-title">캠핑장 등록</h1>
                <p class="camp-form-desc">
                    운영 중인 캠핑장 정보를 입력해 등록할 수 있습니다.
                </p>
            </div>

            <div class="card-box camp-form-card">
                <form action="<%=ctx%>/owner/campForm_process.jsp" method="post" enctype="multipart/form-data">
                    <div class="camp-form-grid">

                        <div class="camp-form-group">
                            <label class="filter-label">캠핑장명</label>
                            <input type="text" name="name" class="common-input" placeholder="예: 가평 숲속 글램핑" required>
                        </div>

                        <div class="camp-form-group">
                            <label class="filter-label">유형</label>
                            <select name="type" class="common-select" required>
                                <option value="">선택하세요</option>
                                <option value="글램핑">글램핑</option>
                                <option value="카라반">카라반</option>
                                <option value="오토캠핑">오토캠핑</option>
                                <option value="차박">차박</option>
                                <option value="백패킹">백패킹</option>
                                <option value="펜션">펜션</option>
                                <option value="풀빌라">풀빌라</option>
                            </select>
                        </div>

                        <div class="camp-form-group full">
                            <label class="filter-label">주소</label>
                            <input type="text" name="address" class="common-input" placeholder="예: 경기도 가평군 북면 ..." required>
                        </div>

                        <div class="camp-form-group full">
                            <label class="filter-label">태그</label>
                            <input type="text" name="tags" class="common-input" placeholder="예: 물놀이,깨끗한,가족,반려견">
                            <p class="camp-form-help">쉼표(,)로 구분해서 입력하세요.</p>
                        </div>

                        <div class="camp-form-group">
                            <label class="filter-label">1박 가격</label>
                            <input type="number" name="price" class="common-input" placeholder="예: 150000" min="0" required>
                        </div>

                        <div class="camp-form-group">
                            <label class="filter-label">운영 상태</label>
                            <select name="status" class="common-select">
                                <option value="open">open</option>
                                <option value="hidden">hidden</option>
                                <option value="closed">closed</option>
                            </select>
                        </div>

                        <div class="camp-form-group full">
                            <label class="filter-label">캠핑장 소개</label>
                            <textarea name="description" class="camp-textarea" placeholder="캠핑장 특징, 시설, 추천 포인트 등을 입력하세요."></textarea>
                        </div>

                        <div class="camp-form-group full">
                            <label class="filter-label">대표 이미지</label>
                            <input type="file" name="imageFile" class="common-input" accept="image/*">
                            <p class="camp-form-help">이미지 업로드 기능을 나중에 연결할 경우 사용합니다.</p>
                        </div>

                    </div>

                    <div class="camp-form-actions">
                        <a href="<%=ctx%>/owner/dashboard.jsp" class="btn-soft">취소</a>
                        <button type="submit" class="btn-main-custom">캠핑장 등록</button>
                    </div>
                </form>
            </div>

        </div>
    </main>

</body>
</html>
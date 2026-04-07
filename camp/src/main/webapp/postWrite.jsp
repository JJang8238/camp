<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer loginUserId = (Integer) session.getAttribute("userId");
    if (loginUserId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String postType = request.getParameter("type");
    if (postType == null || (!postType.equals("news") && !postType.equals("event"))) {
        postType = "news";
    }

    boolean isEvent = "event".equals(postType);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>캠프 메이트 | 게시물 작성</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">

    <style>
        .write-page {
            background: #f8f9fa;
            min-height: 100vh;
            padding: 48px 0 80px;
        }

        .write-wrap {
            max-width: 1000px;
            margin: 0 auto;
        }

        .write-top {
            margin-bottom: 26px;
        }

        .write-badge {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(27, 77, 62, 0.08);
            color: var(--main-green);
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 14px;
        }

        .write-type-switch {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 999px;
            padding: 6px;
            box-shadow: var(--card-shadow);
            margin-bottom: 18px;
        }

        .write-type-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 130px;
            height: 44px;
            padding: 0 20px;
            border-radius: 999px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            color: #555;
            background: transparent;
            transition: 0.2s ease;
        }

        .write-type-btn:hover {
            background: #f4f7f6;
            color: var(--main-green);
        }

        .write-type-btn.active {
            background: var(--main-green);
            color: #fff;
        }

        .write-type-btn.event.active {
            background: var(--point-orange);
            color: #fff;
        }

        .write-title {
            font-size: 32px;
            font-weight: 800;
            color: var(--dark-text);
            margin-bottom: 10px;
        }

        .write-desc {
            color: #666;
            font-size: 15px;
            line-height: 1.7;
            margin: 0;
        }

        .write-card {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 28px;
            box-shadow: var(--card-shadow);
            padding: 34px;
        }

        .write-section + .write-section {
            margin-top: 32px;
            padding-top: 28px;
            border-top: 1px solid #f0f0f0;
        }

        .section-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--dark-text);
            margin-bottom: 18px;
        }

        .form-label {
            font-size: 14px;
            font-weight: 700;
            color: #444;
            margin-bottom: 8px;
        }

        .form-control,
        .form-select,
        textarea.form-control {
            border-radius: 16px;
            border: 1px solid #ddd;
            padding: 14px 16px;
            box-shadow: none;
        }

        .form-control:focus,
        .form-select:focus,
        textarea.form-control:focus {
            border-color: var(--main-green);
            box-shadow: 0 0 0 0.2rem rgba(27, 77, 62, 0.12);
        }

        textarea.form-control {
            min-height: 280px;
            resize: vertical;
            line-height: 1.8;
        }

        .help-text {
            font-size: 13px;
            color: #888;
            margin-top: 8px;
        }

        .thumb-preview-box {
            margin-top: 14px;
            border: 1px dashed #d8d8d8;
            border-radius: 18px;
            background: #fafafa;
            min-height: 180px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .thumb-preview-box img {
            width: 100%;
            max-height: 360px;
            object-fit: cover;
            display: none;
        }

        .thumb-preview-text {
            color: #999;
            font-size: 14px;
        }

        .write-actions {
            margin-top: 34px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .btn-line {
            min-width: 120px;
            height: 48px;
            border-radius: 14px;
            border: 1px solid var(--border-color);
            background: #fff;
            color: #555;
            font-weight: 700;
        }

        .btn-submit {
            min-width: 150px;
            height: 48px;
            border: none;
            border-radius: 14px;
            background: <%= isEvent ? "var(--point-orange)" : "var(--main-green)" %>;
            color: #fff;
            font-weight: 700;
        }

        .event-only {
            display: <%= isEvent ? "block" : "none" %>;
        }

        @media (max-width: 768px) {
            .write-page {
                padding: 28px 0 60px;
            }

            .write-title {
                font-size: 26px;
            }

            .write-card {
                padding: 22px;
                border-radius: 22px;
            }

            .write-type-switch {
                display: flex;
                width: 100%;
            }

            .write-type-btn {
                flex: 1;
                min-width: auto;
            }

            .write-actions {
                flex-direction: column;
            }

            .btn-line,
            .btn-submit {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/include/header.jsp" />

    <main class="write-page">
        <div class="container write-wrap">
            <div class="write-top">
                <div class="write-badge">CONTENT ADMIN</div>

                <div class="write-type-switch">
                    <a href="<%=ctx%>/postWrite.jsp?type=news"
                       class="write-type-btn <%= !isEvent ? "active" : "" %>">
                        소식 작성
                    </a>
                    <a href="<%=ctx%>/postWrite.jsp?type=event"
                       class="write-type-btn event <%= isEvent ? "active" : "" %>">
                        이벤트 작성
                    </a>
                </div>

                <h1 class="write-title">
                    <%= isEvent ? "이벤트 작성" : "캠핑 소식 작성" %>
                </h1>
                <p class="write-desc">
                    <%= isEvent
                        ? "이벤트 게시물로 저장되며 기간, 링크, 쿠폰 코드 같은 상세 정보도 함께 입력할 수 있습니다."
                        : "캠핑 소식 게시물로 저장되며 팁, 추천 캠핑장, 안전 정보 같은 일반 콘텐츠를 작성할 수 있습니다." %>
                </p>
            </div>

            <div class="write-card">
                <form action="<%=ctx%>/post/write" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="postType" value="<%= postType %>">

                    <div class="write-section">
                        <div class="section-title">기본 정보</div>

                        <div class="mb-3">
                            <label class="form-label">제목</label>
                            <input type="text" name="title" class="form-control" maxlength="200" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">요약</label>
                            <input type="text" name="summary" class="form-control" maxlength="500" placeholder="목록에 보일 짧은 소개">
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">카테고리</label>
                                <input type="text" name="category" class="form-control"
                                       placeholder="<%= isEvent ? "프로모션, 쿠폰, 모집" : "캠핑 팁, 안전 정보, 추천 캠핑장" %>">
                            </div>

                            <div class="col-md-3 mb-3">
                                <label class="form-label">게시 상태</label>
                                <select name="status" class="form-select">
                                    <option value="draft">임시저장</option>
                                    <option value="published">공개</option>
                                    <option value="hidden">숨김</option>
                                </select>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label class="form-label">상단 고정</label>
                                <select name="isPinned" class="form-select">
                                    <option value="0">일반</option>
                                    <option value="1">고정</option>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">정렬 우선순위</label>
                                <input type="number" name="displayOrder" class="form-control" value="0">
                            </div>

                            <div class="col-md-8 mb-3">
                                <label class="form-label">공개 시각</label>
                                <input type="datetime-local" name="publishedAt" class="form-control">
                                <div class="help-text">비워두면 NULL로 저장되거나 서버 처리 기준값을 사용합니다.</div>
                            </div>
                        </div>
                    </div>

                    <div class="write-section">
                        <div class="section-title">본문</div>

                        <div class="mb-3">
                            <label class="form-label">내용</label>
                            <textarea name="content" class="form-control" required></textarea>
                        </div>
                    </div>

                    <div class="write-section">
                        <div class="section-title">대표 이미지</div>

                        <div class="mb-3">
                            <label class="form-label">이미지 업로드</label>
                            <input type="file" name="imageFile" class="form-control" accept="image/*" onchange="previewImage(this)">
                            <div class="help-text">
                                업로드 파일이 있으면 저장하고, 없으면 아래 직접 경로 입력값을 사용
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">또는 이미지 경로 직접 입력</label>
                            <input type="text" name="thumbnailPath" class="form-control" placeholder="/assets/img/sample.jpg">
                        </div>

                        <div class="thumb-preview-box">
                            <img id="previewImg" alt="미리보기">
                            <div class="thumb-preview-text" id="previewText">이미지를 선택하면 미리보기가 표시됩니다.</div>
                        </div>
                    </div>

                    <div class="write-section event-only">
                        <div class="section-title">이벤트 상세 정보</div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">시작일</label>
                                <input type="date" name="startDate" class="form-control">
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">종료일</label>
                                <input type="date" name="endDate" class="form-control">
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">이벤트 상태</label>
                                <select name="eventStatus" class="form-select">
                                    <option value="upcoming">upcoming</option>
                                    <option value="ongoing">ongoing</option>
                                    <option value="ended">ended</option>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">신청 링크</label>
                                <input type="text" name="applyUrl" class="form-control" placeholder="https://...">
                            </div>

                            <div class="col-md-3 mb-3">
                                <label class="form-label">쿠폰 코드</label>
                                <input type="text" name="couponCode" class="form-control">
                            </div>

                            <div class="col-md-3 mb-3">
                                <label class="form-label">최대 참여 인원</label>
                                <input type="number" name="maxParticipants" class="form-control">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">당첨 발표 시각</label>
                            <input type="datetime-local" name="winnerAnnounceAt" class="form-control">
                        </div>
                    </div>

                    <div class="write-actions">
                        <button type="button" class="btn-line" onclick="history.back()">취소</button>
                        <button type="submit" class="btn-submit">
                            <%= isEvent ? "이벤트 저장" : "소식 저장" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        function previewImage(input) {
            const file = input.files && input.files[0];
            const img = document.getElementById("previewImg");
            const text = document.getElementById("previewText");

            if (!file) {
                img.style.display = "none";
                img.src = "";
                text.style.display = "block";
                return;
            }

            const reader = new FileReader();
            reader.onload = function(e) {
                img.src = e.target.result;
                img.style.display = "block";
                text.style.display = "none";
            };
            reader.readAsDataURL(file);
        }
    </script>
</body>
</html>
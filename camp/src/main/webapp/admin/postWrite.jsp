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
	<link rel="stylesheet" href="<%=ctx%>/assets/css/admin.css">
    
</head>
<body>
    <jsp:include page="/include/header.jsp" />

    <main class="write-page">
        <div class="container write-wrap">
            <div class="write-top">
                <div class="write-badge">CONTENT ADMIN</div>

                <div class="write-type-switch">
                    <a href="<%=ctx%>/admin/postWrite.jsp?type=news"
                       class="write-type-btn <%= !isEvent ? "active" : "" %>">
                        소식 작성
                    </a>
                    <a href="<%=ctx%>/admin/postWrite.jsp?type=event"
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

    <% if (isEvent) { %>
        <select name="category" class="form-select" required>
            <option value="">카테고리 선택</option>
            <option value="프로모션">프로모션</option>
            <option value="쿠폰">쿠폰</option>
            <option value="모집">모집</option>
            <option value="체험단">체험단</option>
            <option value="이벤트">이벤트</option>
        </select>
    <% } else { %>
        <select name="category" class="form-select" required>
            <option value="">카테고리 선택</option>
            <option value="캠핑 팁">캠핑 팁</option>
            <option value="안전 정보">안전 정보</option>
            <option value="추천 캠핑장">추천 캠핑장</option>
            <option value="장비 가이드">장비 가이드</option>
            <option value="공지">공지</option>
        </select>
    <% } %>
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
                        <button type="submit"
    						class="btn btn-lg <%= isEvent ? "btn-point" : "btn-main-custom" %>">
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
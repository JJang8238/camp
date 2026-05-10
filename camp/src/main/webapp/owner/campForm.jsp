<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.CampDAO, dto.Camp, dao.UserDAO, dto.User" %>
<%@ page import="org.apache.commons.fileupload2.jakarta.servlet6.JakartaServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload2.jakarta.servlet6.JakartaServletDiskFileUpload" %>
<%@ page import="org.apache.commons.fileupload2.core.DiskFileItem" %>
<%@ page import="org.apache.commons.fileupload2.core.DiskFileItemFactory" %>
<%@ page import="java.io.*, java.util.List, java.nio.charset.StandardCharsets" %>

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

    if (loginUser == null || !"owner".equalsIgnoreCase(loginUser.getRole())) {
        response.sendRedirect(ctx + "/main.jsp");
        return;
    }

    String errorMsg = "";

    // ── POST 처리 ──
    if (JakartaServletFileUpload.isMultipartContent(request)) {

        DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
        JakartaServletDiskFileUpload upload = new JakartaServletDiskFileUpload(factory);
        upload.setFileSizeMax(10 * 1024 * 1024L);
        upload.setSizeMax(20 * 1024 * 1024L);

        String name = "", address = "", type = "", tags = "";
        String description = "", status = "active", imagePath = "";
        int price = 0;

        try {
            List<DiskFileItem> items = upload.parseRequest(request);

            for (DiskFileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String value = item.getString(StandardCharsets.UTF_8);
                    switch (fieldName) {
                        case "name":        name        = value; break;
                        case "address":     address     = value; break;
                        case "type":        type        = value; break;
                        case "tags":        tags        = value; break;
                        case "description": description = value; break;
                        case "status":      status      = value; break;
                        case "price":
                            try { price = Integer.parseInt(value); }
                            catch (NumberFormatException ignored) {}
                            break;
                    }
                } else {
                    // 파일 처리
                    String fileName = item.getName();
                    if (fileName != null && !fileName.trim().isEmpty() && item.getSize() > 0) {
                        String ext = "";
                        int dotIdx = fileName.lastIndexOf('.');
                        if (dotIdx >= 0) ext = fileName.substring(dotIdx);

                        String uploadDir = application.getRealPath("/assets/img/camps");
                        File dir = new File(uploadDir);
                        if (!dir.exists()) dir.mkdirs();

                        String safeFileName = System.currentTimeMillis() + ext;
                        File dest = new File(dir, safeFileName);
                        item.write(dest.toPath());

                        imagePath = "/assets/img/camps/" + safeFileName;
                    }
                }
            }

            if (name.trim().isEmpty() || address.trim().isEmpty()) {
                errorMsg = "캠핑장명과 주소는 필수 입력 항목입니다.";
            } else {
                Camp camp = new Camp();
                camp.setName(name.trim());
                camp.setAddress(address.trim());
                camp.setType(type);
                camp.setTags(tags);
                camp.setPrice(price);
                camp.setDescription(description);
                camp.setStatus(status);
                camp.setImage(imagePath);

                boolean ok = CampDAO.insertCamp(camp, loginUserId);
                if (ok) {
                    response.sendRedirect(ctx + "/mypage/camp_manage.jsp");
                    return;
                } else {
                    errorMsg = "등록 중 오류가 발생했습니다.";
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            errorMsg = "파일 업로드 중 오류: " + e.getMessage();
        }
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
        .camp-form-wrap { max-width: 860px; }
        .camp-form-title {
            margin: 0 0 8px;
            font-size: 28px; font-weight: 800;
            color: var(--main-green);
        }
        .camp-form-desc { margin: 0 0 24px; font-size: 15px; color: #666; }
        .camp-form-card { padding: 30px; }
        .camp-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        .camp-form-group { display: flex; flex-direction: column; gap: 6px; }
        .camp-form-group.full { grid-column: 1 / -1; }
        .camp-form-group label { font-size: 13px; font-weight: 600; color: #555; }
        .camp-textarea {
            width: 100%; min-height: 120px;
            padding: 12px 14px;
            border: 1.5px solid #dee2e6; border-radius: 10px;
            font-size: 14px; resize: vertical; outline: none;
            box-sizing: border-box; transition: border-color 0.2s;
        }
        .camp-textarea:focus { border-color: var(--main-green); }
        .camp-form-help { font-size: 12px; color: #888; margin-top: 4px; }
        .camp-form-actions {
            display: flex; justify-content: flex-end;
            gap: 10px; margin-top: 26px;
        }
        .img-upload-area {
            border: 2px dashed #dee2e6; border-radius: 12px;
            padding: 30px 20px; text-align: center; cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            background: #fafafa; position: relative;
        }
        .img-upload-area:hover { border-color: var(--main-green); background: #f0f7ee; }
        .img-upload-area input[type="file"] {
            position: absolute; inset: 0; opacity: 0;
            cursor: pointer; width: 100%; height: 100%;
        }
        .img-upload-label { font-size: 14px; color: #888; pointer-events: none; }
        .img-upload-label strong { color: var(--main-green); }
        .img-preview-wrap { margin-top: 12px; display: none; }
        .img-preview-wrap img {
            max-width: 100%; max-height: 200px;
            border-radius: 10px; object-fit: cover;
        }
        .img-file-name { margin-top: 6px; font-size: 13px; color: #2d5a27; font-weight: 600; }
        .alert-error {
            background: #fdecea; color: #c0392b;
            border: 1px solid #f5c6cb; border-radius: 10px;
            padding: 12px 18px; margin-bottom: 20px; font-size: 14px;
        }
        @media (max-width: 768px) {
            .camp-form-grid { grid-template-columns: 1fr; }
            .camp-form-group.full { grid-column: 1; }
            .camp-form-actions { flex-direction: column; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<main class="camp-form-page">
    <div class="container container-box camp-form-wrap">

        <h1 class="camp-form-title">캠핑장 등록</h1>
        <p class="camp-form-desc">운영 중인 캠핑장 정보를 입력해 등록할 수 있습니다.</p>

        <% if (!errorMsg.isEmpty()) { %>
        <div class="alert-error">⚠️ <%=errorMsg%></div>
        <% } %>

        <div class="card-box camp-form-card">
            <form action="" method="post" enctype="multipart/form-data">
                <div class="camp-form-grid">

                    <div class="camp-form-group">
                        <label>캠핑장명 *</label>
                        <input type="text" name="name" class="common-input"
                               placeholder="예: 가평 숲속 글램핑" required>
                    </div>

                    <div class="camp-form-group">
                        <label>유형 *</label>
                        <select name="type" class="common-select" required>
                            <option value="">선택하세요</option>
                            <option value="글램핑">글램핑</option>
                            <option value="카라반">카라반</option>
                            <option value="오토캠핑">오토캠핑</option>
                            <option value="차박/캠핑">차박/캠핑</option>
                            <option value="백패킹">백패킹</option>
                            <option value="펜션">펜션</option>
                            <option value="풀빌라">풀빌라</option>
                        </select>
                    </div>

                    <div class="camp-form-group full">
                        <label>주소 *</label>
                        <input type="text" name="address" class="common-input"
                               placeholder="예: 경기도 가평군 북면 ..." required>
                    </div>

                    <div class="camp-form-group full">
                        <label>태그</label>
                        <input type="text" name="tags" class="common-input"
                               placeholder="예: 물놀이,깨끗한,가족,반려견">
                        <p class="camp-form-help">쉼표(,)로 구분해서 입력하세요.</p>
                    </div>

                    <div class="camp-form-group">
                        <label>1박 가격 *</label>
                        <input type="number" name="price" class="common-input"
                               placeholder="예: 150000" min="0" required>
                    </div>

                    <div class="camp-form-group">
                        <label>운영 상태</label>
                        <select name="status" class="common-select">
                            <option value="active">운영중</option>
                            <option value="hidden">숨김</option>
                            <option value="closed">운영종료</option>
                        </select>
                    </div>

                    <div class="camp-form-group full">
                        <label>캠핑장 소개</label>
                        <textarea name="description" class="camp-textarea"
                                  placeholder="캠핑장 특징, 시설, 추천 포인트 등을 입력하세요."></textarea>
                    </div>

                    <div class="camp-form-group full">
                        <label>대표 이미지</label>
                        <div class="img-upload-area" id="uploadArea">
                            <input type="file" name="imageFile" id="imageFile" accept="image/*">
                            <div class="img-upload-label">
                                🖼️ 클릭해서 이미지 선택 (파일 탐색기 열림)<br>
                                <strong>JPG, PNG, WEBP</strong> · 최대 10MB
                            </div>
                        </div>
                        <div class="img-preview-wrap" id="previewWrap">
                            <img id="previewImg" src="" alt="미리보기">
                            <div class="img-file-name" id="fileNameLabel"></div>
                        </div>
                    </div>

                </div>

                <div class="camp-form-actions">
                    <a href="<%=ctx%>/mypage/camp_manage.jsp" class="btn-soft">취소</a>
                    <button type="submit" class="btn-main-custom">캠핑장 등록</button>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/include/footer.jsp" />
<script>
    document.getElementById('imageFile').addEventListener('change', function () {
        const file = this.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = function (e) {
            document.getElementById('previewImg').src = e.target.result;
            document.getElementById('previewWrap').style.display = 'block';
            document.getElementById('fileNameLabel').textContent = '✅ ' + file.name;
            document.getElementById('uploadArea').style.borderColor = '#2d5a27';
            document.getElementById('uploadArea').style.background = '#f0f7ee';
        };
        reader.readAsDataURL(file);
    });
</script>
</body>
</html>

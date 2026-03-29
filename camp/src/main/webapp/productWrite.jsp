<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/include/head.jsp" />
    <title>상품 등록 | 캠프 메이트</title>

    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/product.css">
</head>
<body>

    <jsp:include page="/include/header.jsp" />

<main class="product-write-page">
    <div class="product-write-wrap">
        <div class="product-write-top">
            <h2 class="product-write-title">중고 상품 등록</h2>
            <p class="product-write-subtitle">간단한 상품 정보를 입력해 주세요.</p>
        </div>

        <div class="card-box product-write-card">
            <form action="<%=ctx%>/product/write_process" method="post" enctype="multipart/form-data">
                <div class="product-form-grid">

<div class="product-form-group full">
    <label for="images" class="product-form-label">
        상품 이미지<span class="required-mark">*</span>
    </label>

    <div class="product-file-box">
        <input
            type="file"
            id="images"
            name="images"
            class="common-input"
            accept="image/*"
            multiple
            required
        >
        <div class="product-file-guide">
            JPG, PNG 파일 업로드 가능 
        </div>

        <div class="product-image-preview-list" id="previewList"></div>
    </div>
</div>

                    <div class="product-form-group full">
                        <label for="title" class="product-form-label">
                            상품 제목<span class="required-mark">*</span>
                        </label>
                        <input
                            type="text"
                            id="title"
                            name="title"
                            class="common-input"
                            maxlength="100"
                            placeholder="상품 제목을 입력하세요"
                            required
                        >
                    </div>

                    <div class="product-form-group full">
                        <label for="description" class="product-form-label">
                            상품 설명<span class="required-mark">*</span>
                        </label>
                        <textarea
                            id="description"
                            name="description"
                            class="common-input"
                            placeholder="상품 상태와 구성품을 적어주세요"
                            required
                        ></textarea>
                    </div>

                    <div class="product-form-group">
                        <label for="price" class="product-form-label">
                            가격<span class="required-mark">*</span>
                        </label>
                        <input
                            type="number"
                            id="price"
                            name="price"
                            class="common-input"
                            min="0"
                            placeholder="가격 입력"
                            required
                        >
                    </div>

                    <div class="product-form-group">
                        <label for="category" class="product-form-label">
                            카테고리<span class="required-mark">*</span>
                        </label>
                        <select id="category" name="category" class="common-select" required>
                            <option value="">선택</option>
                            <option value="텐트">텐트</option>
                            <option value="테이블">테이블</option>
                            <option value="의자">의자</option>
                            <option value="랜턴">랜턴</option>
                            <option value="침낭">침낭</option>
                            <option value="매트">매트</option>
                            <option value="버너/조리도구">버너/조리도구</option>
                            <option value="기타">기타</option>
                        </select>
                    </div>

                    <div class="product-form-group full">
                        <label for="location" class="product-form-label">
                            거래 지역<span class="required-mark">*</span>
                        </label>
                        <input
                            type="text"
                            id="location"
                            name="location"
                            class="common-input"
                            maxlength="100"
                            placeholder="예: 서울 강남구"
                            required
                        >
                    </div>
                </div>

                <div class="product-write-btns">
                    <a href="<%=ctx%>/productList.jsp" class="btn-soft">취소</a>
                    <button type="submit" class="btn-main-custom">등록</button>
                </div>
            </form>
        </div>
    </div>
</main>
    <jsp:include page="/include/footer.jsp" />

    <script>
document.addEventListener("DOMContentLoaded", function () {
    const imageInput = document.getElementById("images");
    const previewList = document.getElementById("previewList");

    if (!imageInput || !previewList) return;

    let selectedFiles = [];

    function syncFileInput() {
        const dataTransfer = new DataTransfer();

        selectedFiles.forEach(function (file) {
            dataTransfer.items.add(file);
        });

        imageInput.files = dataTransfer.files;
    }

    function renderPreview() {
        previewList.innerHTML = "";

        selectedFiles.forEach(function (file, index) {
            if (!file.type.startsWith("image/")) return;

            const reader = new FileReader();

            reader.onload = function (e) {
                const item = document.createElement("div");
                item.className = "product-image-preview-item";

                const img = document.createElement("img");
                img.src = e.target.result;
                img.alt = "미리보기 이미지";
                img.className = "product-image-preview";

                const removeBtn = document.createElement("button");
                removeBtn.type = "button";
                removeBtn.className = "product-image-remove-btn";
                removeBtn.textContent = "×";

                removeBtn.addEventListener("click", function () {
                    selectedFiles.splice(index, 1);
                    syncFileInput();
                    renderPreview();
                });

                item.appendChild(img);
                item.appendChild(removeBtn);
                previewList.appendChild(item);
            };

            reader.readAsDataURL(file);
        });
    }

    imageInput.addEventListener("change", function () {
        const newFiles = Array.from(this.files);

        newFiles.forEach(function (newFile) {
            const exists = selectedFiles.some(function (file) {
                return file.name === newFile.name &&
                       file.size === newFile.size &&
                       file.lastModified === newFile.lastModified;
            });

            if (!exists) {
                selectedFiles.push(newFile);
            }
        });

        syncFileInput();
        renderPreview();
    });
});
</script>

</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.ProductDAO, dto.Product" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.isEmpty()) {
        response.sendRedirect(ctx + "/owner/productManage.jsp");
        return;
    }

    int productId = 0;
    try { productId = Integer.parseInt(idStr); }
    catch (Exception e) {
        response.sendRedirect(ctx + "/owner/productManage.jsp");
        return;
    }

    ProductDAO productDAO = new ProductDAO();
    Product product = productDAO.getProductById(productId);

    // 본인 소유 확인
    if (product == null || product.getSellerId() != userId) {
        response.sendRedirect(ctx + "/owner/productManage.jsp");
        return;
    }

    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String name        = request.getParameter("name");
        String description = request.getParameter("description");
        String category    = request.getParameter("category");
        String location    = request.getParameter("location");
        String status      = request.getParameter("status");
        int price = 0;
        try { price = Integer.parseInt(request.getParameter("price")); }
        catch (NumberFormatException ignored) {}

        if (name == null || name.trim().isEmpty()) {
            errorMsg = "상품명은 필수 입력 항목입니다.";
        } else {
            boolean ok = productDAO.updateProduct(productId, userId, name.trim(),
                                                  description, category, location, price, status);
            if (ok) {
                response.sendRedirect(ctx + "/owner/productManage.jsp");
                return;
            } else {
                errorMsg = "수정 중 오류가 발생했습니다.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상품 수정 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <style>
        body { background: #f5f4f0; }

        .page-wrapper {
            max-width: 700px;
            margin: 48px auto 80px;
            padding: 0 24px;
        }

        .page-top {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 28px;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            border: 1.5px solid #dee2e6;
            border-radius: 20px;
            font-size: 13px;
            color: #555;
            text-decoration: none;
            background: white;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-back:hover { border-color: #2d5a27; color: #2d5a27; text-decoration: none; }
        .page-title { font-size: 22px; font-weight: 700; color: #1a1a1a; margin: 0; }

        .alert-success {
            background: #e8f5e9; color: #2d5a27;
            border: 1px solid #c8e6c9; border-radius: 10px;
            padding: 12px 18px; margin-bottom: 20px; font-size: 14px;
        }
        .alert-error {
            background: #fdecea; color: #c0392b;
            border: 1px solid #f5c6cb; border-radius: 10px;
            padding: 12px 18px; margin-bottom: 20px; font-size: 14px;
        }

        .form-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            border: 1.5px solid #e9ecef;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group.full { grid-column: 1 / -1; }
        .form-group label { font-size: 13px; font-weight: 600; color: #555; }

        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 10px 14px;
            border: 1.5px solid #dee2e6; border-radius: 8px;
            font-size: 14px; outline: none;
            transition: border-color 0.2s;
            box-sizing: border-box; width: 100%;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus { border-color: #2d5a27; }
        .form-group textarea { height: 120px; resize: vertical; }

        /* 현재 이미지 */
        .current-img-wrap {
            margin-bottom: 8px;
        }
        .current-img-wrap img {
            width: 100px; height: 80px;
            object-fit: cover; border-radius: 8px;
            border: 1.5px solid #dee2e6;
        }
        .current-img-label { font-size: 11px; color: #aaa; margin-top: 4px; }

        .form-actions {
            display: flex; justify-content: space-between;
            align-items: center; margin-top: 24px;
        }
        .btn-cancel {
            padding: 11px 24px;
            border: 1.5px solid #dee2e6; border-radius: 8px;
            font-size: 14px; font-weight: 600;
            color: #555; background: white;
            text-decoration: none;
            transition: border-color 0.2s;
        }
        .btn-cancel:hover { border-color: #999; text-decoration: none; color: #333; }

        .btn-save {
            padding: 11px 28px;
            background: #2d5a27; color: white;
            border: none; border-radius: 8px;
            font-size: 14px; font-weight: 700;
            cursor: pointer; transition: background 0.2s;
        }
        .btn-save:hover { background: #1e3d1b; }

        .btn-delete {
            padding: 11px 20px;
            background: white; color: #e74c3c;
            border: 1.5px solid #e74c3c; border-radius: 8px;
            font-size: 14px; font-weight: 600;
            cursor: pointer; transition: background 0.2s, color 0.2s;
        }
        .btn-delete:hover { background: #e74c3c; color: white; }

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full { grid-column: 1; }
            .form-actions { flex-wrap: wrap; gap: 10px; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/owner/productManage.jsp" class="btn-back">← 상품 관리</a>
        <h2 class="page-title">✏️ 상품 수정</h2>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <div class="form-card">
        <form method="post" action="">
            <div class="form-grid">

                <div class="form-group full">
                    <label>상품명 *</label>
                    <input type="text" name="name"
                           value="<%=product.getName() != null ? product.getName() : ""%>" required>
                </div>

                <div class="form-group">
                    <label>카테고리</label>
                    <select name="category">
                        <option value="">선택하세요</option>
                        <%
                            String[] cats = {"텐트","의자","테이블","랜턴","취사도구","침낭","배낭","기타"};
                            for (String cat : cats) {
                                String sel = cat.equals(product.getCategory()) ? "selected" : "";
                        %>
                        <option value="<%=cat%>" <%=sel%>><%=cat%></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>거래 위치</label>
                    <input type="text" name="location"
                           value="<%=product.getLocation() != null ? product.getLocation() : ""%>"
                           placeholder="예: 수원시">
                </div>

                <div class="form-group">
                    <label>가격 (원) *</label>
                    <input type="number" name="price" min="0"
                           value="<%=product.getPrice()%>" required>
                </div>

                <div class="form-group">
                    <label>판매 상태</label>
                    <select name="status">
                        <%
                            String[] statuses = {"SELLING", "RESERVED", "SOLD"};
                            String[] statusLabels = {"판매중", "예약중", "판매완료"};
                            for (int i = 0; i < statuses.length; i++) {
                                String sel = statuses[i].equalsIgnoreCase(product.getStatus()) ? "selected" : "";
                        %>
                        <option value="<%=statuses[i]%>" <%=sel%>><%=statusLabels[i]%></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group full">
                    <label>상품 설명</label>
                    <textarea name="description"
                              placeholder="상품 상태, 사용 횟수 등을 입력하세요."><%=product.getDescription() != null ? product.getDescription() : ""%></textarea>
                </div>

                <%-- 현재 이미지 표시 --%>
                <% if (product.getImage() != null && !product.getImage().isEmpty()) {
                    String imgSrc = product.getImage().startsWith("http")
                        ? product.getImage()
                        : ctx + "/assets/img/" + product.getImage();
                %>
                <div class="form-group full">
                    <label>현재 이미지</label>
                    <div class="current-img-wrap">
                        <img src="<%=imgSrc%>" alt="현재 이미지"
                             onerror="this.src='<%=ctx%>/assets/img/default.jpg'">
                        <div class="current-img-label">이미지 변경은 추후 지원 예정</div>
                    </div>
                </div>
                <% } %>

            </div>

            <div class="form-actions">
                <%-- 삭제(숨김) 버튼 --%>
                <form method="post" action="<%=ctx%>/productDelete.jsp"
                      onsubmit="return confirm('이 상품을 삭제할까요?');" style="margin:0;">
                    <input type="hidden" name="productId" value="<%=productId%>">
                    <button type="submit" class="btn-delete">🗑 삭제</button>
                </form>

                <div style="display:flex; gap:10px;">
                    <a href="<%=ctx%>/owner/productManage.jsp" class="btn-cancel">취소</a>
                    <button type="submit" class="btn-save">수정 완료</button>
                </div>
            </div>
        </form>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

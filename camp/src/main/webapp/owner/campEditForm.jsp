<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.CampDAO, dto.Camp" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String campIdStr = request.getParameter("id");
    if (campIdStr == null || campIdStr.isEmpty()) {
        response.sendRedirect(ctx + "/mypage/camp_manage.jsp");
        return;
    }

    int campId = 0;
    try { campId = Integer.parseInt(campIdStr); } catch (Exception e) {
        response.sendRedirect(ctx + "/mypage/camp_manage.jsp");
        return;
    }

    CampDAO campDao = new CampDAO();
    Camp camp = campDao.getCampById(campId);

    if (camp == null) {
        response.sendRedirect(ctx + "/mypage/camp_manage.jsp");
        return;
    }

    // 수정 POST 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String name        = request.getParameter("name");
        String address     = request.getParameter("address");
        String type        = request.getParameter("type");
        String tags        = request.getParameter("tags");
        String description = request.getParameter("description");
        String status      = request.getParameter("status");
        int price = 0;
        try { price = Integer.parseInt(request.getParameter("price")); } catch (Exception ignored) {}

        if (name == null || name.trim().isEmpty() || address == null || address.trim().isEmpty()) {
            errorMsg = "캠핑장명과 주소는 필수 입력 항목입니다.";
        } else {
            boolean ok = CampDAO.updateCamp(campId, userId, name.trim(), address.trim(),
                                            type, tags, price, description, status);
            if (ok) {
                successMsg = "캠핑장 정보가 수정되었습니다.";
                camp = campDao.getCampById(campId); // 갱신
            } else {
                errorMsg = "수정 중 오류가 발생했습니다. (권한 확인)";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠핑장 수정 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <style>
        body { background: #f5f4f0; }

        .page-wrapper {
            max-width: 800px;
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

        .form-group label {
            font-size: 13px;
            font-weight: 600;
            color: #555;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 10px 14px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
            box-sizing: border-box;
            width: 100%;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus { border-color: #2d5a27; }

        .form-group textarea { height: 120px; resize: vertical; }

        .form-hint { font-size: 11px; color: #aaa; }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 24px;
        }
        .btn-cancel {
            padding: 11px 24px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            color: #555;
            background: white;
            text-decoration: none;
            transition: border-color 0.2s;
        }
        .btn-cancel:hover { border-color: #999; text-decoration: none; color: #333; }

        .btn-save {
            padding: 11px 28px;
            background: #2d5a27;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-save:hover { background: #1e3d1b; }

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-group.full { grid-column: 1; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/camp_manage.jsp" class="btn-back">← 캠핑장 관리</a>
        <h2 class="page-title">✏️ 캠핑장 수정</h2>
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

                <div class="form-group">
                    <label>캠핑장명 *</label>
                    <input type="text" name="name"
                           value="<%=camp.getName() != null ? camp.getName() : ""%>" required>
                </div>

                <div class="form-group">
                    <label>유형</label>
                    <select name="type">
                        <option value="">선택하세요</option>
                        <%
                            String[] types = {"글램핑","카라반","오토캠핑","차박","백패킹","펜션","풀빌라","차박/캠핑"};
                            for (String t : types) {
                                String selected = t.equals(camp.getType()) ? "selected" : "";
                        %>
                        <option value="<%=t%>" <%=selected%>><%=t%></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group full">
                    <label>주소 *</label>
                    <input type="text" name="address"
                           value="<%=camp.getAddress() != null ? camp.getAddress() : ""%>" required>
                </div>

                <div class="form-group full">
                    <label>태그</label>
                    <input type="text" name="tags"
                           value="<%=camp.getTags() != null ? camp.getTags() : ""%>"
                           placeholder="예: 물놀이,깨끗한,가족,반려견">
                    <span class="form-hint">쉼표(,)로 구분해서 입력하세요.</span>
                </div>

                <div class="form-group">
                    <label>1박 가격 (원)</label>
                    <input type="number" name="price" min="0"
                           value="<%=camp.getPrice()%>">
                </div>

                <div class="form-group">
                    <label>운영 상태</label>
                    <select name="status">
                        <%
                            String[] statuses = {"open", "hidden", "closed"};
                            String[] statusLabels = {"운영중", "숨김", "운영종료"};
                            for (int i = 0; i < statuses.length; i++) {
                                String sel = statuses[i].equals(camp.getStatus()) ? "selected" : "";
                        %>
                        <option value="<%=statuses[i]%>" <%=sel%>><%=statusLabels[i]%></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group full">
                    <label>캠핑장 소개</label>
                    <textarea name="description"
                              placeholder="캠핑장 특징, 시설, 추천 포인트 등을 입력하세요."><%=camp.getDescription() != null ? camp.getDescription() : ""%></textarea>
                </div>

            </div>

            <div class="form-actions">
                <a href="<%=ctx%>/mypage/camp_manage.jsp" class="btn-cancel">취소</a>
                <button type="submit" class="btn-save">수정 완료</button>
            </div>
        </form>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

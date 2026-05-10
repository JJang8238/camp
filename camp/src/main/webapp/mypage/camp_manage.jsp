<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.CampDAO, dto.Camp, java.util.List" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");
    String userName = (String) session.getAttribute("userName");
    String username = (String) session.getAttribute("username");

    if (userId == null || !"owner".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String displayName = (userName != null && !userName.isEmpty()) ? userName : username;

    // 내 캠핑장 목록 조회 (owner_id 기준)
    List<Camp> myCamps = CampDAO.getCampsByOwnerId(userId);

    // 삭제/상태변경 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        String action  = request.getParameter("action");
        String campIdStr = request.getParameter("campId");

        if (campIdStr != null && !campIdStr.isEmpty()) {
            try {
                int campId = Integer.parseInt(campIdStr);

                if ("delete".equals(action)) {
                    boolean ok = CampDAO.deleteCamp(campId, userId);
                    if (ok) successMsg = "캠핑장이 삭제되었습니다.";
                    else    errorMsg   = "삭제 중 오류가 발생했습니다.";
                } else if ("toggleStatus".equals(action)) {
                    String newStatus = request.getParameter("newStatus");
                    boolean ok = CampDAO.updateCampStatus(campId, userId, newStatus);
                    if (ok) successMsg = "운영 상태가 변경되었습니다.";
                    else    errorMsg   = "상태 변경 중 오류가 발생했습니다.";
                }

                // 처리 후 목록 갱신
                myCamps = CampDAO.getCampsByOwnerId(userId);

            } catch (NumberFormatException e) {
                errorMsg = "잘못된 요청입니다.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠핑장 관리 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/common.css">
    <style>
        body { background: #f5f4f0; }

        .page-wrapper {
            max-width: 960px;
            margin: 48px auto 80px;
            padding: 0 24px;
        }

        /* 상단 */
        .page-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
        }
        .page-top-left { display: flex; align-items: center; gap: 12px; }

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

        .btn-register {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #2d5a27;
            color: white;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-register:hover { background: #1e3d1b; color: white; text-decoration: none; }

        /* 알림 */
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

        /* 캠핑장 카드 */
        .camp-card {
            background: white;
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
            overflow: hidden;
            margin-bottom: 18px;
            display: flex;
            transition: box-shadow 0.2s;
        }
        .camp-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.08); }

        .camp-thumb {
            width: 160px;
            flex-shrink: 0;
            object-fit: cover;
            background: #f0f7ee;
        }
        .camp-thumb-placeholder {
            width: 160px;
            flex-shrink: 0;
            background: #f0f7ee;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
        }

        .camp-body {
            flex: 1;
            padding: 22px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
        }

        .camp-info { flex: 1; }

        .camp-name {
            font-size: 17px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 6px;
        }

        .camp-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            font-size: 13px;
            color: #777;
            margin-bottom: 10px;
        }

        .camp-tags { display: flex; flex-wrap: wrap; gap: 5px; }
        .tag-chip {
            background: #f0f7ee;
            color: #2d5a27;
            font-size: 11px;
            font-weight: 600;
            padding: 2px 9px;
            border-radius: 20px;
        }

        /* 상태 배지 */
        .badge-status {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-open   { background: #e8f5e9; color: #2d5a27; }
        .badge-hidden { background: #fff8e1; color: #f57c00; }
        .badge-closed { background: #fdecea; color: #c0392b; }

        /* 액션 버튼 */
        .camp-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-shrink: 0;
        }

        .btn-edit {
            padding: 7px 18px;
            border: 1.5px solid #2d5a27;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #2d5a27;
            background: white;
            text-decoration: none;
            text-align: center;
            transition: background 0.2s, color 0.2s;
        }
        .btn-edit:hover { background: #2d5a27; color: white; text-decoration: none; }

        .btn-toggle {
            padding: 7px 18px;
            border: 1.5px solid #f57c00;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #f57c00;
            background: white;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-toggle:hover { background: #f57c00; color: white; }

        .btn-delete {
            padding: 7px 18px;
            border: 1.5px solid #e74c3c;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            color: #e74c3c;
            background: white;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-delete:hover { background: #e74c3c; color: white; }

        /* 빈 상태 */
        .empty-box {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
        }
        .empty-icon { font-size: 52px; margin-bottom: 16px; }
        .empty-box p { font-size: 15px; color: #aaa; margin: 0 0 20px; }

        @media (max-width: 600px) {
            .camp-card { flex-direction: column; }
            .camp-thumb, .camp-thumb-placeholder { width: 100%; height: 160px; }
            .camp-body { flex-direction: column; align-items: flex-start; }
            .camp-actions { flex-direction: row; flex-wrap: wrap; }
        }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <div class="page-top-left">
            <a href="<%=ctx%>/mypage/owner_mypage.jsp" class="btn-back">← 마이페이지</a>
            <h2 class="page-title">🏕️ 캠핑장 관리</h2>
        </div>
        <a href="<%=ctx%>/owner/campForm.jsp" class="btn-register">+ 새 캠핑장 등록</a>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <% if (myCamps == null || myCamps.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">🏕️</div>
        <p>등록된 캠핑장이 없습니다.</p>
        <a href="<%=ctx%>/owner/campForm.jsp" class="btn-register">첫 캠핑장 등록하기</a>
    </div>

    <% } else {
        for (Camp camp : myCamps) {

            // 이미지 경로
            String rawImg = camp.getImage();
            String imgPath = null;
            if (rawImg != null && !rawImg.trim().isEmpty()) {
                rawImg = rawImg.trim();
                if (rawImg.startsWith("http://") || rawImg.startsWith("https://")) {
                    imgPath = rawImg;
                } else if (rawImg.startsWith("/")) {
                    imgPath = ctx + rawImg;
                } else {
                    imgPath = ctx + "/assets/img/" + rawImg;
                }
            }

            String campStatus = camp.getStatus() != null ? camp.getStatus() : "open";
            String badgeClass, badgeLabel, toggleLabel, toggleStatus;

            switch (campStatus.toLowerCase()) {
                case "open":
                    badgeClass = "badge-open"; badgeLabel = "운영중";
                    toggleLabel = "숨김 처리"; toggleStatus = "hidden"; break;
                case "hidden":
                    badgeClass = "badge-hidden"; badgeLabel = "숨김";
                    toggleLabel = "운영 재개"; toggleStatus = "open"; break;
                case "closed":
                    badgeClass = "badge-closed"; badgeLabel = "운영종료";
                    toggleLabel = "운영 재개"; toggleStatus = "open"; break;
                default:
                    badgeClass = "badge-open"; badgeLabel = campStatus;
                    toggleLabel = "숨김 처리"; toggleStatus = "hidden";
            }
    %>
    <div class="camp-card">

        <% if (imgPath != null) { %>
        <img src="<%=imgPath%>" class="camp-thumb"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
             alt="캠핑장 이미지">
        <div class="camp-thumb-placeholder" style="display:none">🏕️</div>
        <% } else { %>
        <div class="camp-thumb-placeholder">🏕️</div>
        <% } %>

        <div class="camp-body">
            <div class="camp-info">
                <div class="camp-name">
                    <%=camp.getName()%>
                    <span class="badge-status <%=badgeClass%>" style="margin-left:8px;"><%=badgeLabel%></span>
                </div>
                <div class="camp-meta">
                    <% if (camp.getAddress() != null) { %><span>📍 <%=camp.getAddress()%></span><% } %>
                    <% if (camp.getType() != null) { %><span>🏠 <%=camp.getType()%></span><% } %>
                    <span>💰 <%=String.format("%,d", camp.getPrice())%>원</span>
                </div>
                <% if (camp.getTags() != null && !camp.getTags().isEmpty()) { %>
                <div class="camp-tags">
                    <% for (String tag : camp.getTags().split(",")) {
                        if (!tag.trim().isEmpty()) { %>
                    <span class="tag-chip">#<%=tag.trim()%></span>
                    <%  }
                    } %>
                </div>
                <% } %>
            </div>

            <div class="camp-actions">
                <%-- 수정 버튼 --%>
                <a href="<%=ctx%>/owner/campEditForm.jsp?id=<%=camp.getId()%>" class="btn-edit">✏️ 수정</a>

                <%-- 운영 상태 변경 --%>
                <form method="post" action="" style="margin:0;">
                    <input type="hidden" name="action" value="toggleStatus">
                    <input type="hidden" name="campId" value="<%=camp.getId()%>">
                    <input type="hidden" name="newStatus" value="<%=toggleStatus%>">
                    <button type="submit" class="btn-toggle"><%=toggleLabel%></button>
                </form>

                <%-- 삭제 --%>
                <form method="post" action="" style="margin:0;"
                      onsubmit="return confirm('정말 삭제할까요? 복구할 수 없습니다.');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="campId" value="<%=camp.getId()%>">
                    <button type="submit" class="btn-delete">🗑 삭제</button>
                </form>
            </div>
        </div>
    </div>
    <%
        }
    } %>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

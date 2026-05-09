<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dao.UserDAO, dto.User" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    String role    = (String)  session.getAttribute("role");

    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    User user = userDAO.getUserById(userId);
    userDAO.close();

    // 폼 처리
    String successMsg = "";
    String errorMsg   = "";

    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");

        if ("profile".equals(action)) {
            // ── 이름 · 이메일 수정 ──
            String newName  = request.getParameter("name")  != null ? request.getParameter("name").trim()  : "";
            String newEmail = request.getParameter("email") != null ? request.getParameter("email").trim() : "";

            if (newName.isEmpty() || newEmail.isEmpty()) {
                errorMsg = "이름과 이메일을 모두 입력해주세요.";
            } else {
                UserDAO dao2 = new UserDAO();
                boolean ok = dao2.updateProfile(userId, newName, newEmail);
                dao2.close();

                if (ok) {
                    // 세션 갱신
                    session.setAttribute("userName", newName);
                    successMsg = "회원정보가 수정되었습니다.";
                    // user 객체 갱신
                    user.setName(newName);
                    user.setEmail(newEmail);
                } else {
                    errorMsg = "수정 중 오류가 발생했습니다. (이메일 중복 여부 확인)";
                }
            }

        } else if ("password".equals(action)) {
            // ── 비밀번호 변경 ──
            String currentPw = request.getParameter("currentPw") != null ? request.getParameter("currentPw") : "";
            String newPw     = request.getParameter("newPw")     != null ? request.getParameter("newPw")     : "";
            String confirmPw = request.getParameter("confirmPw") != null ? request.getParameter("confirmPw") : "";

            if (currentPw.isEmpty() || newPw.isEmpty() || confirmPw.isEmpty()) {
                errorMsg = "모든 비밀번호 항목을 입력해주세요.";
            } else if (!newPw.equals(confirmPw)) {
                errorMsg = "새 비밀번호가 일치하지 않습니다.";
            } else if (newPw.length() < 6) {
                errorMsg = "새 비밀번호는 6자 이상이어야 합니다.";
            } else {
                UserDAO dao2 = new UserDAO();
                boolean ok = dao2.updatePassword(userId, currentPw, newPw);
                dao2.close();

                if (ok) {
                    successMsg = "비밀번호가 변경되었습니다.";
                } else {
                    errorMsg = "현재 비밀번호가 올바르지 않습니다.";
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원정보 수정 | Camp Mate</title>
    <%@ include file="/include/head.jsp" %>
    <style>
        body { background: #f8f9fa; }

        .page-wrapper {
            max-width: 600px;
            margin: 60px auto;
            padding: 0 20px 80px;
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

        /* 섹션 카드 */
        .section-card {
            background: white;
            border: 1.5px solid #e9ecef;
            border-radius: 14px;
            padding: 28px;
            margin-bottom: 20px;
        }
        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f1f3f5;
        }

        /* 폼 */
        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }
        .form-group input {
            width: 100%;
            padding: 10px 14px;
            border: 1.5px solid #dee2e6;
            border-radius: 8px;
            font-size: 14px;
            color: #1a1a1a;
            box-sizing: border-box;
            transition: border-color 0.2s;
            outline: none;
        }
        .form-group input:focus { border-color: #2d5a27; }
        .form-group input[readonly] { background: #f8f9fa; color: #aaa; cursor: not-allowed; }

        .hint { font-size: 11px; color: #aaa; margin-top: 4px; }

        /* 버튼 */
        .btn-submit {
            width: 100%;
            padding: 12px;
            background: #2d5a27;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 4px;
            transition: background 0.2s;
        }
        .btn-submit:hover { background: #1e3d1b; }
    </style>
</head>
<body>

<jsp:include page="/include/header.jsp" />

<div class="page-wrapper">

    <div class="page-top">
        <a href="<%=ctx%>/mypage/user_mypage.jsp" class="btn-back">← 마이페이지</a>
        <h2 class="page-title">⚙️ 회원정보 수정</h2>
    </div>

    <% if (!successMsg.isEmpty()) { %>
    <div class="alert-success">✅ <%=successMsg%></div>
    <% } %>
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-error">⚠️ <%=errorMsg%></div>
    <% } %>

    <%-- ── 기본 정보 수정 ── --%>
    <div class="section-card">
        <div class="section-title">👤 기본 정보</div>
        <form method="post" action="">
            <input type="hidden" name="action" value="profile">

            <div class="form-group">
                <label>아이디</label>
                <input type="text" value="<%=user != null ? user.getUserId() : ""%>" readonly>
                <div class="hint">아이디는 변경할 수 없습니다.</div>
            </div>

            <div class="form-group">
                <label>이름</label>
                <input type="text" name="name" value="<%=user != null && user.getName() != null ? user.getName() : ""%>" required>
            </div>

            <div class="form-group">
                <label>이메일</label>
                <input type="email" name="email" value="<%=user != null && user.getEmail() != null ? user.getEmail() : ""%>" required>
            </div>

            <button type="submit" class="btn-submit">정보 수정하기</button>
        </form>
    </div>

    <%-- ── 비밀번호 변경 ── --%>
    <div class="section-card">
        <div class="section-title">🔐 비밀번호 변경</div>
        <form method="post" action="">
            <input type="hidden" name="action" value="password">

            <div class="form-group">
                <label>현재 비밀번호</label>
                <input type="password" name="currentPw" placeholder="현재 비밀번호 입력" required>
            </div>

            <div class="form-group">
                <label>새 비밀번호</label>
                <input type="password" name="newPw" id="newPw" placeholder="6자 이상 입력" required>
            </div>

            <div class="form-group">
                <label>새 비밀번호 확인</label>
                <input type="password" name="confirmPw" id="confirmPw" placeholder="새 비밀번호 재입력" required>
                <div class="hint" id="pwMatchHint"></div>
            </div>

            <button type="submit" class="btn-submit">비밀번호 변경하기</button>
        </form>
    </div>

</div>

<jsp:include page="/include/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 비밀번호 일치 여부 실시간 확인
    const newPw     = document.getElementById('newPw');
    const confirmPw = document.getElementById('confirmPw');
    const hint      = document.getElementById('pwMatchHint');

    function checkMatch() {
        if (confirmPw.value === '') { hint.textContent = ''; return; }
        if (newPw.value === confirmPw.value) {
            hint.textContent = '✅ 비밀번호가 일치합니다.';
            hint.style.color = '#2d5a27';
        } else {
            hint.textContent = '❌ 비밀번호가 일치하지 않습니다.';
            hint.style.color = '#c0392b';
        }
    }

    newPw.addEventListener('input', checkMatch);
    confirmPw.addEventListener('input', checkMatch);
</script>
</body>
</html>

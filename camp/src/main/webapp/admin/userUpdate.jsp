<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 1. 관리자 권한 체크
    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 2. 파라미터 수신 (업데이트 데이터)
    String idStr = request.getParameter("id");
    String newRole = request.getParameter("newRole");
    String newStatus = request.getParameter("newStatus");

    // 3. 리다이렉트 시 유지할 필터 값
    String keyword = request.getParameter("keyword");
    String statusFilter = request.getParameter("statusFilter");
    String roleFilter = request.getParameter("roleFilter");

    if (keyword == null) keyword = "";
    if (statusFilter == null) statusFilter = "";
    if (roleFilter == null) roleFilter = "";

    // 유효성 검사
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/users.jsp");
        return;
    }

    int id = Integer.parseInt(idStr);
    UserDAO dao = new UserDAO();
    boolean result = dao.updateUserRoleAndStatus(id, newRole, newStatus);

    // 4. 결과에 따른 이동 (인코딩 처리 포함)
    String redirectUrl = ctx + "/admin/users.jsp?keyword=" + URLEncoder.encode(keyword, "UTF-8")
            + "&status=" + URLEncoder.encode(statusFilter, "UTF-8")
            + "&userRole=" + URLEncoder.encode(roleFilter, "UTF-8");

    if (result) {
%>
    <script>
        alert("성공적으로 변경(승인)되었습니다.");
        location.href = "<%=redirectUrl%>";
    </script>
<%
    } else {
%>
    <script>
        alert("회원 정보 변경에 실패했습니다.");
        history.back();
    </script>
<%
    }
%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.ReservationDAO, dao.AdminLogDAO" %>
<%@ page import="java.util.Map, java.util.LinkedHashMap" %>
<%--
    reservationAction.jsp
    관리자 예약 상태 변경 처리 (승인 / 거절 / 취소 / 완료)
    호출: POST /admin/reservationAction.jsp
    파라미터: id (예약 id), action (approve | reject | cancel | complete)
--%>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminId = (Integer) session.getAttribute("userId");
    String  role    = (String)  session.getAttribute("role");

    if (adminId == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr  = request.getParameter("id");
    String action = request.getParameter("action");
    String referer = request.getParameter("referer"); // 돌아갈 페이지 (detail or list)

    if (idStr == null || action == null) {
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        return;
    }

    int reservationId;
    try {
        reservationId = Integer.parseInt(idStr);
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        return;
    }

    // 허용된 액션만 처리
    Map<String, String> actionMap = new LinkedHashMap<>();
    actionMap.put("approve",  "approved");
    actionMap.put("reject",   "rejected");
    actionMap.put("cancel",   "cancelled");
    actionMap.put("complete", "completed");

    String newStatus = actionMap.get(action);
    if (newStatus == null) {
        response.sendRedirect(ctx + "/admin/reservations.jsp?result=error");
        return;
    }

    boolean ok = ReservationDAO.updateStatus(reservationId, newStatus);

    // ✅ 관리자 로그 기록 (admin_logs 테이블에 저장)
    if (ok) {
        try {
            String logSql =
                "INSERT INTO admin_logs (admin_id, action, target_type, target_id, detail) " +
                "VALUES (?, ?, 'reservation', ?, ?)";
            try (java.sql.Connection conn = util.DBUtil.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, adminId);
                ps.setString(2, "reservation_" + action);
                ps.setInt(3, reservationId);
                ps.setString(4, "예약 #" + reservationId + " → " + newStatus);
                ps.executeUpdate();
            }
        } catch (Exception logEx) {
            logEx.printStackTrace(); // 로그 실패는 무시하고 계속
        }
    }

    // 결과 파라미터 결정
    String resultParam = ok ? "result=" + action + "&id=" + reservationId
                            : "result=error";

    // 돌아갈 위치: detail 페이지 or 목록
    if ("detail".equals(referer)) {
        response.sendRedirect(ctx + "/admin/reservationDetail.jsp?id=" + reservationId + "&" + resultParam);
    } else {
        response.sendRedirect(ctx + "/admin/reservations.jsp?" + resultParam);
    }
%>

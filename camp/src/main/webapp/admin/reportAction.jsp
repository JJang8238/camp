<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="dao.AdminLogDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Integer adminUserId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (adminUserId == null || role == null || !"admin".equals(role)) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String idStr     = request.getParameter("id");
    String action    = request.getParameter("action");
    String targetType = request.getParameter("targetType");
    String targetIdStr = request.getParameter("targetId");

    // 파라미터 검증
    if (idStr == null || idStr.trim().isEmpty() ||
        action == null || action.trim().isEmpty()) {
        response.sendRedirect(ctx + "/admin/reports.jsp?result=error");
        return;
    }

    int reportId = 0;
    int targetId = 0;
    try {
        reportId = Integer.parseInt(idStr.trim());
        if (targetIdStr != null && !targetIdStr.trim().isEmpty()) {
            targetId = Integer.parseInt(targetIdStr.trim());
        }
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/admin/reports.jsp?result=error");
        return;
    }

    if (!action.equals("approve") && !action.equals("reject") && !action.equals("unhide")) {
        response.sendRedirect(ctx + "/admin/reports.jsp?result=error");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작

        AdminLogDAO logDAO = new AdminLogDAO();

        if ("approve".equals(action)) {
            // 1. 신고 상태를 approved로 변경
            pstmt = conn.prepareStatement(
                "UPDATE reports SET status = 'approved' WHERE id = ?"
            );
            pstmt.setInt(1, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. 같은 target의 모든 신고도 approved로 일괄 변경
            if (targetId > 0 && targetType != null) {
                pstmt = conn.prepareStatement(
                    "UPDATE reports SET status = 'approved' WHERE target_type = ? AND target_id = ?"
                );
                pstmt.setString(1, targetType);
                pstmt.setInt(2, targetId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            // 3. 대상 콘텐츠 숨김 처리
            if (targetId > 0 && targetType != null) {
                if ("review".equalsIgnoreCase(targetType) || "리뷰".equals(targetType)) {
                    // posts 테이블의 리뷰 숨김 (status = 'hidden')
                    pstmt = conn.prepareStatement(
                        "UPDATE posts SET status = 'hidden', updated_at = NOW() WHERE id = ? AND post_type = 'review'"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                } else if ("product".equalsIgnoreCase(targetType) || "상품".equals(targetType)) {
                    // product 테이블 숨김
                    pstmt = conn.prepareStatement(
                        "UPDATE product SET status = 'HIDDEN' WHERE id = ?"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                } else if ("post".equalsIgnoreCase(targetType) || "게시글".equals(targetType)) {
                    pstmt = conn.prepareStatement(
                        "UPDATE posts SET status = 'hidden', updated_at = NOW() WHERE id = ?"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            // 4. 관리자 로그 기록
            logDAO.insertLog(adminUserId, "신고 승인(숨김처리)", targetType, targetId,
                "신고 ID " + reportId + " 승인 → " + targetType + " ID:" + targetId + " 숨김");

            conn.commit();
            response.sendRedirect(ctx + "/admin/reports.jsp?result=approved");

        } else if ("reject".equals(action)) {
            // 신고 기각
            pstmt = conn.prepareStatement(
                "UPDATE reports SET status = 'rejected' WHERE id = ?"
            );
            pstmt.setInt(1, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            logDAO.insertLog(adminUserId, "신고 기각", targetType, targetId,
                "신고 ID " + reportId + " 기각 처리");

            conn.commit();
            response.sendRedirect(ctx + "/admin/reports.jsp?result=rejected");

        } else if ("unhide".equals(action)) {
            // 1. 신고 상태를 pending으로 되돌림 (재검토 가능)
            pstmt = conn.prepareStatement(
                "UPDATE reports SET status = 'pending' WHERE id = ?"
            );
            pstmt.setInt(1, reportId);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. 같은 target의 모든 신고도 pending으로 되돌림
            if (targetId > 0 && targetType != null) {
                pstmt = conn.prepareStatement(
                    "UPDATE reports SET status = 'pending' WHERE target_type = ? AND target_id = ? AND status = 'approved'"
                );
                pstmt.setString(1, targetType);
                pstmt.setInt(2, targetId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            // 3. 대상 콘텐츠 숨김 해제
            if (targetId > 0 && targetType != null) {
                if ("review".equalsIgnoreCase(targetType) || "리뷰".equals(targetType)) {
                    pstmt = conn.prepareStatement(
                        "UPDATE posts SET status = 'published', updated_at = NOW() WHERE id = ? AND post_type = 'review'"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                } else if ("product".equalsIgnoreCase(targetType) || "상품".equals(targetType)) {
                    pstmt = conn.prepareStatement(
                        "UPDATE product SET status = 'SELLING' WHERE id = ?"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                } else if ("post".equalsIgnoreCase(targetType) || "게시글".equals(targetType)) {
                    pstmt = conn.prepareStatement(
                        "UPDATE posts SET status = 'published', updated_at = NOW() WHERE id = ?"
                    );
                    pstmt.setInt(1, targetId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            // 4. 관리자 로그
            logDAO.insertLog(adminUserId, "신고 숨김해제", targetType, targetId,
                "신고 ID " + reportId + " 숨김 해제 → " + targetType + " ID:" + targetId + " 복원");

            conn.commit();
            response.sendRedirect(ctx + "/admin/reports.jsp?result=unhidden");
        }

    } catch (Exception e) {
        e.printStackTrace();
        try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
        response.sendRedirect(ctx + "/admin/reports.jsp?result=error");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (conn  != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ignore) {}
    }
%>

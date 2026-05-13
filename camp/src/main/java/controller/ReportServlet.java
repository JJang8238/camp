package controller;

import dao.ReportDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    private static final int AUTO_HIDE_THRESHOLD = 5;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        Integer reporterId = (Integer) req.getSession().getAttribute("userId");
        if (reporterId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String targetType  = req.getParameter("targetType");
        String targetIdStr = req.getParameter("targetId");
        String reason      = req.getParameter("reason");
        String redirectUrl = req.getParameter("redirectUrl");

        // ✅ redirectUrl에서 기존 reportResult 파라미터 제거
        if (redirectUrl != null) {
            redirectUrl = redirectUrl.replaceAll("[&?]reportResult=[^&]*", "");
        }

        if (targetType == null || targetIdStr == null || reason == null || reason.trim().isEmpty()) {
            sendResult(resp, redirectUrl, "invalid"); return;
        }

        int targetId;
        try { targetId = Integer.parseInt(targetIdStr); }
        catch (NumberFormatException e) { sendResult(resp, redirectUrl, "invalid"); return; }

        if (!targetType.matches("post|product|review")) {
            sendResult(resp, redirectUrl, "invalid"); return;
        }

        ReportDAO dao = new ReportDAO();

        // 중복 신고 체크
        if (dao.alreadyReported(reporterId, targetType, targetId)) {
            sendResult(resp, redirectUrl, "duplicate"); return;
        }

        boolean ok = dao.insertReport(reporterId, targetType, targetId, reason.trim());
        if (!ok) { sendResult(resp, redirectUrl, "error"); return; }

        // 누적 5건 이상 자동 숨김
        int count = dao.getReportCount(targetType, targetId);
        if (count >= AUTO_HIDE_THRESHOLD) dao.hideTarget(targetType, targetId);

        sendResult(resp, redirectUrl, "ok");
    }

    private void sendResult(HttpServletResponse resp, String redirectUrl, String result) throws IOException {
        String base = (redirectUrl != null && !redirectUrl.isEmpty()) ? redirectUrl : "/";
        String sep  = base.contains("?") ? "&" : "?";
        resp.sendRedirect(base + sep + "reportResult=" + result);
    }
}

package dao;

import util.DBUtil;

import java.sql.*;
import java.util.*;

public class ReportDAO {

    public boolean insertReport(int reporterId, String targetType, int targetId, String reason) {
        String sql = "INSERT INTO reports (reporter_id, target_type, target_id, reason, status) " +
                     "VALUES (?, ?, ?, ?, 'pending')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ps.setString(2, targetType);
            ps.setInt(3, targetId);
            ps.setString(4, reason);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean alreadyReported(int reporterId, String targetType, int targetId) {
        String sql = "SELECT 1 FROM reports WHERE reporter_id=? AND target_type=? AND target_id=? LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ps.setString(2, targetType);
            ps.setInt(3, targetId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public int getReportCount(String targetType, int targetId) {
        String sql = "SELECT COUNT(*) FROM reports WHERE target_type=? AND target_id=? AND status != 'dismissed'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, targetType);
            ps.setInt(2, targetId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public void hideTarget(String targetType, int targetId) {
        String sql = null;
        switch (targetType) {
            case "post": case "review":
                sql = "UPDATE posts SET hidden_at = NOW(), report_count = report_count + 1 WHERE id = ? AND hidden_at IS NULL"; break;
            case "product":
                sql = "UPDATE product SET hidden_at = NOW(), report_count = report_count + 1 WHERE id = ? AND hidden_at IS NULL"; break;
        }
        if (sql == null) return;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public boolean unhideTarget(String targetType, int targetId) {
        String sql = null;
        switch (targetType) {
            case "post": case "review":
                sql = "UPDATE posts SET hidden_at = NULL WHERE id = ?"; break;
            case "product":
                sql = "UPDATE product SET hidden_at = NULL WHERE id = ?"; break;
        }
        if (sql == null) return false;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean resolveReport(int reportId, String newStatus, String adminNote, int adminId) {
        String sql = "UPDATE reports SET status=?, admin_note=?, resolved_at=NOW(), resolved_by=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, adminNote);
            ps.setInt(3, adminId);
            ps.setInt(4, reportId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Map<String, Object>> getReportList(String statusFilter, int page, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();
        String where = (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter))
                ? "WHERE r.status = '" + statusFilter.replace("'", "") + "'" : "";
        String sql = "SELECT r.id, r.reporter_id, r.target_type, r.target_id, r.reason, " +
                     "r.status, r.admin_note, r.created_at, r.resolved_at, " +
                     "u.username AS reporter_name, " +
                     "(SELECT COUNT(*) FROM reports r2 WHERE r2.target_type=r.target_type AND r2.target_id=r.target_id) AS total_reports " +
                     "FROM reports r LEFT JOIN users u ON r.reporter_id = u.id " +
                     where + " ORDER BY r.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id",            rs.getInt("id"));
                    row.put("reporter_id",   rs.getInt("reporter_id"));
                    row.put("reporter_name", rs.getString("reporter_name"));
                    row.put("target_type",   rs.getString("target_type"));
                    row.put("target_id",     rs.getInt("target_id"));
                    row.put("reason",        rs.getString("reason"));
                    row.put("status",        rs.getString("status"));
                    row.put("admin_note",    rs.getString("admin_note"));
                    row.put("created_at",    rs.getString("created_at"));
                    row.put("resolved_at",   rs.getString("resolved_at"));
                    row.put("total_reports", rs.getInt("total_reports"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int getTotalCount(String statusFilter) {
        String where = (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter))
                ? "WHERE status = '" + statusFilter.replace("'", "") + "'" : "";
        String sql = "SELECT COUNT(*) FROM reports " + where;
        try (Connection conn = DBUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }
}

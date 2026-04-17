package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.AdminLog;
import util.DBUtil;

public class AdminLogDAO {

    public List<AdminLog> getAllLogs() {
        List<AdminLog> list = new ArrayList<>();

        String sql =
            "SELECT l.id, l.admin_id, l.action, l.target_type, l.target_id, l.detail, l.created_at, " +
            "       u.username AS admin_name " +
            "FROM admin_logs l " +
            "LEFT JOIN users u ON l.admin_id = u.id " +
            "ORDER BY l.id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AdminLog log = new AdminLog();
                log.setId(rs.getInt("id"));
                log.setAdminId(rs.getInt("admin_id"));
                log.setAction(rs.getString("action"));
                log.setTargetType(rs.getString("target_type"));
                log.setTargetId(rs.getInt("target_id"));
                log.setDetail(rs.getString("detail"));
                log.setCreatedAt(rs.getString("created_at"));
                log.setAdminName(rs.getString("admin_name"));
                list.add(log);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int insertLog(int adminId, String action, String targetType, int targetId, String detail) {
        int result = 0;

        String sql = "INSERT INTO admin_logs (admin_id, action, target_type, target_id, detail) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, adminId);
            ps.setString(2, action);
            ps.setString(3, targetType);
            ps.setInt(4, targetId);
            ps.setString(5, detail);

            result = ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
}
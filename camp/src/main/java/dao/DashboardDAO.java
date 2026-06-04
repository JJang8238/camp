package dao;

import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

/**
 * 관리자 대시보드용 통계 DAO
 * DB에서 직접 집계 쿼리를 실행합니다.
 */
public class DashboardDAO {

    // ══════════════════════════════════════════════════════════════
    // ✅ 핵심 수치 통계 (카드 6개용)
    // ══════════════════════════════════════════════════════════════
    public static Map<String, Integer> getCounts() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  (SELECT COUNT(*) FROM users WHERE status != 'BANNED' OR status IS NULL) AS userCount, " +
            "  (SELECT COUNT(*) FROM users WHERE status = 'BANNED') AS bannedCount, " +
            "  (SELECT COUNT(*) FROM camps WHERE status = 'active') AS campCount, " +
            "  (SELECT COUNT(*) FROM reservations) AS reservationCount, " +
            "  (SELECT COUNT(*) FROM reservations WHERE status IN ('reserved','pending')) AS waitingCount, " +
            "  (SELECT COUNT(*) FROM product WHERE status != 'HIDDEN' OR status IS NULL) AS productCount, " +
            "  (SELECT COUNT(*) FROM posts) AS postCount, " +
            "  (SELECT COUNT(*) FROM reports WHERE status = 'pending') AS reportCount, " +
            "  (SELECT COUNT(*) FROM inquiries WHERE status = '대기') AS inquiryCount";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("userCount",        rs.getInt("userCount"));
                map.put("bannedCount",      rs.getInt("bannedCount"));
                map.put("campCount",        rs.getInt("campCount"));
                map.put("reservationCount", rs.getInt("reservationCount"));
                map.put("waitingCount",     rs.getInt("waitingCount"));
                map.put("productCount",     rs.getInt("productCount"));
                map.put("postCount",        rs.getInt("postCount"));
                map.put("reportCount",      rs.getInt("reportCount"));
                map.put("inquiryCount",     rs.getInt("inquiryCount"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 매출 통계
    // ══════════════════════════════════════════════════════════════
    public static Map<String, Long> getRevenue() {
        Map<String, Long> map = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  COALESCE(SUM(CASE WHEN status IN ('approved','completed') THEN amount ELSE 0 END), 0) AS totalRevenue, " +
            "  COALESCE(SUM(CASE WHEN status IN ('approved','completed') " +
            "    AND YEAR(created_at) = YEAR(NOW()) AND MONTH(created_at) = MONTH(NOW()) " +
            "    THEN amount ELSE 0 END), 0) AS monthRevenue, " +
            "  COALESCE(SUM(CASE WHEN status IN ('approved','completed') " +
            "    AND DATE(created_at) = CURDATE() " +
            "    THEN amount ELSE 0 END), 0) AS todayRevenue " +
            "FROM reservations";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("totalRevenue", rs.getLong("totalRevenue"));
                map.put("monthRevenue", rs.getLong("monthRevenue"));
                map.put("todayRevenue", rs.getLong("todayRevenue"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 오늘 신규 가입 / 예약 수
    // ══════════════════════════════════════════════════════════════
    public static Map<String, Integer> getTodayStats() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  (SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURDATE()) AS newUsers, " +
            "  (SELECT COUNT(*) FROM reservations WHERE DATE(created_at) = CURDATE()) AS newReservations";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("newUsers",        rs.getInt("newUsers"));
                map.put("newReservations", rs.getInt("newReservations"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 인기 캠핑장 TOP 5 (예약 건수 기준)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getTopCamps() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT c.id, c.name, c.address, c.type, " +
            "       COUNT(r.id) AS reservationCnt, " +
            "       COALESCE(SUM(r.amount), 0) AS totalRevenue " +
            "FROM camps c " +
            "LEFT JOIN reservations r ON c.id = r.camp_id " +
            "  AND r.status IN ('approved','completed') " +
            "WHERE c.status = 'active' " +
            "GROUP BY c.id, c.name, c.address, c.type " +
            "ORDER BY reservationCnt DESC, totalRevenue DESC " +
            "LIMIT 5";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",             rs.getInt("id"));
                row.put("name",           rs.getString("name"));
                row.put("address",        rs.getString("address"));
                row.put("type",           rs.getString("type"));
                row.put("reservationCnt", rs.getInt("reservationCnt"));
                row.put("totalRevenue",   rs.getLong("totalRevenue"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 인기 상품 TOP 5 (구매 건수 기준)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getTopProducts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT p.id, p.name, p.price, p.category, p.status, " +
            "       COUNT(pp.id) AS purchaseCnt " +
            "FROM product p " +
            "LEFT JOIN product_purchase pp ON p.id = pp.product_id " +
            "GROUP BY p.id, p.name, p.price, p.category, p.status " +
            "ORDER BY purchaseCnt DESC, p.id DESC " +
            "LIMIT 5";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",          rs.getInt("id"));
                row.put("name",        rs.getString("name"));
                row.put("price",       rs.getInt("price"));
                row.put("category",    rs.getString("category"));
                row.put("status",      rs.getString("status"));
                row.put("purchaseCnt", rs.getInt("purchaseCnt"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 최근 관리자 로그 (최근 20건)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getRecentAdminLogs() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT al.id, al.action, al.target_type, al.target_id, " +
            "       al.detail, al.created_at, " +
            "       u.name AS adminName, u.username AS adminUsername " +
            "FROM admin_logs al " +
            "LEFT JOIN users u ON al.admin_id = u.id " +
            "ORDER BY al.created_at DESC " +
            "LIMIT 20";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",            rs.getInt("id"));
                row.put("action",        rs.getString("action"));
                row.put("targetType",    rs.getString("target_type"));
                row.put("targetId",      rs.getInt("target_id"));
                row.put("detail",        rs.getString("detail"));
                row.put("createdAt",     rs.getTimestamp("created_at"));
                row.put("adminName",     rs.getString("adminName"));
                row.put("adminUsername", rs.getString("adminUsername"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 최근 7일 일별 가입자 수 (미니 차트용)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getWeeklyNewUsers() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT DATE_FORMAT(created_at, '%m/%d') AS day, COUNT(*) AS cnt " +
            "FROM users " +
            "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
            "GROUP BY DATE_FORMAT(created_at, '%m/%d') " +
            "ORDER BY MIN(created_at) ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("day", rs.getString("day"));
                row.put("cnt", rs.getInt("cnt"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 최근 예약 5건 (대기 중인 것 우선)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getRecentReservations() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT r.id, c.name AS campName, u.name AS guestName, " +
            "       r.check_in, r.check_out, r.amount, r.status, r.created_at " +
            "FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "ORDER BY " +
            "  CASE WHEN r.status IN ('reserved','pending') THEN 0 ELSE 1 END ASC, " +
            "  r.id DESC " +
            "LIMIT 5";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",        rs.getInt("id"));
                row.put("campName",  rs.getString("campName"));
                row.put("guestName", rs.getString("guestName"));
                row.put("checkIn",   rs.getString("check_in"));
                row.put("checkOut",  rs.getString("check_out"));
                row.put("amount",    rs.getInt("amount"));
                row.put("status",    rs.getString("status"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}

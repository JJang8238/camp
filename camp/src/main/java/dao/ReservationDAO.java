package dao;

import dto.ReservationDTO;
import util.DBUtil;

import java.sql.*;
import java.util.*;

public class ReservationDAO {

    // ══════════════════════════════════════════════════════════════
    // 사용자 예약 목록 조회 (기존)
    // ══════════════════════════════════════════════════════════════
    public static List<ReservationDTO> getReservationsByUserId(int userId) {
        List<ReservationDTO> list = new ArrayList<>();
        String sql =
            "SELECT r.id, r.user_id, r.camp_id, c.name AS camp_name, " +
            "       r.reserve_date, r.check_in, r.check_out, r.people_count, " +
            "       r.status, r.created_at, r.order_id, r.payment_key, r.amount " +
            "FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "WHERE r.user_id = ? " +
            "ORDER BY r.check_in DESC, r.id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 전체 예약 목록 조회 (관리자용) - 검색 + 상태 필터 + 페이징
    // ══════════════════════════════════════════════════════════════
    public static List<ReservationDTO> getAllReservations(
            String keyword, String status, String sortBy, int page, int pageSize) {

        List<ReservationDTO> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder(
            "SELECT r.id, r.user_id, r.camp_id, c.name AS camp_name, " +
            "       u.name AS guest_name, u.username, u.email, " +
            "       r.reserve_date, r.check_in, r.check_out, r.people_count, " +
            "       r.status, r.created_at, r.order_id, r.payment_key, r.amount " +
            "FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            if ("reserved".equals(status)) {
                sql.append("AND r.status IN ('reserved','pending') ");
            } else {
                sql.append("AND r.status = ? ");
                params.add(status);
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.name LIKE ? OR c.name LIKE ? OR r.order_id LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }

        if ("checkIn".equals(sortBy))  sql.append("ORDER BY r.check_in DESC ");
        else if ("amount".equals(sortBy)) sql.append("ORDER BY r.amount DESC ");
        else                           sql.append("ORDER BY r.id DESC ");

        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize); params.add(offset);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                else                     ps.setString(i + 1, String.valueOf(p));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ReservationDTO dto = mapRow(rs);
                dto.setGuestName(rs.getString("guest_name"));
                // email 임시 저장 (orderId 필드 활용 대신 별도 DTO 확장 권장)
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 전체 예약 건수 (페이징용)
    // ══════════════════════════════════════════════════════════════
    public static int getTotalCount(String keyword, String status) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            if ("reserved".equals(status)) {
                sql.append("AND r.status IN ('reserved','pending') ");
            } else {
                sql.append("AND r.status = ? ");
                params.add(status);
            }
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.name LIKE ? OR c.name LIKE ? OR r.order_id LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                else                     ps.setString(i + 1, String.valueOf(p));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 예약 단건 조회 (상세)
    // ══════════════════════════════════════════════════════════════
    public static ReservationDTO getReservationById(int id) {
        String sql =
            "SELECT r.id, r.user_id, r.camp_id, c.name AS camp_name, " +
            "       u.name AS guest_name, u.username, u.email, " +
            "       r.reserve_date, r.check_in, r.check_out, r.people_count, " +
            "       r.status, r.created_at, r.order_id, r.payment_key, r.amount " +
            "FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "WHERE r.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ReservationDTO dto = mapRow(rs);
                dto.setGuestName(rs.getString("guest_name"));
                return dto;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 고객 이메일 조회 (고객 연락용)
    // ══════════════════════════════════════════════════════════════
    public static String getGuestEmail(int reservationId) {
        String sql =
            "SELECT u.email FROM reservations r " +
            "LEFT JOIN users u ON r.user_id = u.id " +
            "WHERE r.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("email");
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 예약 상태 변경 (승인 / 거절 / 취소 / 완료)
    // ══════════════════════════════════════════════════════════════
    public static boolean updateStatus(int reservationId, String newStatus) {
        String sql = "UPDATE reservations SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 매출 통계 (관리자 대시보드용)
    // ══════════════════════════════════════════════════════════════
    public static Map<String, Object> getStats() {
        Map<String, Object> stats = new LinkedHashMap<>();

        String sql =
            "SELECT " +
            "  COUNT(*) AS total, " +
            "  SUM(CASE WHEN status IN ('reserved','pending') THEN 1 ELSE 0 END) AS waiting, " +
            "  SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved, " +
            "  SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled, " +
            "  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed, " +
            "  COALESCE(SUM(CASE WHEN status IN ('approved','completed') THEN amount ELSE 0 END), 0) AS totalRevenue, " +
            "  COALESCE(SUM(CASE WHEN status IN ('approved','completed') AND MONTH(created_at) = MONTH(NOW()) AND YEAR(created_at) = YEAR(NOW()) THEN amount ELSE 0 END), 0) AS monthRevenue " +
            "FROM reservations";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("total",        rs.getInt("total"));
                stats.put("waiting",      rs.getInt("waiting"));
                stats.put("approved",     rs.getInt("approved"));
                stats.put("cancelled",    rs.getInt("cancelled"));
                stats.put("completed",    rs.getInt("completed"));
                stats.put("totalRevenue", rs.getLong("totalRevenue"));
                stats.put("monthRevenue", rs.getLong("monthRevenue"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 월별 매출 집계 (최근 6개월, 차트용)
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getMonthlyRevenue() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, " +
            "       COUNT(*) AS cnt, " +
            "       COALESCE(SUM(amount), 0) AS revenue " +
            "FROM reservations " +
            "WHERE status IN ('approved','completed') " +
            "  AND created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
            "GROUP BY DATE_FORMAT(created_at, '%Y-%m') " +
            "ORDER BY month ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("month",   rs.getString("month"));
                row.put("cnt",     rs.getInt("cnt"));
                row.put("revenue", rs.getLong("revenue"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // ✅ 캠핑장별 예약 건수 TOP 5
    // ══════════════════════════════════════════════════════════════
    public static List<Map<String, Object>> getTopCamps() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT c.name AS campName, COUNT(*) AS cnt, COALESCE(SUM(r.amount),0) AS revenue " +
            "FROM reservations r " +
            "LEFT JOIN camps c ON r.camp_id = c.id " +
            "WHERE r.status IN ('approved','completed') " +
            "GROUP BY c.name " +
            "ORDER BY cnt DESC " +
            "LIMIT 5";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("campName", rs.getString("campName"));
                row.put("cnt",      rs.getInt("cnt"));
                row.put("revenue",  rs.getLong("revenue"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ══════════════════════════════════════════════════════════════
    // 공통 ResultSet → DTO 매핑
    // ══════════════════════════════════════════════════════════════
    private static ReservationDTO mapRow(ResultSet rs) throws SQLException {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(rs.getInt("id"));
        dto.setUserId(rs.getInt("user_id"));
        dto.setCampId(rs.getInt("camp_id"));
        dto.setCampName(rs.getString("camp_name"));
        dto.setReserveDate(rs.getString("reserve_date"));
        dto.setCheckIn(rs.getString("check_in"));
        dto.setCheckOut(rs.getString("check_out"));
        dto.setPeopleCount(rs.getInt("people_count"));
        dto.setStatus(rs.getString("status"));
        dto.setCreatedAt(rs.getTimestamp("created_at"));
        dto.setOrderId(rs.getString("order_id"));
        dto.setPaymentKey(rs.getString("payment_key"));
        dto.setAmount(rs.getInt("amount"));
        return dto;
    }
}

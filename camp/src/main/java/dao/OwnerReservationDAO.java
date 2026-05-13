package dao;

import dto.ReservationDTO;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OwnerReservationDAO {

    /**
     * 사장님 소유 캠핑장의 전체 예약 목록 조회
     * (예약자 이름, 캠핑장명 JOIN)
     */
    public static List<ReservationDTO> getReservationsByOwnerId(int ownerId) {
        List<ReservationDTO> list = new ArrayList<>();

        String sql = "SELECT r.id, r.user_id, r.camp_id, r.reserve_date, r.people_count, " +
                     "       r.status, r.created_at, r.order_id, r.payment_key, r.amount, " +
                     "       c.name AS camp_name, u.name AS guest_name " +
                     "FROM reservations r " +
                     "JOIN camps c ON r.camp_id = c.id " +
                     "JOIN users u ON r.user_id = u.id " +
                     "WHERE c.owner_id = ? " +
                     "ORDER BY r.reserve_date DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ReservationDTO dto = new ReservationDTO();
                dto.setId(rs.getInt("id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setCampId(rs.getInt("camp_id"));
                dto.setCampName(rs.getString("camp_name"));
                dto.setGuestName(rs.getString("guest_name"));
                dto.setReserveDate(rs.getString("reserve_date"));
                dto.setPeopleCount(rs.getInt("people_count"));
                dto.setStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setOrderId(rs.getString("order_id"));
                dto.setPaymentKey(rs.getString("payment_key"));
                dto.setAmount(rs.getInt("amount"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 상태별 필터링 조회 (전체/대기/승인/거절)
     */
    public static List<ReservationDTO> getReservationsByOwnerIdAndStatus(int ownerId, String status) {
        List<ReservationDTO> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT r.id, r.user_id, r.camp_id, r.reserve_date, r.people_count, " +
                "       r.status, r.created_at, r.order_id, r.payment_key, r.amount, " +
                "       c.name AS camp_name, u.name AS guest_name " +
                "FROM reservations r " +
                "JOIN camps c ON r.camp_id = c.id " +
                "JOIN users u ON r.user_id = u.id " +
                "WHERE c.owner_id = ? "
        );

        // "reserved" 필터는 pending + reserved 둘 다 대기로 처리
        if (status != null && status.equals("reserved")) {
            sql.append("AND LOWER(r.status) IN ('reserved', 'pending') ");
        } else if (status != null && !status.equals("all")) {
            sql.append("AND LOWER(r.status) = ? ");
        }

        sql.append("ORDER BY r.reserve_date DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, ownerId);
            if (status != null && !status.equals("all") && !status.equals("reserved")) {
                ps.setString(2, status);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ReservationDTO dto = new ReservationDTO();
                dto.setId(rs.getInt("id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setCampId(rs.getInt("camp_id"));
                dto.setCampName(rs.getString("camp_name"));
                dto.setGuestName(rs.getString("guest_name"));
                dto.setReserveDate(rs.getString("reserve_date"));
                dto.setPeopleCount(rs.getInt("people_count"));
                dto.setStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setOrderId(rs.getString("order_id"));
                dto.setPaymentKey(rs.getString("payment_key"));
                dto.setAmount(rs.getInt("amount"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 예약 승인
     */
    public static boolean approveReservation(int reservationId, int ownerId) {
        String sql = "UPDATE reservations r " +
                     "JOIN camps c ON r.camp_id = c.id " +
                     "SET r.status = 'approved' " +
                     "WHERE r.id = ? AND c.owner_id = ? AND LOWER(r.status) IN ('reserved', 'pending')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reservationId);
            ps.setInt(2, ownerId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 예약 거절
     */
    public static boolean rejectReservation(int reservationId, int ownerId) {
        String sql = "UPDATE reservations r " +
                     "JOIN camps c ON r.camp_id = c.id " +
                     "SET r.status = 'rejected' " +
                     "WHERE r.id = ? AND c.owner_id = ? AND LOWER(r.status) IN ('reserved', 'pending')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reservationId);
            ps.setInt(2, ownerId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 상태별 건수 집계
     */
    public static int countByStatus(int ownerId, String status) {
        // "reserved" 카운트는 pending + reserved 합산
        String sql;
        if ("reserved".equals(status)) {
            sql = "SELECT COUNT(*) FROM reservations r " +
                  "JOIN camps c ON r.camp_id = c.id " +
                  "WHERE c.owner_id = ? AND LOWER(r.status) IN ('reserved', 'pending')";
        } else {
            sql = "SELECT COUNT(*) FROM reservations r " +
                  "JOIN camps c ON r.camp_id = c.id " +
                  "WHERE c.owner_id = ? AND r.status = ?";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ownerId);
            if (!"reserved".equals(status)) {
                ps.setString(2, status);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}

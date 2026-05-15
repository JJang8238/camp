package dao;

import dto.ReservationDTO;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    /**
     * 특정 사용자의 예약 목록 조회
     */
    public static List<ReservationDTO> getReservationsByUserId(int userId) {

        List<ReservationDTO> list = new ArrayList<>();

        String sql =
                "SELECT " +
                "    r.id, " +
                "    r.user_id, " +
                "    r.camp_id, " +
                "    c.name AS camp_name, " +
                "    r.reserve_date, " +
                "    r.check_in, " +
                "    r.check_out, " +
                "    r.people_count, " +
                "    r.status, " +
                "    r.created_at, " +
                "    r.order_id, " +
                "    r.payment_key, " +
                "    r.amount " +
                "FROM reservations r " +
                "LEFT JOIN camps c ON r.camp_id = c.id " +
                "WHERE r.user_id = ? " +
                "ORDER BY r.check_in DESC, r.id DESC";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                ReservationDTO dto = new ReservationDTO();

                dto.setId(rs.getInt("id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setCampId(rs.getInt("camp_id"));

                dto.setCampName(rs.getString("camp_name"));

                dto.setReserveDate(rs.getString("reserve_date"));

                // ✅ 추가
                dto.setCheckIn(rs.getString("check_in"));
                dto.setCheckOut(rs.getString("check_out"));

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
}
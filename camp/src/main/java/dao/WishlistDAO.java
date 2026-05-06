package dao;

import dto.WishlistDTO;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO {

    // 내 찜 목록 조회 (camps 테이블 JOIN)
    public static List<WishlistDTO> getWishlistByUserId(int userId) {
        List<WishlistDTO> list = new ArrayList<>();

        String sql = "SELECT w.id, w.camp_id, w.created_at, " +
                     "       c.name, c.address, c.type, c.tags, c.price, c.image, c.status " +
                     "FROM wishlist w " +
                     "JOIN camps c ON w.camp_id = c.id " +
                     "WHERE w.user_id = ? " +
                     "ORDER BY w.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                WishlistDTO dto = new WishlistDTO();
                dto.setId(rs.getInt("id"));
                dto.setCampId(rs.getInt("camp_id"));
                dto.setCreatedAt(rs.getString("created_at"));
                dto.setCampName(rs.getString("name"));
                dto.setCampAddress(rs.getString("address"));
                dto.setCampType(rs.getString("type"));
                dto.setCampTags(rs.getString("tags"));
                dto.setCampPrice(rs.getInt("price"));
                dto.setCampImage(rs.getString("image"));
                dto.setCampStatus(rs.getString("status"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 찜 추가
    public static boolean addWishlist(int userId, int campId) {
        String sql = "INSERT IGNORE INTO wishlist (user_id, camp_id) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, campId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 찜 삭제
    public static boolean removeWishlist(int userId, int campId) {
        String sql = "DELETE FROM wishlist WHERE user_id = ? AND camp_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, campId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 특정 캠핑장을 찜했는지 확인
    public static boolean isWished(int userId, int campId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND camp_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, campId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

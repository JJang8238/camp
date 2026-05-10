package dao;

import util.DBUtil;
import java.sql.*;
import java.util.*;

public class ReviewReplyDAO {

    /**
     * 사장님 소유 캠핑장에 달린 리뷰 목록 조회
     * posts(post_type='review') + category = 캠핑장명 + camps.owner_id = ownerId
     */
    public static List<Map<String, Object>> getReviewsByOwnerId(int ownerId) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT p.id, p.title, p.content, p.summary AS rating, " +
                     "       p.category AS camp_name, p.created_at, " +
                     "       u.name AS guest_name, " +
                     "       rr.content AS reply_content, rr.created_at AS reply_at " +
                     "FROM posts p " +
                     "JOIN users u ON p.author_id = u.id " +
                     "JOIN camps c ON p.category = c.name " +
                     "LEFT JOIN review_reply rr ON rr.post_id = p.id " +
                     "WHERE p.post_type = 'review' " +
                     "  AND p.deleted_at IS NULL " +
                     "  AND c.owner_id = ? " +
                     "ORDER BY p.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id",            rs.getInt("id"));
                map.put("title",         rs.getString("title"));
                map.put("content",       rs.getString("content"));
                map.put("rating",        rs.getString("rating"));
                map.put("camp_name",     rs.getString("camp_name"));
                map.put("guest_name",    rs.getString("guest_name"));
                map.put("created_at",    rs.getString("created_at"));
                map.put("reply_content", rs.getString("reply_content"));
                map.put("reply_at",      rs.getString("reply_at"));
                list.add(map);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 답글 등록 또는 수정 (UPSERT)
     */
    public static boolean saveReply(int postId, int ownerId, String content) {
        String sql = "INSERT INTO review_reply (post_id, owner_id, content) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE content = ?, updated_at = NOW()";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);
            ps.setInt(2, ownerId);
            ps.setString(3, content);
            ps.setString(4, content);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 답글 삭제
     */
    public static boolean deleteReply(int postId, int ownerId) {
        String sql = "DELETE FROM review_reply WHERE post_id = ? AND owner_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);
            ps.setInt(2, ownerId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

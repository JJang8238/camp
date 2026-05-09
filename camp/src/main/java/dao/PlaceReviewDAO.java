package dao;

import java.sql.*;
import java.util.*;
import util.DBUtil;

public class PlaceReviewDAO {

    // ✅ 수정: 장소별 리뷰 목록 조회
    // 기존: place_review 테이블 + user 테이블 조인 (존재하지 않는 테이블)
    // 변경: posts 테이블(post_type='review', category=캠핑장명) + users 테이블 조인
    public List<Map<String, Object>> listByPlace(String place, String sort) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT p.id, p.content, p.category, p.created_at, " +
                     "       u.name AS user, u.id AS userId, " +
                     "       COALESCE(CAST(p.summary AS UNSIGNED), 5) AS rating " +
                     "FROM posts p " +
                     "JOIN users u ON p.author_id = u.id " +
                     "WHERE p.post_type = 'review' " +
                     "  AND p.category = ? " +
                     "  AND p.deleted_at IS NULL ";

        if ("high".equals(sort)) {
            sql += "ORDER BY rating DESC";
        } else {
            sql += "ORDER BY p.created_at DESC";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, place);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id",         rs.getInt("id"));
                map.put("content",    rs.getString("content"));
                map.put("rating",     rs.getInt("rating"));
                map.put("user",       rs.getString("user"));
                map.put("userId",     rs.getInt("userId"));
                map.put("created_at", rs.getTimestamp("created_at"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ✅ 신규: 리뷰 작성 (posts 테이블에 INSERT)
    // summary 컬럼에 별점 저장, category에 캠핑장명 저장
    public boolean insertReview(int authorId, String place, String content, int rating) {
        String sql = "INSERT INTO posts (post_type, title, summary, content, category, author_id, status, published_at) " +
                     "VALUES ('review', ?, ?, ?, ?, ?, 'published', NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, place + " 후기");       // title
            pstmt.setString(2, String.valueOf(rating)); // summary = 별점
            pstmt.setString(3, content);                // content
            pstmt.setString(4, place);                  // category = 캠핑장명
            pstmt.setInt(5, authorId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ✅ 신규: 리뷰 수정
    public boolean updateReview(int postId, int authorId, String content, int rating) {
        String sql = "UPDATE posts SET content = ?, summary = ?, updated_at = NOW() " +
                     "WHERE id = ? AND author_id = ? AND post_type = 'review'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, content);
            pstmt.setString(2, String.valueOf(rating));
            pstmt.setInt(3, postId);
            pstmt.setInt(4, authorId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ✅ 신규: 리뷰 삭제 (soft delete)
    public boolean deleteReview(int postId, int authorId) {
        String sql = "UPDATE posts SET deleted_at = NOW() " +
                     "WHERE id = ? AND author_id = ? AND post_type = 'review'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setInt(2, authorId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}

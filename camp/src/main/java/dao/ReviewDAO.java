package dao;

import dto.ReviewDTO;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    /**
     * 내가 작성한 리뷰 목록 조회 (post_type = 'review', author_id = userId)
     */
    public static List<ReviewDTO> getMyReviews(int userId) {
        List<ReviewDTO> list = new ArrayList<>();

        String sql = "SELECT id, title, summary, content, category, thumbnail, " +
                     "       view_count, status, created_at, updated_at " +
                     "FROM posts " +
                     "WHERE post_type = 'review' " +
                     "  AND author_id = ? " +
                     "  AND deleted_at IS NULL " +
                     "ORDER BY created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setId(rs.getInt("id"));
                dto.setTitle(rs.getString("title"));
                dto.setSummary(rs.getString("summary"));
                dto.setContent(rs.getString("content"));
                dto.setCategory(rs.getString("category"));
                dto.setThumbnail(rs.getString("thumbnail"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getString("created_at"));
                dto.setUpdatedAt(rs.getString("updated_at"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 리뷰 삭제 (본인 글만, soft delete)
     */
    public static boolean deleteReview(int postId, int userId) {
        String sql = "UPDATE posts SET deleted_at = NOW() " +
                     "WHERE id = ? AND author_id = ? AND post_type = 'review'";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

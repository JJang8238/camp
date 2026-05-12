package dao;

import util.DBUtil;

import java.sql.*;
import java.util.*;

public class PlaceReviewDAO {

    public List<Map<String, Object>> listByPlace(String place, String sort) {
        List<Map<String, Object>> list = new ArrayList<>();
        String orderBy = "high".equals(sort)
                ? "ORDER BY COALESCE(CAST(p.summary AS UNSIGNED),5) DESC, p.created_at DESC"
                : "ORDER BY p.created_at DESC";

        String sql = "SELECT p.id, p.content, p.category, p.created_at, p.thumbnail, " +
                     "       u.name AS user, u.id AS userId, " +
                     "       COALESCE(CAST(p.summary AS UNSIGNED), 5) AS rating " +
                     "FROM posts p JOIN users u ON p.author_id = u.id " +
                     "WHERE p.post_type = 'review' " +
                     "  AND p.category = ? " +
                     "  AND p.deleted_at IS NULL " +
                     "  AND p.hidden_at IS NULL " +
                     orderBy;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, place);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id",         rs.getInt("id"));
                    row.put("content",    rs.getString("content"));
                    row.put("category",   rs.getString("category"));
                    row.put("created_at", rs.getString("created_at"));
                    row.put("thumbnail",  rs.getString("thumbnail"));
                    row.put("user",       rs.getString("user"));
                    row.put("userId",     rs.getInt("userId"));
                    row.put("rating",     rs.getInt("rating"));
                    row.put("images",     getPostImages(rs.getInt("id"), conn));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int insertReviewWithImages(int userId, String place, String content,
                                      int rating, String thumbnail,
                                      List<String> savedFileNames, String imgDirWeb) {
        String sql = "INSERT INTO posts " +
                     "(post_type, title, summary, content, category, thumbnail, author_id, status, published_at) " +
                     "VALUES ('review', ?, ?, ?, ?, ?, ?, 'published', NOW())";
        int newId = -1;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, place);
            ps.setString(2, String.valueOf(rating));
            ps.setString(3, content);
            ps.setString(4, place);
            ps.setString(5, thumbnail);
            ps.setInt(6, userId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) newId = keys.getInt(1);
            }
            if (newId > 0 && !savedFileNames.isEmpty()) {
                insertPostImages(conn, newId, savedFileNames, imgDirWeb);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return newId;
    }

    public void insertReview(int userId, String place, String content, int rating) {
        insertReviewWithImages(userId, place, content, rating, null, Collections.emptyList(), "");
    }

    public void updateReview(int postId, int userId, String content, int rating) {
        String sql = "UPDATE posts SET content = ?, summary = ?, updated_at = NOW() " +
                     "WHERE id = ? AND author_id = ? AND post_type = 'review'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, content);
            ps.setString(2, String.valueOf(rating));
            ps.setInt(3, postId);
            ps.setInt(4, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void deleteReview(int postId, int userId) {
        String sql = "UPDATE posts SET deleted_at = NOW() " +
                     "WHERE id = ? AND author_id = ? AND post_type = 'review'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void insertPostImages(int postId, List<String> fileNames, String imgDirWeb) {
        try (Connection conn = DBUtil.getConnection()) {
            insertPostImages(conn, postId, fileNames, imgDirWeb);
        } catch (Exception e) { e.printStackTrace(); }
    }

    private void insertPostImages(Connection conn, int postId,
                                  List<String> fileNames, String imgDirWeb) throws SQLException {
        String sql = "INSERT INTO post_images (post_id, image_path, image_type, sort_order) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int order = 1;
            for (String name : fileNames) {
                ps.setInt(1, postId);
                ps.setString(2, imgDirWeb + name);
                ps.setString(3, "review");
                ps.setInt(4, order++);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public List<Map<String, Object>> getPostImages(int postId) {
        try (Connection conn = DBUtil.getConnection()) {
            return getPostImages(postId, conn);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    private List<Map<String, Object>> getPostImages(int postId, Connection conn) throws SQLException {
        List<Map<String, Object>> images = new ArrayList<>();
        String sql = "SELECT id, image_path, sort_order FROM post_images " +
                     "WHERE post_id = ? AND image_type = 'review' ORDER BY sort_order";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> img = new LinkedHashMap<>();
                    img.put("id",         rs.getInt("id"));
                    img.put("image_path", rs.getString("image_path"));
                    img.put("sort_order", rs.getInt("sort_order"));
                    images.add(img);
                }
            }
        }
        return images;
    }

    public List<String> getPostImagePaths(int postId) {
        List<String> paths = new ArrayList<>();
        String sql = "SELECT image_path FROM post_images WHERE post_id = ? AND image_type = 'review'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) paths.add(rs.getString("image_path"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return paths;
    }

    public String getImagePathById(int imgId) {
        String sql = "SELECT image_path FROM post_images WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imgId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("image_path");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public void deletePostImage(int imgId, int postId) {
        String sql = "DELETE FROM post_images WHERE id = ? AND post_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imgId);
            ps.setInt(2, postId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void updateThumbnailIfEmpty(int postId, String thumbnailPath) {
        String sql = "UPDATE posts SET thumbnail = ? WHERE id = ? AND (thumbnail IS NULL OR thumbnail = '')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, thumbnailPath);
            ps.setInt(2, postId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}

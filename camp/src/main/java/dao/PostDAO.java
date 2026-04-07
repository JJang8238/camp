package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import dto.EventDetail;
import dto.Post;
import util.DBUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PostDAO {

    public int insertPost(Post post) {
        int newId = 0;

        String sql = "INSERT INTO posts "
                + "(post_type, title, summary, content, category, thumbnail, author_id, view_count, status, is_pinned, display_order, published_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, post.getPostType());
            ps.setString(2, post.getTitle());
            ps.setString(3, post.getSummary());
            ps.setString(4, post.getContent());
            ps.setString(5, post.getCategory());
            ps.setString(6, post.getThumbnail());

            if (post.getAuthorId() != null) {
                ps.setInt(7, post.getAuthorId());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }

            ps.setString(8, post.getStatus());
            ps.setInt(9, post.getIsPinned());
            ps.setInt(10, post.getDisplayOrder());

            if (post.getPublishedAt() != null && !post.getPublishedAt().trim().isEmpty()) {
                ps.setString(11, post.getPublishedAt().replace("T", " ") + ":00");
            } else {
                ps.setNull(11, java.sql.Types.TIMESTAMP);
            }

            int result = ps.executeUpdate();

            if (result > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newId = rs.getInt(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return newId;
    }

    public boolean insertEventDetail(EventDetail event) {
        String sql = "INSERT INTO event_details "
                + "(post_id, start_date, end_date, event_status, apply_url, coupon_code, max_participants, winner_announce_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, event.getPostId());

            if (event.getStartDate() != null && !event.getStartDate().trim().isEmpty()) {
                ps.setString(2, event.getStartDate());
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }

            if (event.getEndDate() != null && !event.getEndDate().trim().isEmpty()) {
                ps.setString(3, event.getEndDate());
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }

            ps.setString(4, event.getEventStatus());
            ps.setString(5, event.getApplyUrl());
            ps.setString(6, event.getCouponCode());

            if (event.getMaxParticipants() != null) {
                ps.setInt(7, event.getMaxParticipants());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }

            if (event.getWinnerAnnounceAt() != null && !event.getWinnerAnnounceAt().trim().isEmpty()) {
                ps.setString(8, event.getWinnerAnnounceAt().replace("T", " ") + ":00");
            } else {
                ps.setNull(8, java.sql.Types.TIMESTAMP);
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Post getPostById(int id) {
        Post post = null;

        String sql = "SELECT * FROM posts WHERE id = ? AND deleted_at IS NULL";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setPostType(rs.getString("post_type"));
                    post.setTitle(rs.getString("title"));
                    post.setSummary(rs.getString("summary"));
                    post.setContent(rs.getString("content"));
                    post.setCategory(rs.getString("category"));
                    post.setThumbnail(rs.getString("thumbnail"));
                    post.setAuthorId((Integer) rs.getObject("author_id"));
                    post.setViewCount(rs.getInt("view_count"));
                    post.setStatus(rs.getString("status"));
                    post.setIsPinned(rs.getInt("is_pinned"));
                    post.setDisplayOrder(rs.getInt("display_order"));
                    post.setPublishedAt(rs.getString("published_at"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setUpdatedAt(rs.getString("updated_at"));
                    post.setDeletedAt(rs.getString("deleted_at"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return post;
    }

    public EventDetail getEventDetailByPostId(int postId) {
        EventDetail event = null;

        String sql = "SELECT * FROM event_details WHERE post_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    event = new EventDetail();
                    event.setPostId(rs.getInt("post_id"));
                    event.setStartDate(rs.getString("start_date"));
                    event.setEndDate(rs.getString("end_date"));
                    event.setEventStatus(rs.getString("event_status"));
                    event.setApplyUrl(rs.getString("apply_url"));
                    event.setCouponCode(rs.getString("coupon_code"));
                    event.setMaxParticipants((Integer) rs.getObject("max_participants"));
                    event.setWinnerAnnounceAt(rs.getString("winner_announce_at"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return event;
    }

    public boolean increaseViewCount(int postId) {
        String sql = "UPDATE posts SET view_count = view_count + 1 WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, postId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public List<Post> getFilteredNewsPosts(String category, String keyword) {
        List<Post> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM posts ");
        sql.append("WHERE post_type = 'news' ");
        sql.append("AND status = 'published' ");
        sql.append("AND deleted_at IS NULL ");

        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND category = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (title LIKE ? OR summary LIKE ? OR content LIKE ?) ");
        }

        sql.append("ORDER BY is_pinned DESC, display_order DESC, created_at DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            if (category != null && !category.trim().isEmpty()) {
                ps.setString(idx++, category);
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setPostType(rs.getString("post_type"));
                    post.setTitle(rs.getString("title"));
                    post.setSummary(rs.getString("summary"));
                    post.setContent(rs.getString("content"));
                    post.setCategory(rs.getString("category"));
                    post.setThumbnail(rs.getString("thumbnail"));
                    post.setAuthorId((Integer) rs.getObject("author_id"));
                    post.setViewCount(rs.getInt("view_count"));
                    post.setStatus(rs.getString("status"));
                    post.setIsPinned(rs.getInt("is_pinned"));
                    post.setDisplayOrder(rs.getInt("display_order"));
                    post.setPublishedAt(rs.getString("published_at"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setUpdatedAt(rs.getString("updated_at"));
                    post.setDeletedAt(rs.getString("deleted_at"));
                    list.add(post);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getEventPostList() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT p.*, "
                   + "e.start_date, e.end_date, e.event_status, e.apply_url, e.coupon_code, e.max_participants, e.winner_announce_at "
                   + "FROM posts p "
                   + "LEFT JOIN event_details e ON p.id = e.post_id "
                   + "WHERE p.post_type = 'event' "
                   + "AND p.status = 'published' "
                   + "AND p.deleted_at IS NULL "
                   + "ORDER BY p.is_pinned DESC, p.display_order DESC, p.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Post post = new Post();
                post.setId(rs.getInt("id"));
                post.setPostType(rs.getString("post_type"));
                post.setTitle(rs.getString("title"));
                post.setSummary(rs.getString("summary"));
                post.setContent(rs.getString("content"));
                post.setCategory(rs.getString("category"));
                post.setThumbnail(rs.getString("thumbnail"));
                post.setAuthorId((Integer) rs.getObject("author_id"));
                post.setViewCount(rs.getInt("view_count"));
                post.setStatus(rs.getString("status"));
                post.setIsPinned(rs.getInt("is_pinned"));
                post.setDisplayOrder(rs.getInt("display_order"));
                post.setPublishedAt(rs.getString("published_at"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setUpdatedAt(rs.getString("updated_at"));
                post.setDeletedAt(rs.getString("deleted_at"));

                EventDetail event = new EventDetail();
                event.setPostId(rs.getInt("id"));
                event.setStartDate(rs.getString("start_date"));
                event.setEndDate(rs.getString("end_date"));
                event.setEventStatus(rs.getString("event_status"));
                event.setApplyUrl(rs.getString("apply_url"));
                event.setCouponCode(rs.getString("coupon_code"));
                event.setMaxParticipants((Integer) rs.getObject("max_participants"));
                event.setWinnerAnnounceAt(rs.getString("winner_announce_at"));

                Map<String, Object> row = new HashMap<>();
                row.put("post", post);
                row.put("event", event);

                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getEventPostListByEventStatus(String eventStatus) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT p.*, "
                   + "e.start_date, e.end_date, e.event_status, e.apply_url, e.coupon_code, e.max_participants, e.winner_announce_at "
                   + "FROM posts p "
                   + "INNER JOIN event_details e ON p.id = e.post_id "
                   + "WHERE p.post_type = 'event' "
                   + "AND p.status = 'published' "
                   + "AND p.deleted_at IS NULL "
                   + "AND e.event_status = ? "
                   + "ORDER BY p.is_pinned DESC, p.display_order DESC, p.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, eventStatus);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setPostType(rs.getString("post_type"));
                    post.setTitle(rs.getString("title"));
                    post.setSummary(rs.getString("summary"));
                    post.setContent(rs.getString("content"));
                    post.setCategory(rs.getString("category"));
                    post.setThumbnail(rs.getString("thumbnail"));
                    post.setAuthorId((Integer) rs.getObject("author_id"));
                    post.setViewCount(rs.getInt("view_count"));
                    post.setStatus(rs.getString("status"));
                    post.setIsPinned(rs.getInt("is_pinned"));
                    post.setDisplayOrder(rs.getInt("display_order"));
                    post.setPublishedAt(rs.getString("published_at"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setUpdatedAt(rs.getString("updated_at"));
                    post.setDeletedAt(rs.getString("deleted_at"));

                    EventDetail event = new EventDetail();
                    event.setPostId(rs.getInt("id"));
                    event.setStartDate(rs.getString("start_date"));
                    event.setEndDate(rs.getString("end_date"));
                    event.setEventStatus(rs.getString("event_status"));
                    event.setApplyUrl(rs.getString("apply_url"));
                    event.setCouponCode(rs.getString("coupon_code"));
                    event.setMaxParticipants((Integer) rs.getObject("max_participants"));
                    event.setWinnerAnnounceAt(rs.getString("winner_announce_at"));

                    Map<String, Object> row = new HashMap<>();
                    row.put("post", post);
                    row.put("event", event);

                    list.add(row);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public Post getPrevNewsPost(int currentId) {
        Post post = null;

        String sql = "SELECT * FROM posts "
                   + "WHERE post_type = 'news' "
                   + "AND status = 'published' "
                   + "AND deleted_at IS NULL "
                   + "AND id < ? "
                   + "ORDER BY id DESC "
                   + "LIMIT 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setPostType(rs.getString("post_type"));
                    post.setTitle(rs.getString("title"));
                    post.setSummary(rs.getString("summary"));
                    post.setContent(rs.getString("content"));
                    post.setCategory(rs.getString("category"));
                    post.setThumbnail(rs.getString("thumbnail"));
                    post.setAuthorId((Integer) rs.getObject("author_id"));
                    post.setViewCount(rs.getInt("view_count"));
                    post.setStatus(rs.getString("status"));
                    post.setIsPinned(rs.getInt("is_pinned"));
                    post.setDisplayOrder(rs.getInt("display_order"));
                    post.setPublishedAt(rs.getString("published_at"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setUpdatedAt(rs.getString("updated_at"));
                    post.setDeletedAt(rs.getString("deleted_at"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return post;
    }

    public Post getNextNewsPost(int currentId) {
        Post post = null;

        String sql = "SELECT * FROM posts "
                   + "WHERE post_type = 'news' "
                   + "AND status = 'published' "
                   + "AND deleted_at IS NULL "
                   + "AND id > ? "
                   + "ORDER BY id ASC "
                   + "LIMIT 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setPostType(rs.getString("post_type"));
                    post.setTitle(rs.getString("title"));
                    post.setSummary(rs.getString("summary"));
                    post.setContent(rs.getString("content"));
                    post.setCategory(rs.getString("category"));
                    post.setThumbnail(rs.getString("thumbnail"));
                    post.setAuthorId((Integer) rs.getObject("author_id"));
                    post.setViewCount(rs.getInt("view_count"));
                    post.setStatus(rs.getString("status"));
                    post.setIsPinned(rs.getInt("is_pinned"));
                    post.setDisplayOrder(rs.getInt("display_order"));
                    post.setPublishedAt(rs.getString("published_at"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setUpdatedAt(rs.getString("updated_at"));
                    post.setDeletedAt(rs.getString("deleted_at"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return post;
    }
}
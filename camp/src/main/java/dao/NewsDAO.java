package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.News;
import util.DBUtil;

public class NewsDAO {

    // 전체 목록
    public static List<News> getAll() {
        List<News> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM news ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                News n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setSummary(rs.getString("summary"));
                n.setCategory(rs.getString("category"));
                n.setImage(rs.getString("image"));
                n.setViews(rs.getInt("views"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 상세 조회
    public static News getById(int id) {
        News n = null;

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM news WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setSummary(rs.getString("summary"));
                n.setContent(rs.getString("content"));
                n.setCategory(rs.getString("category"));
                n.setImage(rs.getString("image"));
                n.setViews(rs.getInt("views"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return n;
    }

    // 조회수 증가
    public static void increaseViews(int id) {
        try (Connection conn = DBUtil.getConnection()) {
            String sql = "UPDATE news SET views = views + 1 WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 카테고리별 목록
    public static List<News> getByCategory(String category) {
        List<News> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM news WHERE category = ? ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, category);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                News n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setSummary(rs.getString("summary"));
                n.setContent(rs.getString("content"));
                n.setCategory(rs.getString("category"));
                n.setImage(rs.getString("image"));
                n.setViews(rs.getInt("views"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 카테고리 + 키워드 필터 검색
    public static List<News> getFilteredNews(String category, String keyword) {
        List<News> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM news WHERE 1=1");
        List<String> params = new ArrayList<>();

        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR summary LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                News n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setSummary(rs.getString("summary"));
                n.setContent(rs.getString("content"));
                n.setCategory(rs.getString("category"));
                n.setImage(rs.getString("image"));
                n.setViews(rs.getInt("views"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 이전 글
    public static News getPrevNews(int id) {
        News n = null;

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM news WHERE id < ? ORDER BY id DESC LIMIT 1";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setCategory(rs.getString("category"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return n;
    }

    // 다음 글
    public static News getNextNews(int id) {
        News n = null;

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM news WHERE id > ? ORDER BY id ASC LIMIT 1";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                n = new News();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setCategory(rs.getString("category"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return n;
    }
}
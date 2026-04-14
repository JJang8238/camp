package dao;

import util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InquiryDAO {

    // 🔥 문의 등록 (기존 그대로 유지)
    public boolean insertInquiry(int userId, String username, String title, String content) {
        String sql = "INSERT INTO inquiries(user_id, username, title, content) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, username);
            ps.setString(3, title);
            ps.setString(4, content);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🔥 문의 전체 조회
    public List<Map<String, String>> getAllInquiry() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT * FROM inquiries ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> map = new HashMap<>();

                map.put("id", rs.getString("id"));
                map.put("username", rs.getString("username"));
                map.put("title", rs.getString("title"));
                map.put("content", rs.getString("content"));
                map.put("created_at", rs.getString("created_at"));
                map.put("status", rs.getString("status"));

                list.add(map);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 🔥 문의 상세 조회 (추가)
    public Map<String, String> getInquiryById(int id) {
        Map<String, String> map = new HashMap<>();
        String sql = "SELECT * FROM inquiries WHERE id=?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                map.put("id", rs.getString("id"));
                map.put("username", rs.getString("username"));
                map.put("title", rs.getString("title"));
                map.put("content", rs.getString("content"));
                map.put("reply", rs.getString("reply"));
                map.put("status", rs.getString("status"));
                map.put("created_at", rs.getString("created_at"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    // 🔥 답변 저장 + 상태 변경 (추가)
    public boolean updateReply(int id, String reply) {
        String sql = "UPDATE inquiries SET reply=?, status='완료' WHERE id=?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reply);
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
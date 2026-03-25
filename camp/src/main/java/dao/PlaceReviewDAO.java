package dao;

import java.sql.*;
import java.util.*;
import util.DBUtil; // 프로젝트의 DBUtil 사용

public class PlaceReviewDAO {

    // 장소별 리뷰 목록 조회
    public List<Map<String, Object>> listByPlace(String place, String sort) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.*, u.name as user FROM place_review r " +
                     "JOIN user u ON r.userId = u.id " + // user 테이블과 조인
                     "WHERE r.place = ? ";
        
        if (sort.equals("high")) sql += "ORDER BY r.rating DESC";
        else sql += "ORDER BY r.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, place);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("content", rs.getString("content"));
                map.put("rating", rs.getInt("rating"));
                map.put("user", rs.getString("user"));
                map.put("userId", rs.getInt("userId"));
                map.put("created_at", rs.getTimestamp("created_at"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
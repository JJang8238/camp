package dao;

import java.sql.*;
import java.util.*;
import dto.Match;
import util.DBUtil;

public class MatchDAO {

    // ✅ 수정: 내가 예약한 캠핑장 목록 가져오기 (reservations + camps 기준)
    // 기존: matches 테이블에서 location 가져오기 → 데이터 없어서 드롭다운 비어있던 문제 해결
    public List<Match> getTodayMatches() {
        List<Match> list = new ArrayList<>();
        String sql = "SELECT DISTINCT c.name AS location " +
                     "FROM reservations r " +
                     "JOIN camps c ON r.camp_id = c.id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Match m = new Match();
                m.setLocation(rs.getString("location"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ✅ 수정: 특정 사용자가 해당 캠핑장을 실제로 예약했는지 확인 (reservations 기준)
    // 기존: 항상 true 반환하는 임시 코드 → 실제 DB 조회로 변경
    public boolean isUserReserved(int userId, int matchId) {
        // matchId는 이제 camp_id로 사용
        String sql = "SELECT COUNT(*) FROM reservations " +
                     "WHERE user_id = ? AND camp_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, matchId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ✅ 수정: 캠핑장 이름으로 Match 정보 가져오기 (camps 기준)
    // 기존: matches 테이블에서 location으로 검색 → camps 테이블로 변경
    public List<Match> getTodayMatchesByPlace(String place) {
        List<Match> list = new ArrayList<>();
        String sql = "SELECT id, name AS location FROM camps WHERE name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, place);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Match m = new Match();
                m.setId(rs.getInt("id"));
                m.setLocation(rs.getString("location"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}

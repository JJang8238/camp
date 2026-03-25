package dao;

import java.sql.*;
import java.util.*;
import dto.Match;
import util.DBUtil;

public class MatchDAO {

    // 모든 캠핑장 장소 목록 가져오기 (리뷰 페이지 상단 드롭다운용)
    public List<Match> getTodayMatches() {
        List<Match> list = new ArrayList<>();
        String sql = "SELECT DISTINCT location FROM matches"; // matches 테이블 기준
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

    // 특정 사용자가 해당 캠핑장을 예약(이용)했는지 확인 (리뷰 작성 권한)
    public boolean isUserReserved(int userId, int matchId) {
        // 실제 예약 테이블(예: reservations)이 있다면 해당 로직으로 수정 필요
        return true; // 우선 테스트를 위해 true 반환
    }
    
    // 장소명으로 매치 정보 가져오기
    public List<Match> getTodayMatchesByPlace(String place) {
        List<Match> list = new ArrayList<>();
        String sql = "SELECT * FROM matches WHERE location = ?";
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
package dao;

import java.sql.*;
import util.DBUtil;
import util.PasswordUtil;

public class UserDAO {
    private Connection conn;

    public UserDAO() {
        try {
            conn = DBUtil.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 🔥 추가: 아이디로 사용자의 실명을 가져오는 메서드
    public String getNameByUsername(String username) {
        String name = "";
        String sql = "SELECT name FROM users WHERE username = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                name = rs.getString("name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    // 회원가입 (기존과 동일)
    public boolean registerUser(String username, String password, String name, String email) {
        String sql = "INSERT INTO users (username, password, name, email) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String hashedPassword = PasswordUtil.hashPassword(password);
            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, name);
            pstmt.setString(4, email);
            return pstmt.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException e) {
            System.out.println("❌ 중복된 아이디 또는 이메일");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 로그인 (기존과 동일)
    public boolean login(String username, String password) {
        String sql = "SELECT password FROM users WHERE username=?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                String hashed = rs.getString("password");
                return PasswordUtil.checkPassword(password, hashed);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 아이디 중복 체크 (기존과 동일)
    public boolean isUsernameAvailable(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username=?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) { return rs.getInt(1) == 0; }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}
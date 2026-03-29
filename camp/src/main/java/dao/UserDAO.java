package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLIntegrityConstraintViolationException;

import dto.User;
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

    // 아이디(username)로 사용자의 실명 가져오기
    public String getNameByUsername(String username) {
        String name = "";
        String sql = "SELECT name FROM users WHERE username = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    name = rs.getString("name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return name;
    }

    // 회원가입
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

    // 로그인 체크
    public boolean login(String username, String password) {
        String sql = "SELECT password FROM users WHERE username = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String hashed = rs.getString("password");
                    return PasswordUtil.checkPassword(password, hashed);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 아이디 중복 체크
    public boolean isUsernameAvailable(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 판매자 id 기준 조회
    public User getUserById(int id) {
        User user = null;

        String sql = "SELECT id, username, name, email, created_at FROM users WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username")); // DB username -> DTO userId
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    // username 기준으로 사용자 전체 조회
    public User getUserByUsername(String username) {
        User user = null;

        String sql = "SELECT id, username, name, email, created_at FROM users WHERE username = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username")); // DB username -> DTO userId
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }
    
 // 회원번호(id)로 사용자의 실명 가져오기
    public String getNameByUserId(int id) {
        String name = "";
        String sql = "SELECT name FROM users WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    name = rs.getString("name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return name;
    }
}
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

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
    public boolean registerUser(String username, String password, String name, String email,
                                String role, String status,
                                String campName, String businessName, String businessNumber) {

        String sql = "INSERT INTO users "
                   + "(username, password, name, email, role, status, camp_name, business_name, business_number) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String hashedPassword = PasswordUtil.hashPassword(password);

            String safeRole = (role == null || role.trim().isEmpty()) ? "user" : role.trim().toLowerCase();
            String safeStatus = (status == null || status.trim().isEmpty()) ? "active" : status.trim().toUpperCase();

            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, name);
            pstmt.setString(4, email);
            pstmt.setString(5, role);
            pstmt.setString(6, status);

            if ("owner".equalsIgnoreCase(role)) {
                pstmt.setString(7, campName);
                pstmt.setString(8, businessName);
                pstmt.setString(9, businessNumber);
            } else {
                pstmt.setNull(7, java.sql.Types.VARCHAR);
                pstmt.setNull(8, java.sql.Types.VARCHAR);
                pstmt.setNull(9, java.sql.Types.VARCHAR);
            }

            return pstmt.executeUpdate() == 1;

        } catch (SQLIntegrityConstraintViolationException e) {
            System.out.println("중복된 아이디 또는 이메일");
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

    // 회원번호(id) 기준 사용자 조회
    public User getUserById(int id) {
        User user = null;

        String sql = "SELECT id, username, password, name, email, profileImage, role, status, "
                   + "camp_name, business_name, business_number, created_at "
                   + "FROM users WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setProfileImage(rs.getString("profileImage"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCampName(rs.getString("camp_name"));
                    user.setBusinessName(rs.getString("business_name"));
                    user.setBusinessNumber(rs.getString("business_number"));
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

        String sql = "SELECT id, username, password, name, email, profileImage, role, status, "
                   + "camp_name, business_name, business_number, created_at "
                   + "FROM users WHERE username = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setProfileImage(rs.getString("profileImage"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCampName(rs.getString("camp_name"));
                    user.setBusinessName(rs.getString("business_name"));
                    user.setBusinessNumber(rs.getString("business_number"));
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

    // 관리자용 일반 회원 목록 조회
    public List<User> getAdminUserList(String keyword, String status, String userRole) {
        List<User> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT id, username, name, email, role, status, created_at ");
        sql.append("FROM users WHERE 1=1 ");

        List<String> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (username LIKE ? OR name LIKE ? OR email LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (userRole != null && !userRole.trim().isEmpty()) {
            sql.append("AND role = ? ");
            params.add(userRole.trim().toLowerCase());
        }

        sql.append("ORDER BY id DESC");

        try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pstmt.setString(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(user);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 사업자 승인 대기 목록
    public List<User> getPendingOwnerList(String keyword) {
        List<User> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT id, username, name, email, role, status, camp_name, business_name, business_number, created_at ");
        sql.append("FROM users ");
        sql.append("WHERE role = 'owner' AND status = 'PENDING' ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (username LIKE ? OR name LIKE ? OR email LIKE ? OR camp_name LIKE ? OR business_name LIKE ? OR business_number LIKE ?) ");
        }

        sql.append("ORDER BY id DESC");

        try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                pstmt.setString(1, kw);
                pstmt.setString(2, kw);
                pstmt.setString(3, kw);
                pstmt.setString(4, kw);
                pstmt.setString(5, kw);
                pstmt.setString(6, kw);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUserId(rs.getString("username"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCampName(rs.getString("camp_name"));
                    user.setBusinessName(rs.getString("business_name"));
                    user.setBusinessNumber(rs.getString("business_number"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(user);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 관리자용 권한/상태 수정
    public boolean updateUserRoleAndStatus(int id, String newRole, String newStatus) {
        String sql = "UPDATE users SET role = ?, status = ? WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newRole == null ? "user" : newRole.trim().toLowerCase());
            pstmt.setString(2, newStatus == null ? "ACTIVE" : newStatus.trim().toUpperCase());
            pstmt.setInt(3, id);

            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 사업자 승인
    public boolean approveOwnerRequest(int id) {
        String sql = "UPDATE users SET status = 'ACTIVE' WHERE id = ? AND role = 'owner' AND status = 'PENDING'";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 사업자 반려
    public boolean rejectOwnerRequest(int id) {
        String sql = "UPDATE users SET status = 'BLOCKED' WHERE id = ? AND role = 'owner' AND status = 'PENDING'";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static int getTotalCount() {
        int count = 0;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    // ✅ 이름 + 이메일 수정
    public boolean updateProfile(int userId, String name, String email) {
        String sql = "UPDATE users SET name = ?, email = ? WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, userId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ 비밀번호 변경 (현재 비밀번호 BCrypt 검증 후 변경)
    public boolean updatePassword(int userId, String currentPassword, String newPassword) {
        // 1) 현재 비밀번호 조회
        String selectSql = "SELECT password FROM users WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hashed = rs.getString("password");
                    // 2) BCrypt 검증
                    if (!PasswordUtil.checkPassword(currentPassword, hashed)) {
                        return false; // 현재 비밀번호 불일치
                    }
                } else {
                    return false; // 사용자 없음
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        // 3) 새 비밀번호로 업데이트
        String updateSql = "UPDATE users SET password = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

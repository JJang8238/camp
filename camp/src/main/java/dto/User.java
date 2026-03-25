package dto;

import java.sql.Timestamp;

public class User {
    private int id;             // 고유 번호 (PK)
    private String userId;      // 로그인 아이디
    private String password;    // 비밀번호
    private String name;        // 사용자 이름
    private String email;       // 이메일
    private Timestamp createdAt; // 가입일

    // 기본 생성자
    public User() {}

    // 모든 필드를 포함한 생성자 (선택 사항)
    public User(int id, String userId, String name, String email) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.email = email;
    }

    // Getter & Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
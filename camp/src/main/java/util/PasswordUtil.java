package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // 🔐 비밀번호 해시 생성
    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    // 🔐 비밀번호 검증
    public static boolean checkPassword(String password, String hashed) {
        return BCrypt.checkpw(password, hashed);
    }
}
package util;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordTest {
    public static void main(String[] args) {
        String raw = "1234"; // 원하는 비밀번호
        String hash = BCrypt.hashpw(raw, BCrypt.gensalt());

        System.out.println(hash);
    }
}
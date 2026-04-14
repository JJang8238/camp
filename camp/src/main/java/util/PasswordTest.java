package util;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordTest {
    public static void main(String[] args) {
    	String hash = PasswordUtil.hashPassword("1234");
    
        System.out.println(hash);
    }
}
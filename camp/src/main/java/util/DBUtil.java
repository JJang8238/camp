package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBUtil {

    public static Connection getConnection() throws Exception {
        String endpoint = "database-1.cl8uye0wmyvw.ap-northeast-2.rds.amazonaws.com"; 
        String dbName = "camp_DB"; 
        
        String url = "jdbc:mysql://" + endpoint + ":3306/" + dbName 
                   + "?serverTimezone=Asia/Seoul&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true";
        
        String user = "admin"; 
        String password = "wkdtpgus9162"; 

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, password);
    }
}
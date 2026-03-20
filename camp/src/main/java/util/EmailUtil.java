package util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {

    public static void sendText(String to, String subject, String content) throws Exception {

        // 1. 발송자 정보 설정
        final String fromEmail = "jjang761213@naver.com";   
        // ⚠️ 주의: 네이버 2단계 인증 사용 시, 일반 비밀번호가 아닌 '앱 비밀번호' 16자리를 입력해야 합니다.
        final String password  = "D56P7RQUVZ4J"; 
        final String SENDER_NAME = "캠프메이트"; // 메일 발신자 이름
        // 2. SMTP 서버 설정 (네이버 전용)
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); // 네이버는 SSL 필수
        props.put("mail.smtp.ssl.trust", "smtp.naver.com");

        // 3. 세션 생성 및 인증
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        // 4. 메세지 작성 및 발송
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(content);

            Transport.send(message);
            System.out.println("메일 발송 성공: " + to);
            
        } catch (MessagingException e) {
            System.out.println("메일 발송 중 오류 발생: " + e.getMessage());
            throw e; // Servlet에서 잡아서 처리할 수 있게 던짐
        }
    }
}
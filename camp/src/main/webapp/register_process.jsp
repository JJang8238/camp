<%@ page import="java.sql.*, dao.UserDAO" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
request.setCharacterEncoding("UTF-8");

// 🔥 이메일 인증 체크 (세션 → hidden 값으로 변경)
String emailVerified = request.getParameter("emailVerified");
if (!"1".equals(emailVerified)) {
%>
<script>
    alert("이메일 인증을 먼저 완료해주세요.");
    history.back();
</script>
<%
    return;
}

// 🔥 폼 데이터 받기
String username = request.getParameter("username");
String password = request.getParameter("password");
String name     = request.getParameter("name");
String email    = request.getParameter("email");

// 🔥 null 방어
if (username == null || password == null || name == null || email == null ||
    username.trim().isEmpty() || password.trim().isEmpty() ||
    name.trim().isEmpty() || email.trim().isEmpty()) {
%>
<script>
    alert("모든 값을 입력해주세요.");
    history.back();
</script>
<%
    return;
}

// 🔥 DAO 처리
UserDAO dao = new UserDAO();
boolean success = dao.registerUser(username, password, name, email);

if (success) {
%>
<script>
    alert("회원가입 성공!");
    location.href = "login.jsp";
</script>
<%
} else {
%>
<script>
    alert("회원가입 실패. 아이디 또는 이메일이 이미 존재합니다.");
    history.back();
</script>
<%
}
%>
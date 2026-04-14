<%@ page import="dao.UserDAO" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
request.setCharacterEncoding("UTF-8");

// 이메일 인증 체크
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

// 공통 값
String role     = request.getParameter("role");
String username = request.getParameter("username");
String password = request.getParameter("password");
String name     = request.getParameter("name");
String email    = request.getParameter("email");

// 기본값
if (role == null || role.trim().isEmpty()) {
    role = "user";
}
role = role.trim().toLowerCase();

// 공통 필수값 검사
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

username = username.trim();
password = password.trim();
name = name.trim();
email = email.trim();

// 사장님 전용 값
String campName       = request.getParameter("campName");
String businessName   = request.getParameter("businessName");
String businessNumber = request.getParameter("businessNumber");

// 상태값
String status = "ACTIVE";

// 사장님 추가 검증
if ("owner".equals(role)) {
    if (campName == null || businessName == null || businessNumber == null ||
        campName.trim().isEmpty() || businessName.trim().isEmpty() || businessNumber.trim().isEmpty()) {
%>
<script>
    alert("캠핑장 사장님 회원은 캠핑장명, 사업자명, 사업자등록번호를 모두 입력해야 합니다.");
    history.back();
</script>
<%
        return;
    }

    campName = campName.trim();
    businessName = businessName.trim();
    businessNumber = businessNumber.trim();

    // 사업자 회원은 승인 대기 상태
    status = "PENDING";
} else {
    campName = null;
    businessName = null;
    businessNumber = null;
    status = "ACTIVE";
}

// DAO 처리
UserDAO dao = new UserDAO();

boolean success = dao.registerUser(
	    username,
	    password,
	    name,
	    email,
	    role,
	    status, // 🔥 추가
	    campName,
	    businessName,
	    businessNumber
	);

if (success) {
    String msg = "owner".equals(role)
        ? "회원가입이 완료되었습니다. 관리자 승인 후 일부 사업자 기능이 활성화됩니다."
        : "회원가입 성공!";
%>
<script>
    alert("<%= msg %>");
    location.href = "login.jsp";
</script>
<%
} else {
%>
<script>
    alert("회원가입 실패. 아이디 또는 이메일이 이미 존재하거나 저장 중 오류가 발생했습니다.");
    history.back();
</script>
<%
}
%>
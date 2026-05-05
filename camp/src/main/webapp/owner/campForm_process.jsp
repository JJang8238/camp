<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="util.DBUtil" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>

<%
request.setCharacterEncoding("UTF-8");
String ctx = request.getContextPath();

// 로그인 체크
Integer loginUserId = (Integer) session.getAttribute("userId");
if (loginUserId == null) {
%>
<script>
    alert("로그인이 필요합니다.");
    location.href = "<%=ctx%>/login.jsp";
</script>
<%
    return;
}

// 권한 체크
UserDAO userDAO = new UserDAO();
User loginUser = userDAO.getUserById(loginUserId);

if (loginUser == null || !"owner".equalsIgnoreCase(loginUser.getRole())) {
%>
<script>
    alert("사장님 계정만 접근 가능합니다.");
    location.href = "<%=ctx%>/main.jsp";
</script>
<%
    return;
}

//======================
//파라미터 받기 (Multipart 방식 대응)
//======================

//헬퍼 함수: Part에서 텍스트 값 추출
//(JSP 파일 안에 선언하기 어렵다면 아래처럼 직접 작성)
String name = "";
Part namePart = request.getPart("name");
if (namePart != null) {
 name = new String(namePart.getInputStream().readAllBytes(), "UTF-8");
}

String address = "";
Part addrPart = request.getPart("address");
if (addrPart != null) {
 address = new String(addrPart.getInputStream().readAllBytes(), "UTF-8");
}

String type = "";
Part typePart = request.getPart("type");
if (typePart != null) {
 type = new String(typePart.getInputStream().readAllBytes(), "UTF-8");
}

String tags = "";
Part tagsPart = request.getPart("tags");
if (tagsPart != null) {
 tags = new String(tagsPart.getInputStream().readAllBytes(), "UTF-8");
}

String priceStr = "";
Part pricePart = request.getPart("price");
if (pricePart != null) {
 priceStr = new String(pricePart.getInputStream().readAllBytes(), "UTF-8");
}

String status = "";
Part statusPart = request.getPart("status");
if (statusPart != null) {
 status = new String(statusPart.getInputStream().readAllBytes(), "UTF-8");
}

String description = "";
Part descPart = request.getPart("description");
if (descPart != null) {
 description = new String(descPart.getInputStream().readAllBytes(), "UTF-8");
}
if (name == null || name.trim().isEmpty() ||
    address == null || address.trim().isEmpty()) {
%>
<script>
    alert("필수값이 누락되었습니다.");
    history.back();
</script>
<%
    return;
}

// 숫자 변환
int price = 0;
try {
    price = Integer.parseInt(priceStr);
} catch (Exception e) {
    price = 0;
}

// ======================
// 파일 업로드 처리
// ======================
String uploadPath = application.getRealPath("/upload/camp");
File uploadDir = new File(uploadPath);

if (!uploadDir.exists()) {
    uploadDir.mkdirs();
}

Part filePart = request.getPart("imageFile");
String fileName = "";

if (filePart != null && filePart.getSize() > 0) {
    String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

    String savedFileName = System.currentTimeMillis() + "_" + originalFileName;
    String fullPath = uploadPath + File.separator + savedFileName;

    filePart.write(fullPath);

    fileName = "/upload/camp/" + savedFileName;
}

// ======================
// DB 저장
// ======================
Connection conn = null;
PreparedStatement pstmt = null;

try {
    conn = DBUtil.getConnection();

    String sql = "INSERT INTO camps (name, address, type, tags, price, image, status, description) "
               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    pstmt = conn.prepareStatement(sql);

    pstmt.setString(1, name);
    pstmt.setString(2, address);
    pstmt.setString(3, type);
    pstmt.setString(4, tags);
    pstmt.setInt(5, price);
    pstmt.setString(6, fileName);
    pstmt.setString(7, status);
    pstmt.setString(8, description);

    pstmt.executeUpdate();

} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert("캠핑장 등록 중 오류 발생");
    history.back();
</script>
<%
    return;
} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>

<script>
    alert("캠핑장이 등록되었습니다.");
    location.href = "<%=ctx%>/owner/dashboard.jsp";
</script>
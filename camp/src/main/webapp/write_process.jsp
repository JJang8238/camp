<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page import="util.DBUtil" %>

<%
request.setCharacterEncoding("UTF-8");
String ctx = request.getContextPath();

// 로그인 체크
Integer sellerId = (Integer) session.getAttribute("userId");
if (sellerId == null) {
%>
<script>
    alert("로그인이 필요합니다.");
    location.href = "<%=ctx%>/login.jsp";
</script>
<%
    return;
}

// 일반 파라미터
String name = request.getParameter("title");
String description = request.getParameter("description");
String priceStr = request.getParameter("price");
String category = request.getParameter("category");
String location = request.getParameter("location");

if (name == null) name = "";
if (description == null) description = "";
if (category == null) category = "";
if (location == null) location = "";

name = name.trim();
description = description.trim();
category = category.trim();
location = location.trim();

if (name.isEmpty() || description.isEmpty() || priceStr == null || priceStr.trim().isEmpty()
        || category.isEmpty() || location.isEmpty()) {
%>
<script>
    alert("필수 항목을 모두 입력해 주세요.");
    history.back();
</script>
<%
    return;
}

// 가격 변환
int price = 0;
try {
    price = Integer.parseInt(priceStr.trim());
    if (price < 0) price = 0;
} catch (Exception e) {
%>
<script>
    alert("가격은 숫자로 입력해 주세요.");
    history.back();
</script>
<%
    return;
}

// 업로드 경로
String uploadPath = application.getRealPath("/uploads/product");
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) uploadDir.mkdirs();

// 이미지 저장
List<String> imagePaths = new ArrayList<>();

for (Part part : request.getParts()) {
    if (!"images".equals(part.getName())) continue;
    if (part.getSize() <= 0) continue;

    String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
    if (fileName == null || fileName.isEmpty()) continue;

    String ext = "";
    int dot = fileName.lastIndexOf(".");
    if (dot != -1) ext = fileName.substring(dot);

    String savedName = System.currentTimeMillis() + "_" + (int)(Math.random()*10000) + ext;
    String fullPath = uploadPath + File.separator + savedName;

    part.write(fullPath);
    imagePaths.add("/uploads/product/" + savedName);
}

if (imagePaths.isEmpty()) {
%>
<script>
    alert("이미지를 최소 1장 업로드하세요.");
    history.back();
</script>
<%
    return;
}

// DB 저장
Connection conn = null;
PreparedStatement psProduct = null;
PreparedStatement psImage = null;
ResultSet rs = null;

try {
    conn = DBUtil.getConnection();
    conn.setAutoCommit(false);

    String productSql =
        "INSERT INTO product (name, price, image, seller_id, description, category, location, created_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

    psProduct = conn.prepareStatement(productSql, Statement.RETURN_GENERATED_KEYS);
    psProduct.setString(1, name);
    psProduct.setInt(2, price);
    psProduct.setString(3, imagePaths.get(0)); // 대표 이미지
    psProduct.setInt(4, sellerId);
    psProduct.setString(5, description);
    psProduct.setString(6, category);
    psProduct.setString(7, location);

    psProduct.executeUpdate();

    rs = psProduct.getGeneratedKeys();
    int productId = 0;
    if (rs.next()) productId = rs.getInt(1);

    String imageSql =
        "INSERT INTO product_image (product_id, image_path, sort_order) VALUES (?, ?, ?)";

    psImage = conn.prepareStatement(imageSql);

    for (int i = 0; i < imagePaths.size(); i++) {
        psImage.setInt(1, productId);
        psImage.setString(2, imagePaths.get(i));
        psImage.setInt(3, i + 1);
        psImage.executeUpdate();
    }

    conn.commit();
%>
<script>
    alert("상품 등록 완료!");
    location.href = "<%=ctx%>/productDetail.jsp?id=<%=productId%>";
</script>
<%
} catch (Exception e) {
    e.printStackTrace();
    if (conn != null) conn.rollback();
%>
<script>
    alert("등록 실패");
    history.back();
</script>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    try { if (psImage != null) psImage.close(); } catch (Exception ignore) {}
    try { if (psProduct != null) psProduct.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}
%>
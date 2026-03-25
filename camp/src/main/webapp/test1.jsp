<%@ page import="java.sql.Connection" %>
<%@ page import="util.DBUtil" %>

<%
try {
    Connection conn = DBUtil.getConnection();
    out.println("DB 연결 성공");
    conn.close();
} catch (Exception e) {
    out.println("DB 연결 실패: " + e.getMessage());
    e.printStackTrace();
}
%>
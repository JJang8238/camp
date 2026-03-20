<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.invalidate(); // 세션 삭제
    response.sendRedirect("index.jsp"); // 인덱스로 이동
%>
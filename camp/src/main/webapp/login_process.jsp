<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserDAO" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // 1. 한글 깨짐 방지 설정
    request.setCharacterEncoding("UTF-8");

    // 2. 파라미터 수신 (login.jsp의 input name과 일치해야 함)
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    // 3. 필수값 체크
    if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("아이디와 비밀번호를 모두 입력해주세요.", "UTF-8"));
        return;
    }

    // 4. DAO를 통한 로그인 검증 (BCrypt 비교 로직 포함됨)
    UserDAO dao = new UserDAO();
    boolean loginSuccess = dao.login(username, password);

    if (loginSuccess) {
        // 5. 로그인 성공: 세션에 사용자 아이디 저장
        session.setAttribute("userId", username);
        
        // 메인 페이지 또는 대시보드로 이동 (경로는 본인 환경에 맞게 수정)
        response.sendRedirect("main.jsp"); 
    } else {
        // 6. 로그인 실패: 에러 메시지와 함께 로그인 페이지로 리턴
        String msg = URLEncoder.encode("아이디 또는 비밀번호가 일치하지 않습니다.", "UTF-8");
        response.sendRedirect("login.jsp?error=" + msg);
    }
%>
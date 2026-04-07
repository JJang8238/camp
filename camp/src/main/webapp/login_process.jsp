<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page import="java.net.URLEncoder" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("아이디와 비밀번호를 모두 입력해주세요.", "UTF-8"));
        return;
    }

    username = username.trim();
    password = password.trim();

    UserDAO dao = new UserDAO();
    boolean loginSuccess = dao.login(username, password);

    if (loginSuccess) {
        User loginUser = dao.getUserByUsername(username);

        if (loginUser == null) {
            String msg = URLEncoder.encode("사용자 정보를 불러오지 못했습니다.", "UTF-8");
            response.sendRedirect("login.jsp?error=" + msg);
            return;
        }

        session.setAttribute("userId", loginUser.getId());
        session.setAttribute("username", loginUser.getUserId());
        session.setAttribute("userName", loginUser.getName());
        session.setAttribute("role", loginUser.getRole());
        session.setAttribute("status", loginUser.getStatus());

        response.sendRedirect("main.jsp");
    } else {
        String msg = URLEncoder.encode("아이디 또는 비밀번호가 일치하지 않습니다.", "UTF-8");
        response.sendRedirect("login.jsp?error=" + msg);
    }
%>
package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/approveUser")
public class AdminApproveServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 승인할 유저의 고유 ID와 부여할 역할(OWNER)을 받음
        int id = Integer.parseInt(req.getParameter("id"));
        
        UserDAO dao = new UserDAO();
        // 상태를 1(승인완료)로 변경
        boolean success = dao.updateUserRoleAndStatus(id, "OWNER", "1");

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users.jsp?msg=approved");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users.jsp?error=fail");
        }
    }
}
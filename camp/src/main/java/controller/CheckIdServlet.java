package controller;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/user/checkId")
public class CheckIdServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String username = req.getParameter("username");

        UserDAO dao = new UserDAO();
        boolean available = dao.isUsernameAvailable(username);

        resp.setContentType("text/plain;charset=UTF-8");

        if (available) {
            resp.getWriter().write("available"); // 🔥 핵심
        } else {
            resp.getWriter().write("taken");
        }
    }
}
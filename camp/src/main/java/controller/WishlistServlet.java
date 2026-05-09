package controller;

import dao.WishlistDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/wishToggle")
public class WishlistServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            out.print("{\"success\":false,\"message\":\"login_required\"}");
            return;
        }

        String campIdStr = request.getParameter("campId");
        String action    = request.getParameter("action"); // "add" | "remove"

        if (campIdStr == null || action == null) {
            out.print("{\"success\":false,\"message\":\"invalid_param\"}");
            return;
        }

        try {
            int campId = Integer.parseInt(campIdStr);
            boolean ok;

            if ("add".equals(action)) {
                ok = WishlistDAO.addWishlist(userId, campId);
            } else {
                ok = WishlistDAO.removeWishlist(userId, campId);
            }

            out.print("{\"success\":" + ok + "}");

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"invalid_id\"}");
        }
    }
}

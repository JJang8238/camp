package controller;

import dao.CampDAO;
import dto.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/campList")
public class CampListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CampDAO campDAO = new CampDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String keyword  = request.getParameter("keyword");
        String type     = request.getParameter("type");
        String loc      = request.getParameter("loc");
        String facility = request.getParameter("facility");
        String checkIn  = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");

        // ✅ 메인 AI 질문에서 선택한 캠핑 스타일 파라미터
        String styles = request.getParameter("styles");

        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");

        String sort = request.getParameter("sort");
        if (sort == null || sort.trim().isEmpty()) sort = "recommend";

        int page = 1, pageSize = 10;
        String pageStr = request.getParameter("page");
        try {
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        int totalCount = campDAO.getCampCount(keyword, type, loc, facility, checkIn, checkOut);
        int totalPage  = Math.max(1, (int) Math.ceil((double) totalCount / pageSize));
        if (page > totalPage) page = totalPage;

        // ✅ styles 포함 버전으로 목록 조회
        List<Product> campList = campDAO.getCampListPagingWithStyles(
                keyword, type, loc, facility, sort, checkIn, checkOut, styles, page, pageSize
        );

        request.setAttribute("campList",    campList);
        request.setAttribute("totalCount",  totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPage",   totalPage);
        request.setAttribute("styles",      styles != null ? styles : "");

        request.getRequestDispatcher("/campList.jsp").forward(request, response);
    }
}

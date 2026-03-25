package controller;

import com.google.gson.Gson;
import dao.ProductDAO;
import dto.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.*;

@WebServlet({"/product", "/campList"})
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/product")) {
            handleProductList(request, response);
        } else if (path.equals("/campList")) {
            handleCampSearch(request, response);
        }
    }

    // 중고 용품 목록 조회 - JSON 응답
    private void handleProductList(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        List<Product> list = ProductDAO.getAllProducts();

        String json = new Gson().toJson(list);
        response.getWriter().print(json);
    }

    // 캠핑장 검색 및 필터링 처리
    private void handleCampSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. 기본 검색 파라미터
        String keyword = request.getParameter("keyword");
        String tags = request.getParameter("tags");

        if (keyword == null) keyword = "";
        if (tags == null) tags = "";

        // 2. 숙소유형 (콤마 문자열 → 리스트)
        String typeParam = request.getParameter("type");
        List<String> typeList = (typeParam != null && !typeParam.trim().isEmpty())
                ? Arrays.asList(typeParam.split("\\s*,\\s*"))
                : new ArrayList<>();

        // 3. 지역 (콤마 문자열 → 리스트)
        String locParam = request.getParameter("loc");
        List<String> locList = (locParam != null && !locParam.trim().isEmpty())
                ? Arrays.asList(locParam.split("\\s*,\\s*"))
                : new ArrayList<>();

        // 4. DAO 호출
        List<Product> campList = productDAO.getFilteredCampList(keyword, tags, typeList, locList);

        // 5. JSP 전달
        request.setAttribute("campList", campList);

        request.getRequestDispatcher("/campList.jsp").forward(request, response);
    }
}
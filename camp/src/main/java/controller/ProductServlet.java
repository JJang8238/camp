package controller;

import com.google.gson.Gson;
import dao.ProductDAO;
import dto.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.*;

// 기존 /product(용품)와 새롭게 추가된 /campList(캠핑장) 경로를 모두 처리합니다.
@WebServlet({"/product", "/campList"})
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        // 1. 기존 기능: 메인 하단 중고 용품 목록 (JSON 반환)
        if (path.equals("/product")) {
            handleProductList(request, response);
        } 
        // 2. 추가 기능: 캠핑장 검색 및 필터링 (JSP 포워딩)
        else if (path.equals("/campList")) {
            handleCampSearch(request, response);
        }
    }

    // [기존 기능 유지] 중고 용품 목록 조회 - JSON 응답
    private void handleProductList(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        // DAO의 기존 메서드 호출
        List<Product> list = ProductDAO.getAllProducts();
        
        String json = new Gson().toJson(list);
        response.getWriter().print(json);
    }

    // [새 기능] 캠핑장 검색 및 필터링 처리
    private void handleCampSearch(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        
        // 1. 파라미터 수집 (메인 검색창, 해시태그, 사이드바 필터)
        String keyword = request.getParameter("keyword"); 
        String tags = request.getParameter("tags");       
        String[] types = request.getParameterValues("type"); 

        // 2. DAO를 통해 필터링된 데이터 가져오기 (비즈니스 로직 분리)
        List<Product> campList = productDAO.getFilteredCampList(keyword, tags, types);

        // 3. JSP에서 사용할 수 있도록 데이터를 request에 저장
        request.setAttribute("campList", campList);
        
        // 4. 결과 화면인 campList.jsp로 이동
        request.getRequestDispatcher("/campList.jsp").forward(request, response);
    }
}
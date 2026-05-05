package controller;

import com.google.gson.Gson;
import dao.ProductDAO;
import dto.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 중고 용품 목록 조회 - JSON 응답
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        List<Product> list = ProductDAO.getAllProducts();

        String json = new Gson().toJson(list);
        response.getWriter().print(json);
    }
}
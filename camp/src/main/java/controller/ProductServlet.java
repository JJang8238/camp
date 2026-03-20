package controller;

import com.google.gson.Gson;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import util.DBUtil;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {

            String sql = "SELECT name, price, image FROM product";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("name"));
                map.put("price", rs.getInt("price"));
                map.put("image", rs.getString("image"));

                list.add(map);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        Gson gson = new Gson();
        String json = gson.toJson(list);

        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }
}
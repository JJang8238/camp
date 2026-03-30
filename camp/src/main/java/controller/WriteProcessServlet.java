package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import dto.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import util.DBUtil;

@WebServlet("/product/write_process")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,   // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class WriteProcessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String ctx = request.getContextPath();
        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('로그인이 필요합니다.');");
            response.getWriter().println("location.href='" + ctx + "/login.jsp';");
            response.getWriter().println("</script>");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String category = request.getParameter("category");
        String location = request.getParameter("location");

        if (title == null) title = "";
        if (description == null) description = "";
        if (category == null) category = "";
        if (location == null) location = "";

        title = title.trim();
        description = description.trim();
        category = category.trim();
        location = location.trim();

        if (title.isEmpty() || description.isEmpty() || priceStr == null || priceStr.trim().isEmpty()
                || category.isEmpty() || location.isEmpty()) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('필수 항목을 모두 입력해 주세요.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        int price;
        try {
            price = Integer.parseInt(priceStr.trim());
            if (price < 0) price = 0;
        } catch (Exception e) {
            response.getWriter().println("<script>");
            response.getWriter().println("alert('가격은 숫자로 입력해 주세요.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        String uploadPath = getServletContext().getRealPath("/uploads/product");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        List<String> imagePaths = new ArrayList<>();

        try {
            for (Part part : request.getParts()) {
                if (!"images".equals(part.getName())) continue;
                if (part.getSize() <= 0) continue;

                String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                if (originalFileName == null || originalFileName.isEmpty()) continue;

                String ext = "";
                int dotIdx = originalFileName.lastIndexOf(".");
                if (dotIdx != -1) {
                    ext = originalFileName.substring(dotIdx);
                }

                String savedFileName = System.currentTimeMillis() + "_" + (int)(Math.random() * 100000) + ext;
                String fullPath = uploadPath + File.separator + savedFileName;

                part.write(fullPath);
                imagePaths.add("/uploads/product/" + savedFileName);
            }

            if (imagePaths.isEmpty()) {
                response.getWriter().println("<script>");
                response.getWriter().println("alert('상품 이미지를 1장 이상 업로드해 주세요.');");
                response.getWriter().println("history.back();");
                response.getWriter().println("</script>");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>");
            response.getWriter().println("alert('이미지 업로드 중 오류가 발생했습니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");
            return;
        }

        Connection conn = null;
        PreparedStatement psProduct = null;
        PreparedStatement psImage = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String productSql =
                "INSERT INTO product (name, price, image, seller_id, description, category, location, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

            psProduct = conn.prepareStatement(productSql, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, title);
            psProduct.setInt(2, price);
            psProduct.setString(3, imagePaths.get(0)); // 대표 이미지
            psProduct.setInt(4, userId);
            psProduct.setString(5, description);
            psProduct.setString(6, category);
            psProduct.setString(7, location);

            int result = psProduct.executeUpdate();
            if (result <= 0) {
                throw new Exception("상품 등록 실패");
            }

            int productId = 0;
            rs = psProduct.getGeneratedKeys();
            if (rs.next()) {
                productId = rs.getInt(1);
            }

            if (productId <= 0) {
                throw new Exception("상품 ID 생성 실패");
            }

            String imageSql =
                "INSERT INTO product_image (product_id, image_path, sort_order, created_at) " +
                "VALUES (?, ?, ?, NOW())";

            psImage = conn.prepareStatement(imageSql);

            for (int i = 0; i < imagePaths.size(); i++) {
                psImage.setInt(1, productId);
                psImage.setString(2, imagePaths.get(i));
                psImage.setInt(3, i + 1);
                psImage.executeUpdate();
            }

            conn.commit();

            response.getWriter().println("<script>");
            response.getWriter().println("alert('상품이 등록되었습니다.');");
            response.getWriter().println("location.href='" + ctx + "/productDetail.jsp?id=" + productId + "';");
            response.getWriter().println("</script>");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignore) {}

            response.getWriter().println("<script>");
            response.getWriter().println("alert('상품 등록 중 오류가 발생했습니다.');");
            response.getWriter().println("history.back();");
            response.getWriter().println("</script>");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (psImage != null) psImage.close(); } catch (Exception ignore) {}
            try { if (psProduct != null) psProduct.close(); } catch (Exception ignore) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignore) {}
        }
    }
}
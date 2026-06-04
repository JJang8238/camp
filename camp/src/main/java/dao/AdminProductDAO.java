package dao;

import dto.Product;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminProductDAO {

    // 관리자용 전체 상품 목록 조회
    public List<Product> getAllProductsForAdmin() {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT id, seller_id, name, description, category, location, price, image, status, created_at " +
                     "FROM product ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setSellerId(rs.getInt("seller_id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setCategory(rs.getString("category"));
                p.setLocation(rs.getString("location"));
                p.setPrice(rs.getInt("price"));
                p.setImage(rs.getString("image"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getString("created_at"));
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 상품 상태 변경
    public boolean updateProductStatus(int productId, String status) {
        String sql = "UPDATE product SET status = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ 상품 완전 삭제 (관리자 전용)
    public boolean deleteProduct(int productId) {
        // product_image 먼저 삭제 후 product 삭제 (FK 제약 대비)
        String deleteImageSql = "DELETE FROM product_image WHERE product_id = ?";
        String deleteProductSql = "DELETE FROM product WHERE id = ?";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(deleteImageSql)) {
                ps1.setInt(1, productId);
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = conn.prepareStatement(deleteProductSql)) {
                ps2.setInt(1, productId);
                int affected = ps2.executeUpdate();
                conn.commit();
                return affected > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignore) {}
        }
        return false;
    }
}

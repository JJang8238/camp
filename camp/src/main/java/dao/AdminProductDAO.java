package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.Product;
import util.DBUtil;

public class AdminProductDAO {

    public List<Product> getAllProductsForAdmin() {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT id, seller_id, name, description, category, location, price, image, status, created_at " +
                     "FROM product " +
                     "ORDER BY id DESC";

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
}
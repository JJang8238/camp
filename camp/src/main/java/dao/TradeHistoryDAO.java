package dao;

import dto.Product;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TradeHistoryDAO {

    /**
     * 내가 판매 등록한 상품 목록 (seller_id = userId)
     */
    public static List<Product> getSellList(int userId) {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT id, name, price, image, category, location, status, created_at " +
                     "FROM product " +
                     "WHERE seller_id = ? " +
                     "ORDER BY created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setImage(rs.getString("image"));
                p.setCategory(rs.getString("category"));
                p.setLocation(rs.getString("location"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getString("created_at"));
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 내가 구매한 상품 목록 (product_purchase.buyer_id = userId)
     */
    public static List<Product> getBuyList(int userId) {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.id, p.name, p.price, p.image, p.category, p.location, p.status, " +
                     "       pp.purchased_at AS created_at " +
                     "FROM product_purchase pp " +
                     "JOIN product p ON pp.product_id = p.id " +
                     "WHERE pp.buyer_id = ? " +
                     "ORDER BY pp.purchased_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setImage(rs.getString("image"));
                p.setCategory(rs.getString("category"));
                p.setLocation(rs.getString("location"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getString("created_at"));
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}

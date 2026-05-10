package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.sql.Timestamp;

import dto.Product;
import util.DBUtil;

public class ProductDAO {

    /**
     * 메인 페이지 하단의 중고 용품 목록
     */
	public static List<Product> getAllProducts() {
	    List<Product> list = new ArrayList<>();

	    try (Connection conn = DBUtil.getConnection()) {
	        String sql =
	            "SELECT p.id, p.name, p.price, p.description, p.category, p.location, p.created_at, p.status, " +
	            "       COALESCE(p.image, pi.image_path) AS display_image " +
	            "FROM product p " +
	            "LEFT JOIN product_image pi " +
	            "       ON p.id = pi.product_id AND pi.sort_order = 1 " +
	            "WHERE p.status IS NULL OR p.status <> 'hidden' " +
	            "ORDER BY p.id DESC";

	        PreparedStatement ps = conn.prepareStatement(sql);
	        ResultSet rs = ps.executeQuery();

	        while (rs.next()) {
	            Product p = new Product();
	            p.setId(rs.getInt("id"));
	            p.setName(rs.getString("name"));
	            p.setPrice(rs.getInt("price"));
	            p.setImage(rs.getString("display_image"));
	            p.setDescription(rs.getString("description"));
	            p.setCategory(rs.getString("category"));
	            p.setLocation(rs.getString("location"));
	            p.setCreatedAt(rs.getString("created_at"));
	            p.setStatus(rs.getString("status"));

	            Timestamp created = rs.getTimestamp("created_at");
	            if (created != null) {
	                long diff = System.currentTimeMillis() - created.getTime();
	                long hours = diff / (1000 * 60 * 60);
	                p.setRecent(hours <= 24);
	            }

	            list.add(p);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return list;
	}

	public Product getProductById(int id) {
	    Product p = null;

	    try (Connection conn = DBUtil.getConnection()) {
	        String sql = "SELECT * FROM product WHERE id = ? AND (status IS NULL OR status <> 'hidden')";
	        PreparedStatement ps = conn.prepareStatement(sql);
	        ps.setInt(1, id);

	        ResultSet rs = ps.executeQuery();

	        if (rs.next()) {
	            p = new Product();
	            p.setId(rs.getInt("id"));
	            p.setName(rs.getString("name"));
	            p.setPrice(rs.getInt("price"));
	            p.setImage(rs.getString("image"));
	            p.setSellerId(rs.getInt("seller_id"));
	            p.setDescription(rs.getString("description"));
	            p.setCategory(rs.getString("category"));
	            p.setLocation(rs.getString("location"));
	            p.setCreatedAt(rs.getString("created_at"));
	            p.setStatus(rs.getString("status"));
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return p;
	}
	
	public List<Product> getProductsBySeller(int sellerId) {
	    List<Product> list = new ArrayList<>();

	    try (Connection conn = DBUtil.getConnection()) {
	        String sql = "SELECT * FROM product " +
	                     "WHERE seller_id = ? AND (status IS NULL OR status <> 'hidden') " +
	                     "ORDER BY id DESC";
	        PreparedStatement ps = conn.prepareStatement(sql);
	        ps.setInt(1, sellerId);

	        ResultSet rs = ps.executeQuery();

	        while (rs.next()) {
	            Product p = new Product();
	            p.setId(rs.getInt("id"));
	            p.setName(rs.getString("name"));
	            p.setPrice(rs.getInt("price"));
	            p.setImage(rs.getString("image"));
	            p.setSellerId(rs.getInt("seller_id"));
	            p.setStatus(rs.getString("status"));
	            list.add(p);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return list;
	}
   
    /**
     * 캠핑장 검색 + 필터
     * 
     * @param keyword  검색어 (이름 / 주소)
     * @param tags     메인 태그 검색
     * @param typeList 숙소유형 다중 선택
     * @param locList  지역 다중 선택
     */
    public List<Product> getFilteredCampList(String keyword, String tags, List<String> typeList, List<String> locList) {
        List<Product> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT * FROM camps WHERE 1=1");
        List<String> params = new ArrayList<>();

        // 1. 검색어
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR address LIKE ?)");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        // 2. 메인 태그 검색
        if (tags != null && !tags.trim().isEmpty()) {
            String[] tagArr = tags.split("\\s*,\\s*");

            if (tagArr.length > 0) {
                sql.append(" AND (");
                for (int i = 0; i < tagArr.length; i++) {
                    if (i > 0) sql.append(" OR ");
                    sql.append("tags LIKE ?");
                    params.add("%" + tagArr[i].trim() + "%");
                }
                sql.append(")");
            }
        }

        // 3. 숙소 유형 다중 선택
        if (typeList != null && !typeList.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < typeList.size(); i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("type LIKE ?");
                params.add("%" + typeList.get(i).trim() + "%");
            }
            sql.append(")");
        }

        // 4. 지역 다중 선택
        if (locList != null && !locList.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < locList.size(); i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("address LIKE ?");
                params.add("%" + locList.get(i).trim() + "%");
            }
            sql.append(")");
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // 파라미터 바인딩
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setAddress(rs.getString("address"));
                p.setType(rs.getString("type"));
                p.setTags(rs.getString("tags"));
                p.setPrice(rs.getInt("price"));
                p.setImageUrl(rs.getString("image"));   // campList 용
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ✅ 상품 수정 (본인 소유만)
    public boolean updateProduct(int productId, int sellerId, String name, String description,
                                  String category, String location, int price, String status) {
        String sql = "UPDATE product SET name=?, description=?, category=?, location=?, " +
                     "price=?, status=? WHERE id=? AND seller_id=?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, description);
            ps.setString(3, category);
            ps.setString(4, location);
            ps.setInt(5, price);
            ps.setString(6, status);
            ps.setInt(7, productId);
            ps.setInt(8, sellerId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ 상품 삭제 (숨김 처리, 본인 소유만)
    public boolean deleteProduct(int productId, int sellerId) {
        String sql = "UPDATE product SET status='hidden' WHERE id=? AND seller_id=?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, sellerId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
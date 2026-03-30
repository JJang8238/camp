package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.Product;
import util.DBUtil;

public class ProductDAO {

    /**
     * 메인 페이지 하단의 중고 용품 목록
     */
    public static List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM product";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));              // 상세보기 링크용
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setImage(rs.getString("image"));     // productList / main 용
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
            String sql = "SELECT * FROM product WHERE id=?";
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
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return p;
    }
    
    public List<Product> getProductsBySeller(int sellerId) {
        List<Product> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM product WHERE seller_id = ?";
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
}
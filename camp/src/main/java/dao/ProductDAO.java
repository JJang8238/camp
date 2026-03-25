package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.Product; // 사용자님의 DTO 패키지 경로에 맞게 확인하세요
import util.DBUtil;

public class ProductDAO {

    /**
     * [기존 기능 유지] 메인 페이지 하단의 중고 용품 목록을 가져옵니다.
     */
    public static List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM product";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                // 기존 코드의 p.setImage 유지 (DTO 필드명이 imageUrl이라면 p.setImageUrl로 수정)
                p.setImage(rs.getString("image")); 
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * [신규 기능] 캠핑장 검색 및 사이드바 필터링 결과를 가져옵니다.
     * @param keyword 메인 검색어 (이름 또는 주소 검색)
     * @param tags 메인 해시태그 검색 (#물놀이 등)
     * @param types 사이드바 숙소 유형 필터 (펜션, 글램핑 등 다중 선택)
     */
    public List<Product> getFilteredCampList(String keyword, String tags, String[] types) {
        List<Product> list = new ArrayList<>();
        
        // 1. 동적 SQL 조립 (camps 테이블 기준)
        StringBuilder sql = new StringBuilder("SELECT * FROM camps WHERE 1=1");

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (name LIKE ? OR address LIKE ?)");
        }
        if (tags != null && !tags.isEmpty()) {
            sql.append(" AND tags LIKE ?");
        }
        if (types != null && types.length > 0) {
            sql.append(" AND type IN (");
            for (int i = 0; i < types.length; i++) {
                sql.append(i == 0 ? "?" : ", ?");
            }
            sql.append(")");
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int idx = 1;
            
            // 2. 파라미터 바인딩
            if (keyword != null && !keyword.isEmpty()) {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }
            if (tags != null && !tags.isEmpty()) {
                ps.setString(idx++, "%" + tags + "%");
            }
            if (types != null && types.length > 0) {
                for (String t : types) {
                    ps.setString(idx++, t);
                }
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
                p.setImageUrl(rs.getString("image")); // DB 컬럼명 image를 DTO imageUrl에 세팅
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
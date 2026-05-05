package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import dto.Product;
import dto.Camp;
import util.DBUtil;

public class CampDAO {

    public Camp getCampById(int id) {
        Camp camp = null;
        String sql = "SELECT * FROM camps WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                camp = new Camp();
                camp.setId(rs.getInt("id"));
                camp.setName(rs.getString("name"));
                camp.setAddress(rs.getString("address"));
                camp.setType(rs.getString("type"));
                camp.setTags(rs.getString("tags"));
                camp.setPrice(rs.getInt("price"));
                camp.setImage(rs.getString("image"));
                camp.setStatus(rs.getString("status"));
                camp.setDescription(rs.getString("description"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return camp;
    }

    public List<Camp> getAllCamps() {
        List<Camp> list = new ArrayList<>();
        String sql = "SELECT * FROM camps ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Camp camp = new Camp();
                camp.setId(rs.getInt("id"));
                camp.setName(rs.getString("name"));
                camp.setAddress(rs.getString("address"));
                camp.setType(rs.getString("type"));
                camp.setTags(rs.getString("tags"));
                camp.setPrice(rs.getInt("price"));
                camp.setImage(rs.getString("image"));
                camp.setStatus(rs.getString("status"));
                camp.setDescription(rs.getString("description"));
                list.add(camp);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public boolean insertCampFromCsv(Camp camp) {
        String sql = "INSERT INTO camps "
                   + "(name, address, type, tags, price, image, description, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, camp.getName());
            ps.setString(2, camp.getAddress());
            ps.setString(3, camp.getType());
            ps.setString(4, camp.getTags());
            ps.setInt(5, camp.getPrice());
            ps.setString(6, camp.getImage());
            ps.setString(7, camp.getDescription());
            ps.setString(8, "active");

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public List<Product> getCampListPaging(String keyword, String type, String loc, String facility, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT id, name, address, type, tags, price, image ");
        sql.append("FROM camps ");
        sql.append("WHERE status = 'active' ");

        List<String> params = new ArrayList<>();

        // keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR address LIKE ? OR tags LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // type
        if (type != null && !type.trim().isEmpty()) {
            String[] types = type.split(",");
            sql.append("AND (");
            for (int i = 0; i < types.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("type LIKE ?");
                params.add("%" + types[i].trim() + "%");
            }
            sql.append(") ");
        }

        // loc
        if (loc != null && !loc.trim().isEmpty()) {
        	String[] locs = loc.split(",");
        	List<String> expandedLocs = new ArrayList<>();

        	for (String l : locs) {
        	    expandedLocs.addAll(expandLocationKeyword(l));
        	}

        	sql.append("AND (");
        	for (int i = 0; i < expandedLocs.size(); i++) {
        	    if (i > 0) sql.append(" OR ");
        	    sql.append("address LIKE ?");
        	    params.add("%" + expandedLocs.get(i).trim() + "%");
        	}
        	sql.append(") ");
        }

        // facility
        if (facility != null && !facility.trim().isEmpty()) {
            String[] facilities = facility.split(",");
            sql.append("AND (");
            for (int i = 0; i < facilities.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("tags LIKE ?");
                params.add("%" + facilities[i].trim() + "%");
            }
            sql.append(") ");
        }

        sql.append("ORDER BY id DESC ");
        sql.append("LIMIT ? OFFSET ?");

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int idx = 1;

            for (String param : params) {
                ps.setString(idx++, param);
            }

            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setAddress(rs.getString("address"));
                p.setType(rs.getString("type"));
                p.setTags(rs.getString("tags"));
                p.setPrice(rs.getInt("price"));
                p.setImageUrl(rs.getString("image"));
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public int getCampCount(String keyword, String type, String loc, String facility) {
        int count = 0;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM camps WHERE status = 'active' ");

        List<String> params = new ArrayList<>();

        // keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR address LIKE ? OR tags LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // type
        if (type != null && !type.trim().isEmpty()) {
            String[] types = type.split(",");
            sql.append("AND (");
            for (int i = 0; i < types.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("type LIKE ?");
                params.add("%" + types[i].trim() + "%");
            }
            sql.append(") ");
        }

        // loc
        if (loc != null && !loc.trim().isEmpty()) {
        	String[] locs = loc.split(",");
        	List<String> expandedLocs = new ArrayList<>();

        	for (String l : locs) {
        	    expandedLocs.addAll(expandLocationKeyword(l));
        	}

        	sql.append("AND (");
        	for (int i = 0; i < expandedLocs.size(); i++) {
        	    if (i > 0) sql.append(" OR ");
        	    sql.append("address LIKE ?");
        	    params.add("%" + expandedLocs.get(i).trim() + "%");
        	}
        	sql.append(") ");
        }

        // facility
        if (facility != null && !facility.trim().isEmpty()) {
            String[] facilities = facility.split(",");
            sql.append("AND (");
            for (int i = 0; i < facilities.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("tags LIKE ?");
                params.add("%" + facilities[i].trim() + "%");
            }
            sql.append(") ");
        }

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString())
        ) {
            int idx = 1;

            for (String param : params) {
                ps.setString(idx++, param);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
    
    private List<String> expandLocationKeyword(String loc) {
        List<String> list = new ArrayList<>();

        if (loc == null) return list;

        loc = loc.trim();

        switch (loc) {
            case "경상도":
                list.add("경상도");
                list.add("경상북도");
                list.add("경상남도");
                list.add("경북");
                list.add("경남");
                break;

            case "전라도":
                list.add("전라도");
                list.add("전라북도");
                list.add("전라남도");
                list.add("전북");
                list.add("전남");
                break;

            case "충청도":
                list.add("충청도");
                list.add("충청북도");
                list.add("충청남도");
                list.add("충북");
                list.add("충남");
                break;

            case "강원도":
                list.add("강원도");
                list.add("강원특별자치도");
                break;

            case "제주":
                list.add("제주");
                list.add("제주도");
                list.add("제주특별자치도");
                break;

            case "서울/경기":
                list.add("서울");
                list.add("서울특별시");
                list.add("경기");
                list.add("경기도");
                break;

            case "인천/강화도":
                list.add("인천");
                list.add("인천광역시");
                list.add("강화");
                list.add("강화도");
                break;

            case "거제/남해/통영":
                list.add("거제");
                list.add("남해");
                list.add("통영");
                break;

            case "안면도/태안":
                list.add("안면도");
                list.add("태안");
                break;

            case "대부도/선재도/영흥도":
                list.add("대부도");
                list.add("선재도");
                list.add("영흥도");
                break;

            case "춘천/홍천":
                list.add("춘천");
                list.add("홍천");
                break;

            default:
                list.add(loc);
                break;
        }

        return list;
    }
}
package dao;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import dto.Product;
import dto.Camp;
import util.DBUtil;

public class CampDAO {

    private static final Map<String, Integer> TAG_WEIGHTS = new LinkedHashMap<>();
    static {
        TAG_WEIGHTS.put("글램핑", 50);
        TAG_WEIGHTS.put("풀빌라", 50);
        TAG_WEIGHTS.put("카라반", 45);
        TAG_WEIGHTS.put("차박", 45);
        TAG_WEIGHTS.put("펜션", 40);
        TAG_WEIGHTS.put("Pool캠핑", 40);
        TAG_WEIGHTS.put("반려견", 40);
        TAG_WEIGHTS.put("애견동반", 40);
        TAG_WEIGHTS.put("계곡", 35);
        TAG_WEIGHTS.put("물놀이", 35);
        TAG_WEIGHTS.put("바다", 35);
        TAG_WEIGHTS.put("당일캠프닉", 30);
        TAG_WEIGHTS.put("깨끗한", 25);
        TAG_WEIGHTS.put("여유있는", 25);
        TAG_WEIGHTS.put("조용한", 25);
        TAG_WEIGHTS.put("야경", 20);
        TAG_WEIGHTS.put("캠프파이어", 20);
        TAG_WEIGHTS.put("산책로", 15);
        TAG_WEIGHTS.put("바베큐", 15);
        TAG_WEIGHTS.put("수영장", 15);
        TAG_WEIGHTS.put("스파", 15);
        TAG_WEIGHTS.put("카페", 10);
        TAG_WEIGHTS.put("매점", 10);
    }

    private static final Map<String, Integer> COMBO_BONUS = new LinkedHashMap<>();
    static {
        COMBO_BONUS.put("반려견,차박", 30);
        COMBO_BONUS.put("계곡,차박", 25);
        COMBO_BONUS.put("계곡,반려견", 25);
        COMBO_BONUS.put("글램핑,풀빌라", 20);
        COMBO_BONUS.put("글램핑,스파", 20);
        COMBO_BONUS.put("물놀이,수영장", 20);
        COMBO_BONUS.put("물놀이,바다", 20);
        COMBO_BONUS.put("깨끗한,여유있는", 15);
        COMBO_BONUS.put("당일캠프닉,바베큐", 15);
        COMBO_BONUS.put("반려견,애견동반", 15);
        COMBO_BONUS.put("계곡,물놀이", 20);
        COMBO_BONUS.put("조용한,여유있는", 15);
        COMBO_BONUS.put("캠프파이어,차박", 15);
        COMBO_BONUS.put("글램핑,야경", 15);
    }

    private static final Map<String, List<String>> RELATED_TAGS = new LinkedHashMap<>();
    static {
        RELATED_TAGS.put("차박", Arrays.asList("자연", "조용한", "힐링", "산"));
        RELATED_TAGS.put("글램핑", Arrays.asList("프리미엄", "럭셔리", "감성"));
        RELATED_TAGS.put("반려견", Arrays.asList("애견동반", "펫"));
        RELATED_TAGS.put("계곡", Arrays.asList("자연", "물놀이", "산", "계곡물"));
        RELATED_TAGS.put("물놀이", Arrays.asList("계곡", "수영", "바다", "워터파크"));
        RELATED_TAGS.put("깨끗한", Arrays.asList("청결", "위생", "관리"));
        RELATED_TAGS.put("풀빌라", Arrays.asList("프리미엄", "럭셔리", "풀"));
        RELATED_TAGS.put("바다", Arrays.asList("해변", "바닷가", "해수욕", "낚시"));
        RELATED_TAGS.put("당일캠프닉", Arrays.asList("피크닉", "당일치기", "낮"));
        RELATED_TAGS.put("카라반", Arrays.asList("이동식", "RV", "캠핑카"));
    }

    public static final Map<String, List<String>> STYLE_TO_TAGS = new LinkedHashMap<>();
    static {
        STYLE_TO_TAGS.put("감성힐링", Arrays.asList("글램핑", "야경", "캠프파이어", "조용한", "여유있는"));
        STYLE_TO_TAGS.put("액티브", Arrays.asList("물놀이", "수영장", "계곡", "바베큐", "Pool캠핑"));
        STYLE_TO_TAGS.put("반려동물", Arrays.asList("반려견", "애견동반", "산책로"));
        STYLE_TO_TAGS.put("럭셔리", Arrays.asList("글램핑", "풀빌라", "스파", "깨끗한"));
        STYLE_TO_TAGS.put("자연탐험", Arrays.asList("차박", "계곡", "자연", "조용한"));
        STYLE_TO_TAGS.put("가족여행", Arrays.asList("어린이놀이터", "수영장", "바베큐", "깨끗한", "물놀이"));
        STYLE_TO_TAGS.put("로맨틱", Arrays.asList("글램핑", "야경", "풀빌라", "스파", "감성"));
        STYLE_TO_TAGS.put("당일치기", Arrays.asList("당일캠프닉", "바베큐", "피크닉"));
    }

    private static String COL_CHECK_IN = null;
    private static String COL_CHECK_OUT = null;
    private static boolean reservationTableChecked = false;

    private static synchronized void detectReservationColumns() {
        if (reservationTableChecked) return;
        reservationTableChecked = true;

        try (Connection conn = DBUtil.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "reservations", new String[]{"TABLE"});
            if (!tables.next()) return;

            ResultSet cols = meta.getColumns(null, null, "reservations", null);
            List<String> columnNames = new ArrayList<>();

            while (cols.next()) {
                columnNames.add(cols.getString("COLUMN_NAME").toLowerCase());
            }

            String[] inC = {"check_in", "checkin", "check_in_date", "checkin_date", "start_date"};
            String[] outC = {"check_out", "checkout", "check_out_date", "checkout_date", "end_date"};

            for (String c : inC) {
                if (columnNames.contains(c)) {
                    COL_CHECK_IN = c;
                    break;
                }
            }

            for (String c : outC) {
                if (columnNames.contains(c)) {
                    COL_CHECK_OUT = c;
                    break;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String buildDateFilterSql() {
        if (COL_CHECK_IN == null || COL_CHECK_OUT == null) return null;

        return "AND NOT EXISTS (SELECT 1 FROM reservations r WHERE r.camp_id = camps.id "
                + "AND r.status IN ('pending','approved','paid') "
                + "AND NOT (r." + COL_CHECK_OUT + " <= ? OR r." + COL_CHECK_IN + " >= ?)) ";
    }

    private void buildEnhancedScoreClause(
            StringBuilder sql,
            List<String> scoreParams,
            String keyword,
            String type,
            String loc,
            String facility,
            String styles
    ) {
        sql.append("(0 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("+ CASE WHEN name LIKE ? OR address LIKE ? OR tags LIKE ? THEN 20 ELSE 0 END ");
            String kw = "%" + keyword.trim() + "%";
            scoreParams.add(kw);
            scoreParams.add(kw);
            scoreParams.add(kw);
        }

        List<String> allTags = new ArrayList<>();

        if (styles != null && !styles.trim().isEmpty()) {
            for (String style : styles.split(",")) {
                List<String> mapped = STYLE_TO_TAGS.get(style.trim());
                if (mapped != null) allTags.addAll(mapped);
            }
        }

        if (type != null && !type.trim().isEmpty()) {
            for (String t : type.split(",")) {
                if (!t.trim().isEmpty()) allTags.add(t.trim());
            }
        }

        if (facility != null && !facility.trim().isEmpty()) {
            for (String f : facility.split(",")) {
                if (!f.trim().isEmpty()) allTags.add(f.trim());
            }
        }

        for (String tag : allTags) {
            int weight = TAG_WEIGHTS.getOrDefault(tag, 20);

            sql.append("+ CASE WHEN type LIKE ? OR tags LIKE ? THEN " + weight + " ELSE 0 END ");
            scoreParams.add("%" + tag + "%");
            scoreParams.add("%" + tag + "%");

            List<String> related = RELATED_TAGS.get(tag);
            if (related != null) {
                for (String rel : related) {
                    sql.append("+ CASE WHEN tags LIKE ? THEN " + (weight / 2) + " ELSE 0 END ");
                    scoreParams.add("%" + rel + "%");
                }
            }
        }

        for (Map.Entry<String, Integer> combo : COMBO_BONUS.entrySet()) {
            String[] ct = combo.getKey().split(",");

            boolean has0 = allTags.stream().anyMatch(t -> t.contains(ct[0]) || ct[0].contains(t));
            boolean has1 = allTags.stream().anyMatch(t -> t.contains(ct[1]) || ct[1].contains(t));

            if (has0 && has1) {
                sql.append("+ CASE WHEN (type LIKE ? OR tags LIKE ?) AND (type LIKE ? OR tags LIKE ?) THEN "
                        + combo.getValue() + " ELSE 0 END ");

                scoreParams.add("%" + ct[0] + "%");
                scoreParams.add("%" + ct[0] + "%");
                scoreParams.add("%" + ct[1] + "%");
                scoreParams.add("%" + ct[1] + "%");
            }
        }

        if (loc != null && !loc.trim().isEmpty()) {
            for (String l : loc.split(",")) {
                if (l.trim().isEmpty()) continue;

                for (String expanded : expandLocationKeyword(l.trim())) {
                    sql.append("+ CASE WHEN address LIKE ? OR tags LIKE ? THEN 15 ELSE 0 END ");
                    scoreParams.add("%" + expanded + "%");
                    scoreParams.add("%" + expanded + "%");
                }
            }
        }

        sql.append(") AS recommend_score ");
    }

    public List<Product> getCampListPaging(
            String keyword,
            String type,
            String loc,
            String facility,
            String sort,
            String checkIn,
            String checkOut,
            int page,
            int pageSize
    ) {
        return getCampListPagingWithStyles(
                keyword, type, loc, facility, sort, checkIn, checkOut, null, page, pageSize
        );
    }

    public List<Product> getCampListPagingWithStyles(
            String keyword,
            String type,
            String loc,
            String facility,
            String sort,
            String checkIn,
            String checkOut,
            String styles,
            int page,
            int pageSize
    ) {
        boolean useDate = checkIn != null && !checkIn.trim().isEmpty()
                && checkOut != null && !checkOut.trim().isEmpty();

        if (useDate) detectReservationColumns();

        List<Product> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        List<String> scoreParams = new ArrayList<>();
        List<String> whereParams = new ArrayList<>();

        sql.append("SELECT id, name, address, type, tags, price, image, ");

        if ("recommend".equals(sort)) {
            buildEnhancedScoreClause(sql, scoreParams, keyword, type, loc, facility, styles);
        } else {
            sql.append("0 AS recommend_score ");
        }

        sql.append("FROM camps WHERE status = 'active' ");

        if (useDate) {
            String df = buildDateFilterSql();
            if (df != null) {
                sql.append(df);
                whereParams.add(checkIn);
                whereParams.add(checkOut);
            }
        }

        appendWhereFilters(sql, whereParams, keyword, type, loc, facility, styles);

        if ("priceAsc".equals(sort)) {
            sql.append("ORDER BY price ASC, id DESC ");
        } else if ("priceDesc".equals(sort)) {
            sql.append("ORDER BY price DESC, id DESC ");
        } else {
            sql.append("ORDER BY recommend_score DESC, id DESC ");
        }

        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            for (String p : scoreParams) ps.setString(idx++, p);
            for (String p : whereParams) ps.setString(idx++, p);

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

    public int getCampCount(
            String keyword,
            String type,
            String loc,
            String facility,
            String checkIn,
            String checkOut
    ) {
        boolean useDate = checkIn != null && !checkIn.trim().isEmpty()
                && checkOut != null && !checkOut.trim().isEmpty();

        if (useDate) detectReservationColumns();

        int count = 0;

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM camps WHERE status = 'active' ");
        List<String> params = new ArrayList<>();

        if (useDate) {
            String df = buildDateFilterSql();
            if (df != null) {
                sql.append(df);
                params.add(checkIn);
                params.add(checkOut);
            }
        }

        appendWhereFilters(sql, params, keyword, type, loc, facility);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (String p : params) ps.setString(idx++, p);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) count = rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    private void appendWhereFilters(
            StringBuilder sql,
            List<String> params,
            String keyword,
            String type,
            String loc,
            String facility
    ) {
        appendWhereFilters(sql, params, keyword, type, loc, facility, null);
    }

    private void appendWhereFilters(
            StringBuilder sql,
            List<String> params,
            String keyword,
            String type,
            String loc,
            String facility,
            String styles
    ) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR address LIKE ? OR tags LIKE ?) ");

            String kw = "%" + keyword.trim() + "%";

            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (type != null && !type.trim().isEmpty()) {
            String[] types = type.split(",");

            sql.append("AND (");

            boolean first = true;

            for (String t : types) {
                if (t.trim().isEmpty()) continue;

                if (!first) sql.append(" OR ");

                sql.append("type LIKE ? OR tags LIKE ?");

                params.add("%" + t.trim() + "%");
                params.add("%" + t.trim() + "%");

                first = false;
            }

            sql.append(") ");
        }

        if (loc != null && !loc.trim().isEmpty()) {
            List<String> exp = new ArrayList<>();

            for (String l : loc.split(",")) {
                if (!l.trim().isEmpty()) {
                    exp.addAll(expandLocationKeyword(l.trim()));
                }
            }

            if (!exp.isEmpty()) {
                sql.append("AND (");

                for (int i = 0; i < exp.size(); i++) {
                    if (i > 0) sql.append(" OR ");

                    sql.append("address LIKE ? OR tags LIKE ?");

                    params.add("%" + exp.get(i) + "%");
                    params.add("%" + exp.get(i) + "%");
                }

                sql.append(") ");
            }
        }

        if (facility != null && !facility.trim().isEmpty()) {
            String[] fs = facility.split(",");

            sql.append("AND (");

            boolean first = true;

            for (String f : fs) {
                if (f.trim().isEmpty()) continue;

                if (!first) sql.append(" OR ");

                sql.append("tags LIKE ?");

                params.add("%" + f.trim() + "%");

                first = false;
            }

            sql.append(") ");
        }

        if (styles != null) {
            for (String s : styles.split(",")) {
                if ("반려동물".equals(s.trim())) {
                    sql.append("AND (tags NOT LIKE ? OR tags IS NULL) ");
                    params.add("%반려동물불가%");
                    break;
                }
            }
        }
    }

    private List<String> expandLocationKeyword(String loc) {
        List<String> list = new ArrayList<>();

        if (loc == null) return list;

        switch (loc.trim()) {
            case "경상도":
                list.addAll(Arrays.asList("경상도", "경상북도", "경상남도", "경북", "경남"));
                break;
            case "전라도":
                list.addAll(Arrays.asList("전라도", "전라북도", "전라남도", "전북", "전남"));
                break;
            case "충청도":
                list.addAll(Arrays.asList("충청도", "충청북도", "충청남도", "충북", "충남"));
                break;
            case "강원도":
                list.addAll(Arrays.asList("강원도", "강원특별자치도"));
                break;
            case "제주":
                list.addAll(Arrays.asList("제주", "제주도", "제주특별자치도"));
                break;
            case "서울/경기":
                list.addAll(Arrays.asList("서울", "서울특별시", "경기", "경기도"));
                break;
            case "인천/강화도":
                list.addAll(Arrays.asList("인천", "인천광역시", "강화", "강화도"));
                break;
            case "거제/남해/통영":
                list.addAll(Arrays.asList("거제", "남해", "통영"));
                break;
            case "안면도/태안":
                list.addAll(Arrays.asList("안면도", "태안"));
                break;
            case "대부도/선재도/영흥도":
                list.addAll(Arrays.asList("대부도", "선재도", "영흥도"));
                break;
            case "춘천/홍천":
                list.addAll(Arrays.asList("춘천", "홍천"));
                break;
            default:
                list.add(loc.trim());
                break;
        }

        return list;
    }

    private Camp mapCamp(ResultSet rs) throws Exception {
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

        camp.setFacilities(rs.getString("facilities"));
        camp.setNearbyFacilities(rs.getString("nearby_facilities"));
        camp.setThemes(rs.getString("themes"));

        return camp;
    }

    public Camp getCampById(int id) {
        Camp camp = null;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM camps WHERE id = ?")) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                camp = mapCamp(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return camp;
    }

    public List<Camp> getAllCamps() {
        List<Camp> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM camps ORDER BY id DESC");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapCamp(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean insertCampFromCsv(Camp camp) {
        String sql =
                "INSERT INTO camps "
                        + "(name, address, type, tags, price, image, description, status, "
                        + "facilities, nearby_facilities, themes) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, camp.getName());
            ps.setString(2, camp.getAddress());
            ps.setString(3, camp.getType());
            ps.setString(4, camp.getTags());
            ps.setInt(5, camp.getPrice());
            ps.setString(6, camp.getImage());
            ps.setString(7, camp.getDescription());
            ps.setString(8, "active");

            ps.setString(9, camp.getFacilities());
            ps.setString(10, camp.getNearbyFacilities());
            ps.setString(11, camp.getThemes());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean insertCamp(Camp camp, int ownerId) {
        String sql =
                "INSERT INTO camps "
                        + "(name, address, type, tags, price, image, description, status, owner_id, "
                        + "facilities, nearby_facilities, themes) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, camp.getName());
            ps.setString(2, camp.getAddress());
            ps.setString(3, camp.getType());
            ps.setString(4, camp.getTags());
            ps.setInt(5, camp.getPrice());
            ps.setString(6, camp.getImage());
            ps.setString(7, camp.getDescription());
            ps.setString(8, camp.getStatus());
            ps.setInt(9, ownerId);

            ps.setString(10, camp.getFacilities());
            ps.setString(11, camp.getNearbyFacilities());
            ps.setString(12, camp.getThemes());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static List<Camp> getCampsByOwnerId(int ownerId) {
        List<Camp> list = new ArrayList<>();

        String sql = "SELECT * FROM camps WHERE owner_id = ? ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ownerId);

            ResultSet rs = ps.executeQuery();

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

                camp.setFacilities(rs.getString("facilities"));
                camp.setNearbyFacilities(rs.getString("nearby_facilities"));
                camp.setThemes(rs.getString("themes"));

                list.add(camp);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static boolean deleteCamp(int campId, int ownerId) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM camps WHERE id = ? AND owner_id = ?"
             )) {

            ps.setInt(1, campId);
            ps.setInt(2, ownerId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean updateCampStatus(int campId, int ownerId, String newStatus) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE camps SET status = ? WHERE id = ? AND owner_id = ?"
             )) {

            ps.setString(1, newStatus);
            ps.setInt(2, campId);
            ps.setInt(3, ownerId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean updateCamp(
            int campId,
            int ownerId,
            String name,
            String address,
            String type,
            String tags,
            int price,
            String description,
            String status
    ) {
        String sql =
                "UPDATE camps SET "
                        + "name = ?, "
                        + "address = ?, "
                        + "type = ?, "
                        + "tags = ?, "
                        + "price = ?, "
                        + "description = ?, "
                        + "status = ? "
                        + "WHERE id = ? AND owner_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, address);
            ps.setString(3, type);
            ps.setString(4, tags);
            ps.setInt(5, price);
            ps.setString(6, description);
            ps.setString(7, status);
            ps.setInt(8, campId);
            ps.setInt(9, ownerId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean updateCamp(
            int campId,
            int ownerId,
            String name,
            String address,
            String type,
            String tags,
            int price,
            String description,
            String status,
            String facilities,
            String nearbyFacilities,
            String themes
    ) {
        String sql =
                "UPDATE camps SET "
                        + "name = ?, "
                        + "address = ?, "
                        + "type = ?, "
                        + "tags = ?, "
                        + "price = ?, "
                        + "description = ?, "
                        + "status = ?, "
                        + "facilities = ?, "
                        + "nearby_facilities = ?, "
                        + "themes = ? "
                        + "WHERE id = ? AND owner_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, address);
            ps.setString(3, type);
            ps.setString(4, tags);
            ps.setInt(5, price);
            ps.setString(6, description);
            ps.setString(7, status);

            ps.setString(8, facilities);
            ps.setString(9, nearbyFacilities);
            ps.setString(10, themes);

            ps.setInt(11, campId);
            ps.setInt(12, ownerId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public int updateCampExtraInfoFromCsv(Camp camp) {

    	String sql =
    	        "UPDATE camps SET "
    	                + "facilities = ?, "
    	                + "nearby_facilities = ?, "
    	                + "themes = ?, "
    	                + "tags = ? "
    	                + "WHERE TRIM(name) = TRIM(?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, camp.getFacilities());
            ps.setString(2, camp.getNearbyFacilities());
            ps.setString(3, camp.getThemes());
            ps.setString(4, camp.getTags());

            ps.setString(5, camp.getName());

            return ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}
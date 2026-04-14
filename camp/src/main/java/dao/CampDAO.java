package dao;

import java.sql.*;
import util.DBUtil;

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
}
package dao;

import java.sql.*;
import util.DBUtil;

import dto.Camp;
import util.DBUtil;

public class CampDAO {

	public Camp getCampById(int id) {
	    Camp camp = null;

	    try (Connection conn = DBUtil.getConnection()) {
	        String sql = "SELECT * FROM camps WHERE id=?";
	        PreparedStatement ps = conn.prepareStatement(sql);
	        ps.setInt(1, id);

	        ResultSet rs = ps.executeQuery();

	        if (rs.next()) {
	            camp = new Camp();
	            camp.setId(rs.getInt("id"));
	            camp.setName(rs.getString("name"));
	            camp.setAddress(rs.getString("address"));
	            camp.setType(rs.getString("type"));
	            camp.setTags(rs.getString("tags"));
	            camp.setPrice(rs.getInt("price"));
	            camp.setImage(rs.getString("image"));
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return camp;
	}
}
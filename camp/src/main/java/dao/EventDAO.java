package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import dto.Event;
import util.DBUtil;

public class EventDAO {

    public static List<Event> getAllEvents() {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT * FROM events ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Event e = new Event();
                e.setId(rs.getInt("id"));
                e.setTitle(rs.getString("title"));
                e.setSummary(rs.getString("summary"));
                e.setContent(rs.getString("content"));
                e.setImage(rs.getString("image"));
                e.setStartDate(rs.getString("start_date"));
                e.setEndDate(rs.getString("end_date"));
                e.setStatus(rs.getString("status"));
                e.setCreatedAt(rs.getString("created_at"));
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static List<Event> getEventsByStatus(String status) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE status = ? ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event e = new Event();
                    e.setId(rs.getInt("id"));
                    e.setTitle(rs.getString("title"));
                    e.setSummary(rs.getString("summary"));
                    e.setContent(rs.getString("content"));
                    e.setImage(rs.getString("image"));
                    e.setStartDate(rs.getString("start_date"));
                    e.setEndDate(rs.getString("end_date"));
                    e.setStatus(rs.getString("status"));
                    e.setCreatedAt(rs.getString("created_at"));
                    list.add(e);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static Event getEventById(int id) {
        Event e = null;
        String sql = "SELECT * FROM events WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    e = new Event();
                    e.setId(rs.getInt("id"));
                    e.setTitle(rs.getString("title"));
                    e.setSummary(rs.getString("summary"));
                    e.setContent(rs.getString("content"));
                    e.setImage(rs.getString("image"));
                    e.setStartDate(rs.getString("start_date"));
                    e.setEndDate(rs.getString("end_date"));
                    e.setStatus(rs.getString("status"));
                    e.setCreatedAt(rs.getString("created_at"));
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return e;
    }
}
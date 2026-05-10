package dao;

import dto.ChatMessage;
import dto.ChatRoom;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public int getOrCreateRoom(int productId, int buyerId, int sellerId) {
        int existingRoomId = getRoomId(productId, buyerId, sellerId);

        if (existingRoomId > 0) {
            return existingRoomId;
        }

        String sql = "INSERT INTO chat_room (product_id, buyer_id, seller_id) VALUES (?, ?, ?)";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setInt(1, productId);
            ps.setInt(2, buyerId);
            ps.setInt(3, sellerId);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            return getRoomId(productId, buyerId, sellerId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    public int getRoomId(int productId, int buyerId, int sellerId) {
        String sql = "SELECT id FROM chat_room WHERE product_id = ? AND buyer_id = ? AND seller_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);
            ps.setInt(2, buyerId);
            ps.setInt(3, sellerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    public ChatRoom getRoomById(int roomId) {
        String sql =
            "SELECT cr.*, " +
            "       p.name AS product_name, " +
            "       p.price AS product_price, " +
            "       COALESCE(p.image, pi.image_path) AS product_image, " +
            "       buyer.name AS buyer_name, " +
            "       seller.name AS seller_name " +
            "FROM chat_room cr " +
            "JOIN product p ON cr.product_id = p.id " +
            "LEFT JOIN product_image pi ON p.id = pi.product_id AND pi.sort_order = 1 " +
            "JOIN users buyer ON cr.buyer_id = buyer.id " +
            "JOIN users seller ON cr.seller_id = seller.id " +
            "WHERE cr.id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChatRoom room = new ChatRoom();
                    room.setId(rs.getInt("id"));
                    room.setProductId(rs.getInt("product_id"));
                    room.setBuyerId(rs.getInt("buyer_id"));
                    room.setSellerId(rs.getInt("seller_id"));
                    room.setCreatedAt(rs.getTimestamp("created_at"));
                    room.setProductName(rs.getString("product_name"));
                    room.setProductPrice(rs.getInt("product_price"));
                    room.setProductImage(rs.getString("product_image"));
                    room.setBuyerName(rs.getString("buyer_name"));
                    room.setSellerName(rs.getString("seller_name"));
                    return room;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    public List<ChatRoom> getMyChatRooms(int userId) {
        List<ChatRoom> list = new ArrayList<>();

        String sql =
            "SELECT cr.*, " +
            "       p.name AS product_name, " +
            "       p.price AS product_price, " +
            "       COALESCE(p.image, pi.image_path) AS product_image, " +
            "       buyer.name AS buyer_name, " +
            "       seller.name AS seller_name, " +
            "       (SELECT cm.message FROM chat_message cm " +
            "        WHERE cm.room_id = cr.id " +
            "        ORDER BY cm.id DESC LIMIT 1) AS last_message, " +
            "       (SELECT cm.created_at FROM chat_message cm " +
            "        WHERE cm.room_id = cr.id " +
            "        ORDER BY cm.id DESC LIMIT 1) AS last_message_at, " +
            "       (SELECT COUNT(*) FROM chat_message cm " +
            "        WHERE cm.room_id = cr.id " +
            "          AND cm.sender_id <> ? " +
            "          AND cm.is_read = 0) AS unread_count " +
            "FROM chat_room cr " +
            "JOIN product p ON cr.product_id = p.id " +
            "LEFT JOIN product_image pi ON p.id = pi.product_id AND pi.sort_order = 1 " +
            "JOIN users buyer ON cr.buyer_id = buyer.id " +
            "JOIN users seller ON cr.seller_id = seller.id " +
            "WHERE cr.buyer_id = ? OR cr.seller_id = ? " +
            "ORDER BY COALESCE(last_message_at, cr.created_at) DESC";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatRoom room = new ChatRoom();
                    room.setId(rs.getInt("id"));
                    room.setProductId(rs.getInt("product_id"));
                    room.setBuyerId(rs.getInt("buyer_id"));
                    room.setSellerId(rs.getInt("seller_id"));
                    room.setCreatedAt(rs.getTimestamp("created_at"));
                    room.setProductName(rs.getString("product_name"));
                    room.setProductPrice(rs.getInt("product_price"));
                    room.setProductImage(rs.getString("product_image"));
                    room.setBuyerName(rs.getString("buyer_name"));
                    room.setSellerName(rs.getString("seller_name"));
                    room.setLastMessage(rs.getString("last_message"));
                    room.setLastMessageAt(rs.getTimestamp("last_message_at"));
                    room.setUnreadCount(rs.getInt("unread_count"));

                    list.add(room);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }


    public List<ChatMessage> getMessages(int roomId) {
        List<ChatMessage> list = new ArrayList<>();

        String sql =
            "SELECT cm.*, u.name AS sender_name " +
            "FROM chat_message cm " +
            "JOIN users u ON cm.sender_id = u.id " +
            "WHERE cm.room_id = ? " +
            "ORDER BY cm.id ASC";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt("id"));
                    msg.setRoomId(rs.getInt("room_id"));
                    msg.setSenderId(rs.getInt("sender_id"));
                    msg.setMessage(rs.getString("message"));
                    msg.setRead(rs.getBoolean("is_read"));
                    msg.setCreatedAt(rs.getTimestamp("created_at"));
                    msg.setSenderName(rs.getString("sender_name"));

                    list.add(msg);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }


    public boolean insertMessage(int roomId, int senderId, String message) {
        String sql = "INSERT INTO chat_message (room_id, sender_id, message) VALUES (?, ?, ?)";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, roomId);
            ps.setInt(2, senderId);
            ps.setString(3, message);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public void markAsRead(int roomId, int userId) {
        String sql =
            "UPDATE chat_message " +
            "SET is_read = 1 " +
            "WHERE room_id = ? AND sender_id <> ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, roomId);
            ps.setInt(2, userId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public boolean isRoomMember(int roomId, int userId) {
        String sql =
            "SELECT id FROM chat_room " +
            "WHERE id = ? AND (buyer_id = ? OR seller_id = ?)";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, roomId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public int getProductSellerId(int productId) {
        String sql = "SELECT seller_id FROM product WHERE id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("seller_id");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}
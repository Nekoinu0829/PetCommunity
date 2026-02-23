package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import util.DBManager;

public class ReplyDAO {

    public int addReply(ReplyDTO dto) {
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO REPLY (R_NO, B_NO, R_WRITER, R_CONTENT) VALUES (SEQ_REPLY.NEXTVAL, ?, ?, ?)";
        int result = 0;
        
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dto.getB_no());
            ps.setString(2, dto.getWriter());
            ps.setString(3, dto.getContent());
            result = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return result;
    }

    public ArrayList<ReplyDTO> getReplyList(int b_no) {
        ArrayList<ReplyDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        String sql = "SELECT r.*, m.nickname FROM REPLY r " +
                     "JOIN MEMBER m ON r.r_writer = m.id " +
                     "WHERE r.b_no = ? ORDER BY r.r_no ASC";
        
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, b_no);
            rs = ps.executeQuery();
            while(rs.next()) {
                ReplyDTO dto = new ReplyDTO();
                dto.setR_no(rs.getInt("R_NO"));
                dto.setB_no(rs.getInt("B_NO"));
                dto.setWriter(rs.getString("nickname")); 
                dto.setContent(rs.getString("R_CONTENT"));
                dto.setDate(rs.getDate("R_DATE"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    public int deleteReply(int r_no) {
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "DELETE FROM REPLY WHERE R_NO = ?";
        int result = 0;
        
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, r_no);
            result = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return result;
    }

    public ArrayList<ReplyDTO> getMyReplies(String id) {
        ArrayList<ReplyDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        String sql = "SELECT r.*, m.nickname FROM REPLY r " +
                     "JOIN MEMBER m ON r.r_writer = m.id " +
                     "WHERE r.r_writer = ? ORDER BY r.r_no DESC";

        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();
            
            while(rs.next()) {
                ReplyDTO dto = new ReplyDTO();
                dto.setR_no(rs.getInt("R_NO"));
                dto.setB_no(rs.getInt("B_NO"));
                dto.setWriter(rs.getString("nickname")); 
                dto.setContent(rs.getString("R_CONTENT"));
                dto.setDate(rs.getDate("R_DATE"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    public int deleteBoard(int no) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "DELETE FROM BOARD WHERE B_NO = ?";
        
        try {
            conn = util.DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, no);
            row = ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            util.DBManager.close(conn, ps, null);
        }
        return row;
    }
}
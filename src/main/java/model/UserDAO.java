package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBManager;

public class UserDAO {

    public int join(UserDTO dto) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO PET_MEMBER(ID, PW, NICKNAME) VALUES(?, ?, ?)";
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dto.getId());
            ps.setString(2, dto.getPw());
            ps.setString(3, dto.getNickname());
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }

    public UserDTO login(String id, String pw) {
        UserDTO dto = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM PET_MEMBER WHERE ID = ? AND PW = ?";
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, pw);
            rs = ps.executeQuery();
            if (rs.next()) {
                dto = new UserDTO();
                dto.setId(rs.getString("ID"));
                dto.setPw(rs.getString("PW"));
                dto.setNickname(rs.getString("NICKNAME"));
                try { dto.setPic(rs.getString("PIC")); } catch (Exception e) { dto.setPic(null); }
                dto.setJoinDate(rs.getDate("JOIN_DATE"));
                dto.setRole(rs.getInt("ROLE"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return dto;
    }

    public int updateMember(UserDTO dto) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false);

            String oldNickname = "";
            ps = conn.prepareStatement("SELECT NICKNAME FROM PET_MEMBER WHERE ID = ?");
            ps.setString(1, dto.getId());
            rs = ps.executeQuery();
            if(rs.next()) {
                oldNickname = rs.getString("NICKNAME");
            }
            ps.close(); rs.close();

            String sql = "UPDATE PET_MEMBER SET NICKNAME = ?, PIC = ? WHERE ID = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, dto.getNickname());
            ps.setString(2, dto.getPic());
            ps.setString(3, dto.getId());
            row = ps.executeUpdate();
            ps.close();

            if(row > 0) {
                String sqlBoard = "UPDATE BOARD SET B_NICKNAME = ? WHERE B_WRITER = ?";
                ps = conn.prepareStatement(sqlBoard);
                ps.setString(1, dto.getNickname());
                ps.setString(2, dto.getId());
                ps.executeUpdate();
                ps.close();

                if (oldNickname != null && !oldNickname.isEmpty()) {
                    String sqlReply = "UPDATE REPLY SET R_WRITER = ? WHERE R_WRITER = ?";
                    ps = conn.prepareStatement(sqlReply);
                    ps.setString(1, dto.getNickname());
                    ps.setString(2, oldNickname);
                    ps.executeUpdate();
                    ps.close();
                }
            }
            
            conn.commit();

        } catch (Exception e) { 
            try { if(conn != null) conn.rollback(); } catch(Exception ex) {}
            e.printStackTrace(); 
        } finally { 
            try { if(conn != null) conn.setAutoCommit(true); } catch(Exception ex) {}
            DBManager.close(conn, ps, null); 
        }
        return row;
    }
    
    public int deleteMember(String id, String pw) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "DELETE FROM PET_MEMBER WHERE ID = ? AND PW = ?";
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            ps.setString(2, pw);
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }
}
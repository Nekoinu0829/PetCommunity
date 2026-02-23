package model;

import java.sql.*;
import java.util.ArrayList;
import util.DBManager;

public class PetDAO {

    // 반려동물 등록
    public int insertPet(PetDTO dto) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO PET (PET_NO, MEMBER_ID, PET_NAME, PET_PIC, REG_DATE) "
                   + "VALUES (PET_SEQ.NEXTVAL, ?, ?, ?, SYSDATE)";
        try {
            conn = DBManager.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setString(1, dto.getMemberId());
            ps.setString(2, dto.getPetName());
            // PET_PIC은 CLOB이므로 setClob 대신 setString (Oracle은 4000자 이상도 처리)
            ps.setString(3, dto.getPetPic());
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }

    // 해당 유저의 반려동물 목록 조회
    public ArrayList<PetDTO> getPetList(String memberId) {
        ArrayList<PetDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT PET_NO, MEMBER_ID, PET_NAME, PET_PIC, REG_DATE "
                   + "FROM PET WHERE MEMBER_ID = ? ORDER BY PET_NO ASC";
        try {
            conn = DBManager.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setString(1, memberId);
            rs   = ps.executeQuery();
            while (rs.next()) {
                PetDTO dto = new PetDTO();
                dto.setPetNo(rs.getInt("PET_NO"));
                dto.setMemberId(rs.getString("MEMBER_ID"));
                dto.setPetName(rs.getString("PET_NAME"));
                dto.setPetPic(rs.getString("PET_PIC"));
                dto.setRegDate(rs.getDate("REG_DATE"));
                list.add(dto);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // 반려동물 수정 (이름 + 사진)
    public int updatePet(PetDTO dto) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "UPDATE PET SET PET_NAME = ?, PET_PIC = ? WHERE PET_NO = ? AND MEMBER_ID = ?";
        try {
            conn = DBManager.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setString(1, dto.getPetName());
            ps.setString(2, dto.getPetPic());
            ps.setInt(3, dto.getPetNo());
            ps.setString(4, dto.getMemberId());
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }

    // 반려동물 삭제
    public int deletePet(int petNo, String memberId) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "DELETE FROM PET WHERE PET_NO = ? AND MEMBER_ID = ?";
        try {
            conn = DBManager.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setInt(1, petNo);
            ps.setString(2, memberId);
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }
}
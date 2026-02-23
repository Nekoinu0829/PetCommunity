package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import util.DBManager;

public class BoardDAO {

    // ── INSERT ───────────────────────────────────────────────────────────────
    public int insertBoard(BoardDTO dto) {
        int row = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO BOARD(B_NO, B_TAG, B_TITLE, B_CONTENT, B_PIC, B_WRITER, B_NICKNAME, B_DATE, B_VIEWS, B_LIKES) "
                   + "VALUES(BOARD_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE, 0, 0)";
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setNString(1, dto.getTag());       // NVARCHAR2
            ps.setNString(2, dto.getTitle());     // NVARCHAR2
            ps.setNString(3, dto.getContent());   // NCLOB
            ps.setString(4, dto.getPic());
            ps.setString(5, dto.getWriter());
            ps.setNString(6, dto.getNickname());  // NVARCHAR2
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }

    // ── 게시판 목록 ────────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getBoardList(int page, String tag) {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        int startRow = (page - 1) * 15 + 1;
        int endRow = page * 15;
        try {
            conn = DBManager.getConnection();
            String sql = (tag == null || tag.isEmpty() || tag.equals("전체"))
                ? "SELECT * FROM (SELECT ROWNUM AS RNUM, A.* FROM (SELECT * FROM BOARD WHERE B_TAG NOT LIKE '콘텐츠%' ORDER BY B_NO DESC) A WHERE ROWNUM <= ?) WHERE RNUM >= ?"
                : "SELECT * FROM (SELECT ROWNUM AS RNUM, A.* FROM (SELECT * FROM BOARD WHERE B_TAG = ? AND B_TAG NOT LIKE '콘텐츠%' ORDER BY B_NO DESC) A WHERE ROWNUM <= ?) WHERE RNUM >= ?";
            ps = conn.prepareStatement(sql);
            if (tag == null || tag.isEmpty() || tag.equals("전체")) {
                ps.setInt(1, endRow); ps.setInt(2, startRow);
            } else {
                ps.setNString(1, tag); ps.setInt(2, endRow); ps.setInt(3, startRow);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));           // NVARCHAR2
                d.setTitle(rs.getNString("B_TITLE"));       // NVARCHAR2
                d.setPic(rs.getString("B_PIC"));
                d.setNickname(rs.getNString("B_NICKNAME")); // NVARCHAR2
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                d.setLikes(rs.getInt("B_LIKES"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 게시글 수 ──────────────────────────────────────────────────────────────
    public int getBoardCount(String tag) {
        int count = 0; Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql = (tag == null || tag.isEmpty() || tag.equals("전체"))
                ? "SELECT COUNT(*) FROM BOARD WHERE B_TAG NOT LIKE '콘텐츠%'"
                : "SELECT COUNT(*) FROM BOARD WHERE B_TAG = ? AND B_TAG NOT LIKE '콘텐츠%'";
            ps = conn.prepareStatement(sql);
            if (tag != null && !tag.isEmpty() && !tag.equals("전체")) ps.setNString(1, tag);
            rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return count;
    }

    // ── 단건 조회 ──────────────────────────────────────────────────────────────
    public BoardDTO getBoard(int no) {
        BoardDTO dto = null; Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM BOARD WHERE B_NO = ?");
            ps.setInt(1, no);
            rs = ps.executeQuery();
            if (rs.next()) {
                dto = new BoardDTO();
                dto.setNo(rs.getInt("B_NO"));
                dto.setTag(rs.getNString("B_TAG"));           // NVARCHAR2
                dto.setTitle(rs.getNString("B_TITLE"));       // NVARCHAR2
                dto.setContent(rs.getNString("B_CONTENT"));   // NCLOB
                dto.setPic(rs.getString("B_PIC"));
                dto.setWriter(rs.getString("B_WRITER"));
                dto.setNickname(rs.getNString("B_NICKNAME")); // NVARCHAR2
                dto.setDate(rs.getDate("B_DATE"));
                dto.setViews(rs.getInt("B_VIEWS"));
                dto.setLikes(rs.getInt("B_LIKES"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return dto;
    }

    // ── 조회수 증가 ────────────────────────────────────────────────────────────
    public void updateViews(int no) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("UPDATE BOARD SET B_VIEWS = B_VIEWS + 1 WHERE B_NO = ?");
            ps.setInt(1, no); ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
    }

    // ── 좋아요 체크 ────────────────────────────────────────────────────────────
    public boolean isLike(String id, int bNo) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT 1 FROM BOARD_LIKE WHERE ID = ? AND B_NO = ?");
            ps.setString(1, id); ps.setInt(2, bNo);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) { e.printStackTrace(); return false;
        } finally { DBManager.close(conn, ps, rs); }
    }

    // ── 좋아요 토글 ────────────────────────────────────────────────────────────
    public int toggleLike(String id, int bNo) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        int currentLikes = 0;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false);
            boolean exists = false;
            ps = conn.prepareStatement("SELECT 1 FROM BOARD_LIKE WHERE ID = ? AND B_NO = ?");
            ps.setString(1, id); ps.setInt(2, bNo);
            rs = ps.executeQuery();
            if (rs.next()) exists = true;
            DBManager.close(null, ps, rs);
            if (exists) {
                ps = conn.prepareStatement("DELETE FROM BOARD_LIKE WHERE ID = ? AND B_NO = ?");
                ps.setString(1, id); ps.setInt(2, bNo); ps.executeUpdate(); DBManager.close(null, ps, null);
                ps = conn.prepareStatement("UPDATE BOARD SET B_LIKES = CASE WHEN NVL(B_LIKES,0) > 0 THEN B_LIKES - 1 ELSE 0 END WHERE B_NO = ?");
            } else {
                ps = conn.prepareStatement("INSERT INTO BOARD_LIKE (ID, B_NO) VALUES (?, ?)");
                ps.setString(1, id); ps.setInt(2, bNo); ps.executeUpdate(); DBManager.close(null, ps, null);
                ps = conn.prepareStatement("UPDATE BOARD SET B_LIKES = NVL(B_LIKES,0) + 1 WHERE B_NO = ?");
            }
            ps.setInt(1, bNo); ps.executeUpdate(); DBManager.close(null, ps, null);
            ps = conn.prepareStatement("SELECT NVL(B_LIKES, 0) FROM BOARD WHERE B_NO = ?");
            ps.setInt(1, bNo); rs = ps.executeQuery();
            if (rs.next()) currentLikes = rs.getInt(1);
            conn.commit();
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return -1;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {}
            DBManager.close(conn, ps, rs);
        }
        return currentLikes;
    }

    // ── 좋아요 목록 ────────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getLikeList(String id) {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql = "SELECT B.* FROM BOARD B JOIN BOARD_LIKE L ON B.B_NO = L.B_NO WHERE L.ID = ? ORDER BY L.LIKE_DATE DESC";
            ps = conn.prepareStatement(sql);
            ps.setString(1, id); rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setNickname(rs.getNString("B_NICKNAME"));
                d.setDate(rs.getDate("B_DATE"));
                d.setPic(rs.getString("B_PIC"));
                d.setLikes(rs.getInt("B_LIKES"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 인기 목록 ──────────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getTrendList() {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM (SELECT * FROM BOARD WHERE B_TAG NOT LIKE '콘텐츠%' ORDER BY B_VIEWS DESC) WHERE ROWNUM <= 5");
            rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setPic(rs.getString("B_PIC"));
                d.setNickname(rs.getNString("B_NICKNAME"));
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                d.setLikes(rs.getInt("B_LIKES"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 최신 목록 ──────────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getRecentList() {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM (SELECT * FROM BOARD WHERE B_TAG NOT LIKE '콘텐츠%' ORDER BY B_NO DESC) WHERE ROWNUM <= 8");
            rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setPic(rs.getString("B_PIC"));
                d.setNickname(rs.getNString("B_NICKNAME"));
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                d.setLikes(rs.getInt("B_LIKES"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 관리자 목록 ────────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getAdminList() {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM BOARD WHERE B_WRITER = 'admin' ORDER BY B_NO DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setContent(rs.getNString("B_CONTENT"));
                d.setPic(rs.getString("B_PIC"));
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 콘텐츠(매거진) 목록 ───────────────────────────────────────────────────
    public ArrayList<BoardDTO> getContentList() {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM BOARD WHERE B_TAG LIKE '콘텐츠%' ORDER BY B_NO DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTag(rs.getNString("B_TAG"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setPic(rs.getString("B_PIC"));
                d.setNickname(rs.getNString("B_NICKNAME"));
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                d.setLikes(rs.getInt("B_LIKES"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 내 게시글 목록 ─────────────────────────────────────────────────────────
    public ArrayList<BoardDTO> getMyPosts(String id) {
        ArrayList<BoardDTO> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("SELECT * FROM BOARD WHERE B_WRITER = ? ORDER BY B_NO DESC");
            ps.setString(1, id); rs = ps.executeQuery();
            while (rs.next()) {
                BoardDTO d = new BoardDTO();
                d.setNo(rs.getInt("B_NO"));
                d.setTitle(rs.getNString("B_TITLE"));
                d.setDate(rs.getDate("B_DATE"));
                d.setViews(rs.getInt("B_VIEWS"));
                d.setPic(rs.getString("B_PIC"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, rs); }
        return list;
    }

    // ── 삭제 ──────────────────────────────────────────────────────────────────
    public int deleteBoard(int no) {
        int row = 0; Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("DELETE FROM BOARD WHERE B_NO = ?");
            ps.setInt(1, no); row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }

    // ── 수정 ──────────────────────────────────────────────────────────────────
    public int updateBoard(BoardDTO dto) {
        int row = 0; Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBManager.getConnection();
            ps = conn.prepareStatement("UPDATE BOARD SET B_TAG = ?, B_TITLE = ?, B_CONTENT = ?, B_PIC = ? WHERE B_NO = ?");
            ps.setNString(1, dto.getTag());     // NVARCHAR2
            ps.setNString(2, dto.getTitle());   // NVARCHAR2
            ps.setNString(3, dto.getContent()); // NCLOB
            ps.setString(4, dto.getPic());
            ps.setInt(5, dto.getNo());
            row = ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, ps, null); }
        return row;
    }
}

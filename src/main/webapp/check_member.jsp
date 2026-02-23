<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 명부 확인</title>
<style>
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
    th { background-color: #fdd835; }
    .empty { color: red; font-weight: bold; padding: 20px; }
</style>
</head>
<body>
    <h2 style="text-align:center;">🔍 현재 가입된 회원 목록 (PET_MEMBER)</h2>
    
    <div style="width: 80%; margin: 0 auto;">
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            String url = "jdbc:oracle:thin:@localhost:1521:xe";
            String db_id = "system"; 
            String db_pw = "1234"; // 본인 비번 확인!
            
            conn = DriverManager.getConnection(url, db_id, db_pw);
            
            String sql = "SELECT * FROM PET_MEMBER";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            // 데이터가 있는지 확인
            if (!rs.isBeforeFirst()) {
    %>
                <div class="empty">
                    ❌ 현재 저장된 회원이 0명입니다!<br>
                    (아까 테이블을 새로 만들면서 초기화되었습니다.)<br>
                    <a href="index.jsp">메인으로 돌아가서 회원가입부터 다시 해주세요.</a>
                </div>
    <%
            } else {
    %>
                <table>
                    <tr>
                        <th>아이디(ID)</th>
                        <th>비밀번호(PW)</th>
                        <th>닉네임(NICKNAME)</th>
                        <th>가입일</th>
                    </tr>
    <%
                while(rs.next()) {
    %>
                    <tr>
                        <td><%= rs.getString("ID") %></td>
                        <td><%= rs.getString("PW") %></td>
                        <td><%= rs.getString("NICKNAME") %></td>
                        <td><%= rs.getDate("JOIN_DATE") %></td>
                    </tr>
    <%
                }
    %>
                </table>
                <p style="text-align:center;">
                    ☝ 위 표에 있는 아이디/비번을 <b>복사해서</b> 로그인해 보세요.<br>
                    (띄어쓰기가 포함되어 있을 수도 있습니다!)
                </p>
    <%
            }
        } catch(Exception e) {
            out.println("🚨 에러 발생: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if(rs != null) rs.close();
            if(pstmt != null) pstmt.close();
            if(conn != null) conn.close();
        }
    %>
    <br>
    <div style="text-align:center;">
        <a href="index.jsp"><button style="padding:10px 20px; background:#333; color:white; border:none;">메인화면 가기</button></a>
    </div>
    </div>
</body>
</html>
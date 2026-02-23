<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DB 최종 점검</title>
<style>
    .success { color: green; font-weight: bold; }
    .fail { color: red; font-weight: bold; }
    .log { background: #f0f0f0; padding: 10px; border-radius: 5px; }
</style>
</head>
<body>
<h2>🐕 PET_MEMBER 테이블 생성 및 테스트</h2>
<div class="log">
<%
    Connection conn = null;
    PreparedStatement pstmt = null;

    // DB 정보 (System / 1234)
    String url = "jdbc:oracle:thin:@localhost:1521:xe"; 
    String db_id = "system"; 
    String db_pw = "1234";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(url, db_id, db_pw);
        out.println("✅ 1. DB 접속 성공<br>");

        // 1. 기존 테이블 삭제 (초기화)
        try {
            pstmt = conn.prepareStatement("DROP TABLE PET_MEMBER");
            pstmt.executeUpdate();
            out.println("🗑️ 기존 PET_MEMBER 테이블 삭제함<br>");
            pstmt.close();
        } catch(Exception e) { 
            out.println("ℹ️ 삭제할 기존 테이블 없음 (새로 생성 시작)<br>"); 
        }

        // 2. 테이블 새로 만들기 (이름: PET_MEMBER)
        // MEMBER는 예약어라 에러날 수 있어서 PET_MEMBER로 바꿈!
        String createSql = "CREATE TABLE PET_MEMBER ("
                         + "ID VARCHAR2(50) PRIMARY KEY, "
                         + "PW VARCHAR2(50) NOT NULL, "
                         + "NICKNAME VARCHAR2(50) NOT NULL, "
                         + "JOIN_DATE DATE DEFAULT SYSDATE)";
                         
        pstmt = conn.prepareStatement(createSql);
        pstmt.executeUpdate();
        out.println("✅ 2. 테이블(PET_MEMBER) 생성 완료!<br>");
        pstmt.close();

        // 3. 데이터 넣어보기 (INSERT)
        String insertSql = "INSERT INTO PET_MEMBER (ID, PW, NICKNAME) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(insertSql);
        pstmt.setString(1, "test_" + (int)(Math.random()*1000)); // 중복방지 랜덤 ID
        pstmt.setString(2, "1234");
        pstmt.setString(3, "테스트유저");
        
        int result = pstmt.executeUpdate();
        
        out.println("<h3 class='success'>🎉 3. 데이터 추가 성공! (" + result + "행)</h3>");
        out.println("이제 'PET_MEMBER' 테이블이 완벽하게 준비됐습니다.");

    } catch (Exception e) {
        out.println("<h3 class='fail'>🚨 에러 발생</h3>");
        out.println("에러 내용: " + e.getMessage() + "<br>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>
</div>
<br>
<a href="index.jsp"><button style="padding:10px 20px; font-size:16px;">메인으로 가서 회원가입 해보기</button></a>
</body>
</html>
package util;

import java.sql.*;
import java.util.Properties;

public class DBManager {
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            String url = "jdbc:oracle:thin:@localhost:1521:xe";
            String db_id = "jsl26";
            String db_pw = "1234";

            // Oracle Unicode 문자(일본어 ー 등) 깨짐 방지 설정
            Properties props = new Properties();
            props.setProperty("user", db_id);
            props.setProperty("password", db_pw);
            props.setProperty("oracle.jdbc.defaultNChar", "true"); // ← 여기에 추가
            conn = DriverManager.getConnection(url, props);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }

    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void close(Connection conn, PreparedStatement ps) {
        close(conn, ps, null);
    }
}

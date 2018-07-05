package com.mymunchkin.app;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
public class data {

        public Connection conn = null;

        public data() {
              try {
                        Class.forName("com.mysql.jdbc.Driver");
                        
                        String url = "jdbc:mysql://localhost:3306/Kittens"; 
                        
                        conn = DriverManager.getConnection(url, "root", "abc123");
                        System.out.println("conn built");
                     } 
                     catch (SQLException e) 
                     {
                        e.printStackTrace();
                     } 
                     catch (ClassNotFoundException e) 
                     {
                        e.printStackTrace();
                     }
                  }
        public ResultSet runSql(String sql) throws SQLException 
        {
                Statement sta = conn.createStatement();
                return sta.executeQuery(sql);
        }
        public boolean runSql2(String sql) throws SQLException 
        {
                Statement sta = conn.createStatement();
                return sta.execute(sql);
        }
        @Override
        protected void finalize() throws Throwable 
        {
                if (conn != null || !conn.isClosed()) 
                {
                        conn.close();
                }
        }
}

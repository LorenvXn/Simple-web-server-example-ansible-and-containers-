package com.mymunchkin.app;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
 
public class Main 

{
	public static data db = new data();
 
	public static void main(String[] args) throws SQLException, IOException
  {
		// db.runSql2("TRUNCATE Record;");
		processPage("http://cats.wikia.com");
	}
 
	public static void processPage(String URL) throws SQLException, IOException
  {
	
		String sql = "select * from Record where URL = '"+URL+"'";
    
		ResultSet rs = db.runSql(sql);
		if(!rs.next())
    {
			sql = "INSERT INTO  `Kittens`.`Links` " + "(`URL`) VALUES " + "(?);";
			PreparedStatement stmt = db.conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			stmt.setString(1, URL);
			stmt.execute();
 
			
		 Document doc = Jsoup.connect("http://cats.wikia.com/wiki/Munchkin_(Breed)").get(); 
			if(doc.text().contains("Munchkin")){
				System.out.println(URL);
		}
 
			
			Elements questions = doc.select("a[href]");
			for(Element link: questions)
      {
				if(link.attr("href").contains("cats.wikia"))
					processPage(link.attr("abs:href"));
			}
		}
	}
}

package com.rolfbenz;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
// 
public class bvmDatei extends basisDatei {
	public bvmDatei(String iPfad, String iEndung) {
		super(iPfad,"TMP",iEndung);
		
	}
	public void ausgabe(long sANr,int pNr,Connection con) {
		Statement stmt;
		String sql     = new String();
		ResultSet rs;
		try {
			stmt = con.createStatement();
			this.setName(String.valueOf(sANr));
			this.oeffnen();
			sql = "SELECT kom_abnr FROM plrv11.zus_kommission WHERE kom_sammel_abnr="+sANr;
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("RM"+
					rbTextFormat.format('0',6,rs.getString("kom_abnr"))+
					rbTextFormat.format('0',4,String.valueOf(pNr))+
					bdeZeit.getTimestamp("yyyyMMddHHmmss")+"\n");
			}
			this.aktiviereDatei();
			this.schliessen();
			rs.close();
			stmt.close();
		}
		catch (Exception e) {
			e.printStackTrace();	
		}
	}
}
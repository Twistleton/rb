package com.rolfbenz;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class zusParam  {
	private Connection con;
	// Konstruktoren
	public zusParam() {
	}
	public zusParam(Connection iCon) {
		con=iCon;
	}
	public float getWert(String iParamName) {
		float ret=0;
		try {
			Statement  stmt = con.createStatement();
			stmt.executeQuery("SELECT zup_wert FROM plrv11.zus_param WHERE zup_name='"+iParamName+"'");
			ResultSet  rs = stmt.getResultSet();
			while (rs.next()) {
				ret = rs.getFloat("zup_wert");
			}
			rs.close();
			stmt.close();			
		}
		catch(SQLException sqle) {
			sqle.printStackTrace();
		}
		return(ret);
	}
	public String getText(String iParamName) {
		String ret = new String();
		try {
			Statement  stmt = con.createStatement();
			stmt.executeQuery("SELECT tat_wert FROM plrv11.zus_textAttr WHERE tat_beschr='"+iParamName+"'");
			ResultSet  rs = stmt.getResultSet();
			while (rs.next()) {
				if (rs.getString("tat_wert")==null) {
					ret = "";
				} else {
					ret = rs.getString("tat_wert");
				}
			}
		
			rs.close();
			stmt.close();			
		}
		catch(SQLException sqle) {
			sqle.printStackTrace();
		}
		return(ret);
	}
	
}
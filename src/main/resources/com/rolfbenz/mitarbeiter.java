package com.rolfbenz;
import java.sql.*;

public class mitarbeiter {
	// Konstruktoren
	public mitarbeiter() {
	}
	public static String getDrucker(int maPNr, Connection con) {
		String rueckgabewert = new String();
		String sql = "SELECT ma_drucker FROM plrv11.bde_madat WHERE ma_pnr="+maPNr;
		try {
			Statement stmt = con.createStatement();
			ResultSet rs ;
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			int counter=0;
			while (rs.next()) {
				rueckgabewert = rs.getString("ma_drucker");
				counter++;
			}
			if (counter==0) {
				rueckgabewert="";
			}
			rs.close();
			stmt.close();
		}
		catch (SQLException sqlex) {
			sqlex.printStackTrace();
		}
		return rueckgabewert;
	}
}
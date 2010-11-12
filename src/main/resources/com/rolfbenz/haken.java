package com.rolfbenz;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class haken {
	// Konstruktoren
	public static int historie(Connection iCon, long id,char matKz,int lfdNr,int pNr,char vg) {
		try {
			Statement stmtAlt = iCon.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_UPDATABLE);
			String sql = new String();
			
			sql  = "SELECT hkh_id,hkh_mat_kz,hkh_lfd_nr,hkh_vg,hkh_pnr,hkh_sendtime ";
			sql += "FROM plrv11.zus_hk_historie ";
			sql += " WHERE hkh_id       = "  + id;
			sql += " AND   hkh_mat_kz   = '" + matKz;
			sql += "' AND  hkh_lfd_nr   = "  + lfdNr;
			sql += " ORDER BY hkh_sendtime";
			System.out.println(sql);
			int zaehler=1;
			stmtAlt.executeQuery(sql);
			ResultSet  rs = stmtAlt.getResultSet();
			while (rs.next()) {
				if (zaehler>10) {
					rs.deleteRow();
					System.out.println(zaehler +"ter Datensatz wurde gelöscht");
				}
				zaehler++;
			}
			
			rs.close();
			stmtAlt.close();	

			Statement  stmt = iCon.createStatement();
			sql  = "INSERT INTO plrv11.zus_hk_historie ";
			sql += "(hkh_id,hkh_mat_kz,hkh_lfd_nr,hkh_vg,hkh_pnr,hkh_sendtime) "; 
			sql += "VALUES (";
			sql += id      +  ",'";
			sql += matKz   + "',";
			sql += lfdNr   +  ",";
			sql += "'"+vg+"',";
			sql += pNr     +  ",CURRENT_DATE)";
			System.out.println(sql);
			stmt.executeUpdate(sql);
			stmt.close();
		}
		catch(SQLException sqle) {
			sqle.printStackTrace();
			
			return -1;
		}
		return(0);
	}
}
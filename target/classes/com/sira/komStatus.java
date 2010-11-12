package com.sira;

import java.io.*;
import java.sql.*;

public class komStatus  {
	private Connection con;
	// Konstruktoren
	public komStatus() {
	}
	public komStatus(Connection iCon) {
		con=iCon;
	}
	public int getKomStatus(String abNr,String artNr) {
		int ret=0;
		try {
			Statement  stmt = con.createStatement();
			stmt.executeQuery("SELECT KOM_STATUS FROM plrv11.zus_kommission WHERE kom_abnr="+abNr+" AND kom_art_nr="+artNr);
			ResultSet  rs = stmt.getResultSet();
			while (rs.next()) {
				ret = rs.getInt("kom_status");
			}
			rs.close();
			stmt.close();			
		}
		catch(SQLException sqle) {
			sqle.printStackTrace();
		}
		return(ret);
	}
	public int getSakStatus(String abNr,String artNr) {
                int ret=0;
                try {
                        Statement  stmt = con.createStatement();
                        stmt.executeQuery("SELECT SAK_STATUS FROM plrv11.zus_sammel_kopf WHERE sak_sanr="+abNr+" AND sak_artnr="+artNr);
                        ResultSet  rs = stmt.getResultSet();
                        while (rs.next()) {
                                ret = rs.getInt("sak_status");
                        }
                        rs.close();
                        stmt.close();
                }
                catch(SQLException sqle) {
                        sqle.printStackTrace();
                }
                return(ret);
        }
	public String getKomGebucht(String abNr,String artNr) {
                String ret= "";
                try {
                        Statement  stmt = con.createStatement();
                        stmt.executeQuery("SELECT KOM_GEBUCHT_KZ FROM plrv11.zus_kommission WHERE kom_abnr="+abNr+" AND kom_art_nr="+artNr);
                        ResultSet  rs = stmt.getResultSet();
                        while (rs.next()) {
                                ret = rs.getString("kom_gebucht_kz");
                        }
                        rs.close();
                        stmt.close();
                }
                catch(SQLException sqle) {
                        sqle.printStackTrace();
                }
                return(ret);
        }
        public String getSakArtNr(String abNr) {
                String ret= "";
                try {
                        Statement  stmt = con.createStatement();
                        stmt.executeQuery("SELECT SAK_ARTNR FROM plrv11.zus_sammel_kopf WHERE SAK_SANR="+abNr);
                        ResultSet  rs = stmt.getResultSet();
                        while (rs.next()) {
                                ret = rs.getString("sak_artnr");
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

package com.rolfbenz;

import java.sql.*;
import java.util.*;
import java.text.*;
import java.net.*;

public class qmExport {
    public static void main(String args []){
        System.out.println(export("/etc/zusJsp.conf"));
    }
    public static String export (String confDatei) {
    	String rueck = new String();
    	zusConfigDatei zcd = new zusConfigDatei(confDatei);
	zcd.verarbeiten();
	int zaehler=0;
	try {	
		bdeDb oraBde = new bdeDb(confDatei);
		Connection con = oraBde.getConnection(); 
		con.setAutoCommit(false);
		Statement stmt = con.createStatement();
		ResultSet rs; 
		ResultSetMetaData  rsmd;
		String sql       = new String();

		basisDatei qme = new basisDatei("/tmp","qmExport","csv");
		qme.oeffnen();
		
		sql  = "SELECT * ";
		sql += "FROM plrv11.qm_endkontr WHERE qme_erfass_dat > '01-Jan-2010' ";
		sql += "ORDER BY qme_erfass_dat";
		try {
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			rsmd = rs.getMetaData();
			while (rs.next()) {
				if (zaehler==0) {
					for (int i=1;i<=rsmd.getColumnCount();i++) {
						if (rs.getString(i)!=null) {
							qme.ausgabe.write(rsmd.getColumnName(i));
						}
						qme.ausgabe.write(";");
					}
					qme.ausgabe.write("\n");
				}

				for (int i=1;i<=rsmd.getColumnCount();i++) {
					if (rs.getString(i)!=null) {
						qme.ausgabe.write(rs.getString(i));
					}
					qme.ausgabe.write(";");
				}
				qme.ausgabe.write("\n");
				zaehler++;
			}
		}
		catch (SQLException sqlex) {
			System.out.println(sqlex.getMessage());
		}
		qme.schliessen();
		qme.aktiviereDatei();
		stmt.close();
		con.close();
	}
	catch (Exception e) {
		e.printStackTrace();
		System.out.println(e.getMessage());
	}
	return rueck;
    }
}

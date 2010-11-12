package com.rolfbenz;
import java.sql.*;
import java.util.*;
import java.text.*;
import java.net.*;
import java.io.*;

public class nwwStatistik {
	public static String tabelleFuellen(String confDatei,int tageZurueck, int dbEintrag, String ausgabeFormat) {
		String sql       = new String();
		String sqlDate   = new String();
		String rueck     = new String();
		String heute     = new String();
		String timestamp = new String();
		zusConfigDatei zcd = new zusConfigDatei(confDatei);
		DecimalFormat df = new DecimalFormat("#######0.00");
		zcd.verarbeiten();
		try {
			bdeDb oraBde = new bdeDb(confDatei);
			Connection con = oraBde.getConnection(); 
			con.setAutoCommit(false);
			Statement stmt = con.createStatement();
			ResultSet rs;
			int tag = 0,monat = 0,jahr = 0,fabt = 0;
			int se  = 0;
			float nww   = 0;
			String yymmdd = new String();
			String ddmmyy = new String();
			// Gestrigen Tag ermitteln
			sqlDate   = "SELECT TO_CHAR(CURRENT_DATE-"+tageZurueck+",'DD'), ";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE-"+tageZurueck+",'MM'), ";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE-"+tageZurueck+",'YYYY'),";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE-"+tageZurueck+",'YYMMDD'),";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE-"+tageZurueck+",'DDMMYY'),";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE,'YYYYMMDD'), ";
			sqlDate  +=       " TO_CHAR(CURRENT_DATE,'YYYYMMDD hh24:mi:ss')   FROM DUAL";
			stmt.executeQuery(sqlDate);
			rs = stmt.getResultSet();
			while (rs.next()) {
				tag    = rs.getInt(1);
				monat  = rs.getInt(2);
				jahr   = rs.getInt(3);
				yymmdd = rs.getString(4);
				ddmmyy = rs.getString(5);
				heute  = rs.getString(6);
				timestamp=rs.getString(7);
			}
			rs.close();
			// Fabkal ermitteln
			sql   = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE fab_datum="+ddmmyy;
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				fabt    = rs.getInt("fab_fab_tag");
			}
			rs.close();
			// Werte für SE und Netto-Warenwert für den ermittelten Tag ermitteln (Zeit der Fertigmeldung ist entscheidend)
			sql  = "SELECT sum(lft_nettoww),sum(ako_se)";
			sql += "FROM plrv11.plr_lf_texte ";
			sql += "INNER JOIN plrv11.plr_auftr_kopf   ON lft_abnr=ako_abnr AND lft_aend_ix=ako_aend_ix ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON as_abnr =ako_abnr AND as_aend_ix =ako_aend_ix ";
			sql += "INNER JOIN plrv11.bde_ab_mz        ON abm_abnr=ako_abnr AND abm_aend_ix=ako_aend_ix ";
			sql += "WHERE as_status<>99 ";
			sql += "AND abm_fs_status=40 AND abm_fs='10245100000' "; 
			sql += "AND (ako_aart1=1 OR (ako_aart1=2 AND ako_aart2 IN (15,16))) ";
			sql += "AND abm_sendtime like '"+yymmdd+"%'";
			
			
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			
			while (rs.next()) {
				nww = rs.getFloat(1);
				se  = rs.getInt(2);
			}
			rs.close();
			if (ausgabeFormat.compareTo("text")==0) {
				rueck  = "\n     Datum   Fabt        SE           NettoWW";
				rueck += "\n=============================================";
				rueck += "\n"+rbTextFormat.format(' ',12,tag+"."+monat+"."+jahr ) ;
				rueck += rbTextFormat.format(' ', 5,fabt ) ;
				rueck += rbTextFormat.format(' ', 10,se ) ;
				rueck += rbTextFormat.format(' ', 17,df.format(nww) );
				rueck += "\nNWW-Ermitteln:\n==========\n "+sql+"\n==========\n";
				rueck += "Datum aus Datenbank (heute):"+heute+"\n";
  				rueck += "Stichprobe entnommen für:"+yymmdd+" heute ist: "+heute+" Tage Zurück: "+tageZurueck+" Timestamp(aktuelle Zeit aus der DB):"+timestamp+"\n\n\n";

			} else if (ausgabeFormat.compareTo("html")==0) {
				rueck  = "<TABLE BORDER=1>";
				rueck += "<TR><TH>Datum</TH><TH>Fabt</TH><TH>SE</TH><TH>NettoWW</TH></TR>\n";
				rueck += "<TR><TD>" +tag+"."+monat+"."+jahr;
				rueck += "</TD><TD>"+fabt;
				rueck += "</TD><TD>"+se;
				rueck += "</TD><TD align=\"right\">"+df.format(nww);
				rueck += "</TD></TR></TABLE>";
			}
			if (dbEintrag==1) {
				System.out.println("Datenbank-Eintrag vornehmen:");
				System.out.println("============================");
				sql  = "INSERT INTO plrv11.plr_stat_nww (nww_dat,nww_fabt,nww_se,nww_nww) ";
				sql += "VALUES (TO_DATE('"+jahr+"-"+rbTextFormat.format('0',2,monat)+"-"+tag+"','YYYY-MM-DD'),"+fabt+","+se+",'"+df.format(nww)+"')";
				System.out.println(sql);
				System.out.println("================== Ende SQL Datenbankeintrag vornehmen ============");
				System.out.println("Stichprobe entnommen für:"+yymmdd+" heute ist: "+heute+" Tage Zurück: "+tageZurueck+" Timestamp: "+timestamp+"\n\n\n");
				stmt.executeUpdate(sql);
				con.commit();
			}
			stmt.close();
			con.close();

		}
		catch (Exception e) {
			rueck = "\nFehler "+e.getMessage();
			
		}
		return rueck;
	}
}

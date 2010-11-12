package com.rolfbenz;

import java.sql.*;
import java.util.*;
import java.text.*;
import java.net.*;
import java.io.*;

public class kommission {
    public static String bilden(String confDatei) {
    	String rueck = new String();
    	zusConfigDatei zcd = new zusConfigDatei(confDatei);
	zcd.verarbeiten();
	textDatei protDatei = new textDatei("/tmp","komBilden.log");
	textDatei logDatei  = new textDatei(zcd.getZusLogPfad(),"zusLog.txt");
	logDatei.nichtAnhaengen();
	String inhalt = new String();
	int verarbeitung = 0;
	File sperrDatei = new File(zcd.getKomBildSperrDatei());
	// Einlesen Log-Datei
        // Datei vorhanden => Auftragsannahme ist gelaufen => Kommissionen dürfen gebildet werden
	// Datei nicht vorhanden => Auftragsannahme ist noch nicht fertig => Kommissionen dürfen nicht gebildet werden
	try {
		protDatei.write(bdeZeit.getTimestamp("MM/dd hh:mm")+" Kommissionsbildung wurde angestossen - ");
		FileReader sperr = new FileReader(sperrDatei);
		for (int i=0;i<sperrDatei.length();i++){
			inhalt += (char) sperr.read();
		}
		protDatei.write("Datei gefunden => Verarbeitung - > ");
		verarbeitung = 1;
		sperr.close();
	}
	catch(Exception e) {
		protDatei.write("Datei nicht gefunden => Keine Verarbeitung ");
	}
	rueck ="<TABLE>";
	if (verarbeitung==1) {
		try {	
			bdeDb oraBde = new bdeDb(confDatei);
			Connection con = oraBde.getConnection(); 
			con.setAutoCommit(false);
			Statement stmt = con.createStatement();
			Statement stmtUpdate = con.createStatement();
			ResultSet rs;
			String sql       = new String();
			String sqlUpdate = new String();
			int inserts = 0;
			int updates = 0;
			int fehler  = 0;
			logDatei.write("Kommissionen anlegen -");
			// Kommissionen anlegen
			sql  = "INSERT INTO plrv11.zus_kommission ";
			sql += "(kom_abnr,kom_art_nr,kom_qm_netto,kom_qm_brutto,kom_anz_teile,kom_rest_kz,";
			sql += "kom_reserv_kz,kom_cutter_kz,kom_manuell_kz,kom_anlage_dat,kom_fabt_zuschn,";
			sql += "kom_werk_zuschn,kom_prog,kom_kz_mf,kom_bnr3,kom_zs_sys,kom_kz_praemie,kom_kz_einzel,kom_b_klasse)";
			sql += "SELECT ";
			sql += "ako_abnr,ap_syn,sum(ap_menge_netto),sum(ap_menge_brutto),sum(ap_anz_ld*ap_menge/100),";
			sql += "'N','N','X','X',TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),";
			sql += "ako_fabt_zuschn,ako_werk_zuschn,ako_prog,ako_kz_mf,ako_bnr3,";
			sql += "art_zs_sys,'J','N',ako_b_klasse ";
			sql += "FROM ";
			sql += " plrv11.plr_auftr_kopf ";
			sql += "LEFT JOIN ";
			sql += " plrv11.plr_auftr_status ";
			sql += "ON ";
			sql += " as_abnr=ako_abnr AND as_aend_ix=ako_aend_ix ";
			sql += "LEFT JOIN ";
			sql += " plrv11.plr_art_pos ";
			sql += "ON ";
			sql += " ako_abnr=ap_abnr AND ap_aend_ix=ako_aend_ix ";
			sql += "LEFT JOIN ";
			sql += " plrv11.plr_art_kopf ";
			sql += "ON ";
			sql += " ap_syn=art_nr ";
			sql += "WHERE ";
			sql += " ap_syn IS NOT NULL and ap_syn>'4420000000' AND as_status<>99 and (ap_klasse='M' or ap_klasse='F') AND ";
			sql += " ako_kommission='B' and art_zs_sys is not null ";
			sql += "GROUP BY ako_abnr,ap_syn,ako_fabt_zuschn,ako_werk_zuschn,ako_prog,ako_kz_mf,ako_bnr3,art_zs_sys,ako_b_klasse ";
			sql += "ORDER BY ako_abnr,ap_syn";		
			try {
				inserts = stmt.executeUpdate(sql);
				rueck += "<TR><TD>Eingefuegte Kommissionen</TD><TD>"+inserts+"</TD></TR>\n";
				logDatei.writeln(bdeZeit.getTimestamp("MM/dd hh:mm")+":  Eingefuegte Kommissionen:"+inserts);
				logDatei.anhaengen();
			}
			catch (SQLException sqlex) {
				fehler=1;
				rueck += "<TR><TD>Fehler beim Einfuegen der Kommissionen!!</TD></TR>\n";
				rueck += "<TR><TD>"+sqlex.getMessage()+"</TD></TR>\n";
				logDatei.writeln(bdeZeit.getTimestamp("MM/dd hh:mm")+":  Fehler beim Einfuegen der Kommissionen!!");
				logDatei.writeln("\n"+sql+"\n");
				logDatei.anhaengen();
			}
/*
			// Sonderfertigungs-Kommissionen mit zs_sys=31 Kennzeichnen
			sql  = " SELECT ";
			sql += " kom_abnr,kom_art_nr ";
			sql += " FROM plrv11.zus_kommission ";
			sql += " INNER JOIN plrv11.plr_auftr_status ON as_abnr=kom_abnr ";
			sql += " INNER JOIN plrv11.plr_auftr_kopf ON ako_abnr=as_abnr AND as_aend_ix=ako_aend_ix ";
			sql += " WHERE as_status      <> 99 ";
			sql += " AND   ako_kommission = 'B' ";
			sql += " AND   ako_sf_hw_auftr= 'S' ";
			sql += " GROUP BY kom_abnr,kom_art_nr ";
			
			updates = 0;
			rs = stmt.executeQuery(sql);
			while (rs.next()) {			
				sqlUpdate  = " UPDATE plrv11.zus_kommission ";
				sqlUpdate += " SET kom_zs_sys=31 ";
				sqlUpdate += " WHERE kom_abnr="+rs.getString("kom_abnr");
				sqlUpdate += " AND kom_art_nr="+rs.getString("kom_art_nr");
				updates += stmtUpdate.executeUpdate(sqlUpdate);
			}
			rueck +="<TR><TD>Aktualisierte SF-Auftr&auml;ge</TD><TD>"+updates+"</TD></TR>\n";
			logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm"));
			logDatei.writeln(":  Aktualisierte SF-Auftr&auml;ge:"+updates);
*/			
			
			// Kommissions-Fertigungsstufen
			sql  = "INSERT INTO plrv11.zus_kom_fs ";
			sql += "(kfs_abnr,kfs_artnr,kfs_ordnr,kfs_fs,kfs_tr,kfs_te,kfs_dezi) ";
			sql += "select ";
			sql += "ako_abnr,ap_syn,apz_tmix_pos,apz_tmix_fs,sum(apz_tr),sum(apz_te),sum(apz_tr)+sum(apz_te) ";
			sql += "FROM ";
			sql += "plrv11.plr_auftr_kopf, ";
			sql += "plrv11.plr_art_pos, ";
			sql += "plrv11.plr_bez_pos, ";
			sql += "plrv11.plr_auftr_status, ";
			sql += "plrv11.plr_art_kopf ";
			sql += "WHERE ";
			sql += "ako_abnr    = as_abnr AND ";
			sql += "ako_aend_ix = as_aend_ix AND ";
			sql += "ap_abnr     = as_abnr AND ";
			sql += "ap_aend_ix  = as_aend_ix AND ";
			sql += "ap_posnr    = apz_posnr AND ";
			sql += "apz_abnr    = as_abnr AND ";
			sql += "apz_aend_ix = as_aend_ix AND ";
			sql += "as_status   <>99 AND ";
			sql += "apz_tmix_ss = 2 AND ";
			sql += "ako_kommission='B' AND ";
			sql += "ap_klasse   <>'K' AND ";
			sql += "ap_syn>'4420000000' AND ";
			sql += "ap_syn=art_nr ";
			sql += "GROUP by ako_abnr,ap_syn,apz_tmix_pos,apz_tmix_fs ";
			sql += "ORDER BY ako_abnr ";
			try {
				inserts = stmt.executeUpdate(sql);
				rueck += "<TR><TD>Eingefuegte Kommissionens-Fertigungsstufen</TD><TD>"+inserts+"</TD></TR>\n";
				logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm"));
				logDatei.writeln(":  Eingefuegte Kommissionsfertigungsstufen:"+inserts);
				logDatei.anhaengen();
			}
			catch (SQLException sqlex) {
				fehler=1;
				rueck += "<TR><TD>Fehler beim Einfuegen der Kommissions-Fertigungsstufen!!</TD><TD>";
				rueck += sql+"</TD></TR>";
				logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm"));
				logDatei.writeln(":  Fehler beim Einfuegen der Kommissions-Fertigungsstufen!!<BR>");
				logDatei.writeln(sqlex.getMessage());
				logDatei.anhaengen();
			}
			
			// Kommissions-Haken
			sql  = "INSERT INTO plrv11.zus_kom_hk (khk_abnr,khk_artnr,khk_hkk_id,khk_hkk_mat) ";
			sql += "select ako_abnr,ap_syn,vkn_hkk_id,vkn_hkk_mat_kz ";
			sql += "FROM ";
			sql += "plrv11.plr_auftr_kopf, ";
			sql += "plrv11.plr_art_pos, ";
			sql += "plrv11.plr_auftr_status, ";
			sql += "plrv11.zus_vkn_hkk_zsb, ";
			sql += "plrv11.plr_art_kopf ";
			sql += "WHERE ";
			sql += "ako_abnr=ap_abnr AND ";
			sql += "ako_aend_ix=ap_aend_ix AND ";
			sql += "as_abnr=ako_abnr AND ";
			sql += "as_aend_ix=ako_aend_ix AND ";
			sql += "as_status<>99 AND ";
			sql += "ako_kommission='B' AND ";
			sql += "vkn_sb_id=substr(ap_artnr,4,6) AND ";
			sql += "vkn_hkk_mat_kz='L' AND ";
			sql += "ap_syn>'4420000000' AND ";
			sql += "ap_syn=art_nr ";
			sql += "GROUP BY ";
			sql += "ako_abnr,ap_syn,vkn_hkk_id,vkn_hkk_mat_kz ";
			sql += "ORDER BY ";
			sql += "ako_abnr ";
			try {
				inserts = stmt.executeUpdate(sql);
				rueck += "<TR><TD>Eingefuegte Kommissionens-Haken</TD><TD>"+inserts+"</TD></TR>\n";
				logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm"));
				logDatei.writeln(":  Eingefuegte Kommissions-Haken:"+inserts);
				logDatei.anhaengen();	
			} 
			catch (SQLException sqlex) {
				fehler=1;
				rueck += "<TR><TD>Fehler beim Einfuegen der Kommissions-Haken!!</TD><TD>\n";
				rueck += sql+"</TD></TR>";
				logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm"));
				logDatei.writeln(":  Fehler beim Einfuegen der Kommissions-Haken!!<BR>"+sqlex.getMessage());
				logDatei.anhaengen();	
			}
			
			// Updaten der Auftragsköpfe
			sql  = "UPDATE plrv11.plr_auftr_kopf SET ako_kommission='K' WHERE ako_kommission='B' AND ";
			sql += "ako_abnr IN (SELECT kom_abnr FROM plrv11.zus_kommission)";
			if (fehler==0) {
				updates = stmt.executeUpdate(sql);
				con.commit();
			} else {
				updates = 0;
				con.rollback();
			}
			rueck +="<TR><TD>Updates Auftragskoepfe </TD><TD>"+updates+"</TD></TR>\n";
			logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm")+":  Updates Auftragskoepfe  :"+updates);
	
			// Reservierungen zuordnen
			long abNr    = 0;
			long artNr   = 0;
			long lagerOrt= 0;
			String bemerk = new String("");
			String fungi  = new String("");
	
			sql  = "SELECT kom_abnr,kom_art_nr,res_res_lagerort,res_bemerk,res_fungizid ";
			sql += "FROM plrv11.zus_kommission,plrv11.zus_rest_reserv ";
			sql += "WHERE kom_abnr=res_abnr AND kom_art_nr=res_art_nr AND ";
			sql += "res_status=0 AND res_reserv_kz='J' AND kom_status<10 ";
	
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			updates=0;
			while (rs.next()) {
				abNr    = rs.getLong("kom_abnr");
				artNr   = rs.getLong("kom_art_nr");
				lagerOrt= rs.getLong("res_res_lagerort");
				bemerk  = rs.getString("res_bemerk");
				fungi   = rs.getString("res_fungizid");
				sqlUpdate  = "UPDATE plrv11.zus_kommission SET kom_reserv_kz='J',";
				sqlUpdate += "kom_reserv_lagerort="+lagerOrt+",kom_bemerkung='"+bemerk+"',kom_fungizid='"+fungi+"',kom_zs_sys=10 ";
				sqlUpdate += "WHERE kom_abnr="+abNr+" AND kom_art_nr="+artNr;
				updates += stmtUpdate.executeUpdate(sqlUpdate);
				sqlUpdate  = "Update plrv11.zus_rest_reserv SET res_status=40 WHERE ";
				sqlUpdate += "res_abnr="+abNr+" AND res_art_nr="+artNr;
				stmtUpdate.executeUpdate(sqlUpdate);
	
			}
			rueck +="<TR><TD>Reservierungen zugeordnet</TD><TD>"+updates+"</TD></TR>\n";
			logDatei.writeln("<BR>"+bdeZeit.getTimestamp("MM/dd hh:mm")+":  Reservierungen zugeordnet  :"+updates);
	
			stmt.close();
			con.close();
			if (verarbeitung==1) {
				protDatei.writeln("Datei wurde geloescht : "+sperrDatei.delete());
			}
		}
		catch (Exception e) {
			e.printStackTrace();
			rueck += "<TR><TD BGCOLOR=\"red\">Fehler!<BR>Es wurden keine Kommissionen angelegt</TD></TR>\n";
			logDatei.writeln("Achtung!! Verarbeitung nicht erfolgt!\n"+e.getMessage());
		}

		protDatei.write("\n");
	} else {
		rueck +="<TR><TD><H2>Es liegen keine Dateien zur Verarbeitung vor!</H2></TD></TR>";
		protDatei.write("\n");
	}
	rueck +="</TABLE>";
	return rueck;
    }
}

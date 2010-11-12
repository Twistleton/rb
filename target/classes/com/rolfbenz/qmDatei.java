package com.rolfbenz;

import java.io.*;
import java.sql.*;
import java.util.Date;
import java.text.*;

public class qmDatei extends basisDatei {
	// Konstruktoren
	public qmDatei() {
	}
    	public qmDatei(String iPfad) {
		super(iPfad);
	}
	public qmDatei(String iPfad, String iDateiname, String iEndung) {
		super(iPfad,iDateiname,iEndung);
	}
	public qmDatei(File iPfad) {
		super(iPfad);
	}
	public String getName(){
		return datei.getName();
	}
	public void setNameTimestamp() {
		try {
			dateiname = bdeZeit.getTimestamp("yyMMddHHmmssSSS");
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	public void aktiviereDatei() {
		// Endesatz angängen und Datei umbenennen.
		File temp = new File(pfad+File.separator+dateiname+"."+endung) ;
		datei.renameTo(temp);	
		datei = temp;
	}
	public void satzEinfuegen(String text) {
		try {
			ausgabe.write(text);
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	public int bqsDatei (int abNr,int fsStatus, Connection con) {
		try {
			String sql        = new String();
			String polstPNr   = new String();

			Statement stmt    = con.createStatement();
			ResultSet rs;
			
			sql  = "SELECT abf_abnr,abf_pnr ";
			sql += "FROM plrv11.bde_ab_fs_ma ";
			sql += "WHERE abf_fs_status=40 ";
			sql += "AND abf_fs='10245100000' ";
			sql += "AND abf_abnr="+abNr;
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				polstPNr = rbTextFormat.format('0',4,rs.getString("abf_pnr"));
			}
			if (fsStatus==20) {
				polstPNr = "9"+polstPNr.substring(1);
			}
			ausgabe.write("07");                                   // von Subsystem
			ausgabe.write("02");                                   // nach Subsystem
			ausgabe.write("E001");                                 // Ereignis/Aktion
			ausgabe.write(bdeZeit.getTimestamp("yyyyMMddHHmmss")); // Timestamp
			ausgabe.write("055");                                  // Satzlänge
			ausgabe.write("90");                                   // Paketfolgenummer
			ausgabe.write(rbTextFormat.format(' ', 6,abNr));       // Ab-Nr
			ausgabe.write("AD");                                   // Interner Vorgang
			ausgabe.write("07");				       // Bezogenes Subsystem
			ausgabe.write(rbTextFormat.format('0', 4,polstPNr));   // Personalnummer des Polsterers
			ausgabe.write("10245400000");                          // Fesrtigungsstufe
			ausgabe.write(String.valueOf(fsStatus));	       // FS-Status (10,20,40)
			ausgabe.write("N");				       // Split-KZ
			ausgabe.write("\n");
			return 0;
		}	
		catch (Exception ex) {
			ex.printStackTrace();
			return -1;
		}
	}
	public int qmRWProtokoll(int abNr,Connection con) {
		try {
			String sql        = new String();
			Statement stmt      = con.createStatement();
			String tempString = new String();
			ResultSet rs;
			ausgabe.write("QMRW\n");
			ResultSetMetaData rsmd;
			sql = "SELECT * FROM plrv11.qm_endkontr WHERE qme_abnr="+abNr;
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			rsmd = rs.getMetaData();
			while (rs.next()) {
				for  (int lauf=1;lauf<=rsmd.getColumnCount();lauf++) {
					tempString = rbTextFormat.format(' ',rsmd.getPrecision(lauf),rs.getString(lauf));
					ausgabe.write(tempString);
				}
			}
			ausgabe.write("\n");
			rs.close();
			stmt.close();	
			return 0;
		}
		catch(Exception ex) {
			ex.printStackTrace();
			return -1;
		}

	}
	public int qmPapiere(int abNr,Connection con) {
		try {
			String sql        = new String();
			Statement stmt      = con.createStatement();
			ResultSet rs;
			ausgabe.write("ARPAPQM");	
			ausgabe.write(rbTextFormat.format(' ',6,abNr));
			ausgabe.write("\n");

			/* ************     Auftragskopfdaten       *************** */
			sql  = "SELECT ";
			sql += "ako_abnr,ako_fabt_pps,ako_prog, ";
			sql += "ako_prior,ako_se,ako_fabt_zuschn,ako_sf_hw_auftr,ako_werk_zuschn, ";
			sql += "ako_werk_naht,ako_werk_polst,ako_aart1,ako_aart2,ako_aart3, ";
			sql += "ako_bnr3,ako_vlte,ako_sb_tnr,ako_kunde,ako_vpkz, ako_vlz ";
			sql += "FROM plrv11.plr_auftr_kopf ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON ako_abnr = as_abnr AND ako_aend_ix = as_aend_ix ";
			sql += "WHERE as_status <>99 AND ";
			sql += "ako_abnr="+abNr;
			sql += " ORDER BY ";
			sql += "ako_abnr ";
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("AKO");
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("ako_abnr")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ako_fabt_pps")));
				ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ako_prog")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_prior")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_se")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ako_fabt_zuschn")));	
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ako_sf_hw_auftr")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_werk_zuschn")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_werk_naht")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_werk_polst"))); 
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_aart1")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_aart2")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_aart3")));
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("ako_bnr3")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ako_vlte")));
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("ako_sb_tnr")));	
				ausgabe.write(rbTextFormat.format(' ', 7,rs.getString("ako_kunde")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ako_vpkz")));
				ausgabe.write(rbTextFormat.format(' ', 5,rs.getString("ako_vlz"))+"\n");
			}
			rs.close();
			/* ************     Auftragssondertexte       *************** */
			sql  = "SELECT ";
			sql += "akt_abnr,akt_text_pos,akt_text ";
			sql += "FROM plrv11.plr_ak_texte ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON akt_abnr  = as_abnr AND as_aend_ix = akt_aend_ix ";
			sql += "WHERE as_status <>99 ";
			sql += "AND   akt_text_art='2' ";
			sql += "AND   akt_abnr="+abNr;
			sql += " ORDER BY akt_text_pos";
			stmt.executeQuery(sql);	
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("AKT");
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("akt_abnr")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("akt_text_pos")));
				ausgabe.write(rbTextFormat.format(' ',50,rs.getString("akt_text"))+"\n");
			}
			rs.close();
			/* ***********    Auftragspositionen **************** */
			sql  = "SELECT ";
			sql += "ap_abnr,ap_artnr,ap_menge, ";
			sql += "ap_bezeichn,ap_bezug,ap_syn,ap_vera_hw,ap_schw_grad, ";
			sql += "ap_sf_hw,ap_klasse,ap_menge_netto,ap_menge_brutto,ap_anz_kiss,";
			sql += "ap_anz_ld,ap_anz_st,ap_garn,ap_rv,ap_koeper,";
			sql += "ap_kzbs,ap_posnr,ap_se,ap_anz_kiss ";
			sql += "FROM ";
			sql += "plrv11.plr_art_pos ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON ap_abnr=as_abnr AND ap_aend_ix=as_aend_ix ";
			sql += "WHERE ";
			sql += "ap_abnr="+abNr;
			sql += "AND as_status<>99 ";
			sql += " ORDER BY ";
			sql += "ap_posnr";
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("APO");
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("ap_abnr")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("ap_artnr")));
				ausgabe.write(rbTextFormat.format(' ', 7,rs.getString("ap_menge")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ap_bezeichn")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("ap_bezug")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("ap_syn")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_vera_hw")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_schw_grad")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_sf_hw")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_klasse")));
				ausgabe.write(rbTextFormat.format(' ', 7,String.valueOf(rs.getFloat("ap_menge_netto"))));
				ausgabe.write(rbTextFormat.format(' ', 7,String.valueOf(rs.getFloat("ap_menge_brutto"))));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_anz_kiss")));
				ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ap_anz_ld")));
				ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ap_anz_st")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ap_garn")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ap_rv")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ap_koeper")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_kzbs")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_posnr")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_se")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_anz_kiss"))+"\n");
			}
			rs.close();
			/* ***********    KPR    **************** */
			sql  = "SELECT ";
			sql += "pr_abnr,pr_name,pr_lang,pr_kurz ";
			sql += "FROM plrv11.plr_prdat ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON as_abnr=pr_abnr AND as_aend_ix=pr_aend_ix ";
			sql += "WHERE ";
			sql += "pr_abnr="+abNr;
			sql += " AND as_status<>99 ";
			sql += " ORDER BY ";
			sql += "pr_name";
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("KPR");
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("pr_abnr")));
				ausgabe.write(rbTextFormat.format(' ', 5,rs.getString("pr_name")));
				ausgabe.write(rbTextFormat.format(' ',32,rs.getString("pr_lang")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("pr_kurz")));
				ausgabe.write("\n");
			}
			rs.close();
			/* ************     Polsterer       *************** */
			sql  = "SELECT ";
			sql += "abf_pnr,ma_nname,ma_vname ";
			sql += "FROM plrv11.bde_ab_fs_ma ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
			sql += "INNER JOIN plrv11.bde_madat ON abf_pnr=ma_pnr ";
			sql += "WHERE as_status <>99 ";
			sql += "AND   abf_abnr="+abNr;
			sql += " AND   abf_fs='10245100000' ";
			sql += " ORDER BY abf_abnr";
			stmt.executeQuery(sql);	
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("PDA");
				ausgabe.write(rbTextFormat.format(' ',4,rs.getString("abf_pnr")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_vname").trim()));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_nname").trim())+"\n");
			}
			rs.close();
			/* ************     Zuschnitt       *************** */
			sql  = "SELECT ";
			sql += "abf_pnr,ma_nname,ma_vname ";
			sql += "FROM plrv11.bde_ab_fs_ma ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
			sql += "INNER JOIN plrv11.bde_madat ON abf_pnr=ma_pnr ";
			sql += "WHERE as_status <>99 ";
			sql += "AND   abf_abnr="+abNr;
			sql += " AND   abf_fs='10244100000' ";
			sql += " ORDER BY abf_abnr";
			stmt.executeQuery(sql);	
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("PZU");
				ausgabe.write(rbTextFormat.format(' ',4,rs.getString("abf_pnr")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_vname").trim()));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_nname").trim())+"\n");
			}
			rs.close();
			/* ************     Montagenaht       *************** */
			sql  = "SELECT ";
			sql += "abf_pnr,ma_nname,ma_vname ";
			sql += "FROM plrv11.bde_ab_fs_ma ";
			sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
			sql += "INNER JOIN plrv11.bde_madat ON abf_pnr=ma_pnr ";
			sql += "WHERE as_status <>99 ";
			sql += "AND   abf_abnr="+abNr;
			sql += " AND   abf_fs='10243100000' ";
			sql += " ORDER BY abf_abnr";
			stmt.executeQuery(sql);	
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("PMO");
				ausgabe.write(rbTextFormat.format(' ',4,rs.getString("abf_pnr")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_vname").trim()));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_nname").trim())+"\n");
			}
			rs.close();


			/* ************     Pufferzone       *************** */
			sql  = "SELECT ";
			sql += "pp_pfzone ";
			sql += "FROM plrv11.bde_pufpl ";
			sql += "WHERE (pp_abnr="+abNr;
			sql += " OR     pp_ab2 ="+abNr;
			sql += " OR     pp_ab3 ="+abNr;
			sql += ") AND pp_pfnr=10245400";
			stmt.executeQuery(sql);	
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("PFZ");
				ausgabe.write(rbTextFormat.format(' ',2,rs.getString("pp_pfzone"))+"\n");
			}
			rs.close();
			stmt.close();	
			return 0;
		}
		catch(Exception ex) {
			ex.printStackTrace();
			return -1;
		}
	}
	public String drucken(String iDrucker) {
		String befehl = new String ("lpr -P"+iDrucker+" "+pfad+"/"+dateiname+"."+endung);
		try {
			Process p = Runtime.getRuntime().exec(befehl);
		}
		catch(IOException ioe) {
			ioe.printStackTrace();
			return (befehl);
		}
		return(befehl);
	}
}

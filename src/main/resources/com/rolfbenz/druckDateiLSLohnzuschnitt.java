package com.rolfbenz;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.DecimalFormat;

public class druckDateiLSLohnzuschnitt extends basisDatei {
	// Konstruktoren
	public druckDateiLSLohnzuschnitt() {
	}
    	public druckDateiLSLohnzuschnitt(String iPfad) {
		super(iPfad);
	}
	public druckDateiLSLohnzuschnitt(String iPfad, String iDateiname, String iEndung) {
		super(iPfad,iDateiname,iEndung);
	}
	public druckDateiLSLohnzuschnitt(File iPfad) {
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
	public int arbeitsBegleitpapiere(long sAbNr,Connection con) {	
		try {
			String sql        = new String();
			String sqlApText  = new String();
			String sqlLauf    = new String();
			String sqlAG      = new String();
			String sqlHk      = new String();
			java.util.Date datum = new java.util.Date();
			Statement stmt      = con.createStatement();
			Statement stmtApText= con.createStatement();
			Statement stmtLauf  = con.createStatement(); 
			Statement stmtAG    = con.createStatement();
			Statement stmtHk    = con.createStatement();
			ResultSet rs;
			ResultSet rsApText;
			ResultSet rsLauf;
			ResultSet rsAG;
			ResultSet rsHk;
			DecimalFormat df = new DecimalFormat("###0,00");
			String  teamKz = new String();
			int     team   = 0;
			long    artNr  = 0;
			ausgabe.write("AB_ZLS\n");
			/* ************     Sammelauftragsdaten       *************** */
		
			sql  = "SELECT ";
			sql += "sak_sanr,sak_artnr,art_bez,sak_platz,sak_menge_ist,";
			sql += "sak_charg_nr,sak_lief_kkz,sak_pnr,ma_nname,kom_zs_sys,sak_zbl ";
			sql += "FROM ";
			sql += "plrv11.zus_sammel_kopf inner join plrv11.plr_art_kopf on sak_artnr=art_nr ";
			sql += "INNER JOIN plrv11.zus_kommission ON kom_sammel_abnr=sak_sanr ";
			sql += "LEFT OUTER JOIN plrv11.bde_madat on ma_pnr=sak_pnr ";			
			sql += "WHERE ";
			sql += "sak_sanr  ="+sAbNr;
			sql += " GROUP BY ";
			sql += "sak_sanr,sak_artnr,art_bez,sak_platz,sak_menge_ist,";
			sql += "sak_charg_nr,sak_lief_kkz,sak_pnr,ma_nname,kom_zs_sys,sak_zbl";
			
			
			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("SKO");
				ausgabe.write(rbTextFormat.format(' ',14,sAbNr));
				ausgabe.write(rbTextFormat.format(' ', 6," "));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("sak_artnr")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("art_bez")));
				ausgabe.write(rbTextFormat.format(' ',11,rs.getString("sak_platz")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("sak_menge_ist")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("sak_charg_nr")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("sak_lief_kkz")));
				ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("sak_pnr")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_nname")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("kom_zs_sys")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("sak_zbl"))+"\n");
				artNr = rs.getLong("sak_artnr");
			}
			
			sqlLauf  = "SELECT kom_sammel_abnr,kom_abnr FROM plrv11.zus_kommission ";
			sqlLauf += "WHERE kom_sammel_abnr="+sAbNr+" ORDER BY kom_abnr,kom_art_nr";
			
			stmtLauf.executeQuery(sqlLauf);
			rsLauf = stmtLauf.getResultSet();
			while (rsLauf.next()) {
				teamKz = "";
				team   = 0;
				/* ************     Auftragskopfdaten       *************** */	
				sql  = "SELECT ";
				sql += "kom_sammel_abnr,kom_abnr,kom_art_nr,ako_fabt_pps,ako_prog, ";
				sql += "ako_prior,ako_se,ako_fabt_zuschn,ako_sf_hw_auftr,ako_werk_zuschn, ";
				sql += "ako_werk_naht,ako_werk_polst,ako_aart1,ako_aart2,ako_aart3, ";
				sql += "ako_bnr3,ako_vlte,ako_sb_tnr,ako_kunde,kom_qm_netto, ";
				sql += "kom_qm_brutto ";
				sql += "FROM ";
				sql += "plrv11.zus_kommission,plrv11.plr_auftr_kopf,plrv11.plr_auftr_status ";
				sql += "WHERE ";
				sql += "kom_abnr = ako_abnr AND ";
				sql += "ako_abnr = as_abnr AND ";
				sql += "ako_aend_ix = as_aend_ix AND ";
				sql += "as_status <>99 AND ";
				sql += "kom_sammel_abnr="+sAbNr+ " AND ";
				sql += "kom_abnr="+rsLauf.getString("kom_abnr");
				sql += " ORDER BY ";
				sql += "ako_abnr ";
			
				stmt.executeQuery(sql);
				rs = stmt.getResultSet();
				while (rs.next()) {
					ausgabe.write("AKO");
					ausgabe.write(rbTextFormat.format(' ',14,sAbNr));	
					ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("kom_abnr")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("kom_art_nr")));
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
					ausgabe.write(rbTextFormat.format(' ',10,String.valueOf(rs.getFloat("kom_qm_netto"))));
					ausgabe.write(rbTextFormat.format(' ',10,String.valueOf(rs.getFloat("kom_qm_brutto")))+"\n");
				}
				//  Wenn Auftrag durch ein Team bearbeitet wurde...
				sql  = "SELECT kfs_pnr,ma_team,ma_team_kz";
				sql += " FROM plrv11.zus_kommission";
				sql += " INNER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr";
				sql += " INNER JOIN plrv11.bde_madat ON kfs_pnr=ma_pnr";
				sql += " WHERE kom_sammel_abnr="+sAbNr;
				sql += " AND   kom_abnr="+rsLauf.getString("kom_abnr");
				sql += " GROUP BY kfs_pnr,ma_team,ma_team_kz";
				rs = stmt.executeQuery(sql);
				while (rs.next()) {
					teamKz = rs.getString("ma_team_kz");
					team   = rs.getInt("kfs_pnr");
				}
				if (teamKz.compareTo("J")==0) {
					sql  = " SELECT";
					sql += " ma_pnr,ma_nname";
					sql += " FROM plrv11.bde_madat ";
					sql += " WHERE ma_team = "+team;
					sql += " AND ma_team_kz = 'N'";
					sql += " ORDER BY ma_nname";
					rs = stmt.executeQuery(sql);
					while (rs.next()) {
						ausgabe.write("APN");
						ausgabe.write(rbTextFormat.format(' ',14,sAbNr));		
						ausgabe.write(rbTextFormat.format(' ', 6,rsLauf.getString("kom_abnr")));
						ausgabe.write(rbTextFormat.format(' ',10,artNr));
						ausgabe.write(rbTextFormat.format(' ', 4,rs.getString("ma_pnr")));
						ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ma_nname"))+"\n");
					}
				}
				/* ************     Liefertexte      *************** */
				
				sql  = "SELECT ";
				sql += "kom_sammel_abnr,kom_abnr,kom_art_nr,lft_laddr1,lft_laddr2,lft_laddr3,lft_laddr4,lft_kdkomm,lft_kdabnr ";
				sql += "FROM ";
				sql += "plrv11.zus_kommission ";
				sql += "INNER JOIN plrv11.plr_lf_texte ON kom_abnr=lft_abnr ";
				sql += "INNER JOIN plrv11.plr_auftr_status ON lft_abnr=as_abnr AND lft_aend_ix=as_aend_ix ";
				sql += "WHERE ";
				sql += "kom_sammel_abnr="+sAbNr+" AND ";
				sql += "kom_abnr="+rsLauf.getString("kom_abnr");
				sql += " ORDER BY kom_abnr";

				stmt.executeQuery(sql);
				rs = stmt.getResultSet();
				
				while (rs.next()) {
					ausgabe.write("LFT");
					ausgabe.write(rbTextFormat.format(' ',14,sAbNr));
					ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("kom_abnr")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("kom_art_nr")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr1")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr2")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr3")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr4")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_kdkomm")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("lft_kdabnr"))+"\n");
				}
				
				/* ************     Auftragspositionen       *************** */
				sql  = "SELECT ";
				sql += "kom_sammel_abnr,kom_abnr,kom_art_nr,ap_artnr,ap_menge, ";
				sql += "ap_bezeichn,ap_bezug,ap_syn,ap_vera_hw,ap_schw_grad, ";
				sql += "ap_sf_hw,ap_klasse,ap_menge_netto,ap_menge_brutto,ap_anz_kiss,";
				sql += "ap_anz_ld,ap_anz_st,ap_garn,ap_rv,ap_koeper,";
				sql += "ap_kzbs,ap_posnr,ap_se,ap_anz_kiss ";
				sql += "FROM ";
				sql += "plrv11.zus_kommission ";
				sql += "INNER JOIN plrv11.plr_art_pos ON kom_abnr=ap_abnr ";
				sql += "INNER JOIN plrv11.plr_auftr_status ON ap_abnr=as_abnr AND ap_aend_ix=as_aend_ix ";
				sql += "WHERE ";
				sql += "kom_sammel_abnr="+sAbNr+" AND ";
				sql += "kom_abnr="+rsLauf.getString("kom_abnr")+" AND ";
				sql += "as_status<>99 ";
				sql += " ORDER BY ";
				sql += "kom_abnr,kom_art_nr";
				
				stmt.executeQuery(sql);
				rs = stmt.getResultSet();
				while (rs.next()) {
					ausgabe.write("APO");
					ausgabe.write(rbTextFormat.format(' ',14,sAbNr));
					ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("kom_abnr")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("kom_art_nr")));
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
					sqlApText  = "SELECT";
					sqlApText += " apt_text,apt_typ,apt_auspr";
					sqlApText += " FROM plrv11.plr_ap_texte ";
					sqlApText += " INNER JOIN plrv11.plr_auftr_status ";
					sqlApText += " ON apt_abnr=as_abnr AND apt_aend_ix=as_aend_ix ";
					sqlApText += " WHERE as_status<>99";
					sqlApText += " AND apt_text_art='C'";
					sqlApText += " AND apt_abnr="+rsLauf.getString("kom_abnr");
					sqlApText += " AND apt_abnr_pos="+rs.getString("ap_posnr");
					stmtApText.executeQuery(sqlApText);
					rsApText = stmtApText.getResultSet();
					while (rsApText.next()) {
						ausgabe.write("AVT");
						ausgabe.write(rbTextFormat.format(' ',14,sAbNr));
						ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("kom_abnr")));
						ausgabe.write(rbTextFormat.format(' ',10,rs.getString("kom_art_nr")));
						ausgabe.write(rbTextFormat.format(' ',32,rsApText.getString("apt_text")));
						ausgabe.write(rbTextFormat.format(' ', 2,rsApText.getString("apt_typ")));
						ausgabe.write(rbTextFormat.format(' ', 2,rsApText.getString("apt_auspr"))+"\n");
					}
					
				}

				/* ************     Auftragssondertexte       *************** */
				sql  = "SELECT ";
				sql += "kom_sammel_abnr,kom_abnr,kom_art_nr,akt_text_pos,akt_text ";
				sql += "FROM ";
				sql += "plrv11.zus_kommission,plrv11.plr_ak_texte,plrv11.plr_auftr_status ";
				sql += "WHERE ";
				sql += "kom_abnr   = akt_abnr AND ";
				sql += "kom_abnr   = as_abnr AND ";
				sql += "as_aend_ix = akt_aend_ix AND ";
				sql += "as_status <>99 AND ";
				sql += "akt_text_art='2' AND ";
				sql += "kom_sammel_abnr="+sAbNr+ " AND ";
				sql += "kom_abnr="+rsLauf.getString("kom_abnr");
				sql += " ORDER BY kom_abnr";
				stmt.executeQuery(sql);	
				rs = stmt.getResultSet();
				while (rs.next()) {
					ausgabe.write("AKT");
					ausgabe.write(rbTextFormat.format(' ',14,sAbNr));
					ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("kom_abnr")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("kom_art_nr")));
					ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("akt_text_pos")));
					ausgabe.write(rbTextFormat.format(' ',50,rs.getString("akt_text"))+"\n");
				}
				
			}
			stmt.close();
			stmtLauf.close();	
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

	                                                  	

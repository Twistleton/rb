package com.rolfbenz;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.DecimalFormat;

public class vsDatei extends basisDatei {
	// Konstruktoren
	public vsDatei() {
	}
    	public vsDatei(String iPfad) {
		super(iPfad);
	}
	public vsDatei(String iPfad, String iDateiname, String iEndung) {
		super(iPfad,iDateiname,iEndung);
	}
	public vsDatei(File iPfad) {
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

	public int vsPapiere(int abNr,Connection con) {
		try {
			String sql        = new String();
			Statement stmt      = con.createStatement();
			ResultSet rs;
			ausgabe.write("ABVS");
			ausgabe.write("\n");

			/* ************     Auftragskopfdaten       *************** */
			sql  = "SELECT ";
			sql += "ako_abnr,ako_fabt_pps,ako_prog, ";
			sql += "ako_prior,ako_se,ako_fabt_zuschn,ako_sf_hw_auftr,ako_werk_zuschn, ";
			sql += "ako_werk_naht,ako_werk_polst,ako_aart1,ako_aart2,ako_aart3, ";
			sql += "ako_bnr3,ako_vlte,ako_sb_tnr,ako_kunde,ako_vpkz, ako_vlz, ako_lfg, ako_kz_pg, ako_pos_lfg ";
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
                ausgabe.write(rbTextFormat.format(' ', 7,rs.getString("ako_kunde")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_werk_naht")));
				ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ako_lfg")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ako_kz_pg")));
                ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ako_sf_hw_auftr")));
                ausgabe.write(rbTextFormat.format(' ',24," "));
                ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ako_pos_lfg")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ako_aart1")));
                ausgabe.write(rbTextFormat.format(' ', 2, rs.getString("ako_aart2")));
                ausgabe.write(rbTextFormat.format(' ', 2, rs.getString("ako_aart3")));
                ausgabe.write(rbTextFormat.format(' ', 3, rs.getString("ako_sb_tnr")));
                ausgabe.write(rbTextFormat.format(' ', 1, rs.getString("ako_vpkz"))+ "\n");
			}
			rs.close();

            /* ************     Liefertexte      *************** */

				sql  = "SELECT ";
				sql += "lft_abnr,lft_laddr1,lft_laddr2,lft_laddr3,lft_laddr4,lft_kdkomm,lft_kdabnr, ";
                sql += "lft_gewicht, lft_volumen, lft_anz_colli ";
				sql += "FROM plrv11.plr_lf_texte ";
				sql += "INNER JOIN plrv11.plr_auftr_status ON lft_abnr=as_abnr AND lft_aend_ix=as_aend_ix ";
				sql += "WHERE lft_abnr = "+abNr;
				sql += " ORDER BY lft_abnr";

				stmt.executeQuery(sql);
				rs = stmt.getResultSet();

				while (rs.next()) {
					ausgabe.write("LFT");
					ausgabe.write(rbTextFormat.format(' ', 6,abNr));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr1")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr2")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr3")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_laddr4")));
					ausgabe.write(rbTextFormat.format(' ',32,rs.getString("lft_kdkomm")));
					ausgabe.write(rbTextFormat.format(' ',10,rs.getString("lft_kdabnr")));
					ausgabe.write(rbTextFormat.format('0', 7,rs.getString("lft_gewicht")));
					ausgabe.write(rbTextFormat.format('0', 7,rs.getString("lft_volumen")));
					ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("lft_anz_colli")) + "\n");
				}

            rs.close();

            /* ***********    Auftragspositionen **************** */
            sql = "select   ap_abnr                             " +
                    "     , ap_posnr                            " +
                    "     , ap_artnr                            " +
                    "     , ap_menge                            " +
                    "     , ap_me                               " +
                    "     , ap_bezeichn                         " +
                    "     , ap_bezug                            " +
                    "     , ap_bezbez                           " +
                    "     , ap_vera_hw                          " +
                    "     , ap_schw_grad                        " +
                    "     , ap_holz_farbe                       " +
                    "     , ap_sf_hw                            " +
                    "     , ap_status                           " +
                    "     , ap_klasse                           " +
                    "     , ap_menge_netto                      " +
                    "     , ap_menge_sort1                      " +
                    "     , ap_menge_sort2                      " +
                    "     , ap_menge_sort3                      " +
                    "     , ap_menge_brutto                     " +
                    "     , ap_anz_kiss                         " +
                    "     , ap_anz_ld                           " +
                    "     , ap_anz_st                           " +
                    "     , ap_garn                             " +
                    "     , ap_rv                               " +
                    "     , ap_koeper                           " +
                    "     , ap_kz_bart3                         " +
                    "     , ap_bnr3                             " +
                    "     , ap_syn                              " +
                    "     , ap_kzbs                             " +
                    "     , ap_se                               " +
                    "     , ap_sai                              " +
                    "     , ap_gewicht                          " +
                    "     , ap_volumen                          " +
                    "     , ap_anz_colli                        " +
                    "     , ap_menge_cutter                     " +
                    " from plrv11.plr_art_pos                   " +
            "INNER JOIN plrv11.plr_auftr_status ON ap_abnr=as_abnr AND ap_aend_ix=as_aend_ix " +
                    "WHERE ap_abnr=" + abNr +
                    "  AND as_status<>99 " +
                    " ORDER BY ap_posnr";

			stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
				ausgabe.write("APO");
				ausgabe.write(rbTextFormat.format(' ', 6,rs.getString("ap_abnr")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_posnr")));
				ausgabe.write(rbTextFormat.format(' ', 7,rs.getString("ap_menge")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ap_bezeichn")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("ap_artnr")));
				ausgabe.write(rbTextFormat.format(' ',10,rs.getString("ap_bezug")));
				ausgabe.write(rbTextFormat.format(' ', 2,rs.getString("ap_vera_hw")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_schw_grad")));
				ausgabe.write(rbTextFormat.format(' ', 3,rs.getString("ap_holz_farbe")));
				ausgabe.write(rbTextFormat.format(' ',24,rs.getString("ap_bezbez")));
				ausgabe.write(rbTextFormat.format(' ', 1,rs.getString("ap_klasse")) + "\n");
			}
			rs.close();

			/* ************     Kollidaten       *************** */
			sql  = "SELECT kl_abnr          " +
                   "     , kl_abpos         " +
                   "     , kl_kolli_nr      " +
                   "     , kl_vol           " +
                   "     , kl_laenge        " +
                   "     , kl_breite        " +
                   "     , kl_hoehe         " +
                   "     , kl_durchm        " +
                   "     , kl_bez           " +
                   "     , kl_kartnr        " +
                   "     , kl_lief          " +
                   "     , kl_ean           " +
                   "     , kl_kz_druck      " +
			       " FROM plrv11.plr_kolli  " +
			 " INNER JOIN plrv11.plr_auftr_status ON kl_abnr  = as_abnr AND as_aend_ix = kl_aend_ix " +
			 "      WHERE as_status <>99    " +
			 "        AND kl_abnr="+abNr      + 
			 "      ORDER BY 1, 2, 3 ";

            stmt.executeQuery(sql);
			rs = stmt.getResultSet();
			while (rs.next()) {
                ausgabe.write("AKD");
                ausgabe.write(rbTextFormat.format(' ',  6, rs.getString("kl_abnr")));
                ausgabe.write(rbTextFormat.format('0',  2, rs.getString("kl_abpos")));
                ausgabe.write(rbTextFormat.format('0',  4, rs.getString("kl_kolli_nr")));

                DecimalFormat df1 = new DecimalFormat("000.000");
                ausgabe.write(rbTextFormat.format('0', 7, df1.format(rs.getFloat("kl_vol"))));

                DecimalFormat df2 = new DecimalFormat("0.000");
                ausgabe.write(rbTextFormat.format('0',  5, df2.format(rs.getFloat("kl_laenge"))));
                ausgabe.write(rbTextFormat.format('0',  5, df2.format(rs.getFloat("kl_breite"))));
                ausgabe.write(rbTextFormat.format('0',  5, df2.format(rs.getFloat("kl_hoehe"))));
                ausgabe.write(rbTextFormat.format('0',  5, df2.format(rs.getFloat("kl_durchm"))));
                ausgabe.write(rbTextFormat.format(' ', 24, rs.getString("kl_bez")));
                ausgabe.write(rbTextFormat.format(' ', 10, rs.getString("kl_kartnr")));
                ausgabe.write(rbTextFormat.format(' ', 10, rs.getString("kl_lief")));
                ausgabe.write(rbTextFormat.format(' ', 20, rs.getString("kl_ean")));
                ausgabe.write(rbTextFormat.format(' ',  1, rs.getString("kl_kz_druck"))+"\n");

			}
			rs.close();

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

package com.rolfbenz;

import java.sql.*;
import java.io.*;


public class sammelAuftrag {
	public static int istZbl(Connection con, long sAbNr) {
		try {
			String sql = new String();
			Statement stmt = con.createStatement();
			ResultSet rs;
			int i=0;
			sql  = "SELECT sak_zbl FROM plrv11.zus_sammel_kopf ";
			sql += "WHERE sak_sanr="+sAbNr+" AND sak_zbl='J'";
			rs = stmt.executeQuery(sql);
			while (rs.next()) {
				i++;
			}
			rs.close();
			stmt.close();
			if (i>0) {
				return(1);
			} else {
				return(0);
			}
		}
		catch (Exception e) {
			e.printStackTrace();
			return(-1);
		}
	}
	public static int zblDeziSetzen(Connection con,long sAbNr) {
		try {
			String    sql = new String();
			Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_UPDATABLE);
			File datei = new File("/tmp/doppelkunz.tmp");
			FileOutputStream   ausgabeStrom = new FileOutputStream(datei);
			OutputStreamWriter ausgabe      = new OutputStreamWriter(ausgabeStrom,"ISO-8859-1");

			ResultSet rs;
			float wert=0;
			float faktor=1;
			int zsSys=0;
			int iWert=0;

			// Zuschnittsystem des Sammelauftrags ermitteln
			sql = "SELECT sak_zs_sys FROM plrv11.zus_sammel_kopf WHERE sak_sanr="+sAbNr;
			rs = stmt.executeQuery(sql);
			while (rs.next()) {
				zsSys = rs.getInt("sak_zs_sys");
			}
			rs.close();

			if (istZbl(con,sAbNr)==1) {
				// zbl-Faktor für das Zuschnittsystem ermitteln
				sql = "SELECT att_bez FROM plrv11.plr_attrAttr WHERE att_TabName='zblZuschl' AND att_Attr="+zsSys;
				rs = stmt.executeQuery(sql);
				while (rs.next()) {
					faktor = Float.parseFloat(rs.getString("att_bez"));
				}
				rs.close();
				ausgabe.write("ist ein ZBL\n");
			} else {
				ausgabe.write("kein ZBL\n");
			}
			ausgabe.write("ausgelesener Faktor fuer das ZS-Sys "+String.valueOf(zsSys)+" :"+String.valueOf(faktor)+"\n");	
			
			if (zsSys!=0) {
				// Zuerst nochmal alles zurücksetzen, falls der Auftrag umgeplant wird
				sql  = "UPDATE plrv11.zus_kom_fs SET kfs_dezi=(kfs_tr+kfs_te) WHERE ";
				sql += "kfs_fs IN (10244100001,10244100002,10244100003,10244100004) ";
				sql += " AND kfs_abnr  IN (SELECT kom_abnr   FROM plrv11.zus_kommission WHERE kom_sammel_abnr="+sAbNr+")";
				sql += " AND kfs_artnr IN (SELECT kom_art_nr FROM plrv11.zus_kommission WHERE kom_sammel_abnr="+sAbNr+")";
				stmt.executeUpdate(sql);

				// Alle Kommissionsfertigungsstufen dieses Sammelauftrags Updaten (Dezi)
				sql  = "SELECT kfs_fs,kfs_tr,kfs_te,kfs_dezi ";
				sql += "FROM plrv11.zus_kom_fs ";
				if (zsSys==10) {
					sql += "WHERE kfs_fs IN (10244100001,10244100002,10244100003) ";
				} else {
					sql += "WHERE kfs_fs IN (10244100001,10244100002,10244100003,10244100004) ";
				}
				sql += " AND kfs_abnr  IN (SELECT kom_abnr   FROM plrv11.zus_kommission WHERE kom_sammel_abnr="+sAbNr+")";
				sql += " AND kfs_artnr IN (SELECT kom_art_nr FROM plrv11.zus_kommission WHERE kom_sammel_abnr="+sAbNr+")";
				stmt.executeQuery(sql);
				rs = stmt.getResultSet();
				while (rs.next()) {
					wert = (float) rs.getInt("kfs_tr") + (float) rs.getInt("kfs_te");
					wert = wert * faktor;
					iWert= (int) Math.round(wert);
					ausgabe.write("TR : "+ rs.getInt("kfs_tr")+"\n");	
					ausgabe.write("TE : "+ rs.getInt("kfs_te")+"\n");	
					ausgabe.write("Errechneter Wert : "+ iWert +"\n");	
					rs.updateInt("kfs_dezi",iWert);
					rs.updateRow();
				}
				rs.close();
				stmt.close();
			} else {
				stmt.close();
			}
			
			ausgabe.flush();
			ausgabe.close();
			ausgabeStrom.close();
			return(1);	
		}
		catch (Exception e) {
			e.printStackTrace();
			return(-1);
		}
	}
}

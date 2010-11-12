package com.sira;

import java.io.*;
import java.sql.*;

public class komDruckDatei extends basisDatei {
	// Konstruktoren
	public komDruckDatei() {
	}
    	public komDruckDatei(String iPfad) {
		super(iPfad);
	}
	public komDruckDatei(String iPfad, String iDateiname, String iEndung) {
		super(iPfad,iDateiname,iEndung);
	}
	public komDruckDatei(File iPfad) {
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
	public int dateiAusgabe(String sqlString,Connection con) {
		String tempString = new String();
		String aktSql     = new String();		
		int zaehler = -1;
		int abNr    =  0;
		int altAbNr =  0;
		aktSql = "SELECT akt_text " +
			" FROM plrv11.plr_ak_texte,plrv11.plr_auftr_status " +
			" WHERE akt_abnr=as_abnr AND akt_aend_ix=as_aend_ix AND " +
			" as_status<>99 AND akt_text_art='2' AND akt_abnr=";
		try {
			Statement stmt = con.createStatement();
			Statement stmtAkt = con.createStatement();
			ResultSet rs;
			ResultSet rsAkt;
			ResultSetMetaData rsmd;
			stmt.executeQuery(sqlString);
			rs = stmt.getResultSet();
			rsmd = rs.getMetaData();
			zaehler=0;
			while (rs.next()) {
				zaehler++;
				for  (int lauf=1;lauf<=rsmd.getColumnCount();lauf++) {
					tempString = rbTextFormat.format(' ',rsmd.getPrecision(lauf),rs.getString(lauf));
					ausgabe.write(tempString +"|");
					// Wir merken uns mal die Auftragsnummer
					if (lauf==2) {
						abNr = rs.getInt(lauf);
					}
				}
				
				ausgabe.write("\n");
				if ((abNr!=altAbNr) && (altAbNr>0)) {
					// Die AbNr hat sich veraendert)
					stmtAkt.executeQuery(aktSql+abNr+" ORDER BY akt_text_pos");
					rsAkt = stmtAkt.getResultSet();
					while (rsAkt.next()) {
						ausgabe.write("AKT"+rsAkt.getString("akt_text")+"\n");	
					}
				}
				altAbNr=abNr;
			}
		}
		catch(Exception e) {
			e.printStackTrace();
			return(-1);
		}
		return(zaehler);
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

	                                                  	

package com.rolfbenz;
import java.util.*;

public class dbConfigDatei extends configDatei {
	private String dbname     = new String("");
	private String dbip       = new String("");
	private int    dbport     = 0;
	private String dbuser     = new String("");
	private String dbpass     = new String("");

	public dbConfigDatei() {
	}
	public dbConfigDatei(String dname) {
		super(dname);
	}
	public String getDbName() {
		return dbname;
	}
	public String getDbIp() {
		return dbip;
	}
	public String getDbUser() {
		return dbuser;
	}
	public int getDbPort() {
		return dbport;
	}
	public String getDbPass() {
		return dbpass;
	}
	public String verarbeiten() {
		super.einlesen();
		String retString = new String();		
		// Auswerten der Config-Datei
		StringTokenizer st = new StringTokenizer(inhalt,"\n");
		String aktToken = new String();
		while (st.hasMoreTokens()) {
			aktToken=st.nextToken();
			if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("dbname")==0) {
				dbname = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("dbip")==0) {
				dbip =  aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("dbport")==0) {
				try {
					dbport = Integer.parseInt(aktToken.substring(aktToken.indexOf(":")+1));
				}
				catch(NumberFormatException nfe) {
					retString += "DB-Port muss vom Typ Integer sein\n";
				}
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("dbuser")==0) {
                                dbuser = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("dbpass")==0) {
				dbpass = aktToken.substring(aktToken.indexOf(":")+1);
			} 
		}
		return retString;
	}
}

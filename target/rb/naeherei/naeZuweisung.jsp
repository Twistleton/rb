<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>Naeherei Selbstzuweisung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <META HTTP-EQUIV="refresh" CONTENT="2; URL=naeEin.jsp">
</HEAD>
<BODY BGCOLOR="#CCCCCC">
<CENTER>
<CENTER>
    <%
bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");	 
bdeConfigDatei bcd = new bdeConfigDatei("/etc/bdeServlet.conf");
bcd.verarbeiten();
Connection  con = oraBde.getConnection();

con.setAutoCommit(false);

Statement stmt = con.createStatement();
ResultSet rs;
int fehler   = 0;
long fs      = 0;
int abNr     = 0;
int maPNr    = 0;
int fsStatus = 0;
int j        = 0;
int maPIN    = 0;
int aendIx   = 0;
long maPlatz = 0;

String sqlString     = new String();
String ausgabe       = new String();
String fehlerMeldung = new String();
String ppPfPlatz     = new String();

boolean neuzuweis = false;
int pufferZaehler =0;
int aktive   =0;
int zugeteilt=0;

try {
	if(request.getParameter("neuzuweis").compareTo("true")==0) {
		neuzuweis = true;
	} else {
		neuzuweis = false;
	}
}
catch (NullPointerException npe) {
	neuzuweis = false;
}
try {
	fsStatus = Integer.parseInt(request.getParameter("status"));
}
catch(NumberFormatException nfe) {
	fsStatus=0;
	if (neuzuweis==true) {
		ausgabe += "Es wird NUR ein neuer Auftrag zugewiesen.<BR>";
	} else {
		fehlerMeldung = "<IMG SRC=\"./warndreieck.gif\" align=\"middle\">Es wurde kein Status ausgewählt.";
		fehler = 1;
	}
}
try {
	maPNr = Integer.parseInt(request.getParameter("pNr"));
	abNr  = Integer.parseInt(request.getParameter("abNr"));
	fs    = Long.parseLong(request.getParameter("fs"));
}
catch(NumberFormatException nfe) {
	nfe.printStackTrace();
}
if (fsStatus!=0) {
	// Alten Auftrag abfertigen
	sqlString = "SELECT as_aend_ix FROM plrv11.plr_auftr_status WHERE as_status<>99 AND as_abnr="+request.getParameter("abNr");
	stmt.executeQuery(sqlString);
	rs = stmt.getResultSet();
	while (rs.next()) {
		aendIx = rs.getInt("as_aend_ix");
	}

	// Puffer freiräumen nicht nötig, da hier Auftrag dem MA bereits zugewiesen ist
	// ab_fs_ma aktualisieren
	sqlString = "UPDATE plrv11.bde_ab_fs_ma SET abf_fs_status="+fsStatus+
		" WHERE abf_abnr="+request.getParameter("abNr")+
		" AND abf_fs='"+request.getParameter("fs")+"'";
	ausgabe +="<BR>";
	stmt.executeQuery(sqlString);

	// 06.12.2002 (Nikolaus!!) Druckkennzeichen gesetzt ==> Papiere drucken und Puffer freiräumen
	if (request.getParameter("druck").compareTo("y")==0) {
		// Pufferplatz des Auftrags suchen
		sqlString = "SELECT pp_pf_platz FROM plrv11.bde_pufpl WHERE pp_fs='"+fs+"' AND pp_abnr="+abNr+" AND pp_kz='J'";
		stmt.executeQuery(sqlString);
		rs = stmt.getResultSet();
		pufferZaehler=0;
		while (rs.next()) {
			ppPfPlatz = rs.getString("pp_pf_platz");
			pufferZaehler++;
		}
		// Puffer auf dem der Auftrag Stand auf leer setzen	
		sqlString = "UPDATE plrv11.bde_pufpl SET pp_kz='N' WHERE  pp_pf_platz='"+ppPfPlatz+"'";
		stmt.executeUpdate(sqlString);	
		ausgabe += "Puffer wurde geleert.<BR>";

		// Arbeitspapiere des neuen Auftrages erstellen
		naehPapDatei npd = new naehPapDatei(bcd.getNapDir()+"/"+bdeZeit.getTimestamp("yyMMddHHmmssSSS")+".nap");
		npd.setDb(oraBde);
		npd.druckeDatei(bcd,abNr,maPNr,ppPfPlatz);
	}
	// Eintrag in Meldezeiten vornehmen
	sqlString = "INSERT INTO plrv11.bde_ab_mz (abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto) "+
		"VALUES ("+abNr    +
		","       +aendIx  +
		",'"      +fs  +
		"',"      +fsStatus +
		",'"      +bdeZeit.getTimestamp("yyMMddHHmm") +
		"',"      +maPNr +
		",10,'N')";
	stmt.executeQuery(sqlString);

	// Datei schreiben für Uwe
	// Bemelden des Auftrags (alt)
	bdeDatei bdeDat = new bdeDatei(bcd.getVomNaeDir()+"/"+bdeZeit.getTimestamp("yyMMddHHmmssSSS")+".bde");
	int i=0;
	i = bdeDat.oeffnen();
	i+= bdeDat.setVonSubsystem(5);
	i+= bdeDat.setNachSubsystem(2);
	i+= bdeDat.setEreignisAktion("E001");
	i+= bdeDat.setPaketFolgeNr(90);
	i+= bdeDat.setAuftragsNr(abNr);
	i+= bdeDat.setInternerVorgang("AD");
	i+= bdeDat.setBezogenesSubsystem(5);
	i+= bdeDat.setNeuPersonalNr(maPNr);
	i+= bdeDat.setFertigungsstufe(fs);
	i+= bdeDat.setFsStatus(fsStatus);
	i+= bdeDat.setFsSplit('N');
	if (i!=0) {
		ausgabe +="Fehler beim erstellen der BDE-Datei<BR>";
	}
	bdeDat.setNameTimestamp("yyMMddHHmmssSSS");
	bdeDat.schreibeSatz();
	bdeDat.schreibeEndeSatz();
	bdeDat.schliessen();
	bdeDat.aktiviereDatei();
}

// Wenn Neuzuweisung ausgewählt wurde...
try {
	if (request.getParameter("neuzuweis").compareTo("true")==0) {
		fsStatus=0;
		// Hier muss noch überprüft werden, ob der MA bereits zugeteilte Aufträge hat!
		sqlString  = "SELECT";
		sqlString += " abf_abnr,abf_aend_ix,abf_fs,abf_prog,abf_pnr,abf_fs_status,ma_ap";
		sqlString += " FROM";
		sqlString += " plrv11.bde_ab_fs_ma ";
		sqlString += " INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr  AND abf_aend_ix=as_aend_ix ";
		sqlString += " INNER JOIN plrv11.plr_subsys_kopf  ON sko_abnr=abf_abnr AND sko_aend_ix=as_aend_ix ";
		sqlString += " INNER JOIN plrv11.bde_madat        ON ma_pnr=abf_pnr ";
		sqlString += " WHERE as_status<>99 "; // Einschränkung des Änderungs-Status
		sqlString += " AND sko_subsys=4 AND sko_logsys=4 "; // Termin spätester Start Nähen 
		sqlString += " AND abf_pnr="+request.getParameter("pNr"); // Einschränkung auf Mitarbeiter
		sqlString += " AND abf_fs_status>1 AND abf_fs_status<40 ";
		sqlString += " ORDER BY abf_fs_status,sko_fabt,sko_uhrzeit";
		stmt.executeQuery(sqlString);
		rs = stmt.getResultSet();
		j=0;
		while (rs.next()) {
			if ((rs.getInt("abf_fs_status")==10)||(rs.getInt("abf_fs_status")==30)) {
				// Es gibt noch aktive Aufträge
				aktive = 1;
			}
			if (rs.getInt("abf_fs_status")==5) {
				// Es gibt zugewiesene Aufträge
				if (zugeteilt==0) {
					// Der erste zugewiesene Auftrag in der Sortierreihenfolge soll verwendet werden
					zugeteilt = 1;
					abNr     = rs.getInt("abf_abnr");
					fs       = rs.getLong("abf_fs");
					fsStatus = rs.getInt("abf_fs_status");
					aendIx   = rs.getInt("abf_aend_ix");
					maPlatz  = rs.getLong("ma_ap");
				}
				j++;
			}
		}
		// Wenn keine aktiven mehr da sind und keiner zugeteilt ist
		if ( (aktive==0) && (zugeteilt==0) ) {
			// Es wurden keine zugewiesene Aufträge gefunden
			
			// Alle Aufträge des MA sind beendet oder in Störung
			// es soll ein Neuer Auftrag zugewiesen werden
			sqlString  = "SELECT abf_abnr,abf_fs,abf_fs_status,abf_prog,sko_fabt,sko_uhrzeit,ap_platznr,ap_fs,abf_aend_ix,ma_ap ";
			sqlString += " FROM ";
			sqlString += " plrv11.bde_ab_fs_ma,";
			sqlString += " plrv11.bde_ma_prog,";
			sqlString += " plrv11.bde_madat,";
			sqlString += " plrv11.bde_apdat,";
			sqlString += " plrv11.plr_subsys_kopf,";
			sqlString += " plrv11.plr_auftr_status ";
			sqlString += " WHERE abf_fs_status<5";
			sqlString += " AND abf_prog=map_prog AND abf_fs=map_fs "; // Einarbeitung des Mitarbeiters
			sqlString += " AND ma_pnr=map_pnr AND ma_ap=ap_platznr AND map_pnr="+ request.getParameter("pNr");// AP somit FS des MA
			sqlString += " AND sko_abnr=abf_abnr ";                                                  // Näherei-Termin des Auftrags
			sqlString += " AND sko_aend_ix=as_aend_ix AND sko_subsys=4 AND sko_logsys=4 ";           // Näherei-Termin des Auftrags
			sqlString += " AND as_abnr=abf_abnr AND as_aend_ix = abf_aend_ix AND as_status <> 99 ";  // Gueltiger Aenderungs-Index
			sqlString += " AND abf_pf_status>=40 ";
			sqlString += " ORDER BY sko_fabt, sko_uhrzeit";
			stmt.executeQuery(sqlString);
			rs = stmt.getResultSet();
			// Ersten Auftrag aus der Liste auswählen
			while ( (rs.next()) && (j==0)){
				abNr     = rs.getInt("abf_abnr");
				fs       = rs.getLong("abf_fs");
				aendIx   = rs.getInt("abf_aend_ix");
				fsStatus = rs.getInt("abf_fs_status");
				maPlatz  = rs.getLong("ma_ap");
				j++;
			}
		}
		if ((aktive==0) && (j>0)) {
			// Hier MUSS ein Neuer Auftrag gefunden worden sein
			ausgabe +="Ihr neuer Auftrag:<FONT COLOR=green><B>"+abNr+"</B></FONT><BR>";
			// Status der Auftrages auf gestartet (10) setzen
			fsStatus=10;
			sqlString  = "UPDATE plrv11.bde_ab_fs_ma";
			sqlString += " SET abf_fs_status=10,";
			sqlString += " abf_pnr="+request.getParameter("pNr");
			sqlString += " WHERE abf_abnr="+abNr;
			sqlString += " AND   abf_fs='"+fs;
			sqlString += "' AND  abf_aend_ix="+aendIx;
			stmt.executeQuery(sqlString);	
			ausgabe += "Status des Auftrags wurde erhöht<BR>";
			
			// Bemelden des Auftrags (neu)
			// Eintrag in Meldezeiten vornehmen
			sqlString  = "INSERT INTO plrv11.bde_ab_mz";
			sqlString += " (abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto)";
			sqlString += " VALUES ("+abNr;
			sqlString += ","       + aendIx;
			sqlString += ",'"      + fs;
			sqlString += "',"      + fsStatus;
			sqlString += ",'"      + bdeZeit.getTimestamp("yyMMddHHmm");
			sqlString += "',"      + maPNr;
			sqlString += ",10,'N')";
			stmt.executeQuery(sqlString);

			// Melde-Datei an Uwe senden
			bdeDatei bdeDat = new bdeDatei(bcd.getVomNaeDir()+"/"+bdeZeit.getTimestamp("yyMMddHHmmssSSS")+".bde");
			int i=0;	
			i = bdeDat.oeffnen();
			i+= bdeDat.setVonSubsystem(5);
			i+= bdeDat.setNachSubsystem(2);
			i+= bdeDat.setEreignisAktion("E001");
			i+= bdeDat.setPaketFolgeNr(90);
			i+= bdeDat.setAuftragsNr(abNr);
			i+= bdeDat.setInternerVorgang("AD");
			i+= bdeDat.setBezogenesSubsystem(5);
			i+= bdeDat.setPersonalNr(maPNr);
			i+= bdeDat.setFertigungsstufe(fs);
			i+= bdeDat.setFsStatus(fsStatus);
			i+= bdeDat.setFsSplit('N');
			if (i!=0) {
				ausgabe +="Fehler beim Erstellen der BDE-Datei";
			}
			bdeDat.setNameTimestamp("yyMMddHHmmssSSS");
			bdeDat.schreibeSatz();
			bdeDat.schreibeEndeSatz();
			bdeDat.schliessen();
			bdeDat.aktiviereDatei();

			// Pufferplatz des Auftrags suchen
			sqlString = "SELECT pp_pf_platz FROM plrv11.bde_pufpl WHERE pp_fs='"+fs+"' AND pp_abnr="+abNr+" AND pp_kz='J'";
			stmt.executeQuery(sqlString);
			rs = stmt.getResultSet();
			pufferZaehler=0;
			while (rs.next()) {
				ppPfPlatz = rs.getString("pp_pf_platz");
				pufferZaehler++;
			}
			
			// Puffer auf dem der Auftrag Stand auf leer setzen	
			sqlString = "UPDATE plrv11.bde_pufpl SET pp_kz='N' WHERE  pp_pf_platz='"+ppPfPlatz+"'";
			stmt.executeUpdate(sqlString);	
			ausgabe += "Puffer wurde geleert.<BR>";
			
			// Arbeitspapiere des neuen Auftrages erstellen
			naehPapDatei npd = new naehPapDatei(bcd.getNapDir()+"/"+bdeZeit.getTimestamp("yyMMddHHmmssSSS")+".nap");

			npd.setDb(oraBde);
			if (String.valueOf(maPlatz).substring(0,2).compareTo("22")==0) {
				ausgabe += "Sesselfertigung<BR>";
				npd.druckeDatei(bcd,abNr,maPNr,ppPfPlatz,bcd.getSesselDrucker());
			} else {
				ausgabe += "Normal<BR>";
				npd.druckeDatei(bcd,abNr,maPNr,ppPfPlatz,bcd.getNaeDrucker());
			}

			ausgabe += "Neuzuweisung erfolgreich";
		} else {
			ausgabe += "<B>keine weiteren Aufträge vorhanden bzw. noch Auftr&auml;ge in Arbeit</B><BR>";
			fehler = 1;
		}
	}
}
catch (NullPointerException npe) {
	ausgabe += "Sie bekommen <B>keinen</B> neuen Auftrag zugewiesen<BR>";
	fehler   = 1;
}
out.println(ausgabe);
ausgabe +="</CENTER>";
con.commit();
%>
<FORM ACTION="naeEin.jsp" METHOD="POST">
    <INPUT TYPE="SUBMIT" NAME="OK" VALUE="Weiter">
</FORM>
</BODY>
</HTML>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>Naeherei Selbstzuweisung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
        <%
bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");	 
zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
zcd.verarbeiten();
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

String sqlString     = new String();
String ausgabe       = new String();
String fehlerMeldung = new String();

// Auswerten der Eingabe
try {	
	fs = Long.parseLong(request.getParameter("fs"));
} 
catch(NumberFormatException nfe) {
}
try {	
	abNr  = Integer.parseInt(request.getParameter("abNr"));
}
catch(NumberFormatException nfe){
	abNr=0;
}
try {	
	maPNr = Integer.parseInt(request.getParameter("pNr")); // Das schafft er halt manchmal nicht
} 
catch(NumberFormatException nfe) {
	maPNr =0;
}

if ((maPNr==0) && (abNr!=0)) {
	// Selbstzuweisung, alter Auftrag vorhanden
	// Ab-Nr Prüfen, wenn diese AB-Nummer auf dieser FS nicht vorhanden ist oder einen "falschen" Status hat ==> zurück mit Fehlermeldung
	sqlString = "SELECT abf_abnr,abf_fs,abf_fs_status,abf_pnr FROM plrv11.bde_ab_fs_ma,plrv11.plr_auftr_status WHERE "+
		"abf_abnr="    +abNr+
		" AND abf_fs='" +fs  +
		"' AND abf_abnr = as_abnr "+
		" AND as_status<>99 "+
		" AND abf_aend_ix=as_aend_ix";
	stmt.executeQuery(sqlString);
	rs = stmt.getResultSet();
	j=0;
	while (rs.next()) {
		fsStatus = rs.getInt("abf_fs_status");
		maPNr    = rs.getInt("abf_pnr");
		j++;
	}
	if ((j!=1) || ((fsStatus<5) || (fsStatus>30))) {
		fehlerMeldung = "<IMG SRC=\"./warndreieck.gif\" align=\"middle\">Auftrags-Nummer nicht vorhanden oder nicht g&uuml;ltig.";
		fehler = 1;
	}
	if (j>1) {
		ausgabe +="<B>Selbstzuweisung, alter Auftrag vorhanden</B><BR>\n";
	}
	
} else if ((maPNr!=0) && (abNr==0)){
	// Anmeldung überprüfen, wenn fehlerhaft angemeldet, dann Zurück zu Eingabemaske
	sqlString = "SELECT ma_pnr,ma_pin,ma_recht FROM plrv11.bde_madat WHERE ma_pnr=" + maPNr;
	stmt.executeQuery(sqlString);
	rs = stmt.getResultSet();
	j=0;
	while (rs.next()) {
		maPIN = rs.getInt("ma_pin");
		j++;
	}
	rs.close();
	if ((j!=1) || (request.getParameter("pin").compareTo(String.valueOf(maPIN))!=0) ) {
		fehlerMeldung = "<IMG SRC=\"./warndreieck.gif\" align=\"middle\">Falscher Benutzername/Passwort - Ungültige Kostenstelle";
		fehler = 1;
	}
	if ((request.getParameter("abNr").compareTo("")==0) && (fehler==0)) {
		// Selbstzuweisung, kein alter Auftrag vorhanden
		ausgabe +="Selbstzuweisung, kein alter Auftrag<BR>\n";
		// Überprüfen, ob dieser Mitarbeiter noch aktive Aufträge im Pool hat
		sqlString = "SELECT abf_abnr,abf_aend_ix,abf_pnr,abf_fs_status FROM plrv11.bde_ab_fs_ma,plrv11.plr_auftr_status ";
		sqlString+= "WHERE abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix AND as_status<>99 AND ";
		sqlString+= " abf_fs_status IN (10,30) AND abf_pnr="+maPNr;
		stmt.executeQuery(sqlString);
		rs = stmt.getResultSet();
		while (rs.next()) {
			fehlerMeldung  ="<IMG SRC=\"./warndreieck.gif\" align=\"middle\">";
			fehlerMeldung +="Sie haben noch aktive Aufträge.<BR>Auftrag: "+rs.getString("abf_abnr");
			fehler = 1;
		}
	}
} else if ((maPNr!=0) && (abNr!=0)){
        fehler=1;
	ausgabe += "Bitte entweder Auftrags-Nr ODER Personal-Nr/PIN eingeben!";
}


if (((maPNr==0)&& (abNr==0)) || (fehler==1)) {
	out.println("</HEAD><BODY BGCOLOR=\"#CCCCCC\" onLoad=\"document.form.abNr.focus();\"><CENTER>");
	out.println(ausgabe);
	out.println(fehlerMeldung);
	out.println("<H2>Statusmeldung N&auml;herei</H2>");
	out.println("<FORM name=\"form\" METHOD=\"POST\">");
	out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"formular\" VALUE=\"selbstAus\">");
	out.println("<TABLE BORDER=1>");
	out.println("<TR><TD>Auftragsnummer</TD><TD ALIGN=\"right\">");
	out.println("<INPUT TYPE=\"TEXT\"     NAME=\"abNr\" SIZE=\"6\"  MAXLENGTH=\"6\" onChange=\"document.form.submit();\"></TD></TR>");
	out.println("<INPUT TYPE=\"hidden\"   NAME=\"fs\"   VALUE=\"10243100000\">");
	out.println("<TR><TD>Personal-Nr.  </TD><TD ALIGN=\"right\">");
	out.println("<INPUT TYPE=\"TEXT\"     NAME=\"pNr\"  SIZE=\"4\"  MAXLENGTH=\"4\" ></TD></TR>");
	out.println("<TR><TD>PIN           </TD><TD ALIGN=\"right\">");
	out.println("<INPUT TYPE=\"password\" NAME=\"pin\"  SIZE=\"4\"  MAXLENGTH=\"4\" onChange=\"document.form.submit();\"></TD></TR>");
	out.println("<TR><TD COLSPAN=\"2\" ALIGN=\"CENTER\"><INPUT TYPE=\"SUBMIT\" VALUE=\"OK\"></TD></TR></FORM>");
	out.println("</TABLE>");
} else {	
	out.println("</HEAD><BODY BGCOLOR=\"#CCCCCC\" onLoad=\"document.form.ok.focus();\"><CENTER>");
	out.println(ausgabe);
	out.println("<FORM ACTION=\"naeZuweisung.jsp\" NAME=\"form\" METHOD=\"GET\" >\n");
	out.println("<INPUT TYPE=\"hidden\" NAME=\"formular\" VALUE=\"neuzuweis\">\n");
	out.println("<INPUT TYPE=\"hidden\" NAME=\"abNr\"     VALUE=\""+abNr+"\">\n");
	out.println("<INPUT TYPE=\"hidden\" NAME=\"fs\"       VALUE=\""+fs+"\">\n");
	out.println("<INPUT TYPE=\"hidden\" NAME=\"pNr\"      VALUE=\""+maPNr+"\">\n");
	out.println("<B>Aktive Personal-Nummer:</B>  "+maPNr +"<BR>\n");
	out.println("<B>Aktive Fertigungs-Stufe:</B> "+fs+"<BR>\n");
	out.println("<TABLE BORDER=\"1\">\n");

	// Je nach Status muss hier Stoerung bzw. Stoerung ende eingeblendet werden
	if ((fsStatus==1) || (fsStatus==5))   
		out.println("<TR BGCOLOR=#ddffdd><TD><input type=radio name=\"status\" value=\"10\" checked>Start</TD></TR>\n");
	if (fsStatus==10)
		out.println("<TR BGCOLOR=#ffdddd><TD><input type=radio name=\"status\" value=\"20\">St&ouml;rung</TD></TR>\n");
	if (fsStatus==20)
		out.println("<TR BGCOLOR=#ffdddd><TD><input type=radio name=\"status\" value=\"30\" checked>St&ouml;rung Ende</TD></TR>\n");
	if ((fsStatus==10) || (fsStatus==30))
		out.println("<TR BGCOLOR=#ddddff><TD><input type=radio name=\"status\" value=\"40\" checked>Ende</TD></TR>\n");
	if ((fsStatus==10) || (fsStatus==30) || (fsStatus==0))
		out.println("<TR><TD><input type=checkbox name=\"neuzuweis\" value=\"true\" checked>Neuzuweisung</TD></TR>\n");
	
	// Im Falle eines bereits zugewiesenem Auftrags müssen Arbeitspapiere ausgedruckt werden, es sei denn sie wurden schon gedruckt
	if (fsStatus==5)
		out.println("<INPUT TYPE=\"hidden\" NAME=\"druck\" VALUE=\"y\">");
	else
		out.println("<INPUT TYPE=\"hidden\" NAME=\"druck\" VALUE=\"n\">");
	out.println("<TR><TD ALIGN=\"CENTER\"><input type=\"submit\"  NAME=\"ok\" value=\"OK\"></TD></TR></TABLE></FORM>\n");
}
con.commit();
%>
    </CENTER>
    </BODY>
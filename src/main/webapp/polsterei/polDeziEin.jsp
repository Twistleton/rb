<!--JSP-Import-Files-->
<%@ page errorPage="myErrorPage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Polsterei/Verpacken Dezi-Melden</title>
    <link rel="stylesheet" type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.form.abNrFs.focus()">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        bdeConfigDatei bcd = new bdeConfigDatei("/etc/bdeServlet.conf");
        bcd.verarbeiten();
        Connection con = oraBde.getConnection();
        String sqlString = new String();

        int abNr = 0;
        int maPNr = 0;
        int maPIN = 0;
        int maKst = 0;
        int j = 0;
        int fsStatus = 0;
        int pfStatus = 0;
        int aendIx = 0;
        int dezi = 0;

        long fs = 0;
        con.setAutoCommit(false);

        Statement stmt = con.createStatement();
        ResultSet rs;

// Anmeldung überprüfen, wenn fehlerhaft angemeldet, dann Zurück zu Eingabemaske
        try {
            maPNr = Integer.parseInt(request.getParameter("pNr")); // Das schafft er halt manchmal nicht
        } catch (NumberFormatException nfe) {
            maPNr = 0;
        }

        sqlString = "SELECT ma_pnr,ma_pin,ma_recht, ma_kst FROM plrv11.bde_madat WHERE ma_pnr=" + maPNr;
        stmt.executeQuery(sqlString);
        rs = stmt.getResultSet();
        j = 0;
        while (rs.next()) {
            maPIN = rs.getInt("ma_pin");
            maKst = rs.getInt("ma_kst");
            j++;
        }
        rs.close();

        if ((j != 1) || (request.getParameter("pin").compareTo(String.valueOf(maPIN)) != 0)) {
            throw new Exception("Falscher Benutzername/Passwort");
        }
// Überprüfen, ob gültige Auftragsnummer
        try {
            String abNrFs = new String(request.getParameter("abNrFs"));
            abNr = Integer.parseInt(abNrFs.substring(0, 6));
            fs = Long.parseLong(abNrFs.substring(6));
        }
        catch (Exception e) {

        }

        if ((abNr != 0) && (fs != 0)) {
            sqlString = "SELECT abf_abnr,abf_fs,abf_fs_status,abf_pf_status,as_aend_ix, abf_dezi FROM plrv11.bde_ab_fs_ma,plrv11.plr_auftr_status " +
                    " WHERE abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix AND as_status<>99 AND " +
                    " abf_abnr=" + abNr + " AND abf_fs='" + fs + "' AND abf_fs_status<40 ";
            stmt.executeQuery(sqlString);
            rs = stmt.getResultSet();
            int k = 0;

            while (rs.next()) {
                k++;
                fsStatus = rs.getInt("abf_fs_status");
                pfStatus = rs.getInt("abf_pf_status");
                aendIx = rs.getInt("as_aend_ix");
                dezi = rs.getInt("abf_dezi");
            }
            rs.close();
            if (k == 0) {
                // Keine gültige Meldung
                out.println("<IMG SRC=\"warndreieck.gif\" align=\"middle\"><BR>Gemeldete Auftrags-Nr <B><FONT SIZE=+2 COLOR=\"#FF0000\">");
                out.println(abNr + "</FONT></B> konnte nicht gefunden werden.<BR>");
                out.println("Meldung wurde nicht verarbeitet!<BR><BR>");
            } else {
                // Gültige Meldung
                // In ab_fs_ma: fsStatus auf 40 setzen
                sqlString = "UPDATE plrv11.bde_ab_fs_ma SET abf_fs_status=40,abf_pnr=" + maPNr +
                        " WHERE abf_abnr=" + abNr +
                        " AND abf_fs='" + fs + "' AND abf_aend_ix=" + aendIx;
                stmt.execute(sqlString);
                // Eintrag in Meldezeiten vornehmen
                sqlString = "INSERT INTO plrv11.bde_ab_mz ";
                sqlString += "(abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto) " +
                        "VALUES (" + abNr +
                        "," + aendIx +
                        ",'" + fs +
                        "',40" +
                        ",'" + bdeZeit.getTimestamp("yyMMddHHmm") +
                        "'," + maPNr +
                        ",40,'N')";
                stmt.executeQuery(sqlString);

                sqlString = "INSERT INTO plrv11.bde_ma_lodat ";
                sqlString += "(mal_pnr,mal_abnr,mal_fs,mal_dezi,mal_loart,mal_kst,mal_sendtime,mal_status,mal_artnr) " +
                        "VALUES (" + maPNr + "," + abNr + ",'" + fs + "'," + dezi + ",101," + maKst + ",'" + bdeZeit.getTimestamp("yyMMddHHmm") + "',10,0)";
                stmt.executeQuery(sqlString);
                con.commit();
                out.println("<B>Meldung Erfolgreich!</B><BR>");
            }
        }

// Verarbeiten der Meldungen
        out.println("Gelesene Auftrags-Nr: <B>" + abNr);
        out.println("</B>\n<BR>Gelesene FS: <B>" + fs);
        out.println("</B>\n<BR><H2>Statusmeldung Polsterei/Verpacken</H2>");

        out.println("<TABLE BORDER=\"0\">");
        out.println("<FORM name=\"form\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"pNr\" VALUE=\"" + request.getParameter("pNr") + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"pin\" VALUE=\"" + request.getParameter("pin") + "\">");

    %>

    <TR BGCOLOR="#DDDDFF">
        <TD>Auftrags-Nr und<BR>Fertigungsstufe</TD>
        <TD ALIGN="right"><INPUT TYPE="TEXT" NAME="abNrFs" SIZE="18" MAXLENGTH="18"></TD>
        <TD ALIGN="right"><INPUT TYPE="SUBMIT" NAME="enter" VALUE="OK"></TD>
    </TR>
    </FORM>
    <FORM ACTION="polDeziLogin.jsp" METHOD="POST">
        <TR BGCOLOR="#FFDDDD">
            <TD COLSPAN="2">Abmelden</TD>
            <TD><INPUT TYPE="submit" VALUE="OK"></TD>
        </TR>
    </FORM>
    </TABLE>
</CENTER>
</BODY>




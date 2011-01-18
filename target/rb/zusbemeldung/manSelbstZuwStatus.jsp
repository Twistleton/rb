<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftragszuweisung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <SCRIPT TYPE="text/javascript">
        function checkPNr(t) {
            if (t.value == "1") {
                alert("Wählen Sie bitte einen Mitarbeiter aus und drücken Sie ok");
                return false;
            } else {
                return true;
            }
        }
    </SCRIPT>
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    Statement stmtInArbeit = con.createStatement();

    ResultSet rs;
    ResultSet rsInArbeit;
    String sql = new String();
    String sqlInArbeit = new String();
    String retString = new String();
    String ausgabe = new String();

    out.println("<B>Auftragszuweisung Manueller Zuschnitt</B><BR>");

    long sANr = 0;
    int pNr = 0;
    int pin = 0;
    int dbPin = 0;
    int inArbeit = 0;
    int nochAuftraege = 0;
    int fsStatus = 0;
    int vollstKomm;
    int hakenDa;
    long artNr = 0;
    int abNr = 0;
    int anzKomm = 0;
    String trace = new String();

    try {
        trace = request.getParameter("trace");
    }
    catch (Exception e) {
    }

    try {
        // Eingabe der Kommissionsnummer erfolgt?
        if (request.getParameter("komNr") != null) {
            artNr = Long.parseLong(request.getParameter("komNr").substring(0, 10));
            abNr = Integer.parseInt(request.getParameter("komNr").substring(10, 16));
            // Selektion des dazugehörigen Mitarbeiters

            sql = "SELECT kfs_pnr,kfs_fs_status,count(*) FROM plrv11.zus_kom_fs ";
            sql += " INNER JOIN plrv11.zus_kommission ON kfs_abnr=kom_abnr AND kfs_artnr=kom_art_nr ";
            sql += " WHERE ";
            sql += " kom_zs_sys  =30 AND ";
            sql += " kfs_artnr   =" + artNr;
            sql += " AND kfs_abnr=" + abNr;
            sql += " AND kfs_fs='10244100000' ";
            sql += " GROUP BY kfs_pnr,kfs_fs_status";

            try {
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    pNr = rs.getInt("kfs_pnr");
                    fsStatus = rs.getInt("kfs_fs_status");
                    if ((fsStatus < 20) ||
                            ((fsStatus > 20) && (fsStatus < 40))) {
                        nochAuftraege = 1;
                    }
                }
                if (pNr == 0) {
                    out.println("<FONT COLOR=\"red\">Diese Kommission kann nicht bemeldet werden</FONT><BR>");
                }
            }
            catch (SQLException sqlex) {
                out.println(sqlex.getMessage() + "<BR>" + sql);
            }
        }
    }
    catch (Exception e) {
        sANr = 0;
    }
    try {
        // Eingabe der Personal-Nummer Erfolgt?
        if ((request.getParameter("pNr") != null) && (request.getParameter("pin") != null) && (pNr == 0)) {
            pNr = Integer.parseInt(request.getParameter("pNr"));
            pin = Integer.parseInt(request.getParameter("pin"));
            // Gibts den Mitarbeiter und stimmt die PIN ?
            sql = "SELECT ma_pnr,ma_pin FROM plrv11.bde_madat WHERE ma_kst=244 AND ma_team_kz='N' AND ma_team=1 AND ma_pnr=" + pNr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                dbPin = rs.getInt("ma_pin");
            }
            if (pin != dbPin) {
                out.println("<FONT COLOR=\"red\">Fehlerhafte Personal-Nr / PIN</FONT><BR>");
                pNr = 0;
            }
            sql = "SELECT kfs_abnr,kfs_artnr,kfs_fs_status ";
            sql += " FROM plrv11.zus_kom_fs ";
            sql += " INNER JOIN plrv11.zus_kommission ON kfs_abnr=kom_abnr AND kfs_artnr=kom_art_nr ";
            sql += " WHERE ";
            sql += " kom_zs_sys=30 AND ";
            sql += " kfs_fs='10244100000' AND ";
            sql += " kfs_fs_status>=10 AND ";
            sql += " kfs_fs_status<>20 AND ";
            sql += " kfs_fs_status<40 AND ";
            sql += " kfs_pnr=" + pNr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();

            ausgabe = "<TABLE BORDER=1>";
            ausgabe += "<TR><TD BGCOLOR=\"#ffdddd\" COLSPAN=\"3\"><CENTER>Diese Kommissionen ";
            ausgabe += "müssen zuerst<BR>noch bearbeitet werden</CENTER></TD</TR>";
            while (rs.next()) {
                ausgabe += "<TR><TD>" + rbTextFormat.format('0', 10, rs.getString("kfs_artnr"));
                ausgabe += rbTextFormat.format('0', 6, rs.getString("kfs_abnr")) + "</TD><TD>";
                ausgabe += rs.getString("kfs_fs_status") + "</TD>";
                ausgabe += "<FORM ACTION=\"manSelbstZuwStatus.jsp\" METHOD=\"POST\"><TD ALIGN=\"CENTER\">";
                ausgabe += "<INPUT TYPE=\"HIDDEN\" NAME=\"komNr\" VALUE=\"";
                ausgabe += rs.getString("kfs_artnr") + rs.getString("kfs_abnr") + "\">";
                ausgabe += "<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\">";
                ausgabe += "</TD></FORM></TR>";
                nochAuftraege = 1;
            }
            ausgabe += "</TABLE>";
            if (nochAuftraege > 0) {
                out.println(ausgabe);
            }
        }
    }
    catch (Exception e) {
        out.println("<FONT COLOR=\"red\">Fehlerhafte Eingabe</FONT>");
        pNr = 0;
        pin = 0;
    }

    if ((artNr != 0) && (abNr != 0) && (pNr != 0)) {
        // Bemelden evtl. vorhandener Fertigungsstufen
        sql = "SELECT kfs_pnr,kfs_fs_status,kfs_abnr,kfs_artnr ";
        sql += " FROM plrv11.zus_kom_fs WHERE kfs_pnr=" + pNr;
        sql += " AND kfs_fs='10244100000' AND ";
        sql += " kfs_fs_status<40 AND ";
        sql += " kfs_abnr=" + abNr + " AND ";
        sql += " kfs_artnr=" + artNr;

        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        out.println("<FORM ACTION=\"manSelbstZuwMeldung.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"abNr\"  VALUE=\"" + abNr + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"pNr\"   VALUE=\"" + pNr + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"trace\" VALUE=\"" + trace + "\">");
        out.println("<TABLE BORDER=1>");
        while (rs.next()) {
            out.println("<TR><TD>Art-Nr</TD><TD ALIGN=\"right\">" + artNr + "</TD></TR>");
            out.println("<TR><TD>Ab-Nr </TD><TD ALIGN=\"right\">" + abNr + "</TD></TR>");
            out.println("<TR><TD>Status</TD><TD ALIGN=\"right\">");
            out.println("<TABLE>");
            if (rs.getInt("kfs_fs_status") == 10) {
                out.println("<TR><TD>St&ouml;rung Start</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"20\"></TD></TR>");
            }
            if (rs.getInt("kfs_fs_status") == 20) {
                out.println("<TR><TD>St&ouml;rung Ende</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"30\" CHECKED></TD></TR>");
            }
            if ((rs.getInt("kfs_fs_status") == 30) || (rs.getInt("kfs_fs_status")) == 10) {
                out.println("<TR><TD>Ende</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"40\" CHECKED></TD></TR>");
            }
            out.println("</TABLE></TR>");
            if ((rs.getInt("kfs_fs_status") == 30) || (rs.getInt("kfs_fs_status")) == 10) {
                sqlInArbeit = "SELECT COUNT(*) FROM plrv11.zus_kom_fs WHERE kfs_pnr=" + pNr;
                sqlInArbeit += " AND (kfs_fs_status=10 OR kfs_fs_status=30) AND ";
                sqlInArbeit += "kfs_fs='10244100000'";
                stmtInArbeit.executeQuery(sqlInArbeit);
                rsInArbeit = stmtInArbeit.getResultSet();
                while (rsInArbeit.next()) {
                    inArbeit = rsInArbeit.getInt(1);
                }
                if (inArbeit <= 1) {
                    out.println("<TR><TD>Neuzuweisung</TD><TD ALIGN=\"right\">");
                    out.println("<INPUT TYPE=\"CHECKBOX\" NAME=\"neuZuw\" VALUE=\"1\" CHECKED></TD></TR>");
                } else {
                    out.println("<TR><TD>Noch " + inArbeit + " Kommissionen in Arbeit</TD><TD ALIGN=\"right\">");
                }
            }
            out.println("<TR><TD ALIGN=\"center\" COLSPAN=2><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"ok\"></TD></TR>");
        }
        out.println("</TABLE></FORM>");
    }
    if ((pNr != 0) && (abNr == 0) && (artNr == 0) && (nochAuftraege == 0)) {
        out.println("Anmeldung ist in Ordnung->Mitarbeiter hat keine Aufträge mehr<BR>");
        out.println("<FORM ACTION=\"manSelbstZuwMeldung.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"trace\" VALUE=\"" + trace + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"pNr\"   VALUE=\"" + pNr + "\">");
        out.println("<TABLE BORDER=1>");
        out.println("<TR><TD>Neuzuweisung</TD><TD ALIGN=\"right\">");
        out.println("<INPUT TYPE=\"CHECKBOX\" NAME=\"neuZuw\" VALUE=\"1\" CHECKED></TD></TR>");
        out.println("<TR><TD ALIGN=\"center\" COLSPAN=2><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"ok\"></TD></TR>");
        out.println("</TABLE></FORM>");
    }


    con.close();
%>
</CENTER>
</body>
</html>

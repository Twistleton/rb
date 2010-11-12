<%@ page language="java" contentType="text/html" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Arrays" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Kommissionen HS-Schaumstoff</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" onload="document.SM.auftrag.focus(); document.ende.ende.focus()" link="#FF0000"
      alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        String zeile = new String();
        String auftrag = new String();
        String abnr_str = new String();

        Statement stmt = con.createStatement();
        ResultSet rs, rs2;

        int akt;
        boolean gefunden;
// Eingabe einer Auftragsnummer ...
        try {
            auftrag = request.getParameter("auftrag");
            if ((auftrag != null) && !(auftrag.compareTo("null") == 0)) { // ABNR ?
                /* Auftragsnummer wurde eingegeben (entweder Manuell oder durch folgen eines Links */
                if (auftrag.length() == 6 && request.getParameter("auswahl") != null) { // ABNR=6 Stellen
                    // ABNR wird akzeptiert, wenn HOST Freigabe (PF-Satz) vorhanden
                    // Doppelmeldungen werde nicht verarbeitet
                    gefunden = false;
                    sql = "select ga_status, ga_bez_vorh from plrv11.plr_ga_dat where ga_abnr=" + auftrag;
                    // sql +=" and ga_status in (2,8,9,15)";
                    stmt.executeQuery(sql);
                    rs2 = stmt.getResultSet();
                    // nur 1 DS
                    while (rs2.next()) {
                        gefunden = true;
                        akt = rs2.getInt("ga_status");
                        switch (akt) {
                            case 2: //angelegt und frei gegeben
                            case 9: //angelegt, Bezug vorhanden und frei gegeben
                            case 15: //angelegt, avisiert, Bezug und frei gegeben
                                sql = "update plrv11.plr_ga_dat set ga_status=ga_status+8 where ga_abnr=" + auftrag;
                                stmt.executeQuery(sql);
                                // Kommsys = 41, Person = 0, Ende Kommission = 40 ...
                                sql = "insert into plrv11.bde_sm_melden values (" + auftrag + ",41,0,40,";
                                sql += bdeZeit.getTimestamp("yyyyMMddHHmmss") + ")";
                                stmt.executeQuery(sql);
                                zeile = "Auftrag:" + auftrag + " wurde bei Rolf Benz angemeldet.";
                                break;
                            case 8: //angelegt; bei avisiert = Freigabe vorhanden
                                if (rs2.getString("ga_bez_vorh").compareTo("X") == 0) {
                                    zeile = "Auftrag:" + auftrag + " noch nicht freigegeben.";
                                    continue;
                                } else {
                                    sql = "update plrv11.plr_ga_dat set ga_status=ga_status+8 where ga_abnr=" + auftrag;
                                    stmt.executeQuery(sql);
                                    // Kommsys = 41, Person = 0, Ende Kommission = 40 ...
                                    sql = "insert into plrv11.bde_sm_melden values (" + auftrag + ",41,0,40,";
                                    sql += bdeZeit.getTimestamp("yyyyMMddHHmmss") + ")";
                                    stmt.executeQuery(sql);
                                    zeile = "Auftrag:" + auftrag + " wurde bei Rolf Benz angemeldet.";
                                }
                                break;
                            case 1: //angelegt
                            case 0: //noch nicht angelegt
                            case 7: //angelegt und avisiert
                            case 14: //angelegt, avisiert und Bezug vorhanden
                                zeile = "Auftrag:" + auftrag + " noch nicht freigegeben.";
                                break;
                            default:
                                zeile = "Auftrag:" + auftrag + " wurde bereits angemeldet.";
                                break;
                        }
                    }
                    if (gefunden) {
                        out.println(zeile);
                        out.println("</TABLE>");
                        out.println("<form name=ende method=post>");
                        out.println("<table border=1 bgcolor=\"#007fff\">");
                        out.println("<input type=\"hidden\" name=\"auftrag\" value=\"null\">");
                        out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\" tabindex=\"1\"></td></table></form>");
                    } else {
                        out.println("Der Auftrag (barcode) " + auftrag + " ist noch nicht bekannt!");
                        out.println("</TABLE>");
                        out.println("<form name=ende method=post>");
                        out.println("<table border=1 bgcolor=\"#007fff\">");
                        out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\"></td></table></form>");
                    }
                } else {
                    // Eingabe nicht 6-stellig
                    // Auswahlmaske angezeigen
                    if (request.getParameter("anzeige") != null) {
                        sql = "SELECT ga_abnr, ga_prog, ga_se, ga_status, ga_fabt_pps, ga_bez_vorh ";
                        sql += "FROM plrv11.plr_ga_dat where ga_zulief=3 and ga_status in (2,8,9,15) ";
                        sql += "ORDER by ga_fabt_pps";
                        stmt.executeQuery(sql);
                        rs = stmt.getResultSet();
                        out.println("<h2><font color=\"#007FFF\">");
                        out.println("Rolf Benz-Anforderungen ohne R&uuml;ckmeldung</h2>");
                        out.println("<h2>Bei Anwahl eines Auftrages = Freigabe zum Abruf</h2>");
                        out.println("<form name=ende method=post>");
                        out.println("<table border=1 bgcolor=\"#007fff\">");
                        out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\">");
                        out.println("</td></table></form>");
                        out.println("<TABLE BORDER=1>");
                        out.println("<TR BGCOLOR=\"#ffdddd\">");
                        out.println("<TH>Freigabe</TH><TH>Auftrag</TH><TH>Prog</TH><TH>SE</TH><TH>Plantag</TH></TR>");
                        while (rs.next()) { // wenn in bde_melden ...
                            if (rs.getInt("ga_status") == 8
                                    && rs.getString("ga_bez_vorh").compareTo("X") == 0)
                                continue;
                            zeile = "<FORM METHOD='post'>";
                            zeile += "<TR><TD><INPUT TYPE=\"submit\" NAME=\"auswahl\" VALUE=\"Freigabe\">";
                            // 4-stellige ABNR ? kleiner ist nicht im Bestand ...
                            if (rs.getLong("ga_abnr") < 10000) {
                                abnr_str = "00" + rs.getString("ga_abnr");
                                /* zeile += abnr_str+">"; */
                                zeile += "<INPUT TYPE=\"hidden\" NAME=\"auftrag\" VALUE=";
                                zeile += abnr_str + ">";
                            } else {
                                if (rs.getLong("ga_abnr") < 100000) {
                                    abnr_str = "0" + rs.getString("ga_abnr");
                                    /* zeile += abnr_str+">"; */
                                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"auftrag\" VALUE=";
                                    zeile += abnr_str + ">";
                                } else {
                                    /* zeile += rs.getString("ga_abnr")+">"; */
                                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"auftrag\" VALUE=";
                                    zeile += rs.getString("ga_abnr") + ">";
                                }
                            }

                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("ga_abnr");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("ga_prog");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("ga_se");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("ga_fabt_pps");
                            zeile += "</TD></TR></FORM>";
                            out.println(zeile);
                        }
                        out.println("</TABLE>");
                        out.println("<form name=ende method=post>");
                        out.println("<table border=1 bgcolor=\"#007fff\">");
                        out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\">");
                        out.println("</td></table></form>");
                    } else {
                        out.println("Der angegebene Auftrag (barcode) " + auftrag + " ist ung&uuml;tig!");
                        out.println("<p><a href=HSmelden.jsp>neuer Versuch/Neustart</a></p>");
                    }
                }
            } else { // Einstiegsmaske
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr>");
                out.println("<td align=\"left\"><img src=\"/rb-logo.gif\"></td>");
                out.println("<td align=center bgcolor=\"#007FFF\">");
                out.println("<font FACE=\"ARIAL\" SIZE=\"5\"><b>Auftrag Anmelden HS</b></font></td>");
                out.println("<td align=\"right\">" + bdeZeit.getTimestamp("dd.MM.yyyy") + "</td>");
                sql = "SELECT fab_fab_tag ";
                sql += "FROM plrv11.plr_fabkal_dat where fab_datum = to_number(to_char(sysdate,'DDMMYY'))";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) { // wenn in plr_fabkal_dat ...
                    out.println("<td align=\"right\">Fabriktag: " + rs.getInt("fab_fab_tag") + "</td>");
                    out.println("<td align=\"right\">Puffertag: " + (rs.getInt("fab_fab_tag") + 3) + "</td>");
                }
                out.println("</tr>");
                out.println("</TABLE>");
                out.println("</p><hr><p>");

                // AB-Nr ohne kommsys
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr><td align=center>");
                out.println("<form  name='SM' method=post>Auftrag (6-stellig):");
                out.println("<input type=\"text\" name=\"auftrag\" tabindex=\"1\" size=\"6\" maxlength=\"6\">");
                out.println("<input type=\"submit\" name=\"auswahl\" tabindex=\"2\" VALUE=\"OK\">");
                out.println("<input type=\"submit\" name=\"anzeige\" tabindex=\"3\" ");
                out.println("VALUE=\"offene Anforderungen\">");
                out.println("</td></tr></form></TABLE>");
                out.println("</p><hr><p>");
            }
        } catch (Exception ex) {
            out.println("---nix ausgew&auml;hlt--->" + ex.getMessage() + "<<BR>");
            ex.printStackTrace();
        }
        con.close();
    %>
</CENTER>
</body>
</html>

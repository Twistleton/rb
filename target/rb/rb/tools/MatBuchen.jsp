<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Arrays" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Material buchen</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000"
      vlink="#FF0000" onload="document.MATERIAL.abnr.focus();">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        String zeile = new String();

        Statement stmt = con.createStatement();
        ResultSet rs;

        boolean gesperrt;

        try { // Eingabe Auftrag zur Buchung... Datum gebuchter Teile
            if (request.getParameter("abnr") != null && request.getParameter("buchen") != null) {
                // Kommissioniersystem rueckmelden
                // pro kommsys 1 sql update
                if (request.getParameter("mattyp").compareTo("44") == 0) {
                    sql = "update plrv11.plr_mat_dat set mt_rueck_meld='J',mt_status=20,";
                    sql += "mt_timestamp=" + bdeZeit.getTimestamp("yyyyMMddHHmmss") + " where mt_rueck_meld<>'J' and ";
                    sql += "mt_mat_typ = 25 and mt_abnr='" + request.getParameter("abnr") + "'";
                    stmt.executeQuery(sql);
                    sql = "select mt_teilenr, mt_bezeichn, sum(mt_menge)/100 from plrv11.plr_mat_dat where mt_rueck_meld='J' and ";
                    sql += "mt_mat_typ = 25 and mt_abnr=" + request.getParameter("abnr") + " group by mt_teilenr,mt_bezeichn";
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    out.println("<h2><font color=\"#007FFF\">Buchung " + request.getParameter("abnr") + " &uuml;ber ...</h2>");
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Teilenummer</TH><TH>Bezeichnung</TH><TH>Buchungsmenge</TH>");
                    while (rs.next()) {
                        zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs.getString("mt_teilenr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("mt_bezeichn");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getInt("sum(mt_menge)/100");
                        zeile += "</TD></TR>";
                        out.println(zeile);
                    }
                    out.println("</TABLE>"); // besteht aus n Teilenummern
                    out.println("</TABLE>");
                    out.println("<form method=post>");
                    out.println("<table border=1 bgcolor=\"#007fff\">");
                    out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\"></td></table></form>");
                }
            } // Liste gebuchter Teilenummern/Kommissioniersystem zu einem Datum
            if (request.getParameter("teil") != null && request.getParameter("listen") != null) {
                out.println("<h2><font color=\"#007FFF\">Liste " + request.getParameter("datum") + " gebucht</font></h2>");
                out.println("<TABLE BORDER=1>");
                out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Teilenummer</TH><TH>Bezeichnung</TH><TH>Buchungsmenge</TH>");
                sql = "select mt_teilenr, mt_bezeichn, sum(mt_menge)/100 from plrv11.plr_mat_dat ";
                sql += "where mt_teilenr='" + request.getParameter("teil") + "' and ";
                sql += "substr(mt_timestamp,1,8)='" + request.getParameter("datum") + "' and ";
                sql += "mt_rueck_meld='J' and mt_status>19 group by mt_teilenr,mt_bezeichn";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) { // Liste der gesperrten Teile
                    zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs.getString("mt_teilenr");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("mt_bezeichn");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getInt("sum(mt_menge)/100");
                    zeile += "</TD></TR>";
                    out.println(zeile);
                }
                out.println("</TABLE>");
                out.println("<form method=post>");
                out.println("<table border=1 bgcolor=\"#007fff\">");
                out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\"></td></table></form>");
            } else {
                //Kopflayout Rolf Benz
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr>");
                out.println("<td align=\"left\"><img src=\"/rb-logo.gif\"></td>");
                out.println("<td align=center bgcolor=\"#007FFF\">");
                out.println("<font FACE=\"ARIAL\" SIZE=\"5\"><b>Verbuchen von Material/Kommissioniersystem</b></font></td>");
                out.println("<td align=\"right\">" + bdeZeit.getTimestamp("dd.MM.yyyy") + "</td>");
                out.println("</tr>");
                out.println("</TABLE>");
                out.println("</p><hr><p>");
                // AB-Nr-Eingabefeld
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr><td align=center>");
                out.println("<form name=\"MATERIAL\" method=\"post\">Auftrag (6-stellig):");
                out.println("<input type=\"text\" name=\"abnr\" tabindex=\"1\" size=\"6\" maxlength=\"8\">");
                out.println("Materialtyp : <select name=\"mattyp\" size=\"1\">");
                //out.println("<option value=\"41\">VOPO Material</option>");
                //out.println("<option value=\"43\">Polstermaterial</option>");
                out.println("<option value=\"44\">Montagematerial/RK</option></select>");
                out.println("<input type=\"submit\" name=\"buchen\" VALUE=\"Buchen\">");
                out.println("</td></tr>");
                out.println("<tr><td align=center>");
                out.println("Datum(JJJJMMTT) :");
                out.println("<input type=\"text\" name=\"datum\" VALUE=" + bdeZeit.getTimestamp("yyyyMMdd") + " size=\"8\" maxlength=\"8\">");
                out.println("Teilenummer (10-stellig):");
                out.println("<input type=\"text\" name=\"teil\" size=\"10\" maxlength=\"10\">");
                out.println("<input type=\"submit\" name=\"listen\" VALUE=\"SW\">");
                out.println("</td></tr>");
                out.println("</form></TABLE>");
                out.println("</p><hr><p>");
            }
        }
        catch (Exception ex) {
            out.println("---nix ausgew&auml;hlt---" + ex.getMessage() + "<BR>");
            ex.printStackTrace();
        }
        con.close();
    %>
</CENTER>
</body>
</html>

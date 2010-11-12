<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FFffff" alink="#FFffff" vlink="#FFffff">
<table border="0" align="center">
    <tr>
        <td align="center">
            <font size="+1">
                <b>
                    Reservierungsverwaltung
                </b>
            </font>
        </td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    long reservArtNr = 0;
    long reservLagerOrt = 0;
    //float reservMenge   = 0;
    String reservMenge = "";
    int reservStatus = 0;
    int reservId = 0;
    int reservPROGNR = 0;
    long reservABNR = 0;
    String charge = "";
    String liefkkz = "";
    String anlageDat = "";
    String lief = "";
    String charge_out = "";
    String fungi = "";
    String bem = "";
    String bem1 = "";
    int count = 0;
    String jahr = "";
    String monat = "";
    String tag = "";
    String uhrzeit = "";
    String anlageDatString = "";

    //#####---Nur Reservierungen anzeigen, daher die WHERE-Bedingung---#####
    sql = "SELECT RES_ART_NR,RES_ABNR,RES_PROG_NR,RES_CHARG_NR,RES_FUNGIZID,RES_BEMERK,RES_QM_BRUTTO,RES_RES_LAGERORT,";
    sql += "RES_STATUS,RES_ID,RES_LIEF_KKZ,RES_ANLAGE_DAT";
    sql += " FROM PLRV11.ZUS_REST_RESERV";
    sql += " WHERE RES_RESERV_KZ='J' ORDER BY RES_ART_NR";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr>");
    out.println("<td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Prog.</b></td>");
    out.println("<td align=\"center\"><b>ABNR</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<td align=\"center\"><b>Lieferant</b></td>");
    out.println("<td align=\"center\"><b>Menge[qm]</b></td>");
    out.println("<td align=\"center\"><b>Fungizid</b></td>");
    out.println("<td align=\"center\"><b>Bem.</b></td>");
    out.println("<td align=\"center\"><b>Lagerort</b></td>");
    out.println("<td align=\"center\"><b>Status</b></td>");
    out.println("<td align=\"center\"><b>Anlagedatum</b></td>");
    out.println("<td align=\"center\"><b>Aktion</b></td></tr>");

    try {
        while (resultSet.next()) {

            reservABNR = resultSet.getLong("RES_ABNR");
            reservPROGNR = resultSet.getInt("RES_PROG_NR");
            reservArtNr = resultSet.getLong("RES_ART_NR");
            //reservMenge    = resultSet.getFloat("RES_QM_BRUTTO");
            reservMenge = resultSet.getString("RES_QM_BRUTTO").replace('.', ',');
            reservStatus = resultSet.getInt("RES_STATUS");
            reservLagerOrt = resultSet.getLong("RES_RES_LAGERORT");
            reservId = resultSet.getInt("RES_ID");
            charge = resultSet.getString("RES_CHARG_NR");
            liefkkz = resultSet.getString("RES_LIEF_KKZ");
            anlageDat = resultSet.getString("RES_ANLAGE_DAT");
            fungi = resultSet.getString("RES_FUNGIZID");
            bem = resultSet.getString("RES_BEMERK");
            if (bem == null) bem = "";
            String lagerort = "" + reservLagerOrt;
            String lager1 = lagerort.substring(0, 8);
            String lager2 = lagerort.substring(8);

            String artnr = "" + reservArtNr;
            String artnr1 = artnr.substring(0, 3);
            String artnr2 = artnr.substring(3, 8);
            String artnr3 = artnr.substring(8);
            //out.println(artnr1+"."+artnr2+"."+artnr3+"<br>");

            if (anlageDat != null) {
                jahr = anlageDat.substring(0, 4);
                monat = anlageDat.substring(5, 7);
                tag = anlageDat.substring(8, 10);
                uhrzeit = anlageDat.substring(11, 16);
                anlageDatString = "&nbsp;" + tag + "." + monat + "." + jahr + "<br>" + uhrzeit;
            } else {
                anlageDatString = "-";
            }

            count = bem.length();

            if (count <= 10) {
                bem1 = bem;
            } else {
                bem1 = bem.substring(0, 10);
            }

            if (charge != null) {
                charge_out = charge;
            } else {
                charge_out = "-";
            }

            if (liefkkz != null) {
                lief = liefkkz;
            } else {
                lief = "-";
            }

            out.println("<tr>");
            out.println("<td align=\"center\">" + artnr1 + "." + artnr2 + "." + artnr3 + "</td>");
            out.println("<td align=\"center\">" + reservPROGNR + "</td>");
            out.println("<td align=\"center\">" + reservABNR + "</td>");
            out.println("<td align=\"center\">" + charge_out + "</td>");
            out.println("<td align=\"center\">" + lief + "</td>");
            out.println("<td align=\"center\">" + reservMenge + "</td>");
            out.println("<td align=\"center\">" + fungi + "</td>");
            out.println("<td align=\"center\">" + bem1 + "</td>");
            out.println("<td align=\"center\">" + lager1 + "." + lager2 + "</td>");
            out.println("<td align=\"center\">" + reservStatus + "</td>");
            out.println("<td align=\"center\">" + anlageDatString + "</td>");
            out.println("<td align=\"center\" bgcolor=\"red\">");
            out.println("<a href=\"./loeschen_confirm.jsp?artnr=" + reservArtNr + "&artID=" + reservId + "&var=rest\">L&ouml;schen</a>");
            out.println("</td>");
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Daten!<br>");
        out.println(e);
    }
    out.println("</tr></table>");
    con.close();
%>
</body>
</html>
      

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
                    Resteverwaltung
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

    long restArtNr = 0;
    long restLagerOrt = 0;
    //float restMenge   = 0;
    String restMenge = "";
    int restStatus = 0;
    int restId = 0;
    String charge = "";
    String liefkkz = "";
    String lief = "";
    String anlageDat = "";
    String charge_out = "";
    String fungi = "";
    String bem = "";
    String bem1 = "";
    int count = 0;
    int buendel = 0;
    String jahr = "";
    String monat = "";
    String tag = "";
    String uhrzeit = "";
    String anlageDatString = "";

    //#####---Nur Reste anzeigen, daher die WHERE-Bedingung---###
    sql = "SELECT RES_ART_NR,RES_CHARG_NR,RES_FUNGIZID,RES_BEMERK,RES_QM_BRUTTO,RES_RES_LAGERORT,RES_STATUS,RES_ID,";
    sql += "RES_LIEF_KKZ,RES_BUENDEL,RES_ANLAGE_DAT FROM PLRV11.ZUS_REST_RESERV";
    sql += " WHERE RES_REST_KZ='J' ORDER BY RES_ART_NR";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");

    out.println("<tr><td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Brutto[qm]</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<td align=\"center\"><b>Lieferant</b></td>");
    out.println("<td align=\"center\"><b>Lagerort</b></td>");
    out.println("<td align=\"center\"><b>Fungizid</b></td>");
    out.println("<td align=\"center\"><b>B&uuml;ndelkl.</b></td>");
    out.println("<td align=\"center\"><b>Bem.</b></td>");
    out.println("<td align=\"center\"><b>Status</b></td>");
    out.println("<td align=\"center\"><b>Anlagedatum</b></td>");
    out.println("<td align=\"center\"><b>Aktion</b></td></tr>");

    try {
        while (resultSet.next()) {

            restArtNr = resultSet.getLong("RES_ART_NR");
            //restMenge    = resultSet.getFloat("RES_QM_BRUTTO");
            restMenge = resultSet.getString("RES_QM_BRUTTO").replace('.', ',');
            restStatus = resultSet.getInt("RES_STATUS");
            restLagerOrt = resultSet.getLong("RES_RES_LAGERORT");
            restId = resultSet.getInt("RES_ID");
            charge = resultSet.getString("RES_CHARG_NR");
            fungi = resultSet.getString("RES_FUNGIZID");
            bem = resultSet.getString("RES_BEMERK");
            liefkkz = resultSet.getString("RES_LIEF_KKZ");
            buendel = resultSet.getInt("RES_BUENDEL");
            anlageDat = resultSet.getString("RES_ANLAGE_DAT");

            String lagerort = "" + restLagerOrt;
            String lager1 = lagerort.substring(0, 8);
            String lager2 = lagerort.substring(8);

            String artnr = "" + restArtNr;
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

            if (bem != null) {
                try {
                    count = bem.length();

                    if (count <= 10) {
                        bem1 = bem;
                    } else {
                        bem1 = bem.substring(0, 10);
                    }

                } catch (Exception e) {
                    //out.println("<br>");
                    //out.println(e);
                }
            } else {
                bem1 = "-";
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

            out.println("<tr><td align=\"center\">" + artnr1 + "." + artnr2 + "." + artnr3 + "</td>");
            out.println("<td align=\"center\">" + restMenge + "</td>");
            out.println("<td align=\"center\">" + charge_out + "</td>");
            out.println("<td align=\"center\">" + lief + "</td>");
            out.println("<td align=\"center\">" + lager1 + "." + lager2 + "</td>");
            out.println("<td align=\"center\">" + fungi + "</td>");
            out.println("<td align=\"center\">" + buendel + "</td>");
            out.println("<td align=\"center\">" + bem1 + "</td>");
            out.println("<td align=\"center\">" + restStatus + "</td>");
            out.println("<td align=\"center\">" + anlageDatString + "</td>");
            out.println("<td align=\"center\" bgcolor=\"red\">");
            out.println("<a href=\"./loeschen_confirm.jsp?artnr=" + restArtNr + "&artID=" + restId + "&var=rest\">L&ouml;schen</a>");
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
      
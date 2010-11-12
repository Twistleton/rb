<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#ffffff" alink="#ffffff" vlink="#000000">
<table border="0" align="center">
    <tr>
        <td align="center">
            <font size="+1">
                <b>
                    Reste-Liste
                </b>
            </font>
        </td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    Statement stmt1;
    String sql;
    String sql1;
    ResultSet resultSet;
    ResultSet resultSet1;
    String artNr = "";
    String charge = "";
    String lieferant = "";
    int anzahl = 0;
    String menge = "";
    String lager = "";


    //#####---Reste mit gleicher ArtNr/Lieferant/ChargeNr---#####
    sql = "SELECT RES_ART_NR,RES_CHARG_NR,RES_LIEF_KKZ,COUNT(*) AS CNT,SUM(RES_QM_BRUTTO)FROM plrv11.ZUS_REST_RESERV";
    sql += " WHERE RES_REST_KZ='J' GROUP BY  RES_ART_NR,RES_CHARG_NR,RES_LIEF_KKZ ORDER BY RES_ART_NR";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr>");
    out.println("<td align=\"center\"><b>ArtNr</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<td align=\"center\"><b>Lieferant</b></td>");
    out.println("<td align=\"center\"><b>Lagerort [Menge]</b></td></tr>");

    try {
        while (resultSet.next()) {

            artNr = resultSet.getString("RES_ART_NR");
            charge = resultSet.getString("RES_CHARG_NR");
            lieferant = resultSet.getString("RES_LIEF_KKZ");
            anzahl = resultSet.getInt("CNT");

            String newartnr1 = artNr.substring(0, 3);
            String newartnr2 = artNr.substring(3, 8);
            String newartnr3 = artNr.substring(8);

            if (anzahl > 1) {
                //#####---Reste mit gleicher ArtNr/Lieferant/ChargeNr---#####
                sql1 = "SELECT RES_QM_BRUTTO,RES_RES_LAGERORT FROM plrv11.ZUS_REST_RESERV";
                sql1 += " WHERE RES_REST_KZ='J' AND RES_ART_NR=" + artNr + " AND RES_CHARG_NR=" + charge + " AND RES_LIEF_KKZ='" + lieferant + "'";

                //out.println(sql1);
                stmt1 = con.createStatement();
                stmt1.executeQuery(sql1);
                resultSet1 = stmt1.getResultSet();

                out.println("<tr>");
                out.println("<td align=\"center\">" + newartnr1 + "." + newartnr2 + "." + newartnr3 + "</td>");
                out.println("<td align=\"center\">" + charge + "</td>");
                out.println("<td align=\"center\">" + lieferant + "</td>");
                out.println("<td align=\"center\">");

                while (resultSet1.next()) {
                    menge = resultSet1.getString("RES_QM_BRUTTO");
                    lager = resultSet1.getString("RES_RES_LAGERORT");
                    String neue_menge = rbTextFormat.format('0', 5, menge);
                    String lager1 = lager.substring(0, 8);
                    String lager2 = lager.substring(8);

                    out.println(lager1 + "." + lager2 + "&nbsp;&nbsp;&nbsp;[" + neue_menge + "]<br>");
                }
                out.println("</td></tr>");
            }
            //out.println("<td align=\"center\" bgcolor=\"red\">");
            //out.println("<a href=\"./prog_sperren.jsp?art=freigeben&prognr="+prog+"\">Entsperren</a></td></tr>");
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Daten!<br>");
        out.println(e);
    }
    out.println("</table>");
    con.close();
%>
</body>
</html>
     

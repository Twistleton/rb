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
                    Artikel f&uuml;r Zuschnittsystem CUTTER
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

    long ART_NR = 0;
    String artbez = "";
    String art_sperrkz = "";
    String zsSys = "";


    //#####---Nur Reservierungen anzeigen, daher die WHERE-Bedingung---#####
    sql = "SELECT ART_NR,ART_BEZ FROM PLRV11.PLR_ART_KOPF";
    sql += " WHERE ART_ZS_SYS=10 ORDER BY ART_NR";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr>");
    out.println("<td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Bezeichnung</b></td>");
    out.println("<td align=\"center\" ><b>ZS-System</b></td></tr>");
    //out.println("<td align=\"center\"><b>Aktion</b></td></tr>");

    try {
        while (resultSet.next()) {

            ART_NR = resultSet.getLong("ART_NR");
            artbez = resultSet.getString("ART_BEZ");

            String artnr = "" + ART_NR;
            String artnr1 = artnr.substring(0, 3);
            String artnr2 = artnr.substring(3, 8);
            String artnr3 = artnr.substring(8);
            //out.println(artnr1+"."+artnr2+"."+artnr3+"<br>");

            out.println("<tr>");
            out.println("<td align=\"center\">" + artnr1 + "." + artnr2 + "." + artnr3 + "</td>");
            out.println("<td align=\"center\">" + artbez + "</td>");
            out.println("<td align=\"center\" bgcolor=\"#00ff00\">Cutter</td></tr>");
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
     
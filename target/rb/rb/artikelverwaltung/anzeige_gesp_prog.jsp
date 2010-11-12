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
                    Gesperrte Programme
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
    String prog = "";
    String sperrdat = "";
    String jahr = "";
    String monat = "";
    String tag = "";
    String uhrzeit = "";
    String sperrdatString = "";

    //#####---Nur Reservierungen anzeigen, daher die WHERE-Bedingung---#####
    sql = "SELECT PRG_PRG,PRG_SPERRDAT FROM PLRV11.PLR_PRG_SPERR ORDER BY PRG_PRG";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr>");
    out.println("<td align=\"center\"><b>Programm</b></td>");
    out.println("<td align=\"center\"><b>Gesperrt am:</b></td>");
    out.println("<td align=\"center\"><b>Aktion</b></td>");

    try {
        while (resultSet.next()) {

            prog = resultSet.getString("PRG_PRG");
            sperrdat = resultSet.getString("PRG_SPERRDAT");

            if (sperrdat != null) {
                jahr = sperrdat.substring(0, 4);
                monat = sperrdat.substring(5, 7);
                tag = sperrdat.substring(8, 10);
                uhrzeit = sperrdat.substring(11, 16);
                sperrdatString = "&nbsp;" + tag + "." + monat + "." + jahr + "<br>" + uhrzeit;
            } else {
                sperrdatString = "-";
            }

            out.println("<tr>");
            out.println("<td align=\"center\">" + prog + "</td>");
            out.println("<td align=\"center\">" + sperrdatString + "</td>");
            out.println("<td align=\"center\" bgcolor=\"red\">");
            out.println("<a href=\"./prog_sperren.jsp?art=freigeben&prognr=" + prog + "\">Entsperren</a></td></tr>");
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
     
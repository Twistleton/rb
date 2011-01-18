<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#000000" alink="#000000" vlink="#000000">
<table border="0" align="center">
    <tr>
        <td align="center">
            <h2><b>ZBL-Liste</b></h2>
        </td>
    </tr>
    <tr>
        <td align="center">
            <a href="./zbl_anlegen_maske.jsp" target="_self">Neues ZBL anlegen</a>
        </td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    String artnr = "";
    String lief_kkz = "";
    int charge = 0;

    sql = "SELECT * FROM PLRV11.ZUS_ZBL ORDER BY ZBL_TNR";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");

    out.println("<tr style=\"background-color:#d0d0d0;\"><td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Lieferanten-Kurzkennzeichen</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<td colspan=\"2\" align=\"center\"><b>Aktion</b></td></tr>");
    try {
        while (resultSet.next()) {

            artnr = resultSet.getString("ZBL_TNR");
            lief_kkz = resultSet.getString("ZBL_LIEF_KKZ");
            charge = resultSet.getInt("ZBL_CHARG_NR");

            String newartnr1 = artnr.substring(0, 3);
            String newartnr2 = artnr.substring(3, 8);
            String newartnr3 = artnr.substring(8);

            out.println("<tr><td align=\"center\">" + newartnr1 + ".<b>" + newartnr2 + "</b>." + newartnr3 + "</td>");
            out.println("<td align=\"center\">" + lief_kkz + "</td>");
            out.println("<td align=\"center\">" + charge + "</td>");
            out.println("<td align=\"center\">");
            out.println("<a href=\"./zbl_bearbeiten.jsp?artnr=" + artnr + "&lief_kkz=" + lief_kkz + "&charge=" + charge + "\">");
            out.println("<img src=\"./bearbeiten.gif\" border=\"0\" title=\"Bearbeiten\"></a></td>");
            out.println("<td align=\"center\">");
            out.println("<a href=\"./zbl_loeschen_confirm.jsp?artnr=" + artnr + "&lief_kkz=" + lief_kkz + "&charge=" + charge + "\">");
            out.println("<img src=\"./trashy.jpg\" border=\"0\" title=\"L&ouml;schen\"></a></td>");
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
      
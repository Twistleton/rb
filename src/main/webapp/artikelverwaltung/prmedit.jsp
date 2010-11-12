<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center">
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    String artBez = "";
    String artSperrKz = "";
    String zuschnittsys = "";
    String artNr = "";
    String zsArt = "";
    String artnr = request.getParameter("artnr");

    String cutterparameter = "";
    String digitparameter = "";

    sql = "SELECT * FROM PLRV11.PLR_ART_KOPF where ART_NR=" + artnr;
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<center><h3>Parameter &auml;ndern:</h3></center>");
    out.println("<form action=\"./prmedit_update.jsp\" method=\"post\">");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
    out.println("<colgroup><col width=\"210\"><col width=\"210\"></colgroup>");

    try {
        resultSet.next();

        artNr = resultSet.getString("ART_NR");
        artBez = resultSet.getString("ART_BEZ");
        artSperrKz = resultSet.getString("ART_SPERR_KZ");
        zuschnittsys = resultSet.getString("ART_ZS_SYS");
        cutterparameter = resultSet.getString("ART_CUT_PARM");
        digitparameter = resultSet.getString("ART_DIG_PARM");

        if (zuschnittsys.equals("10")) {
            zsArt = "Cutter";
        } else if (zuschnittsys.equals("30")) {
            zsArt = "Manuell";
        } else if (zuschnittsys.equals("20")) {
            zsArt = "Cutter/Manuell";
        }

        String newartnr = "" + artNr;
        String newartnr1 = artnr.substring(0, 3);
        String newartnr2 = artnr.substring(3, 8);
        String newartnr3 = artnr.substring(8);

        out.println("<tr><td>Artikelnummer</td><td align=\"center\">" + newartnr1 + "." + newartnr2 + "." + newartnr3 + "</td></tr>");
        out.println("<tr><td>Bezeichnung</td><td align=\"center\">" + artBez);
        out.println("<input type=\"hidden\" name=\"artNr\" value=\"" + artNr + "\"></input></td></tr>");

        if (artSperrKz.equals("N")) {
            out.println("<tr><td>Gesperrt</td><td bgcolor=\"#00ff00\" align=\"center\">Nein</td></tr>");
        } else {
            out.println("<tr><td>Gesperrt</td><td bgcolor=\"red\" align=\"center\">Ja</td></tr>");
        }
        out.println("<tr><td>Zuschnittsystem</td><td align=\"center\">" + zsArt + "</td></tr>");
        out.println("<tr><td>Cutterparameter</td><td align=\"center\">");
        out.println("<input type=\"text\" name=\"cutterparameter\" value=\"" + cutterparameter + "\" maxlength=\"40\"></input></td></tr>");
        out.println("<tr><td>Digitparameter</td><td align=\"center\">");
        out.println("<input type=\"text\" name=\"digitparameter\" value=\"" + digitparameter + "\" maxlength=\"40\"></input></td></tr></table>");
        out.println("<table border=\"0\" align=\"center\">");
        out.println("<tr><td align=\"center\"><input type=\"submit\" value=\"&Auml;nderung &uuml;bernehmen\"></input></td></tr></table></form>");


    } catch (SQLException e) {
        out.println("Artikelnummer nicht gefunden!<br>");
        out.println(e);
    }
    con.close();
%>

</body>
</html>
      
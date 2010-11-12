<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">
<table border="0" align="center">
    <tr>
        <td align="center">
            <b>Rohstoffe/Materialien</b>
        </td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    int matNr = 0;
    String matKzBez = "";
    String matBez = "";

    //#####---Alle Rohstoffe anzeigen ausser AA-DUMMY(AMB_MAT_NR 1)---#####
    sql = "SELECT * FROM PLRV11.ZUS_MATBEZ WHERE AMB_MAT_NR <> 1 ORDER BY AMB_MAT_KZBEZ";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");

    out.println("<tr><td align=\"center\"><b>Kurzbezeichnung</b></td>");
    out.println("<td align=\"center\"><b>Bezeichnung</b></td></tr>");

    try {
        while (resultSet.next()) {

            matKzBez = resultSet.getString("AMB_MAT_KZBEZ");
            matBez = resultSet.getString("AMB_MAT_BEZ");

            out.println("<tr><td align=\"center\">" + matKzBez + "</td>");
            out.println("<td align=\"center\">" + matBez + "</td>");
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
      

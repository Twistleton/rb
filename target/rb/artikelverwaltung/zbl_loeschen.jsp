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
        <td align="center">&nbsp;</td>
    </tr>
</table>
<div align="center">
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt;
        String sql;
        ResultSet resultSet;

        String artnr = request.getParameter("artNr");
        String lief_kkz = request.getParameter("lief_kkz");
        String charge = request.getParameter("charge");
        String delete = request.getParameter("delete");

        if (delete.equals("1")) {
            //#####---Erst DB-Eintrag loeschen....---#####
            sql = "DELETE FROM PLRV11.ZUS_ZBL WHERE ZBL_TNR=" + artnr + " AND ZBL_LIEF_KKZ='" + lief_kkz + "' AND ZBL_CHARG_NR=" + charge;
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Datensatzes:&nbsp;" + e + "<p>");
            }
            out.println("<br>Datensatz erfolgreich gel&ouml;scht!<br><br>");
            out.println("<a href=\"./zbl_anzeigen.jsp\">zur ZBL-Liste</a>");
        }
        //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
        else if (delete.equals("0")) {
            out.println("<br>Das war knapp:<br>Datensatz <b>NICHT</b> gel&ouml;scht!<br><br>");
            out.println("<a href=\"./zbl_anzeigen.jsp\">zur ZBL-Liste</a>");
        } else {
            out.println("Fehler beim L&ouml;schen:Kein L&ouml;schparameter &uuml;bergeben!<br>");
        }
        con.close();
    %>
</div>
</body>
</html>
      
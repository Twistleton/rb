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
        <td>&nbsp;</td>
    </tr>
</table>
<div align="center">
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt;
        String sql;
        ResultSet resultSet;

        String artCutFhg = "";
        String artManZs = "";

        String artnr = request.getParameter("artnr");
        String cutkennz = request.getParameter("cutkennz");

        //#####---Auf manuell setzen---#####
        if (cutkennz.equals("N")) {

            sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_MAN_ZS='J',ART_CUT_FHG='N' WHERE ART_NR=" + artnr;
            stmt = con.createStatement();
            stmt.executeQuery(sql);

            out.println("Bearbeitungskennzeichen ge&auml;ndert!<br>");
            out.println("<font color=\"#ff0000\"><b>Artikel auf MANUELLEN ZUSCHNITT gesetzt</b></font>");
        }
        //#####---Auf cutterfaehig setzen---#####
        else if (cutkennz.equals("J")) {

            sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_MAN_ZS='N', ART_CUT_FHG='J' WHERE ART_NR=" + artnr;
            stmt = con.createStatement();
            stmt.executeQuery(sql);

            out.println("Bearbeitungskennzeichen ge&auml;ndert!<br>");
            out.println("<font color=\"#00ff00\"><b>Artikel auf CUTTERF&Auml;HIG gesetzt</b></font>");
        } else {
            out.println("Fehler:Kein Bearbeitungskennzeichen &uuml;bergeben!!");
        }

        out.println("<br><br>");
        con.close();
    %>

    <a href="./anzeigen.jsp?ART_NR=<%=artnr%>&sent=1&sel=j">zur&uuml;ck zum Artikel</a>
</div>
</body>
</html>

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
        Statement stmt = con.createStatement();
        ResultSet resultSet;
        String sql = "";
        String artSperrKz = "";

        //#####---Parameter---#####
        String artnr = request.getParameter("artnr");
        String sperrkz = request.getParameter("sperrkz");

        //#####---Artikel sperren-Sperrkennzeichen setzen---#####
        if (sperrkz.equals("N")) {

            sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_SPERR_KZ='J',ART_SPERRDAT=sysdate WHERE ART_NR=" + artnr;
            //out.println(sql);
            stmt.executeQuery(sql);
            out.println("Sperrkennzeichen ge&auml;ndert!<br><font color=\"#ff0000\"><b>Artikel GESPERRT</b></font>");
        }

        //#####---Artikel freigeben-Sperrkennzeichen entfernen---#####
        else if (sperrkz.equals("J")) {

            sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_SPERR_KZ='N' WHERE ART_NR=" + artnr;
            //out.println(sql);
            stmt.executeQuery(sql);
            out.println("Sperrkennzeichen ge&auml;ndert!<br><font color=\"#00ff00\"><b>Artikel FREIGEGEBEN</b></font>");
        } else {
            out.println("B&ouml;ser Fehler:Kein Sperrkennzeichen &uuml;bergeben!!");
        }

        out.println("<br><br>");
        con.close();
    %>
    <a href="./anzeigen.jsp?ART_NR=<%=artnr%>&sent=1&sel=j">zur&uuml;ck zum Artikel</a>
</div>
</body>
</html>
      
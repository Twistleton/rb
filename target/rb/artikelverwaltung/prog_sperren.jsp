<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<HTML>
<HEAD>
    <TITLE>
    </TITLE>
</HEAD>
<BODY bgcolor="#eeeeee">
<div align="center">
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt;
        String sql;
        ResultSet resultSet;

        String prognr = request.getParameter("prognr");
        String art = request.getParameter("art");

        //#####---Eintrag in DB:Tabelle PLR_PRG_SPERR ---#####
        if (art.equals("sperren")) {
            sql = "INSERT INTO PLRV11.PLR_PRG_SPERR (PRG_PRG,PRG_SPERRDAT) VALUES(" + prognr + ",sysdate)";
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("Programm<b>&nbsp;" + prognr + "</b>&nbsp;gesperrt!");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
            }
        } else {
            sql = "DELETE FROM PLRV11.PLR_PRG_SPERR WHERE PRG_PRG=" + prognr;
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("Programm<b>&nbsp;" + prognr + "</b>&nbsp;freigegeben!");
            } catch (SQLException e) {
                out.println("Fehler beim Löschen des Datensatzes:&nbsp;" + e + "<p>");
            }
        }
        out.println("<br><br>");
        con.close();
    %>
    <a href="./blank.html">weiter</a>
</div>
</BODY>
</HTML>

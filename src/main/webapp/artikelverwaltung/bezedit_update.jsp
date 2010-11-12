<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;

    String artNr = request.getParameter("artNr");
    String artBez = request.getParameter("artBez");
    String insertString = artBez.toUpperCase();

    sql = "UPDATE plrv11.plr_art_kopf SET ART_BEZ='" + insertString + "' WHERE ART_NR=" + artNr;
    //out.println(sql);

    try {
        stmt = con.createStatement();
        stmt.executeQuery(sql);
        out.println("<br>Bezeichnung erfolgreich ge&auml;ndert!<br>");
    } catch (SQLException e) {
        out.println("<br>Fehler beim Datenbankeintrag!!<br>" + e + "<p>");
    }

    con.close();
%>
</body>
</html>
      
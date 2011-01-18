<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Ausgangswerte</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    String sql = new String();

    sql = "select distinct ap_syn from plrv11.plr_art_pos left join plrv11.plr_art_kopf ";
    sql += "on ap_syn=art_nr where art_nr is null and ap_syn > '4420000000'";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<h2>Fehlende Bez&uuml;ge! Bitte anlegen</h2>");
    out.println("<TABLE BORDER=1>");
    while (rs.next()) {
        out.println("<TR><TD>" + rs.getString(1) + "</TD></TR>");
    }
    out.println("</TABLE>");
%>
</TABLE>
</body>
</html>
      

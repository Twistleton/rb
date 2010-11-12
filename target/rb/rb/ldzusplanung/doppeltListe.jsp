<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>R&uuml;ckmeldung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<H2>Auftr&auml;ge, die eine Kommissionsbildung verhindern</H2>
Folgende Auftr&auml;ge sind bereits im System vorhanden.
Sie müssen vor eine erneuten Kommissionsbildung gel&ouml;scht werden.
<br>ACHTUNG!!! L&ouml;schen geht nur wenn admin angemeldet ist!!!
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();
    long aktArtikel = 0;
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    sql = " SELECT ako_abnr ";
    sql += " FROM plrv11.plr_auftr_kopf ";
    sql += " INNER JOIN plrv11.plr_auftr_status ON ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix ";
    sql += " INNER JOIN plrv11.zus_kommission ON ako_abnr=kom_abnr ";
    sql += " WHERE as_status <>99 ";
    sql += " AND ako_kommission='B'";
    rs = stmt.executeQuery(sql);
    out.println("<TABLE>");
    while (rs.next()) {
        out.println("<TR><TD><A HREF=\"../zusbemeldung/auftrInfo.jsp?abNr=" + rs.getString("ako_abnr"));
        out.println("\">" + rs.getString("ako_abnr") + "</A></TD</TR>");
    }
    out.println("</TABLE>");
    con.close();
%>
</body>
</html>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Pflege von Attributen</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.neu.attrNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/plrv11Jsp.conf");

    String sql = new String();
    basisDatei datei;
    datei = new basisDatei("/tmp", "tabellen", "txt");
    datei.oeffnen();
    datei.ausgabe.write("\n");

    String wert = new String();
    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    sql = "SELECT table_name,tablespace_name from user_tables ";
    sql += "WHERE tablespace_name is not null and tablespace_name<>'TS_AQ_DB' order by table_name";

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\"><TD>TabName</TD></TR>");
    while (rs.next()) {
        out.println("<TR><TD>" + rs.getString("table_name") + "</TD>");
        out.println("</TR>");
        datei.ausgabe.write("DESC " + rs.getString("table_name") + ";\n");
    }
    out.println("</TABLE>");
    datei.aktiviereDatei();
    datei.schliessen();
    con.close();
%>
</body>
</html>

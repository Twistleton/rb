<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Zuschnitt-Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String wert = new String();
    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    ResultSetMetaData rsmd;
    sql = "select kom_werk_zuschn,kom_fabt_zuschn,sum(ako_se),sum(kom_qm_brutto) FROM ";
    sql += "plrv11.zus_kommission,plrv11.plr_auftr_kopf,plrv11.plr_auftr_status ";
    sql += "WHERE ";
    sql += "as_abnr=ako_abnr AND ";
    sql += "as_abnr=kom_abnr AND ";
    sql += "as_aend_ix=ako_aend_ix AND ";
    sql += "as_status<>99 AND ";
    sql += "kom_status=0 ";
    sql += "group by ";
    sql += "kom_werk_zuschn,kom_fabt_zuschn ";
    sql += "ORDER BY ";
    sql += "kom_werk_zuschn,kom_fabt_zuschn";

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    rsmd = rs.getMetaData();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\"></TR>");

    while (rs.next()) {
        out.println("<TR>");
        for (int lauf = 1; lauf <= rsmd.getColumnCount(); lauf++) {
            out.println("<TD>" + rs.getString(lauf) + "</TD>");
        }
        out.println("</TR>");
    }
    out.println("</TABLE>");
    con.close();

%>
</body>
</html>

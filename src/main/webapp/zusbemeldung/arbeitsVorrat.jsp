<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Arbeitsvorrat</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    String zsSys = new String();
    String pNr = new String();
    DecimalFormat df = new DecimalFormat("#######0.00");

    String sort = new String(" kom_werk_zuschn,min(kom_fabt_zuschn)");
    try {
        sort = request.getParameter("sort");
    }
    catch (Exception e) {
        sort = " kom_werk_zuschn,min(kom_fabt_zuschn)";
    }
    if (sort == null) {
        sort = " kom_werk_zuschn,min(kom_fabt_zuschn)";
    }

    out.println("<CENTER><H2>Arbeitsvorrat</H2><HR>");


    sql = " SELECT ";
    sql += " kom_abnr,kom_art_nr,min(kom_fabt_zuschn),sum(kom_qm_brutto),kom_werk_zuschn,kom_prog,ako_fabt_pps ";
    sql += " FROM plrv11.zus_kommission ";
    sql += " INNER JOIN plrv11.plr_auftr_kopf ON ako_abnr=kom_abnr ";
    sql += " INNER JOIN plrv11.plr_auftr_status ON as_abnr=ako_abnr AND ako_aend_ix=ako_aend_ix ";
    sql += " WHERE kom_status<40 ";
    sql += " AND as_status<>99 ";
    sql += " GROUP BY kom_art_nr,kom_abnr,kom_werk_zuschn,kom_prog,ako_fabt_pps";
    sql += " ORDER BY " + sort;


    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=kom_abnr\">AB-Nr</A></TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=kom_art_nr\">Art-Nr</A></TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=kom_prog\">Prog</A></TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=min(kom_fabt_zuschn)\">Zuschnitt-Tag</A></TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=ako_fabt_pps\">Polst-Tag</A></TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=sum(kom_qm_brutto)\">Brutto-Menge</TD>");
    out.println("<TD ALIGN=CENTER><A HREF=\"arbeitsVorrat.jsp?sort=kom_werk_zuschn\">Werk</A></TD></TR>");
    while (rs.next()) {
        out.println("<TR><TD>");
        out.println("<A HREF=\"../zusbemeldung/auftrInfo.jsp?abNr=" + rs.getString("kom_abnr") + "\">");
        out.println(rs.getString("kom_abnr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.print(rs.getString("kom_art_nr").substring(3, 5) + ".");
        out.println(rs.getString("kom_art_nr").substring(5, 8) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_prog") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString(3) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("ako_fabt_pps") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(df.format(rs.getFloat(4)) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_werk_zuschn"));
        out.println("</TD></TR>");
    }
    con.close();
    out.println("</TABLE>");
%>
</body>
</html>

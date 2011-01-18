<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>In Kommissionierung</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();
    String sqlSelect = new String();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    Statement stmtSelect = con.createStatement();
    ResultSet rs;
    ResultSet rsSelect;
    String zsSys = new String();
    String pNr = new String();
    float sumQm = 0;

    DecimalFormat df = new DecimalFormat("#######0.00");

    String sort = new String(" kom_werk_zuschn,min(kom_fabt_zuschn)");
    String werk = new String();
    String einschr = new String();

    try {
        sort = request.getParameter("sort");
        werk = request.getParameter("werk");
        zsSys = request.getParameter("zsSys");
    }
    catch (Exception e) {
        sort = " min(kom_fabt_zuschn)";
    }
    if (sort == null) {
        sort = " min(kom_fabt_zuschn)";
    }

    out.println("<CENTER><H2>In Kommissionierung</H2><HR>");

    sql = " SELECT ";
    sql += " kom_sammel_abnr,min(kom_fabt_zuschn),sum(kom_qm_brutto),kom_werk_zuschn,kom_zs_sys ";
    sql += " FROM plrv11.zus_kommission ";
    sql += " WHERE kom_status=40 ";
    sql += " AND kom_sammel_abnr is not null ";
    if (werk != null) {
        if (werk.compareTo("") != 0) {
            sql += " AND kom_werk_zuschn=" + werk;
            einschr += "&werk=" + werk;
        }
    }
    if (zsSys != null) {
        if (zsSys.compareTo("") != 0) {
            sql += " AND kom_zs_sys=" + zsSys;
            einschr += "&zsSys=" + zsSys;
        }
    }
    sql += " GROUP BY kom_sammel_abnr,kom_werk_zuschn,kom_zs_sys";
    sql += " ORDER BY " + sort;

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR><TD COLSPAN=\"5\" ALIGN=\"CENTER\">");
    out.println("<FORM ACTION=\"inKommission.jsp\" METHOD=\"GET\">");
    out.println("<TABLE BORDER=\"1\"><TR>");
    out.println("<TD>Werk</TD><TD ALIGN=\"right\">");
    sqlSelect = "SELECT kom_werk_zuschn FROM plrv11.zus_kommission GROUP BY kom_werk_zuschn ORDER BY 1";
    rsSelect = stmtSelect.executeQuery(sqlSelect);
    out.println("<SELECT NAME=\"werk\">");
    while (rsSelect.next()) {
        out.println("<OPTION VALUE=\"" + rsSelect.getString("kom_werk_zuschn") + "\">" + rsSelect.getString("kom_werk_zuschn"));
    }
    out.println("<OPTION VALUE=\"\" SELECTED>Alle</SELECT>");
    out.println("</TD>");
    out.println("<TD ROWSPAN=\"2\"><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Darstellung einschr&auml;nken\"</TD></TR>");
    out.println("<TR><TD>ZS-Sys</TD><TD ALIGN=\"right\">");
    sqlSelect = "SELECT kom_zs_sys FROM plrv11.zus_kommission GROUP BY kom_zs_sys ORDER BY 1";
    rsSelect = stmtSelect.executeQuery(sqlSelect);
    out.println("<SELECT NAME=\"zsSys\">");
    while (rsSelect.next()) {
        out.println("<OPTION VALUE=\"" + rsSelect.getString("kom_zs_sys") + "\">" + rsSelect.getString("kom_zs_sys"));
    }
    out.println("<OPTION VALUE=\"\" SELECTED>Alle</SELECT>");
    out.println("</TD>");
    out.println("</TR></TABLE></FORM></TD></TR>");
    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inKommission.jsp?sort=kom_sammel_abnr" + einschr + "\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inKommission.jsp?sort=min(kom_fabt_zuschn)" + einschr + "\">Zuschnitt-Tag</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inKommission.jsp?sort=sum(kom_qm_brutto)" + einschr + "\">Brutto-Menge</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inKommission.jsp?sort=kom_werk_zuschn" + einschr + "\">Werk</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inKommission.jsp?sort=kom_zs_sys" + einschr + "\">Zus-System</A></TD></TR>");
    while (rs.next()) {
        sumQm += rs.getFloat(3);
        out.println("<TR><TD>");
        out.println("<A HREF=\"../zusadmin/zusSammelAbNrAus.jsp?sANr=" + rs.getString("kom_sammel_abnr") + "\">");
        out.println(rs.getString("kom_sammel_abnr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString(2) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(df.format(rs.getFloat(3)) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_werk_zuschn") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_zs_sys") + "</TD>");

        out.println("</TR>");
    }
    out.println("<TR BGCOLOR=\"#AAAAFF\"><TD></TD><TD></TD><TD ALIGN=\"right\">" + df.format(sumQm) + "</TD><TD></TD></TR>");
    con.close();
    out.println("</TABLE>");
%>
</body>
</html>

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
    String puffer = new String();

    try {
        sort = request.getParameter("sort");
        zsSys = request.getParameter("zsSys");
    }
    catch (Exception e) {

    }
    out.println("<CENTER><H2>Puffer-&Uuml;bersicht</H2><HR>");
    out.println("<TABLE><TR>");
    out.println("<TD>Puffer</TD>");
    out.println("<TD><FORM ACTION=\"pufferVorrat.jsp\" METHOD=\"POST\" NAME=\"puffer\">");
    try {
        if (request.getParameter("puffer") != null) {
            puffer = request.getParameter("puffer");
        } else {
            puffer = "10244100";
        }
    }
    catch (NullPointerException npe) {
        puffer = "10244100";
    }


    sql = "SELECT";
    sql += " att_bez,att_attr";
    sql += " FROM plrv11.plr_attrAttr ";
    sql += " WHERE att_tabname='zusPuffer' ORDER BY att_attr";
    out.println(oraBde.getHtmlSelectAllgS("puffer", sql, puffer));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.print("</FORM></TD></TR></TABLE><HR>");

    sql = " SELECT ";
    sql += " sak_sanr,sak_platz,sak_zs_sys,sum(kom_qm_brutto),art_nr,art_bez";
    sql += " FROM plrv11.zus_sammel_kopf";
    sql += " INNER JOIN plrv11.zus_kommission ON sak_sanr=kom_sammel_abnr ";
    sql += " INNER JOIN plrv11.plr_art_kopf ON sak_artnr=art_nr ";
    sql += " WHERE sak_platz like '" + puffer + "%' ";
    sql += " AND sak_zugew='N' ";
    sql += " AND kom_ab_gedruckt='N' ";
    if (puffer != null) {
        einschr += "&puffer=" + puffer;
    }

    sql += " GROUP BY sak_sanr,sak_platz,sak_zs_sys,art_nr,art_bez";
    sql += " ORDER BY " + sort;

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");

    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=sak_sanr" + einschr + "\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=sak_platz" + einschr + "\">Platz</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=sak_zs_sys" + einschr + "\">ZS-Sys</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=sum(kom_qm_brutto)" + einschr + "\">QM-Brutto</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=art_nr" + einschr + "\">Art-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"pufferVorrat.jsp?sort=art_bez" + einschr + "\">Art-Bez</A></TD></TR>");
    while (rs.next()) {
        sumQm += rs.getFloat(4);
        out.println("<TR><TD>");
        out.println("<A HREF=\"../zusadmin/zusSammelAbNrAus.jsp?sANr=" + rs.getString("sak_sanr") + "\">");
        out.println(rs.getString("sak_sanr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_platz").substring(8) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_zs_sys") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString(4) + "</TD><TD>");
        out.print(rs.getString("art_nr").substring(3, 5) + ".");
        out.println(rs.getString("art_nr").substring(5, 8) + "</TD><TD>");
        out.println(rs.getString("art_bez") + "</TD>");
        out.println("</TR>");
    }
    out.println("<TR BGCOLOR=\"#AAAAFF\"><TD></TD><TD></TD><TD></TD><TD ALIGN=\"right\">" + df.format(sumQm) + "</TD><TD></TD><TD></TD></TR>");
    con.close();
    out.println("</TABLE>");
%>
</body>
</html>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Puffer Zuschnitt</title>
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
    float sumQm = 0;

    DecimalFormat df = new DecimalFormat("#######0.00");

    String sort = new String(" sak_ztag");
    try {
        sort = request.getParameter("sort");
    }
    catch (Exception e) {
        sort = " sak_ztag";
    }
    if (sort == null) {
        sort = " sak_ztag";
    }


    out.println("<CENTER><H2>In Arbeit</H2><HR>");
    out.println("<TABLE><TR><TD BGCOLOR=\"#DDDDFF\">P-Nr</TD><TD BGCOLOR=\"#DDDDFF\"><FORM ACTION=\"inArbeit.jsp\" METHOD=\"POST\" NAME=\"pNr\">");
    try {
        if (request.getParameter("pNr") != null) {
            pNr = request.getParameter("pNr");
        } else {
            pNr = "";
        }
        if (request.getParameter("zsSys") != null) {
            zsSys = request.getParameter("zsSys");
        } else {
            zsSys = "";
        }
    }
    catch (NullPointerException npe) {
        pNr = "";
        zsSys = "";
    }
    sql = "SELECT";
    sql += " CONCAT(ma_pnr,CONCAT(' ',CONCAT(ma_nname,CONCAT(', ',ma_vname)))),ma_pnr";
    sql += " FROM plrv11.bde_madat ";
    sql += " WHERE ma_kst=244 ";
    sql += " AND ma_pnr<>1 ORDER BY ma_pnr";
    out.println(oraBde.getHtmlSelectAllgS("pNr", sql, pNr));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.println("</FORM></TD><TD BGCOLOR=\"#DDFFDD\">Zuschnitt-System</TD><TD BGCOLOR=\"#DDFFDD\">");
    out.println("<FORM ACTION=\"inArbeit.jsp\" METHOD=\"POST\" NAME=\"zsSys\">");

    sql = "SELECT";
    sql += " kom_zs_sys,kom_zs_sys";
    sql += " FROM plrv11.zus_kommission ";
    sql += " WHERE kom_zs_sys<>20 ";
    sql += "GROUP BY kom_zs_sys";

    out.println(oraBde.getHtmlSelectAllgS("zsSys", sql, zsSys));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.println("</FORM></TD><TD>");
    out.println("</TR></TABLE><HR>");


    sql = " SELECT ";
    sql += " sak_sanr,sak_artnr,sak_platz,sak_zs_sys,sak_charg_nr,sak_ztag,sum(kom_qm_brutto),sak_zugew,sak_status,sak_pnr ";
    sql += " FROM plrv11.zus_sammel_kopf";
    sql += " INNER JOIN plrv11.zus_kommission ON sak_sanr=kom_sammel_abnr ";
    sql += " WHERE sak_zugew='J'";
    sql += " AND sak_sanr IN (";
    sql += " SELECT kom_sammel_abnr ";
    sql += " FROM plrv11.zus_kommission ";
    sql += " INNER JOIN plrv11.zus_kom_fs on kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";
    sql += " WHERE kfs_fs_status<40 ) ";
    if (pNr.compareTo("") != 0) {
        sql += "AND sak_pnr=" + pNr;
    } else if (zsSys.compareTo("") != 0) {
        sql += "AND kom_zs_sys=" + zsSys;
    }

    sql += " GROUP BY sak_sanr,sak_artnr,sak_platz,sak_zs_sys,sak_charg_nr,sak_ztag,sak_zugew,sak_status,sak_pnr ";
    sql += " ORDER BY " + sort;


    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inArbeit.jsp?sort=sak_sanr\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inArbeit.jsp?sort=sak_ztag\">Zuschnitt-Tag</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inArbeit.jsp?sort=sum(kom_qm_brutto)\">Brutto-Menge</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inArbeit.jsp?sort=sak_status\">Status</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"inArbeit.jsp?sort=sak_pnr\">PNr</A></TD>");
    out.println("</TR>");
    while (rs.next()) {
        sumQm += rs.getFloat(7);
        out.println("<TR><TD>");
        out.println("<A HREF=\"zusSammelAbNrAus.jsp?sANr=" + rs.getString("sak_sanr") + "\">");
        out.println(rs.getString("sak_sanr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_ztag") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(df.format(rs.getFloat(7)) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_status") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_pnr"));
        out.println("</TD></TR>");
    }
    con.close();
    out.println("<TR BGCOLOR=\"AAAAFF\"><TD></TD><TD></TD><TD ALIGN=\"right\">" + df.format(sumQm) + "</TD><TD></TD><TD></TD></TR>");
    out.println("</TABLE>");
%>
</body>
</html>

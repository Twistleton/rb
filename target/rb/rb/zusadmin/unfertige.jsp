<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Unfertige</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();
    String sqlSelect = new String();
    String einschr = new String();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    Statement stmtSelect = con.createStatement();
    ResultSet rs;
    ResultSet rsSelect;
    String zsSys = new String();
    String pNr = new String();
    String sort = new String(" min(kom_fabt_zuschn)");
    String werk = new String();

    int status = 0;
    int fsStatus = 0;
    int fabt = 0;
    DecimalFormat df = new DecimalFormat("#######0.00");
    out.println("<CENTER><H2>Unfertige</H2><HR>");


    try {
        werk = request.getParameter("werk");
        zsSys = request.getParameter("zsSys");
    }
    catch (Exception e) {

    }

    try {
        fabt = Integer.parseInt(request.getParameter("fabt"));
    }
    catch (Exception e) {
        fabt = 0;
    }

    try {
        sort = request.getParameter("sort");
    }
    catch (Exception e) {
        sort = " min(kom_fabt_zuschn)";
    }
    if (sort == null) {
        sort = " min(kom_fabt_zuschn)";
    }

    sql = " SELECT ";
    sql += " kom_sammel_abnr,kom_abnr,kom_art_nr,kom_prog,kom_werk_zuschn,min(kom_fabt_zuschn),kfs_fs_status,kom_status,kom_zs_sys,kfs_pnr,ako_vlte ";
    sql += " FROM plrv11.zus_kommission ";
    sql += " INNER JOIN plrv11.plr_auftr_kopf ON kom_abnr=ako_abnr ";
    sql += " INNER JOIN plrv11.plr_auftr_status ON ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix ";
    sql += " LEFT OUTER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";
    sql += " LEFT OUTER JOIN plrv11.zus_sammel_kopf ON sak_sanr=kom_sammel_abnr ";
    sql += " WHERE (kfs_fs_status<40 OR kfs_fs_status is null) ";
    sql += " AND (kfs_fs='10244100000' OR (kfs_fs IS NULL AND sak_zugew='N')) ";
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
    if (fabt != 0) {
        sql += " AND kom_fabt_zuschn<=" + fabt;
        einschr += "&fabt=" + fabt;
    }


    sql += " AND kom_werk_zuschn=10 ";
    sql += " GROUP BY kom_sammel_abnr,kom_abnr,kom_art_nr,kom_prog,kom_werk_zuschn,kfs_fs_status,kom_status,kom_zs_sys,kfs_pnr,ako_vlte  ";
    sql += " ORDER BY " + sort;

// out.println ("<BR>"+sql+"<BR>");

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<FORM ACTION=\"unfertige.jsp\" METHOD=\"GET\">");
    out.println("<TR><TD COLSPAN=\"10\" ALIGN=\"CENTER\"><TABLE>");
    out.println("<TR><TD>Werk</TD><TD>ZS-Sys</TD><TD>Fabt (<=zf)</TD></TR>");
    out.println("<TR><TD ALIGN=\"right\">");
    sqlSelect = "SELECT kom_werk_zuschn FROM plrv11.zus_kommission GROUP BY kom_werk_zuschn ORDER BY 1";
    rsSelect = stmtSelect.executeQuery(sqlSelect);
    out.println("<SELECT NAME=\"werk\">");
    while (rsSelect.next()) {
        out.println("<OPTION VALUE=\"" + rsSelect.getString("kom_werk_zuschn") + "\">" + rsSelect.getString("kom_werk_zuschn"));
    }
    out.println("<OPTION VALUE=\"\" SELECTED>Alle</SELECT>");
    out.println("</TD><TD>");
    sqlSelect = "SELECT kom_zs_sys FROM plrv11.zus_kommission GROUP BY kom_zs_sys ORDER BY 1";
    rsSelect = stmtSelect.executeQuery(sqlSelect);
    out.println("<SELECT NAME=\"zsSys\">");
    while (rsSelect.next()) {
        out.println("<OPTION VALUE=\"" + rsSelect.getString("kom_zs_sys") + "\">" + rsSelect.getString("kom_zs_sys"));
    }
    out.println("<OPTION VALUE=\"\" SELECTED>Alle</SELECT>");
    out.println("</TD><TD>");
    out.println("<INPUT TYPE=\"TEXT\" NAME=\"fabt\" \"MAXLENGTH=\"4\" SIZE=\"4\">");
    out.println("</TD></TR>");
    out.println("<TR><TD COLSPAN=\"3\"><INPUT TYPE=\"SUBMIT\" VALUE=\"Anzeige einschr&auml;nken\" NAME=\"ok\"></TD></TR>");

    out.println("</TABLE></TD></TR></FORM>");
    out.println("<TR BGCOLOR=\"#ddddff\">");


    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_sammel_abnr" + einschr + "\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_abnr" + einschr + "\">AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_art_nr" + einschr + "\">Art-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_prog" + einschr + "\">Programm</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_werk_zuschn" + einschr + "\">Werk</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=min(kom_fabt_zuschn)" + einschr + "\">Zuschn.-Fabt</A></TD>");
    out.println("<TD ALIGN=\"CENTER\">VLTE</TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_zs_sys" + einschr + "\">ZS-Sys</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kom_status,kfs_fs_status" + einschr + "\">Status</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"unfertige.jsp?sort=kfs_pnr" + einschr + "\">PNr</A></TD>");
    out.println("</TR>");
    while (rs.next()) {
        status = rs.getInt("kom_status");
        fsStatus = rs.getInt("kfs_fs_status");
        out.println("<TR><TD>");
        out.println("<A HREF=\"zusSammelAbNrAus.jsp?sANr=" + rs.getString("kom_sammel_abnr") + "\">");
        out.println(rs.getString("kom_sammel_abnr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.println("<A HREF=\"../zusbemeldung/auftrInfo.jsp?abNr=" + rs.getString("kom_abnr") + "\">");
        out.println(rs.getString("kom_abnr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.print(rs.getString("kom_art_nr").substring(3, 5) + ".");
        out.print(rs.getString("kom_art_nr").substring(5, 8) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rbTextFormat.format('0', 3, rs.getString("kom_prog")) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_werk_zuschn") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("min(kom_fabt_zuschn)") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("ako_vlte") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_zs_sys") + "</TD><TD ALIGN=\"RIGHT\">");
        if (status == 40) {
            out.println("in Kom.");
        } else if (status == 50) {
            if (fsStatus == 0) {
                out.println("im Puffer");
            } else if (fsStatus == 10) {
                out.println("gestartet");
            } else if (fsStatus == 20) {
                out.println("In Störung");
            } else if (fsStatus == 30) {
                out.println("Störung Ende");
            } else {
                out.println("&nbsp;");
            }
        } else {
            out.println("&nbsp;");
        }
        if (rs.getString("kfs_pnr") != null) {
            out.println("<TD>" + rs.getString("kfs_pnr") + "</TD>");
        } else {
            out.println("<TD>keine</TD>");
        }
        out.println("</TD></TR>");
    }
    con.close();
    out.println("</TABLE>");
%>
</body>
</html>

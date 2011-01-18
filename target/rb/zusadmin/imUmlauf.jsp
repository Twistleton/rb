<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Im Umlauf</title>
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
    String sort = new String(" min(kom_fabt_zuschn)");
    int status = 0;
    int fsStatus = 0;
    DecimalFormat df = new DecimalFormat("#######0.00");
    out.println("<CENTER><H2>Im Umlauf</H2><HR>");


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
    sql += " kom_sammel_abnr,kom_abnr,kom_art_nr,kom_prog,kom_werk_zuschn,min(kom_fabt_zuschn),kfs_fs_status,kom_status,kom_zs_sys,kfs_pnr ";
    sql += " FROM plrv11.zus_kommission ";
    sql += " INNER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";

    sql += " WHERE kom_status>=40 ";
    sql += " AND kom_sammel_abnr is not null ";
    sql += " AND (kfs_fs_status<40 OR kfs_fs_status is null) ";
    sql += " AND kfs_fs='10244100000' ";
    sql += " AND kom_werk_zuschn=10 ";
    sql += " GROUP BY kom_sammel_abnr,kom_abnr,kom_art_nr,kom_prog,kom_werk_zuschn,kfs_fs_status,kom_status,kom_zs_sys,kfs_pnr  ";
    sql += " ORDER BY " + sort;

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_sammel_abnr\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_abnr\">AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_art_nr\">Art-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_prog\">Programm</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=min(kom_fabt_zuschn)\">Zuschn.-Fabt</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_zs_sys\">ZS-Sys</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kom_status,kfs_fs_status\">Status</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"imUmlauf.jsp?sort=kfs_pnr\">PNr</A></TD>");
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
//	out.println(rs.getString("kom_werk_zuschn")                    + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("min(kom_fabt_zuschn)") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("kom_zs_sys") + "</TD><TD ALIGN=\"RIGHT\">");
        if (status == 40) {
            out.println("in Kom.");
        }
        if (status == 50) {
            if (fsStatus == 0) {
                out.println("im Puffer");
            }
            if (fsStatus == 10) {
                out.println("gestartet");
            }
            if (fsStatus == 20) {
                out.println("In Störung");
            }
            if (fsStatus == 30) {
                out.println("Störung Ende");
            }
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

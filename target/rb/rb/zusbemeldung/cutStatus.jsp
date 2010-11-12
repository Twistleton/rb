<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Statusmeldung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    String sql = new String();

    long artNr = 0;
    int abNr = 0;
    int fsStatus = 0;
    int zaehler = 0;

    out.println("<CENTER><B>Statusmeldung Cutter</B><BR>");

    try {
        // Eingabe der Kommissionsnummer erfolgt?
        if (request.getParameter("komNr") != null) {
            artNr = Long.parseLong(request.getParameter("komNr").substring(0, 10));
            abNr = Integer.parseInt(request.getParameter("komNr").substring(10, 16));
        }
        sql = "SELECT kfs_fs_status ";
        sql += " FROM plrv11.zus_kom_fs ";
        sql += " INNER JOIN plrv11.zus_kommission ON kfs_abnr=kom_abnr AND kfs_artnr=kom_art_nr WHERE ";
        sql += " kfs_fs='10244100000' AND ";
        sql += " kom_zs_sys in (10, 11) AND ";
        sql += " (kfs_fs_status<40 OR kfs_fs_status is null) AND ";
        sql += " kfs_abnr=" + abNr + " AND kfs_artnr=" + artNr;
        sql += " GROUP BY kfs_fs_status";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        while (rs.next()) {
            fsStatus = rs.getInt("kfs_fs_status");
            zaehler++;
        }
        if (zaehler == 1) {
            out.println("<FORM ACTION=\"cutStatusEnde.jsp\" METHOD=\"POST\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"abNr\"  VALUE=\"" + abNr + "\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
            out.println("<TABLE BORDER=1><TR><TD>Ab-Nr </TD><TD>" + abNr + "</TD></TR>");
            out.println("<TR><TD>Art-Nr</TD><TD>" + artNr + "</TD></TR>");
            out.println("<TR><TD COLSPAN=2>");
            out.println("<TABLE>");
            if (fsStatus == 10) {
                out.println("<TR><TD>St&ouml;rung Start</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"20\"></TD></TR>");
            }
            if (fsStatus == 20) {
                out.println("<TR><TD>St&ouml;rung Ende</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"30\" CHECKED></TD></TR>");
            }
            if ((fsStatus == 30) || (fsStatus == 10)) {
                out.println("<TR><TD>Ende</TD><TD ALIGN=\"right\">");
                out.println("<INPUT TYPE=\"radio\" NAME=\"status\" VALUE=\"40\" CHECKED></TD></TR>");
            }
            out.println("</TABLE></TD></TR>");
            out.println("<TR><TD ALIGN=\"center\" COLSPAN=2><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
            out.println("</TABLE>");
        } else {
            out.println("Diese Kommission ist nicht vorhanden,<BR>");
            out.println("bereits fertiggemeldet oder<BR>die Fertigungsstufen sind in unterschiedlichen Stati");
        }
    }
    catch (Exception e) {
        out.println("Fehlerhafte Kommissionsnummer<BR>");
    }
    con.close();
%>
</CENTER>
</body>
</html>

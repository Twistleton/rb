<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <title>R&uuml;ckmeldung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.rueckForm.komArtAbNr.focus()"
">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String wert = new String();
    int abNr = 0;
    long artNr = 0;
    int zsSys = 0;
    String restKz = new String("N");
    String reservKz = new String("N");

    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    int anz = 0;

    if (request.getParameter("komArtAbNr") != null) {
        try {
            artNr = Long.parseLong(request.getParameter("komArtAbNr").substring(0, 10));
            abNr = Integer.parseInt(request.getParameter("komArtAbNr").substring(10, 16));

            // Handelt es sich um eine Reservierung oder um einen Rest? ?
            sql = "SELECT kom_rest_kz,kom_reserv_kz,kom_zs_sys FROM plrv11.zus_kommission WHERE ";
            sql += "kom_abnr=" + abNr + " AND kom_art_nr=" + artNr;

            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                restKz = rs.getString("kom_rest_kz");
                reservKz = rs.getString("kom_reserv_kz");
                zsSys = rs.getInt("kom_zs_sys");
            }

            if (zsSys != 31) {
                sql = "SELECT art_zs_sys FROM plrv11.plr_art_kopf WHERE art_nr=" + artNr;
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    zsSys = rs.getInt("art_zs_sys");
                }

                // Reste und Reservierungen werden prinzipiell Manuell geschnitten
                if ((restKz.compareTo("J") == 0) || (reservKz.compareTo("J") == 0)) {
                    zsSys = 30;
                }
            }

            sql = "UPDATE plrv11.zus_kommission ";
            sql += "SET kom_sammel_abnr=NULL,";
            sql += "kom_kom_kz='N',";
            sql += "kom_status=0,";
            sql += "kom_tagesmenge_dat=NULL,";
            sql += "kom_rest_kz='N',";
            sql += "kom_reserv_kz='N',";
            sql += "kom_ab_gedruckt='N',";
            sql += "kom_rest_lagerort  =NULL,";
            sql += "kom_reserv_lagerort=NULL,";
            sql += "kom_zs_sys=" + zsSys;
            sql += " WHERE kom_abnr=" + abNr;
            sql += " AND kom_art_nr=" + artNr;
            sql += " AND kom_abnr NOT IN (SELECT kfs_abnr FROM plrv11.zus_kom_fs ";
            sql += " WHERE kfs_artnr=" + artNr;
            sql += " AND kfs_abnr=" + abNr;
            sql += " AND kfs_fs_status>30";
            sql += " AND kfs_fs='10244100000')";
            anz = stmt.executeUpdate(sql);
            //out.println(sql+"<BR>");

            sql = "UPDATE plrv11.zus_kom_fs ";
            sql += "SET kfs_pnr=NULL,";
            sql += " kfs_fs_status=NULL ";
            sql += " WHERE kfs_abnr=" + abNr;
            sql += " AND   kfs_artnr=" + artNr;
            sql += " AND   kfs_fs='10244100000' ";
            sql += " AND   kfs_fs_status<40 ";
            stmt.executeUpdate(sql);
            if ((restKz.compareTo("J") == 0) || (reservKz.compareTo("J") == 0)) {
                sql = "UPDATE plrv11.zus_rest_reserv SET ";
                sql += "res_status=0 WHERE ";
                sql += "res_abnr=" + abNr;
                sql += " AND res_art_nr=" + artNr;
                stmt.executeUpdate(sql);
            }
            if (anz > 0) {
                out.println("<CENTER><FONT COLOR=\"green\">Daten verarbeitet<br></FONT></CENTER>");
            } else {
                out.println("<CENTER><FONT COLOR=\"red\">Auftrag bereits im Zuschnitt oder nicht");
                out.println("verarbeitet<br></FONT></CENTER>");
            }
        }
        catch (Exception e) {
            out.println("<CENTER><FONT COLOR=\"red\">Fehlerhafte Eingabe!<BR>");
            out.println("Änderung nicht durchgef&uuml;hrt!<BR>" + e.getMessage() + "</FONT></CENTER>");
        }
    }
    out.println("<CENTER><B>R&uuml;ckmeldung nicht bereitgestellter Kommissionen</B><BR>");
    out.println("<TABLE BORDER=1>");
    out.println("<FORM ACTION=\"rueckMeld.jsp\" NAME=\"rueckForm\" METHOD=\"POST\">");
    out.println("<TR><TD><INPUT TYPE=\"text\" NAME=\"komArtAbNr\" SIZE=16 MAXLENGTH=16>");
    out.println("</TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
    out.println("</FORM></TABLE></CENTER>");
    con.close();
%>
</body>
</html>

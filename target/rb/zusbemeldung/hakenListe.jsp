<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Haken an Arbeitspl&auml;tzen</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <H2>Haken an Arbeitspl&auml;tzen</H2>
    <HR>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);

        String sql = new String();
        String sqlAb = new String();
        String sqlReserv = new String();
        String sqlUpdate = new String();
        Statement stmt = con.createStatement();
        Statement stmtAb = con.createStatement();
        ResultSet rs;
        ResultSet rsAb;
        ResultSet rsReserv;
        int i = 0;
        int updates = 0;
        String hkIdStr = new String();
        long hkId = 0;
        int hkLfdNr = 0;
        int hkAnlJahr = 0;
        long hkStandort = 0;

        long neueSaNr = 0;

        String naechsterPlatz = new String();


        try {
            if (request.getParameter("id").compareTo("") != 0) {
                hkIdStr = request.getParameter("id");
                out.print(rbTextFormat.format('0', 3, hkIdStr.substring(0, hkIdStr.length() - 5)) + ".");
                out.print(hkIdStr.substring(hkIdStr.length() - 5, hkIdStr.length() - 3) + ".");
                out.print(hkIdStr.substring(hkIdStr.length() - 3) + "<BR>");

                hkId = Long.parseLong(request.getParameter("id"));
                hkLfdNr = Integer.parseInt(request.getParameter("lfdNr"));
                hkAnlJahr = Integer.parseInt(request.getParameter("anlJahr"));
                hkStandort = Long.parseLong(request.getParameter("standort"));

                Statement stmtReserv = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement stmtUpdate = con.createStatement();

                // out.println("Laufende Nummer--------"+hkLfdNr+"<BR>");
                // Wird der Haken von einem anderen Mitarbeiter benoetigt?
                sqlReserv = "SELECT rkr_sanr,rkr_hkk_id,rkr_platz,rkr_status ";
                sqlReserv += "FROM plrv11.zus_hk_res ";
                sqlReserv += "WHERE rkr_hkk_Id=" + hkId;
                sqlReserv += " AND rkr_status=10 ";
                sqlReserv += " ORDER BY rkr_anlagedat";

                stmtReserv.executeQuery(sqlReserv);
                rsReserv = stmtReserv.getResultSet();
                int zaehler = 0;
                naechsterPlatz = "NULL";
                while (rsReserv.next() && (zaehler < 1)) {
                    neueSaNr = rsReserv.getLong("rkr_sanr");
                    naechsterPlatz = rsReserv.getString("rkr_platz");

                    // Status der Reservierung auf 40 setzen
                    rsReserv.updateInt("rkr_status", 40);
                    rsReserv.updateRow();
                    zaehler++;
                }
                rsReserv.close();

                // Haken-Details aktualisieren
                sqlUpdate = "UPDATE plrv11.zus_haken_detail SET ";
                sqlUpdate += "hkd_akt_platz=" + naechsterPlatz;
                sqlUpdate += " WHERE hkd_id      =" + hkId;
                sqlUpdate += " AND   hkd_lfd_nr  =" + hkLfdNr;
                sqlUpdate += " AND   hkd_anl_jahr=" + hkAnlJahr;
                sqlUpdate += " AND   hkd_mat_kz  ='L'";

                stmtUpdate.executeUpdate(sqlUpdate);
                // out.println("<BR>"+sqlUpdate+"<BR>");

                if (naechsterPlatz.compareTo("NULL") != 0) {
                    // Bei den Kommissonshaken des evtl. gefundenen neuen Mitarbeiters Detail-Daten eintragen
                    sqlUpdate = "UPDATE plrv11.zus_kom_hk ";
                    sqlUpdate += "SET khk_lfd_nr  =" + hkLfdNr;
                    sqlUpdate += ",   khk_standort=" + hkStandort;
                    sqlUpdate += ",   khk_akt_pltz=" + naechsterPlatz;
                    sqlUpdate += " WHERE khk_abnr IN ";
                    sqlUpdate += " (SELECT kom_abnr FROM plrv11.zus_kommission ";
                    sqlUpdate += " WHERE kom_sammel_abnr=" + neueSaNr + ")";
                    sqlUpdate += " AND   khk_hkk_id     =" + hkId;
                    sqlUpdate += " AND   khk_hkk_mat    ='L'";

                    out.println("<H2>Weitergabe des Hakens an Platz <b>");
                    out.println("<font color=\"blue\"> " + naechsterPlatz + " " + hkLfdNr + "</font></b></H2><BR>");
                    //out.println(sqlUpdate+"<BR>");
                    updates = stmtUpdate.executeUpdate(sqlUpdate);
                    out.println(updates + " Haken aktualisiert<BR>");


                } else {
                    out.println("Der Haken kommt jetzt wieder ins Lager.<BR>");
                }
                //con.rollback();
                con.commit();
                out.println("<HR>");
                // out.println(i+" Datens&auml;tze <BR>"+sql);
            }
        }
        catch (Exception e) {
            // out.println(e);
        }

        sql = " SELECT hkd_id,hkd_anl_jahr,hkd_mat_kz,hkd_lfd_nr,hkd_standort,hkd_akt_platz ";
        sql += " FROM plrv11.zus_haken_detail ";
        sql += " INNER JOIN plrv11.bde_apdat ON hkd_akt_platz=ap_platznr ";
        sql += " WHERE hkd_akt_platz IS NOT NULL";

        rs = stmt.executeQuery(sql);
        out.println("<TABLE BORDER=\"1\">");
        out.println("<TR BGCOLOR=\"#ffdddd\">");
        out.println("<TH>Haken-Nr</TH>");
        out.println("<TH>Anlauf-Jahr</TH>");
        out.println("<TH>Material</TH>");
        out.println("<TH>Lfd-Nr.</TH>");
        out.println("<TH>Standort</TH>");
        out.println("<TH>Akt.Platz</TH>");
        out.println("<TH>Ab-Nrn</TH>");
        out.println("<TH>Aktion</TH>");
        out.println("</TH>");
        out.println("</TH></TR>");
        while (rs.next()) {
            out.print("<TR><TD ALIGN=\"right\">");
            out.print(rbTextFormat.format('0', 3, rs.getString("hkd_id").substring(0, rs.getString("hkd_id").length() - 5)) + ".");
            out.print(rs.getString("hkd_id").substring(rs.getString("hkd_id").length() - 5, rs.getString("hkd_id").length() - 3) + ".");
            out.print(rs.getString("hkd_id").substring(rs.getString("hkd_id").length() - 3));
            out.println("</TD><TD ALIGN=\"CENTER\">" + rs.getString("hkd_anl_jahr"));
            out.println("</TD><TD ALIGN=\"CENTER\">" + rs.getString("hkd_mat_kz"));
            out.println("</TD><TD ALIGN=\"CENTER\">" + rs.getString("hkd_lfd_nr"));
            try {
                out.println("</TD><TD ALIGN=\"CENTER\">" + rs.getString("hkd_standort").substring(8));
            }
            catch (Exception ex) {
                out.println("</TD><TD ALIGN=\"CENTER\">Kein Standort");
            }
            out.println("</TD><TD ALIGN=\"CENTER\">" + rs.getString("hkd_akt_platz").substring(8));
            out.println("</TD><TD><TABLE>");
            sqlAb = "SELECT kfs_abnr";
            sqlAb += " FROM plrv11.zus_kom_hk ";
            sqlAb += " INNER JOIN plrv11.zus_kom_fs ON khk_abnr=kfs_abnr AND khk_artnr=kfs_artnr ";
            sqlAb += " WHERE khk_hkk_mat = '" + rs.getString("hkd_mat_kz") + "'";
            sqlAb += " AND khk_hkk_id    = " + rs.getString("hkd_id");
            sqlAb += " AND khk_lfd_nr    = " + rs.getString("hkd_lfd_nr");
            sqlAb += " AND kfs_fs_status < 40 ";
            sqlAb += " AND kfs_fs        = '10244100000'";
            rsAb = stmtAb.executeQuery(sqlAb);
            while (rsAb.next()) {
                out.println("<TR><TD ALIGN=\"RIGHT\">" + rsAb.getString("kfs_abnr") + "</TD></TR>");
            }
            out.println("</TABLE>");
            out.println("<TD><FORM ACTION=\"hakenListe.jsp\" METHOD=\"POST\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"id\"       VALUE=\"" + rs.getString("hkd_id") + "\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"lfdNr\"    VALUE=\"" + rs.getString("hkd_lfd_nr") + "\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"anlJahr\"  VALUE=\"" + rs.getString("hkd_anl_jahr") + "\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"standort\" VALUE=\"" + rs.getString("hkd_standort") + "\">");
            out.println("<INPUT TYPE=\"submit\" NAME=\"ok\"       VALUE=\"Zur&uuml;ckgeben\">");
            out.println("</TD></FORM></TR>");
        }
        out.println("</TABLE>");
        con.close();
    %>
</CENTER>
</body>
</html>

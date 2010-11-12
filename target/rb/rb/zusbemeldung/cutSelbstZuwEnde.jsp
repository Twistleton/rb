<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Vector" %>

<html>
<head>
    <title>Auftragszuweisung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%

        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
// out.println("<H2>"+zcd.getCutZusDrucker()+"</H2>");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);

        zusParam zp = new zusParam(con);
        Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ResultSet rs;

        String sql = new String();
        String[] sANr = request.getParameterValues("sANr");
        String drucker = new String();

        long artNr = 0;
        int updates = 0;

        if (sANr == null) {
            out.println("Es wurden keine Sammel-Auftr&auml;ge ausgew&auml;lt!<BR>");
        } else {
            out.println("<TABLE BORDER=1>");
            out.println("<TR BGCOLOR=\"ddddff\">");
            out.println("<TD ALIGN=\"CENTER\">SA-Nr</TD>");
            out.println("<TD ALIGN=\"CENTER\">FS-Aktualisiert</TD>");
            out.println("<TD ALIGN=\"CENTER\">Papiere gedruckt</TD>");
            out.println("<TD ALIGN=\"CENTER\">Host-Datei</TD>");
            for (int i = 0; i < sANr.length; i++) {
                try {
                    // Drucker festlegen
                    drucker = mitarbeiter.getDrucker(Integer.parseInt(request.getParameter("team")), con);
                    if (drucker.compareTo("") == 0) {
                        // Wenn's keinen Drucker gibt, wird standardmäßig der im Conf-File hinterlegte Drucker verwendet
                        drucker = zcd.getCutZusDrucker();
                    }
                    // Aktuelle Artikel-Nummer selektieren
                    sql = "SELECT kom_art_nr FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sANr[i];
                    sql += " GROUP BY kom_art_nr";
                    rs = stmt.executeQuery(sql);
                    while (rs.next()) {
                        artNr = rs.getLong("kom_art_nr");
                    }

                    out.println("<TR>");
                    sql = "UPDATE plrv11.zus_sammel_kopf SET sak_zugew='J',sak_pnr=" + request.getParameter("team");
                    sql += " WHERE sak_sanr=" + sANr[i];
                    if (stmt.executeUpdate(sql) == 0) {
                        out.println("<TD ALIGN=\"CENTER\"><FONT COLOR=\"red\">" + sANr[i]);
                        out.println("nicht gefunden</FONT></TD>");
                    } else {
                        out.println("<TD ALIGN=\"CENTER\">" + sANr[i] + " => " + request.getParameter("team") + "</TD>");
                    }
                    sql = "UPDATE plrv11.zus_kom_fs SET kfs_pnr=" + request.getParameter("team");
                    sql += ",kfs_fs_status=10 WHERE ";
                    sql += "kfs_fs='10244100000' ";
                    sql += " AND kfs_artnr in (select kom_art_nr FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sANr[i] + ") ";
                    sql += " AND kfs_abnr in (select kom_abnr from plrv11.zus_kommission WHERE kom_sammel_abnr=" + sANr[i] + ")";

                    if (stmt.executeUpdate(sql) == 0) {
                        out.println("<TD><FONT COLOR=\"red\">nicht aktualisiert</TD>");
                    } else {
                        out.println("<TD ALIGN=\"CENTER\">aktualisiert</TD>");
                    }

                    String kzGedruckt = new String();
                    sql = "SELECT kom_ab_gedruckt FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sANr[i];
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    while (rs.next()) {
                        kzGedruckt = rs.getString("kom_ab_gedruckt");
                    }
                    if (kzGedruckt.compareTo("N") == 0) {
                        // Ausdrucken Auftragspapiere
                        druckDatei apd = new druckDatei(zcd.getAbpDruckPfad(), "auftragsPapierDatei", zcd.getAbpEndung());
                        apd.setNameTimestamp();
                        apd.oeffnen();
                        apd.arbeitsBegleitpapiere(Long.parseLong(sANr[i]), con);
                        apd.schliessen();
                        apd.aktiviereDatei();
                        apd.drucken(drucker);
                        out.println("<TD ALIGN=\"CENTER\">Ja</TD>");

                        sql = "UPDATE plrv11.zus_kommission SET ";
                        sql += "kom_ab_gedruckt='J' WHERE kom_sammel_abnr=" + sANr[i];
                        try {
                            stmt.executeUpdate(sql);
                        }
                        catch (SQLException sqlex) {
                        }
                    } else {
                        out.println("<TD ALIGN=\"CENTER\"><FONT COLOR=\"red\">Nein</FONT></TD>");
                    }
                    // Datei an Host
                    bvmDatei bvm = new bvmDatei(zcd.getRueckMeldPfad(), zcd.getRueckMeldEndung());
                    bvm.ausgabe(Long.parseLong(sANr[i]), Integer.parseInt(request.getParameter("team")), con);
                    out.println("<TD ALIGN=\"CENTER\">bereitgestellt</TD>");

                    // Artikelpositionen des Sammel-Auftrags markieren
                    sql = "UPDATE plrv11.plr_art_pos SET ";
                    sql += " ap_sai='B'";
                    sql += " WHERE ap_syn=" + artNr;
                    sql += " AND ap_sai ='N' ";
                    sql += " AND ap_abnr IN (SELECT kom_abnr FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sANr[i] + ")";
                    sql += " AND ap_aend_ix IN ";
                    sql += "(SELECT as_aend_ix ";
                    sql += " FROM plrv11.zus_kommission ";
                    sql += " INNER JOIN plrv11.plr_auftr_status ON kom_abnr=as_abnr";
                    sql += " WHERE as_status<>99)";
                    updates = stmt.executeUpdate(sql);
                    //out.println("<TD>"+updates+"</TD>");
                    con.commit();
                    //con.rollback();
                }
                catch (Exception ex) {
                    out.println("Fehler " + ex + "<BR>" + sql);
                    con.rollback();
                }
            }
            out.println("</TABLE>");
            out.println("Verwendeter Drucker : " + drucker + "<BR>");
            out.println("<FORM ACTION=\"cutSelbstZuwEnde2.jsp\" METHOD=\"POST\">");
            out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
            out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"lauf\"  VALUE=\"1\">");
            out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"team\"  VALUE=\"" + request.getParameter("team") + "\">");
            out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\"    VALUE=\"Weiter\">");
            out.println("</FORM>");

        }
        stmt.close();
        con.close();

    %>
    </FORM>
</CENTER>
</body>
</html>


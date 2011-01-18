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
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        String sql = new String();
        String sqlUpdate = new String();

        int abNr = 0;
        int i = 0;
        int status = 0;
        int updates = 0;
        int aktFabt = 0;
        int anzDatensaetze = 0;

        long sANr = Long.parseLong(rbTextFormat.format('0', 10, bdeZeit.getTimestamp("MMddHHmmss"))) * 10000; // Sammel-Auftrags-Nr
        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        Statement stmt = con.createStatement();
        Statement stmtUpdate = con.createStatement();
        ResultSet rs;

        komDruckDatei kdd = new komDruckDatei(zcd.getZusDruckPfad(), "komdruckdatei", "kdd");

        if (request.getParameter("abNr") != null) {
            try {
                abNr = Integer.parseInt(request.getParameter("abNr"));

                sql = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE FAB_DATUM=TO_CHAR(CURRENT_DATE,'DDMMYY')";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    aktFabt = rs.getInt("fab_fab_tag");
                }

                sql = "SELECT kom_status FROM plrv11.zus_kommission ";
                sql += " WHERE kom_abnr=" + abNr;

                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    status = rs.getInt("kom_status");
                }
                if (status == 0) {
                    out.println("<H2>Der Auftrag wir beschleunigt</H2>");
                    out.println("<IMG SRC=\"beschl.jpg\"><BR>");
                    sql = "SELECT kom_abnr,kom_art_nr,kom_zs_sys ";
                    sql += "FROM plrv11.zus_kommission ";
                    sql += "WHERE kom_abnr=" + abNr;
                    sql += " AND kom_status=0";

                    rs = stmt.executeQuery(sql);
                    while (rs.next()) {
                        sANr++;
                        sqlUpdate = "UPDATE plrv11.zus_kommission ";
                        sqlUpdate += " SET kom_status=40, ";
                        sqlUpdate += " kom_sammel_abnr=" + sANr;
                        sqlUpdate += ",kom_sammel_rflg=1,";
                        sqlUpdate += " kom_zs_sys=30, ";
                        sqlUpdate += " kom_kom_kz='J' ";
                        sqlUpdate += " WHERE kom_abnr=" + abNr;
                        sqlUpdate += " AND kom_art_nr=" + rs.getString("kom_art_nr");
                        // out.println(sqlUpdate+"<BR>");
                        updates = stmt.executeUpdate(sqlUpdate);

                        sql = "SELECT kom_sammel_abnr,kom_abnr,kom_art_nr,kom_charg_nr,kom_fungizid,kom_kz_mf, ";
                        sql += "kom_werk_zuschn,kom_fabt_zuschn,kom_prog,kom_qm_netto,kom_qm_brutto,kom_anz_teile,kom_rest_kz, ";
                        sql += "kom_rest_lagerort,kom_reserv_kz,kom_reserv_lagerort,kom_bemerkung,kom_tagesmenge_dat,kom_kom_kz, ";
                        sql += "kom_gebucht_kz,kom_ab_gedruckt,kom_lager_kz,kom_cutter_kz,kom_manuell_kz,kom_status,kom_anlage_dat, ";
                        sql += "ap_posnr,ap_menge,ap_artnr,ap_bezeichn,ap_sf_hw,ap_klasse,ap_menge_netto,";
                        sql += "ap_menge_sort1,ap_menge_sort2,ap_menge_sort3,ap_menge_brutto, ";
                        sql += "ap_anz_ld,ap_kzbs,ap_bnr3,ap_garn,art_bez,ap_schw_grad,ako_fabt_pps ";
                        sql += "FROM plrv11.zus_kommission ";
                        sql += "INNER JOIN plrv11.plr_art_pos ON ap_abnr=kom_abnr AND ap_syn=kom_art_nr ";
                        sql += "INNER JOIN plrv11.plr_auftr_status ON as_abnr=ap_abnr AND as_aend_ix=ap_aend_ix ";
                        sql += "INNER JOIN plrv11.plr_auftr_kopf  ON as_abnr=ako_abnr AND as_aend_ix=ako_aend_ix ";
                        sql += "INNER JOIN plrv11.plr_art_kopf ON kom_art_nr=art_nr ";
                        sql += "WHERE as_status<>99 ";
                        sql += " AND kom_sammel_abnr=" + sANr;
                        sql += " ORDER BY";
                        sql += " kom_art_nr,kom_abnr,ap_posnr,kom_sammel_abnr";

                        kdd.setNameTimestamp();
                        kdd.oeffnen();
                        kdd.satzEinfuegen("ZULKOM EA " + aktFabt + " 10\n");
                        anzDatensaetze = kdd.dateiAusgabe(sql, con);

                        out.println("Es wurden " + anzDatensaetze + " Datens&auml;tze ausgedruckt<BR>");
                        kdd.schliessen();
                        kdd.aktiviereDatei();
                        out.println(kdd.drucken(zcd.getZusDrucker()));

                    }
                    con.commit();
                } else {
                    out.println("Kein Auftrag zum Beschkeunigen");
                }
            }
            catch (Exception e) {
                out.println("<CENTER><FONT COLOR=\"red\">Fehlerhafte Eingabe!<BR>");
                out.println(e + "</FONT></CENTER>");
                e.printStackTrace();
                con.rollback();
            }
        }
        con.close();
    %>
</CENTER>
</body>
</html>

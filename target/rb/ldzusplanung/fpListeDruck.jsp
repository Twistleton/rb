<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Liste: Farblich passend</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<BODY>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    komDruckDatei kdd = new komDruckDatei(zcd.getZusDruckPfad(), "komdruckdatei", "kdd");
    String sql = new String();
    int anzDatensaetze = 0;
    int aktFabt = 0;
    java.util.Date datum = new java.util.Date();

    sql = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE FAB_DATUM=TO_CHAR(CURRENT_DATE,'DDMMYY')";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        aktFabt = rs.getInt("fab_fab_tag");
    }
    int fabt = 0;

    String fabtString = new String();
    try {
        fabt = Integer.parseInt(request.getParameter("fabt"));
    }
    catch (NumberFormatException nfe) {
        out.println("Fehlerhafte Eingabe");
    }
    if (fabt != 0) {
        fabtString = " kom_fabt_zuschn<=" + fabt;
    } else {
        fabtString = "";
    }

/* **************************************************** */
/* ******** Vergabe der Sammelauftrags-Nummern ******** */

    long sAbNr = Long.parseLong(rbTextFormat.format('0', 10, bdeZeit.getTimestamp("MMddHHmmss"))) * 10000; // Sammel-Auftrags-Nr.
    gruppenWechsel gw = new gruppenWechsel();
    gruppenWechsel gww = new gruppenWechsel();
    int schonHochgezaehlt = 0;
    int saRflg = 1;

    sql = "SELECT kom_sammel_abnr,kom_sammel_rflg,kom_abnr,kom_art_nr,kom_kom_kz,kom_status,kom_lager_kz,kom_zs_sys,";
    sql += "kom_tagesmenge_dat,kom_werk_zuschn FROM plrv11.zus_kommission WHERE ";
    sql += "kom_kom_kz='N' AND ";
    sql += "kom_bnr3>0 AND ";
    sql += "kom_kz_mf<>'F' AND kom_kz_mf<>'M' AND ";
    sql += fabtString;
    sql += " AND kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) ";
    sql += " AND kom_art_nr NOT IN (SELECT art_nr FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
    sql += "ORDER BY kom_art_nr,kom_werk_zuschn";

    Statement stmtUpd = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    stmtUpd.executeQuery(sql);
    rs = stmtUpd.getResultSet();
    while (rs.next()) {
        // Es handelt sich um eine verl. Werkbank
        try {
            if (gw.veraendert(rs.getString("kom_art_nr")) == 1) {
                sAbNr++;
                saRflg = 1;
                schonHochgezaehlt = 1;
            }
            if ((gww.veraendert(rs.getString("kom_werk_zuschn")) == 1) && (schonHochgezaehlt == 0)) {
                sAbNr++;
                saRflg = 1;
            }
            schonHochgezaehlt = 0;
            rs.updateLong("kom_sammel_abnr", sAbNr);
            rs.updateInt("kom_sammel_rflg", saRflg);
            saRflg++;
            //out.println(rs.getString("kom_art_nr")+ " -> "+ sAbNr + "<BR>");
        }
        catch (Exception e) {
            out.println(e.getMessage());
        }
        rs.updateRow();
    }
/* ***************************************************** */

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
    sql += "AND kom_kom_kz='N' ";
    sql += "AND kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) ";
    sql += "AND kom_art_nr NOT IN (SELECT art_nr FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";

    sql += " AND kom_kz_mf<>'F' AND kom_kz_mf<>'M' ";
    sql += " AND " + fabtString;
    sql += " AND kom_bnr3>0 ";
    sql += "ORDER BY ";
    sql += "kom_art_nr,kom_bnr3,kom_werk_zuschn,kom_abnr,ap_posnr,kom_sammel_abnr";

    kdd.setNameTimestamp();
    kdd.oeffnen();
    kdd.satzEinfuegen("ZULKOM PG " + aktFabt + "\n");
    anzDatensaetze = kdd.dateiAusgabe(sql, con);
    out.println("Es wurden " + anzDatensaetze + " Datens&auml;tze ausgedruckt<BR>");
    kdd.schliessen();
    kdd.aktiviereDatei();

    if (anzDatensaetze > 0) {
        sql = "SELECT kom_sammel_abnr,kom_abnr,kom_art_nr,kom_kom_kz,kom_status,kom_lager_kz,kom_zs_sys,";
        sql += "kom_tagesmenge_dat,kom_werk_zuschn FROM plrv11.zus_kommission WHERE ";
        sql += "kom_kom_kz='N' AND ";
        sql += "kom_bnr3>0 AND ";
        sql += fabtString;
        sql += " AND kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) ";
        sql += " AND kom_art_nr NOT IN (SELECT art_nr FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
        sql += "ORDER BY kom_art_nr";

        stmtUpd.executeQuery(sql);
        rs = stmtUpd.getResultSet();
        while (rs.next()) {
            rs.updateString("kom_kom_kz", "J");
            rs.updateInt("kom_status", 40);
            rs.updateString("kom_lager_kz", "N");
            rs.updateInt("kom_zs_sys", 10); // Ehemals 30 - Änderung am 30.01.2008
            if (rs.getInt("kom_werk_zuschn") > 10) {
                // Es handelt sich um eine verl. Werkbank
                try {
                    rs.updateDate("kom_tagesmenge_dat", new java.sql.Date(datum.getTime()));
                }
                catch (Exception e) {
                    out.println(e.getMessage());
                }
            }
            rs.updateRow();
        }
        out.println(kdd.drucken(zcd.getZusDrucker()));
    }
    con.close();
%>
</body>
</html>

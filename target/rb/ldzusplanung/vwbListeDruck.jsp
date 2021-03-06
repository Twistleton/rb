<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Liste: Verl&auml;ngerte Werkbank</title>
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
    int zusTag = 0;

    try {
        zusTag = Integer.parseInt(request.getParameter("zusTag"));
    }
    catch (Exception e) {

    }
    sql = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE FAB_DATUM=TO_CHAR(CURRENT_DATE,'DDMMYY')";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        aktFabt = rs.getInt("fab_fab_tag");
    }
    String werk = new String(request.getParameter("werk"));

/* **************************************************** */
/* ******** Vergabe der Sammelauftrags-Nummern ******** */

    long sAbNr = Long.parseLong(rbTextFormat.format('0', 10, bdeZeit.getTimestamp("MMddHHmmss"))) * 10000; // Sammel-Auftrags-Nr.
    gruppenWechsel gw = new gruppenWechsel();
    int saRflg = 1;

    sql = "SELECT kom_sammel_abnr,kom_sammel_rflg,kom_abnr,kom_art_nr,kom_kom_kz,kom_status,kom_lager_kz,kom_zs_sys,";
    sql += "kom_tagesmenge_dat,kom_werk_zuschn FROM plrv11.zus_kommission WHERE ";
    sql += "kom_werk_zuschn=" + werk + " AND ";
    sql += "kom_kom_kz='N' AND ";
    if (zusTag != 0) {
        sql += "kom_fabt_zuschn<=" + zusTag + " AND ";
    }
    sql += "(kom_bnr3=0 OR kom_bnr3 IS NULL) AND ";
    sql += "kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND ";
    sql += "kom_art_nr NOT IN (SELECT art_nr FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
    sql += "ORDER BY kom_art_nr";

    Statement stmtUpd = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    stmtUpd.executeQuery(sql);
    rs = stmtUpd.getResultSet();
    while (rs.next()) {
        try {
            if (gw.veraendert(rs.getString("kom_art_nr")) == 1) {
                sAbNr++;
                saRflg = 1;
            }
            rs.updateLong("kom_sammel_abnr", sAbNr);
            rs.updateInt("kom_sammel_rflg", saRflg);
            // out.println(rs.getString("kom_art_nr")+ " -> "+ sAbNr+ "<BR>");
            saRflg++;

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

    sql += " AND kom_werk_zuschn=" + werk;
    sql += " AND (kom_bnr3=0 OR kom_bnr3 IS NULL) ";
    if (zusTag != 0) {
        sql += " AND kom_fabt_zuschn<=" + zusTag;
    }
    sql += "ORDER BY ";
    sql += "kom_werk_zuschn,kom_art_nr,kom_bnr3,kom_abnr,ap_posnr";

// out.println(sql);

    kdd.setNameTimestamp();
    kdd.oeffnen();
    kdd.satzEinfuegen("ZULKOM VW " + aktFabt + " " + werk + "\n");
    anzDatensaetze = kdd.dateiAusgabe(sql, con);
    out.println("Es wurden " + anzDatensaetze + " Datens&auml;tze ausgedruckt<BR>");
    kdd.schliessen();
    kdd.aktiviereDatei();

    if (anzDatensaetze > 0) {
        sql = "UPDATE plrv11.zus_kommission SET kom_kom_kz='J',";
        sql += "kom_status=40,kom_tagesmenge_dat=TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD') WHERE ";
        sql += "kom_werk_zuschn=" + werk + " AND kom_kom_kz='N' AND (kom_bnr3=0 OR kom_bnr3 IS NULL) AND ";
        if (zusTag != 0) {
            sql += "kom_fabt_zuschn<=" + zusTag + " AND ";
        }
        sql += "kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND ";
        sql += "kom_art_nr NOT IN (SELECT art_nr FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
        stmt.executeUpdate(sql);
        out.println(kdd.drucken(zcd.getZusDrucker()));
    }
    con.close();
%>
</body>
</html>

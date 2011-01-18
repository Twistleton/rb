<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Sperrungen</title>
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
    int fabt = 0;

    sql = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE FAB_DATUM=TO_CHAR(CURRENT_DATE,'DDMMYY')";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        aktFabt = rs.getInt("fab_fab_tag");
    }
    String sperr = new String(request.getParameter("sperr"));
    try {
        fabt = Integer.parseInt(request.getParameter("fabt"));
    }
    catch (NumberFormatException nfe) {
        out.println("Fehlerhafte Eingabe");
    }

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

    sql += "AND kom_fabt_zuschn <=" + fabt;

    kdd.setNameTimestamp();
    kdd.oeffnen();
    if (sperr.compareTo("prog") == 0) {
        sql += " AND kom_prog IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) ";
        kdd.satzEinfuegen("ZULKOM GP " + aktFabt + " 10\n");
    } else {
        sql += " AND kom_art_nr IN (SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
        kdd.satzEinfuegen("ZULKOM GA " + aktFabt + " 10\n");
    }
    sql += "ORDER BY ";
    sql += "kom_fabt_zuschn,kom_art_nr,kom_abnr,ap_posnr";

// out.println(sql);

    anzDatensaetze = kdd.dateiAusgabe(sql, con);
    out.println("Es wurden " + anzDatensaetze + " Datens&auml;tze ausgedruckt<BR>");
    kdd.schliessen();
    kdd.aktiviereDatei();
    if (anzDatensaetze > 0) {
        out.println(kdd.drucken(zcd.getZusDrucker()));
    }
    con.close();
%>
</body>
</html>

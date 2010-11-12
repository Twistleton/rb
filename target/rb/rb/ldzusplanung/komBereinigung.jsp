<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Restezuordnung</title>
</head>
<BODY>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    komDruckDatei kdd = new komDruckDatei("/tmp", "komdruckdatei", "kdd");

    String sql = new String();

    sql = "SELECT kom_abnr,kom_art_nr,kom_fungizid,kom_qm_netto,kom_qm_brutto,kom_anz_teile,kom_rest_kz, ";
    sql += "kom_anz_teile,kom_rest_kz,kom_rest_lagerort,kom_reserv_kz,kom_bemerkung,kom_tagesmenge_dat,kom_kom_kz, ";
    sql += "kom_gebucht_kz,kom_ab_gedruckt,kom_lager_kz,kom_cutter_kz,kom_manuell_kz,kom_cutter_kz,kom_status,kom_anlage_dat, ";
    sql += "ap_posnr,ap_menge,ap_bezeichn,ap_sf_hw,ap_klasse,ap_menge_netto,ap_menge_sort1,ap_menge_sort2,ap_menge_sort3,ap_menge_brutto, ";
    sql += "ap_anz_ld,ap_kzbs ";
    sql += "FROM plrv11.zus_kommission,plrv11.plr_art_pos,plrv11.plr_auftr_status WHERE ";
    sql += "ap_abnr=kom_abnr AND ";
    sql += "ap_bezug=kom_art_nr AND ";
    sql += "kom_status=10 AND ";
    sql += "ap_abnr=as_abnr AND ";
    sql += "ap_aend_ix=as_aend_ix AND ";
    sql += "as_status<>99 ";
    sql += "ORDER BY ";
    sql += "kom_abnr,ap_posnr";

    out.println(sql);
    kdd.setNameTimestamp();
    kdd.oeffnen();
    kdd.satzEinfuegen("ZULKOM PG\n");
    out.println(kdd.dateiAusgabe(sql, con));
    kdd.schliessen();
    con.close();
%>
</body>
</html>

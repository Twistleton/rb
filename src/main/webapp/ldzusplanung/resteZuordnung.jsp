<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Restezuordnung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<BODY>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    Date datum = new Date();
    float maxKom = 0;
    float minKom = 0;
    float mvMin = new Float(request.getParameter("mvMin")).floatValue();
    float mvMax = new Float(request.getParameter("mvMax")).floatValue();
    long aktArtNr = 0;
    long restLagerort = 0;
    int resId = 0;
    int zaehler = 0;
    int aktAbNr = 0;
    int buendelKlasse = 0;
    String sqlRest = new String();
    String sqlKomZuRest = new String();
    String sqlRestUpdate = new String();
    Connection con = oraBde.getConnection();

    Statement stmtRest = con.createStatement();
    Statement stmtKomZuRest = con.createStatement();
    Statement stmtRestUpdate = con.createStatement();
    ResultSet rsRest;
    ResultSet rsKomZuRest;

// Reste Selektieren
    sqlRest = "SELECT res_id,res_qm_brutto,res_art_nr,res_res_lagerort,res_buendel ";
    sqlRest += "FROM plrv11.zus_rest_reserv ";
    sqlRest += "WHERE res_rest_kz='J' ";
    stmtRest.executeQuery(sqlRest);

    rsRest = stmtRest.getResultSet();

    out.println("<TABLE BORDER=1>");

    out.println("<TR><TD>Art-Nr</TD><TD>Inhalt</TD></TR>");
    while (rsRest.next()) {
        aktArtNr = rsRest.getLong("res_art_nr");
        resId = rsRest.getInt("res_id");
        restLagerort = rsRest.getLong("res_res_lagerort");
        buendelKlasse = rsRest.getInt("res_buendel");
        out.println("<TR><TD>" + aktArtNr + "</TD>");
        try {
            maxKom = rsRest.getFloat("res_qm_brutto") * (mvMax / (float) 100);
            minKom = rsRest.getFloat("res_qm_brutto") * (mvMin / (float) 100);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        sqlKomZuRest = "SELECT kom_abnr,kom_qm_brutto,ap_kz_bart3,ap_bnr3,ako_leder_kl ";
        sqlKomZuRest += "FROM plrv11.zus_kommission,plrv11.plr_art_pos,plrv11.plr_auftr_status,plrv11.plr_auftr_kopf WHERE ";
        sqlKomZuRest += "ap_abnr=kom_abnr AND as_aend_ix=ap_aend_ix AND AS_status<>99 AND as_abnr=ap_abnr AND ";
        sqlKomZuRest += "ako_abnr=as_abnr AND as_aend_ix=ako_aend_ix AND ";
        sqlKomZuRest += "ap_bezug=kom_art_nr AND kom_art_nr=" + aktArtNr + " AND ap_bnr3=0 AND kom_reserv_kz<>'J' AND ";
        sqlKomZuRest += "((TO_CHAR(CURRENT_DATE,'YYYY-MM-DD')=TO_CHAR(kom_tagesmenge_dat,'YYYY-MM-DD')) OR (kom_werk_zuschn>10 AND kom_status=0)) AND ";
        sqlKomZuRest += "kom_kz_mf<>'M' AND kom_kz_mf<>'F' AND kom_kom_kz='N' AND ";
        sqlKomZuRest += "kom_qm_brutto BETWEEN " + minKom + " AND " + maxKom + " AND ";
        sqlKomZuRest += "kom_zs_sys<>31 AND ";
        sqlKomZuRest += "ako_leder_kl<6 AND ";
        sqlKomZuRest += "ako_b_klasse>=" + buendelKlasse + " AND ";
        sqlKomZuRest += "kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND ";
        sqlKomZuRest += "kom_art_nr NOT IN (SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";
        sqlKomZuRest += "GROUP BY kom_abnr,kom_qm_brutto,ap_kz_bart3,ap_bnr3,ako_leder_kl";
        // out.println("<BR>"+sqlKomZuRest);

        stmtKomZuRest.executeQuery(sqlKomZuRest);

        rsKomZuRest = stmtKomZuRest.getResultSet();

        out.println("<TD><TABLE BORDER=1>");
        zaehler = 0;
        while (rsKomZuRest.next() && (zaehler < 1)) {
            aktAbNr = rsKomZuRest.getInt("kom_abnr");

            out.println("<TR><TD>");
            out.println(rsKomZuRest.getString("kom_abnr") + "</TD><TD>" + rsKomZuRest.getFloat("kom_qm_brutto"));

            sqlRestUpdate = "UPDATE plrv11.zus_kommission SET ";
            sqlRestUpdate += "kom_rest_kz='J',kom_rest_lagerort=" + restLagerort + ",kom_lager_kz='N',";
            sqlRestUpdate += "kom_zs_sys=10,kom_status=10 ";
            sqlRestUpdate += "WHERE kom_abnr=" + aktAbNr + " AND kom_art_nr=" + aktArtNr;
            stmtRestUpdate.executeQuery(sqlRestUpdate);

            out.println("</TD><TD>" + restLagerort + "</TD><TD>");
            sqlRestUpdate = "UPDATE plrv11.zus_rest_reserv SET ";
            sqlRestUpdate += "res_abnr=" + aktAbNr + ",res_status=40 WHERE res_id=" + resId;
            sqlRestUpdate += " AND res_art_nr=" + aktArtNr;
            stmtRestUpdate.executeQuery(sqlRestUpdate);

            out.println("</TD></TR>");
            zaehler++;
        }
        out.println("</TABLE>");
        out.println("</TD></TR>");
    }
    out.println("</TABLE>");
    stmtRestUpdate.close();
    stmtKomZuRest.close();
    stmtRest.close();
    con.close();
%>
</body>
</html>

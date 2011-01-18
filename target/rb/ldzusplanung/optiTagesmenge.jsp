<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<html>
<head>
    <title>Kommission Anzeigen</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    Date datum = new Date();
    String sqlTerm = new String();
    String sqlOpti = new String();
    String sqlZuTagesmenge = new String();
    String sqlOptiZuTagesmenge = new String();

    float gesamtSF = 0;
    float gesamtSFBrutto = 0;

    long aktArtikel = 0;
    float nettoMengeTerm = 0;
    long anzTeileTerm = 0;
    float dSchabFlTerm = 0;
    float nettoMengeOpt = 0;
    long anzTeileOpt = 0;
    float dSchabFlOpt = 0;
    float nettoMengeGes = 0;
    long anzTeileGes = 0;
    float dSchabFlGes = 0;
    float optiFakt = new Float(request.getParameter("optifakt")).floatValue();
    int fabt1 = new Integer(request.getParameter("fabt1")).intValue();
    int fabt2 = new Integer(request.getParameter("fabt2")).intValue();
    DecimalFormat df = new DecimalFormat("0.000");
    String ausgabe = new String();

    Connection con = oraBde.getConnection();

// *************************************************************
// ****************** Terminmenge Selektieren ******************
// *************************************************************

    sqlTerm = "SELECT kom_art_nr,sum(kom_qm_netto),sum(kom_anz_teile),sum(kom_qm_brutto) ";
    sqlTerm += "FROM plrv11.zus_kommission ";
    sqlTerm += "LEFT JOIN plrv11.plr_art_kopf ON art_nr = kom_art_nr AND art_sperr_kz='N' AND kom_status<10 AND kom_tagesmenge_dat IS NULL ";
    sqlTerm += "WHERE kom_tagesmenge_dat IS NULL AND kom_kz_mf<>'M' AND kom_kz_mf<>'F' AND ";
    sqlTerm += "kom_art_nr>4420000000 AND kom_fabt_zuschn<=" + fabt1 + " AND ";
    sqlTerm += "kom_kom_kz='N' AND kom_werk_zuschn=10 AND kom_zs_sys<>11 AND kom_prog not in ";
    sqlTerm += "(SELECT prg_prg FROM plrv11.plr_prg_sperr) AND kom_art_nr NOT IN ";
    sqlTerm += "(SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') ";

    sqlTerm += "GROUP BY kom_art_nr";
// out.println(sqlTerm);
    Statement stmtTerm = con.createStatement();
    Statement stmtOpti = con.createStatement();
    Statement stmtUpd = con.createStatement();

    try {
        stmtTerm.executeQuery(sqlTerm);
        ResultSet rsFlTerm = stmtTerm.getResultSet();
        ResultSet rsFlOpti;

        ausgabe = "<TABLE BORDER=\"1\">";
        ausgabe += "<TR BGCOLOR=\"#ffffff\"><TD ALIGN=CENTER>Artikel-Nr</TD>";
        ausgabe += "<TD ALIGN=CENTER>qm(Netto)<BR>Termin</TD>";
        ausgabe += "<TD ALIGN=CENTER>AnzTeile<BR>Termin</TD>";
        ausgabe += "<TD ALIGN=CENTER>&Oslash;-SchablFl<BR>Termin</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#FFDDDD>qm(Netto)<BR>Opti</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#FFDDDD >AnzTeile<BR>Opti</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#FFDDDD>&Oslash;-SchabFl<BR>Opti</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#DDFFDD>qm(Netto)<BR>Gesamt</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#DDFFDD>AnzTeile<BR>Gesamt</TD>";
        ausgabe += "<TD ALIGN=CENTER BGCOLOR=#DDFFDD>&Oslash;<BR>SchabFl<BR>Gesamt</TD></TR>";
        while (rsFlTerm.next()) {
            aktArtikel = rsFlTerm.getLong("kom_art_nr");
            nettoMengeTerm = rsFlTerm.getFloat(2);
            anzTeileTerm = rsFlTerm.getLong(3);
            dSchabFlTerm = nettoMengeTerm / anzTeileTerm;
            gesamtSFBrutto += rsFlTerm.getFloat(4);
            gesamtSF += nettoMengeTerm;

            ausgabe += "<TR><TD BGCOLOR=#ddddff>" + aktArtikel + "</TD><TD ALIGN=right>";
            ausgabe += df.format(nettoMengeTerm) + "</TD><TD ALIGN=right>";
            ausgabe += anzTeileTerm + "</TD><TD ALIGN=right>" + df.format(dSchabFlTerm);

            // *************************************************************
            // ************** Optimierungsmenge Selektieren ****************
            // *************************************************************

            sqlOpti = "SELECT kom_art_nr,sum(kom_qm_netto),sum(kom_anz_teile),sum(kom_qm_brutto) from plrv11.zus_kommission ";
            sqlOpti += "LEFT JOIN plrv11.plr_art_kopf ON art_nr = kom_art_nr AND art_sperr_kz='N' ";
            sqlOpti += "WHERE kom_tagesmenge_dat IS NULL and kom_kz_mf<>'M' AND kom_kz_mf<>'F' AND ";
            sqlOpti += "kom_status<10 AND kom_zs_sys<>11 AND kom_tagesmenge_dat IS NULL AND ";
            sqlOpti += "kom_kom_kz='N' AND kom_werk_zuschn=10 AND ";
            sqlOpti += "kom_art_nr=" + aktArtikel + " AND ";
            sqlOpti += "kom_fabt_zuschn>" + fabt1 + " AND kom_fabt_zuschn<=" + fabt2 + " AND ";
            sqlOpti += "kom_prog NOT IN ";
            sqlOpti += "(SELECT prg_prg FROM plrv11.plr_prg_sperr) AND  kom_art_nr NOT IN ";
            sqlOpti += "(SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J')";
            sqlOpti += " GROUP BY kom_art_nr";

            // Terminmenge zur Tagesmenge hinzufügen
            sqlZuTagesmenge = "UPDATE plrv11.zus_kommission SET kom_status=10,kom_tagesmenge_dat=SYSDATE WHERE kom_art_nr=" + aktArtikel;
            sqlZuTagesmenge += " AND kom_status<10 AND kom_werk_zuschn=10 AND kom_zs_sys<>11 AND kom_kz_mf<>'M' and kom_kz_mf<>'F' and kom_fabt_zuschn<=" + fabt1;
            sqlZuTagesmenge += " AND kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND kom_art_nr NOT IN ";
            sqlZuTagesmenge += "(SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J')";
            // out.println("</TD><TD>"+sqlZuTagesmenge);
            stmtUpd.executeQuery(sqlZuTagesmenge);

            stmtOpti.executeQuery(sqlOpti);
            rsFlOpti = stmtOpti.getResultSet();

            while (rsFlOpti.next()) {
                nettoMengeOpt = rsFlOpti.getFloat(2);
                anzTeileOpt = rsFlOpti.getLong(3);
                dSchabFlOpt = nettoMengeOpt / anzTeileOpt;

                nettoMengeGes = nettoMengeTerm + nettoMengeOpt;
                anzTeileGes = anzTeileTerm + anzTeileOpt;
                dSchabFlGes = nettoMengeGes / anzTeileGes;
                ausgabe += "</TD><TD BGCOLOR=#FFDDDD ALIGN=right>" + df.format(nettoMengeOpt);
                ausgabe += "</TD><TD BGCOLOR=#FFDDDD ALIGN=right>";
                ausgabe += anzTeileOpt + "</TD><TD BGCOLOR=#FFDDDD ALIGN=right>" + df.format(dSchabFlOpt);
                ausgabe += "<TD BGCOLOR=#DDFFDD ALIGN=right>" + df.format(nettoMengeGes);
                ausgabe += "</TD><TD BGCOLOR=#DDFFDD ALIGN=right>" + anzTeileGes;
                ausgabe += "</TD><TD BGCOLOR=#DDFFDD ALIGN=right>" + df.format(dSchabFlGes);
                if ((dSchabFlTerm >= dSchabFlGes * optiFakt) || (dSchabFlTerm <= dSchabFlGes / optiFakt) ||
                        (dSchabFlOpt >= dSchabFlGes * optiFakt) || (dSchabFlOpt <= dSchabFlGes / optiFakt)) {
                    ausgabe += "</TD><TD BGCOLOR=yellow>&nbsp;";
                    gesamtSF += nettoMengeOpt;
                    gesamtSFBrutto += rsFlOpti.getFloat(4);
                    sqlOptiZuTagesmenge = "UPDATE plrv11.zus_kommission SET ";
                    sqlOptiZuTagesmenge += "kom_status=10,kom_tagesmenge_dat=SYSDATE WHERE kom_art_nr=" + aktArtikel;
                    sqlOptiZuTagesmenge += " AND kom_werk_zuschn=10 AND kom_kz_mf<>'M' and kom_kz_mf<>'F' and kom_fabt_zuschn>" + fabt1;
                    sqlOptiZuTagesmenge += " AND kom_status<10 AND kom_zs_sys<>11 AND kom_fabt_zuschn<=" + fabt2;
                    sqlOptiZuTagesmenge += " AND kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND kom_art_nr NOT IN ";
                    sqlOptiZuTagesmenge += " (SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J')";
                    stmtUpd.executeQuery(sqlOptiZuTagesmenge);
                }
            }
            ausgabe += "</TD></TR>";
        }

        out.println("Gesamt-SF (Netto) :" + gesamtSF + "<BR>");
        out.println("Gesamt-SF (Brutto):" + gesamtSFBrutto + "<BR>");
        String sql = new String("");
        out.println(ausgabe + "</TABLE>");
    }
    catch (SQLException sqlex) {
        out.println(sqlex.getMessage());
        out.println(sqlex.toString());
    }
%>
</body>
</html>

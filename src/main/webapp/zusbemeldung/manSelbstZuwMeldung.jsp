<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftragszuweisung Manuell</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <SCRIPT TYPE="text/javascript">
        function checkPNr(t) {
            if (t.value == "1") {
                alert("Wählen Sie bitte en Mitarbeiter aus und drücken Sie ok");
                return false;
            } else {
                return true;
            }
        }
    </SCRIPT>
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();
    con.setAutoCommit(false);
    java.util.Date datum = new java.util.Date();

    Statement stmt = con.createStatement();
    Statement stmtEinarb = con.createStatement();
    Statement stmtHaken = con.createStatement();
    Statement stmtKomm = con.createStatement();
    Statement stmtVorhand = con.createStatement();
    Statement stmtUpdate = con.createStatement();
    Statement stmtW = con.createStatement();
    Statement stmtReserv = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    Statement stmtFreigeben = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);


    ResultSet rs;
    ResultSet rsEinarb;
    ResultSet rsHaken;
    ResultSet rsKomm;
    ResultSet rsVorhand;
    ResultSet rsW;
    ResultSet rsReserv;
    ResultSet rsFreigeben;

    String sql = new String();
    String sqlEinarb = new String();
    String sqlW = new String();
    String sqlHaken = new String();
    String sqlKomm = new String();
    String sqlVorhand = new String();
    String sqlFreigeben = new String();
    String sqlReserv = new String();
    String retString = new String();
    String sqlUpdate = new String();
    String ausgabe = new String();
    String ausgabeHaken = new String();
    String maPlatz = new String("");
    String naechsterPlatz = new String();
    String leihDatum = new String();
    out.println("<B>Auftragszuweisung Manueller Zuschnitt</B><BR>");


    long sANr = 0;
    long neueSaNr = 0;
    long hakenId = 0;
    long hakenStandort = 0;
    long artNr = 0;


    int pNr = 0;
    int hakenLfdNr = 0;
    int hakenAnlJahr = 0;
    int fsStatus = 0;
    int anzUpdates = 0;
    int vollstKomm;
    int hakenDa;

    int abNr = 0;
    int anzKomm = 0;
    int neuZuweis = 0;
    int nochGebraucht = 0;
    int anzEinarb = 0;
    int gefunden = 0;
    int keineEinarbeit = 0;
    int keineSchablonen = 0;
    int aendIx = 0;
    int dezi = 0;

    textDatei errorDatei = new textDatei(zcd.getErrorDir(), "error.log");

    String trace = new String();

    try {
        trace = request.getParameter("trace");
    }
    catch (Exception e) {
    }
    try {
        // Eingabe der Personal-Nummer Erfolgt?
        if (request.getParameter("pNr") != null) {
            pNr = Integer.parseInt(request.getParameter("pNr"));
        }
        if (request.getParameter("artNr") != null) {
            artNr = Long.parseLong(request.getParameter("artNr"));
        }
        if (request.getParameter("abNr") != null) {
            abNr = Integer.parseInt(request.getParameter("abNr"));
        }
        if (request.getParameter("status") != null) {
            fsStatus = Integer.parseInt(request.getParameter("status"));
        }
        if (request.getParameter("neuZuw") != null) {
            neuZuweis = 1;
        }
    }
    catch (Exception e) {
        out.println(e.getMessage() + "<BR>");
    }
// Platz-Nr des Mitarbeiters feststellen
    sql = "SELECT ma_ap FROM plrv11.bde_madat WHERE ma_pnr=" + pNr;
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        maPlatz = rs.getString("ma_ap");
    }


// Status Melden...
    if ((pNr != 0) && (abNr != 0) && (artNr != 0) && (maPlatz.compareTo("") != 0)) {
        try {
            sql = "SELECT as_aend_ix FROM plrv11.plr_auftr_status WHERE as_status<>99 AND as_abnr=" + abNr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                aendIx = rs.getInt("as_aend_ix");
            }

            // Zu welchem Sammelauftrag gehört die Kommission
            sql = "SELECT kom_sammel_abnr,sum(kfs_dezi) FROM plrv11.zus_kommission ";
            sql += "INNER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";
            sql += "WHERE kom_abnr=" + abNr + " AND kom_art_nr=" + artNr;
            sql += " AND kfs_fs='10244100000' ";
            sql += " GROUP BY kom_sammel_abnr";
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                sANr = rs.getLong("kom_sammel_abnr");
                dezi = rs.getInt(2);
            }

            sqlUpdate = "UPDATE plrv11.zus_kom_fs SET kfs_fs_status=" + fsStatus + " WHERE kfs_pnr=" + pNr;
            sqlUpdate += " AND kfs_abnr=" + abNr + " AND kfs_artnr=" + artNr + " AND kfs_fs='10244100000' AND kfs_fs_status<>" + fsStatus;
            anzUpdates = stmtUpdate.executeUpdate(sqlUpdate);
            ausgabeHaken += sqlUpdate + "<BR>" + anzUpdates + "<BR>";

            if (anzUpdates > 0) {
                // out.println("Status-Meldung wurde vorgenommen<BR>");
                // Eintrag in bde_ab_mz

                sql = "INSERT INTO plrv11.bde_ab_mz ";
                sql += "(abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto,abm_artnr) VALUES (";
                sql += abNr + "," + aendIx + ",'10244100000'," + fsStatus + ",'" + bdeZeit.getTimestamp("yyMMddHHmm");
                sql += "'," + pNr + ",10,'N'," + artNr + ")";
                stmt.executeQuery(sql);

                ausgabeHaken += sql + "<BR>";

                if (fsStatus == 40) {
                    // *******************************************************************************************************
                    // *************** Bei Ende-Meldung                                                 **********************
                    // *************** Nicht mehr benötigte Haken ins Lager oder zu MA, der sie braucht **********************
                    // *******************************************************************************************************

                    sql = "SELECT khk_hkk_id,khk_lfd_nr,khk_standort,khk_akt_pltz,khk_hkk_mat ";
                    sql += " FROM plrv11.zus_kom_hk ";
                    sql += " WHERE khk_abnr =" + abNr;
                    sql += " AND khk_artnr  =" + artNr;
                    sql += " AND khk_hkk_mat='L'";
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    while (rs.next()) {
                        out.println("<BR><B>Haken-Nr.:");
                        out.println(rbTextFormat.hakenFormat(rs.getString("khk_hkk_id")));
                        out.println(" (" + rs.getString("khk_lfd_nr") + ")</B><BR>");

                        errorDatei.write(bdeZeit.getTimestamp("dd.MM HH:mm:ss"));
                        errorDatei.write(" P-NR   : " + pNr);
                        errorDatei.write(" AB-Nr. : " + abNr);
                        errorDatei.write(" HK-Nr. : " + rs.getLong("khk_hkk_id"));
                        errorDatei.write(" LFD-Nr.: " + rs.getString("khk_lfd_nr"));

                        // ************** Für alle Leder-Haken der Kommission *************
                        sqlHaken = "SELECT khk_hkk_id FROM ";
                        sqlHaken += "plrv11.zus_kommission ";
                        sqlHaken += "INNER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";
                        sqlHaken += "INNER JOIN plrv11.zus_kom_hk ON kom_abnr=khk_abnr AND kom_art_nr=khk_artnr ";
                        sqlHaken += "WHERE khk_hkk_id=" + rs.getLong("khk_hkk_id");
                        sqlHaken += " AND khk_hkk_mat='L' ";
                        sqlHaken += " AND kom_sammel_abnr=" + sANr;
                        sqlHaken += " AND kfs_fs_status<40";
                        stmtHaken.executeQuery(sqlHaken);
                        rsHaken = stmtHaken.getResultSet();
                        nochGebraucht = 0;
                        while (rsHaken.next()) {
                            nochGebraucht++;
                        }
                        if (nochGebraucht > 0) {
                            // Der Haken wird noch gebraucht in anderen Kommissionen dieses Auftrags
                            out.println("Dieser Haken wird noch ben&ouml;tigt.<BR>");
                            errorDatei.write(" Haken wird noch benötigt \n");
                        } else {
                            // Der Haken wird nicht mehr gebraucht
                            // out.println("Dieser Haken wird nicht mehr ben&ouml;tigt.<BR>");
                            errorDatei.write(" Haken wird frei -> ");
                            // Wird der Haken von einem anderen Mitarbeiter benötigt?
                            sqlReserv = " SELECT rkr_sanr,rkr_hkk_id,rkr_platz,rkr_status ";
                            sqlReserv += " FROM plrv11.zus_hk_res ";
                            sqlReserv += " WHERE rkr_hkk_Id  = " + rs.getString("khk_hkk_id");
                            sqlReserv += " AND   rkr_status  = 10 ";
                            sqlReserv += " ORDER BY rkr_anlagedat";
                            stmtReserv.executeQuery(sqlReserv);
                            rsReserv = stmtReserv.getResultSet();
                            int zaehler = 0;
                            naechsterPlatz = "NULL";
                            leihDatum = "NULL";

                            while (rsReserv.next() && (zaehler < 1)) {
                                neueSaNr = rsReserv.getLong("rkr_sanr");
                                naechsterPlatz = rsReserv.getString("rkr_platz");
                                leihDatum = "SYSDATE";
                                rsReserv.updateInt("rkr_status", 40);
                                rsReserv.updateRow();
                                zaehler++;
                            }
                            rsReserv.close();
                            sqlUpdate = "UPDATE plrv11.zus_haken_detail ";
                            sqlUpdate += " SET hkd_akt_platz=" + naechsterPlatz;
                            sqlUpdate += " ,hkd_leih_dat=" + leihDatum;
                            sqlUpdate += " WHERE hkd_id     =" + rs.getString("khk_hkk_id");
                            sqlUpdate += " AND   hkd_lfd_nr =" + rs.getString("khk_lfd_nr");
                            sqlUpdate += " AND   hkd_mat_kz ='L'";
                            stmtUpdate.executeUpdate(sqlUpdate);
                            // out.println(sqlUpdate+"<BR>");
                            if (naechsterPlatz.compareTo("NULL") != 0) {
                                // Kommissonshaken des (evtl. gefundenen) neuen Mitarbeiters
                                // auf Haken-Detail setzen
                                sqlUpdate = "UPDATE plrv11.zus_kom_hk ";
                                sqlUpdate += " SET khk_lfd_nr=" + rs.getString("khk_lfd_nr");
                                sqlUpdate += "  ,khk_standort=" + rs.getString("khk_standort");
                                sqlUpdate += "  ,khk_akt_pltz=" + naechsterPlatz;
                                sqlUpdate += " WHERE khk_abnr IN ";
                                sqlUpdate += " (SELECT kom_abnr FROM plrv11.zus_kommission ";
                                sqlUpdate += " WHERE kom_sammel_abnr=" + neueSaNr + ")";
                                sqlUpdate += " AND        khk_hkk_id=" + rs.getString("khk_hkk_id");
                                sqlUpdate += " AND       khk_hkk_mat='L'";
                                out.println("<FONT COLOR=\"RED\" SIZE=\"+2\">");
                                out.print("Haken an Arbeitsplatz <B>");
                                out.print(naechsterPlatz.substring(8) + "</B><BR>");
                                out.println("</FONT>");
                                stmtUpdate.executeUpdate(sqlUpdate);
                                // out.println(sqlUpdate+"<BR>");
                                //
                                sqlW = "SELECT ma_pnr FROM plrv11.bde_madat ";
                                sqlW += "WHERE ma_ap=" + naechsterPlatz;
                                stmtW.executeQuery(sqlW);
                                rsW = stmtW.getResultSet();
                                while (rsW.next()) {
                                    haken.historie(con, rs.getLong("khk_hkk_id"), 'L', rs.getInt("khk_lfd_nr"), rsW.getInt("ma_pnr"), 'W');
                                }
                                rsW.close();

                            } else {
                                out.println("Der Haken kommt ins Lager<BR>");
                                haken.historie(con, rs.getLong("khk_hkk_id"), 'L', rs.getInt("khk_lfd_nr"), pNr, 'Z');
                            }
                            errorDatei.write(naechsterPlatz + "\n");
                        }
                    }
                    // Vom aktuellen MA benötigte Haken
                    // *******************************************************************************************************
                    // ************  Suchen nach evtl. reservierten Haken für verbleibende Kommissionen   ********************
                    // *******************************************************************************************************
                    sqlReserv = "SELECT hkd_id,hkd_akt_platz,hkd_lfd_nr,hkd_standort,hkd_mat_kz,hkd_leih_dat ";
                    sqlReserv += "FROM plrv11.zus_haken_detail ";
                    sqlReserv += "WHERE hkd_akt_platz IS NULL ";
                    sqlReserv += " AND hkd_mat_kz='L' ";
                    sqlReserv += " AND hkd_id IN ";
                    sqlReserv += "(SELECT rkr_hkk_id FROM plrv11.zus_hk_res WHERE ";
                    sqlReserv += " rkr_status=10 AND rkr_sanr=" + sANr + ")";
                    stmtReserv.executeQuery(sqlReserv);
                    rsReserv = stmtReserv.getResultSet();
                    while (rsReserv.next()) {
                        out.println("<B><FONT COLOR=\"blue\">Sind inzwischen Haken frei geworden?</FONT></B><BR>");
                        /*
                          DIESEN FALL DARF ES GAR NICHT GEBEN!!!
                          // inzischen ist ein Haken Frei
                          sqlUpdate = "UPDATE plrv11.zus_hk_res SET rkr_status=40 WHERE rkr_sanr="+sANr;
                          sqlUpdate += " AND rkr_hkk_id="+rsReserv.getString("hkd_id");
                          stmtUpdate.executeQuery(sqlUpdate);
                          out.println("Reservierung auf 40 setzen<BR>");

                          rsReserv.updateLong("hkd_akt_platz",Long.parseLong(maPlatz));
                          java.sql.Date  sqlDatum  = new java.sql.Date(datum.getTime());
                          rsReserv.updateDate("hkd_leih_dat", sqlDatum); // cbu
                          rsReserv.updateRow();
                          sqlUpdate  = "UPDATE plrv11.zus_kom_hk SET ";
                          sqlUpdate += " khk_akt_pltz= "+maPlatz;
                          sqlUpdate += ",khk_lfd_nr  = "+rsReserv.getString("hkd_lfd_nr");
                          sqlUpdate += ",khk_standort= "+rsReserv.getString("hkd_standort");
                          // out.println("Kommissionshaken aktualisieren<BR>");
                          ausgabeHaken += sqlUpdate+"<BR>";
                          // In Hakenhistorie Eintragen
                          out.println("In Hakenhistorie eingetragen");
                          haken.historie(con,rsReserv.getLong("hkd_id"),'L',rs.getInt("hkd_lfd_nr"),pNr,'A');
                          */
                    }

                    /*
                     // Lohndaten erstellen
                     sqlUpdate  = "INSERT INTO plrv11.bde_ma_lodat ";
                     sqlUpdate += "(mal_pnr,mal_abnr,mal_fs,mal_dezi,mal_loart,mal_kst,mal_sendtime,mal_status,mal_artnr) VALUES (";
                     sqlUpdate += pNr+","+abNr+",'10244100000',"+dezi+",101,244,'";
                     sqlUpdate += bdeZeit.getTimestamp("yyMMddHHmm")+"',10,"+artNr+")"; */
                    ausgabeHaken += sql + "<BR>";
                    // stmtUpdate.executeUpdate(sqlUpdate);
                }
            } else {
                out.println("Es wurden keine Datensätze zum Verändern gefunden<BR>");
            }
            // out.println("Commit<BR>");
            con.commit();
        }
        catch (SQLException e) {
            out.println("Fehler:" + e.getMessage() + "<BR>");
            out.println("SQL:" + e.getSQLState() + "<BR>");
            out.println("Error:" + e.getErrorCode() + "<BR>");
            out.println("StackTrace:" + e.getStackTrace() + "<BR>");
            e.printStackTrace();
            con.rollback();
        }
    }

    if (trace.compareTo("an") == 0) {
        // out.println(ausgabeHaken);
    }

// Wenn Neuzuweisung...
    if ((neuZuweis == 1) && (pNr != 0) && (maPlatz.compareTo("") != 0)) {
        // Selektion des Sammelauftrags
        // Hier haben wir auf jeden Fall eine Personal-Nummer und der Mitarbeiter soll einen neuen Auftrag bekommen

        //Einarbeit des Mitarbeiters
        sql = "SELECT COUNT(*) FROM plrv11.bde_ma_prog WHERE map_fs='10244100000' AND map_pnr=" + pNr;
        int allgEinarb = 0;
        try {
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                allgEinarb = rs.getInt(1);
            }
        }
        catch (SQLException sqlex) {
            out.println(sqlex.getMessage() + "<BR>" + sql + "<BR>");
        }
        sql = "SELECT sak_pnr,sak_sanr,sak_artnr,sak_ztag,kom_werk_zuschn,sum(kom_qm_brutto) ";
        sql += "FROM plrv11.zus_sammel_kopf ";
        sql += "INNER JOIN plrv11.zus_kommission ON kom_sammel_abnr=sak_sanr ";
        sql += "WHERE sak_zs_sys=30 AND kom_werk_zuschn=10 AND ";
        sql += "(sak_pnr is null OR sak_pnr=" + pNr + ") AND ";
        sql += "sak_zugew='N' ";
        sql += "GROUP BY sak_pnr,sak_sanr,sak_artnr,sak_ztag,kom_werk_zuschn ";
        sql += "ORDER BY sak_pnr ,sak_ztag,sak_artnr,sak_sanr";
        try {
            stmt.executeQuery(sql);
            rs = stmt.executeQuery(sql);
            ausgabe += "<TABLE BORDER=1>";
            ausgabe += "<TR><TD>Sammel-AbNr</TD><TD>PNr</TD><TD>Fabt-Zuschn</TD><TD>Fehlende Einarbeit";
            ausgabe += "<BR> bei ...Programmen</TD><TD>Haken</TD><TD>";
            ausgabe += "Verfügbare</TD></TR>";
            while (rs.next() && (gefunden == 0)) {
                ausgabe += "<TR><TD>" + rs.getString("sak_sanr") + "</TD><TD>" + rs.getString("sak_pnr");
                ausgabe += "</TD><TD>" + rs.getString("sak_ztag") + "</TD>";

                // Wenn Einarbeit gepflegt ist - Einarbeit ueberpruefen
                sqlEinarb = "SELECT kom_prog ";
                sqlEinarb += "FROM plrv11.zus_sammel_kopf ";
                sqlEinarb += "INNER JOIN plrv11.zus_kommission ON sak_sanr=kom_sammel_abnr ";
                sqlEinarb += "LEFT OUTER JOIN plrv11.bde_ma_prog ON kom_prog=map_prog AND ";
                sqlEinarb += "map_fs='10244100000' AND map_pnr=" + pNr;
                sqlEinarb += " WHERE kom_sammel_abnr=" + rs.getString("sak_sanr");
                sqlEinarb += " AND map_prog IS NULL";
                anzEinarb = 0;
                if (allgEinarb > 0) {
                    stmtEinarb.executeQuery(sqlEinarb);
                    rsEinarb = stmtEinarb.getResultSet();
                    ausgabe += "<TD ALIGN=\"CENTER\"><TABLE BORDER=1>";
                    while (rsEinarb.next()) {
                        anzEinarb++;
                        ausgabe += "<TR><TD>" + anzEinarb + "</TD><TD>" + rsEinarb.getString("kom_prog") + "</TD></TR>";
                    }
                    ausgabe += "</TABLE></TD>";
                } else {
                    ausgabe += "<TD>Volle Einarbeit</TD>";
                }
                sqlKomm = "SELECT kom_abnr,kom_art_nr FROM plrv11.zus_kommission WHERE ";
                sqlKomm += "kom_sammel_abnr=" + rs.getString("sak_sanr");
                stmtKomm.executeQuery(sqlKomm);
                rsKomm = stmtKomm.getResultSet();
                vollstKomm = 0;
                anzKomm = 0;
                ausgabe += "<TD>";
                while (rsKomm.next()) {
                    // Benötigte Haken aktueller Kommission Selektieren
                    sqlHaken = "SELECT khk_hkk_id,COUNT(*) FROM plrv11.zus_kom_hk ";
                    sqlHaken += " WHERE khk_abnr   =" + rsKomm.getString("kom_abnr");
                    sqlHaken += " AND   khk_hkk_mat='L'";
                    sqlHaken += " AND   khk_artnr  =" + rsKomm.getString("kom_art_nr");
                    sqlHaken += " GROUP BY khk_hkk_id";
                    stmtHaken.executeQuery(sqlHaken);
                    rsHaken = stmtHaken.getResultSet();
                    hakenDa = 1;
                    ausgabe += "<TABLE BORDER=1>";
                    ausgabe += "<TR><TD>Haken-ID</TD><TD>Anz/Kommission</TD>";
                    ausgabe += "<TD>Verfügbar</TD><TD>Lfd.Kommission</TD><TD>Status</TD></TR>";
                    while (rsHaken.next()) {
                        ausgabe += "<TR><TD>" + rsHaken.getLong(1) + "</TD>";
                        ausgabe += "<TD BGCOLOR=\"yellow\">" + rsHaken.getInt(2) + "</TD><TD BGCOLOR=\"lightgreen\">";
                        // Anzahl vorhandener Haken
                        sqlVorhand = "SELECT COUNT(*) FROM plrv11.zus_haken_detail ";
                        sqlVorhand += " WHERE hkd_id        =" + rsHaken.getLong(1);
                        sqlVorhand += " AND   hkd_standort is not null";
                        sqlVorhand += " AND   hkd_standort >10244500000";
                        sqlVorhand += " AND   hkd_akt_platz is null";
                        sqlVorhand += " AND   hkd_mat_kz    ='L'";
                        stmtVorhand.executeQuery(sqlVorhand);
                        rsVorhand = stmtVorhand.getResultSet();
                        retString = "";
                        while (rsVorhand.next()) {
                            ausgabe += rsVorhand.getInt(1) + "</TD>";
                            if (rsVorhand.getInt(1) == 0) {
                                hakenDa = 0;
                                retString = " <TD BGCOLOR=\"red\">Nicht da!</TD>";
                            }
                        }
                        ausgabe += "<TD>" + vollstKomm + "</TD>";
                        ausgabe += retString;
                        ausgabe += "</TR>\n";
                    }
                    if (hakenDa == 1) {
                        vollstKomm++;
                    }
                    ausgabe += "</TABLE><BR>";
                    anzKomm++;
                }
                if (anzEinarb >= 0) {
                    keineEinarbeit = 1;
                }
                if ((vollstKomm >= 2) || (anzKomm == vollstKomm)) {
                    if (anzEinarb == 0) {
                        ausgabe += "<TD>Drin!</TD></TR>";
                        gefunden = 1;
                        sANr = rs.getLong("sak_sanr");
                    } else {
                        ausgabe += "<TD>Keine Einarbeit</TD><TR>";
                    }
                } else {
                    ausgabe += "<TD>Es fehlen zu viele Haken</TD></TR>";
                    keineSchablonen = 1;
                }
                ausgabe += "</TD></TR>";
            }
            ausgabe += "</TABLE>";
        }
        catch (Exception e) {
            out.println(e.getMessage() + "-" + e.getStackTrace() + "<BR>");
            out.println(sql + "<BR>");
        }
        if (gefunden == 0) {
            out.println("Es wurden keine Auft&auml;ge zugeteilt aufgrund<BR>");
            if (keineSchablonen == 1) {
                out.println("<LI>nicht ausreichend verf&uuml;gbarer Schablonen<BR>");

            }
            if (keineEinarbeit == 1) {
                out.println("<LI>keiner entsprechenden Einarbeit<BR>");
            }

        } else {
            try {
                out.println("<H2>Zuweisung Sammel-Auftrag " + sANr + "</H2>");
                // ******** Kennzeichen SammelAuftrag Zugewiesen setzen *******
                sqlUpdate = "UPDATE plrv11.zus_sammel_kopf SET sak_zugew='J',sak_pnr=" + pNr;
                sqlUpdate += " WHERE sak_sanr=" + sANr;

                stmtUpdate.executeQuery(sqlUpdate);
                // out.println("Sammelauftragskopf aktualisieren<BR>");
                // out.println(sqlUpdate+"<BR>");

                // ******** Setzen der pNr und FS-Status   ********************
                sql = "SELECT kom_abnr,kom_art_nr FROM plrv11.zus_kommission WHERE ";
                sql += "kom_sammel_abnr=" + sANr;
                stmt.executeQuery(sql);

                rs = stmt.getResultSet();
                while (rs.next()) {
                    sqlUpdate = "UPDATE plrv11.zus_kom_fs SET kfs_pnr=" + pNr + ",kfs_fs_status=10 WHERE ";
                    sqlUpdate += "kfs_fs='10244100000' AND kfs_abnr=" + rs.getString("kom_abnr");
                    sqlUpdate += " AND kfs_artnr=" + rs.getString("kom_art_nr");
                    stmtUpdate.executeQuery(sqlUpdate);
                    // out.println("Personalnummer und FS-Status in Kommissions-FS setzen<BR>");
                    // out.println(sqlUpdate+"<BR>");
                }
                // ******* Haken Festlegen und Reservieren ********************

                sql = " SELECT khk_hkk_id ";
                sql += " FROM plrv11.zus_kom_hk ";
                sql += " INNER JOIN plrv11.zus_kommission ON kom_abnr=khk_abnr AND kom_art_nr=khk_artnr ";
                sql += " WHERE kom_sammel_abnr=" + sANr;
                sql += " AND   khk_hkk_mat='L' ";
                sql += " GROUP BY khk_hkk_id";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();

                // Für jeden benötigten Haken...
                while (rs.next()) {
                    // ... Genau EINEN Eintrag aus Haken_Detail 'raussuchen
                    sqlHaken = "SELECT hkd_id,hkd_lfd_nr,hkd_standort,hkd_anl_jahr FROM plrv11.zus_haken_detail WHERE ";
                    sqlHaken += "hkd_id=" + rs.getString("khk_hkk_id");
                    sqlHaken += " AND hkd_akt_platz IS NULL ";
                    sqlHaken += " AND hkd_mat_kz='L'";
                    sqlHaken += " AND hkd_standort is not null ";
                    sqlHaken += " AND hkd_standort >10244500000 ";
                    stmtHaken.executeQuery(sqlHaken);
                    rsHaken = stmtHaken.getResultSet();
                    hakenId = 0;
                    hakenLfdNr = 0;
                    while (rsHaken.next()) {
                        hakenId = rsHaken.getLong("hkd_id");
                        hakenLfdNr = rsHaken.getInt("hkd_lfd_nr");
                        hakenStandort = rsHaken.getLong("hkd_standort");
                        hakenAnlJahr = rsHaken.getInt("hkd_anl_jahr");
                    }

                    if (hakenId != 0) {
                        out.println("<B><FONT COLOR=\"green\">Haken-Detail gefunden: " + hakenId + "</FONT></B><BR>");
                        sqlUpdate = "UPDATE plrv11.zus_haken_detail SET hkd_akt_platz=" + maPlatz;
                        sqlUpdate += ",hkd_leih_dat=SYSDATE ";
                        sqlUpdate += " WHERE hkd_id=" + hakenId;
                        sqlUpdate += " AND hkd_lfd_nr=" + hakenLfdNr;
                        sqlUpdate += " AND hkd_mat_kz='L'";
                        stmtUpdate.executeUpdate(sqlUpdate);
                        // out.println("In Haken-Detail AP Eintragen<BR>");
                        // out.println(sqlUpdate+"<BR>");
                        sqlKomm = "SELECT kom_abnr,kom_art_nr FROM plrv11.zus_kommission ";
                        sqlKomm += "INNER JOIN plrv11.zus_kom_hk ON kom_abnr=khk_abnr AND kom_art_nr=khk_artnr ";
                        sqlKomm += "WHERE kom_sammel_abnr=" + sANr;
                        sqlKomm += " AND khk_hkk_id =" + hakenId;
                        sqlKomm += " AND khk_hkk_mat='L'";
                        stmtKomm.executeQuery(sqlKomm);
                        rsKomm = stmtKomm.getResultSet();
                        while (rsKomm.next()) {
                            sqlUpdate = "UPDATE plrv11.zus_kom_hk SET khk_lfd_nr=" + hakenLfdNr;
                            sqlUpdate += ",khk_standort=" + hakenStandort;
                            sqlUpdate += ",khk_akt_pltz=" + maPlatz;
                            sqlUpdate += " WHERE khk_abnr=" + rsKomm.getString("kom_abnr");
                            sqlUpdate += " AND khk_artnr=" + rsKomm.getString("kom_art_nr");
                            sqlUpdate += " AND khk_hkk_id=" + hakenId;
                            sqlUpdate += " AND khk_hkk_mat='L'";
                            // out.println("Kommissionshaken aktualisieren<BR>");
                            // out.println(sqlUpdate+"<BR>");
                            stmtUpdate.executeUpdate(sqlUpdate);
                            errorDatei.write(bdeZeit.getTimestamp("dd.MM HH:mm:ss"));
                            errorDatei.write(" P-Nr.  : " + pNr);
                            errorDatei.write(" SA-NR  : " + sANr);
                            errorDatei.write(" HKD-ID : " + hakenId);
                            errorDatei.write(" LFD-Nr : " + hakenLfdNr);
                            errorDatei.write(" Arbeitsplatz -> " + maPlatz);
                            errorDatei.write(" Zuweisung\n");
                        }
                        haken.historie(con, hakenId, 'L', hakenLfdNr, pNr, 'A');
                    } else {
                        out.println("<B><FONT COLOR=\"red\">Kein Haken verf&uuml;gbar: " + rs.getString("khk_hkk_id"));
                        out.println("</FONT></B><BR>");
                        sqlUpdate = "INSERT INTO plrv11.zus_hk_res ";
                        sqlUpdate += " (rkr_hkk_id,rkr_platz,rkr_sanr,rkr_anlagedat,rkr_status) VALUES ";
                        sqlUpdate += " (" + rs.getString("khk_hkk_id") + ",";
                        sqlUpdate += maPlatz + "," + sANr + ",TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),10)";
                        stmtUpdate.executeUpdate(sqlUpdate);
                        out.println(" Dieser Haken wird reserviert<BR>");
                        // out.println(sqlUpdate+"<BR>");
                    }
                }


                // ***************** Auftragspapiere drucken ****************************
                druckDatei apd = new druckDatei(zcd.getAbpDruckPfad(), "auftragsPapierDatei", zcd.getAbpEndung());
                apd.setNameTimestamp();
                apd.oeffnen();
                apd.arbeitsBegleitpapiere(sANr, con);
                apd.schliessen();
                apd.aktiviereDatei();
                apd.drucken(zcd.getManZusDrucker());

                sqlUpdate = "UPDATE plrv11.zus_kommission SET kom_ab_gedruckt='J' WHERE kom_sammel_abnr=" + sANr;
                stmtUpdate.executeUpdate(sqlUpdate);

                out.println("Sammelauftrag als gedruckt markieren<BR>");
                // out.println(sqlUpdate+"<BR>");
                out.println("AB Gedruckt");

                con.commit();
                // ******* Zuschnitt-Start-Meldung an Host *********************

                // Datei an Host
                bvmDatei bvm = new bvmDatei(zcd.getRueckMeldPfad(), zcd.getRueckMeldEndung());
                bvm.ausgabe(sANr, pNr, con);
                out.println("Datei für Host bereitgestellt<BR>");
            }
            catch (Exception e) {
                out.println("Neuzuweisung fehlgeschlagen<BR>" + sqlUpdate + "<BR>" + e);
                con.rollback();
            }
        }
    }
    out.println("<FORM ACTION=\"manSelbstZuw.jsp\" METHOD=\"POST\">");
    out.println("<INPUT TYPE=\"hidden\" NAME=\"trace\" VALUE=\"" + trace + "\">");
    out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Weiter zur Selbstzuweisung\">");
    out.println("</FORM>");

    if (trace.compareTo("an") == 0) {
        out.println(ausgabe);
    }

    con.close();
%>
</CENTER>
</body>
</html>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftragszuweisung Cutter</title>
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
    Statement stmt = con.createStatement();
    Statement stmtEinarb = con.createStatement();
    Statement stmtHaken = con.createStatement();
    Statement stmtKomm = con.createStatement();
    Statement stmtVorhand = con.createStatement();
    Statement stmtUpdate = con.createStatement();
    Statement stmtReserv = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    Statement stmtFreigeben = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);

    ResultSet rs;
    ResultSet rsEinarb;
    ResultSet rsHaken;
    ResultSet rsKomm;
    ResultSet rsVorhand;
    ResultSet rsReserv;
    ResultSet rsFreigeben;

    String sql = new String();
    String sqlEinarb = new String();
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
    out.println("<B>Auftragszuweisung Manueller Zuschnitt</B><BR>");


    long sANr = 0;
    long neueSaNr = 0;
    long hakenId = 0;
    long hakenStandort = 0;
    long artNr = 0;


    int pNr = 0;
    int hakenLfdNr = 0;
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

    if ((pNr != 0) && (maPlatz.compareTo("") != 0)) {
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
        sql += "(sak_pnr is null OR sak_pnr=" + pNr + ") ";
//	sql += " AND sak_zugew='N' ";
        sql += "GROUP BY sak_pnr,sak_sanr,sak_artnr,sak_ztag,kom_werk_zuschn ";
        sql += "ORDER BY sak_pnr ,sak_ztag,sak_artnr,sak_sanr";
        try {
            stmt.executeQuery(sql);
            rs = stmt.executeQuery(sql);
            ausgabe += "<TABLE BORDER=1>";
            ausgabe += "<TR><TD>Sammel-AbNr</TD><TD>PNr</TD><TD>Fabt-Zuschn</TD><TD>Fehlende Einarbeit";
            ausgabe += "<BR> bei ...Programmen</TD><TD>Haken</TD><TD>";
            ausgabe += "Verfügbare</TD></TR>";
            while (rs.next()) {
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
                    sqlHaken = "SELECT hkd_id,hkd_lfd_nr,hkd_standort FROM plrv11.zus_haken_detail WHERE ";
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
                    }

                    if (hakenId != 0) {
                        out.println("<B><FONT COLOR=\"green\">Haken-Detail gefunden: " + hakenId + "</FONT></B><BR>");
                        sqlUpdate = "UPDATE plrv11.zus_haken_detail SET hkd_akt_platz=" + maPlatz;
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
                        }
                    } else {
                        out.println("<B><FONT COLOR=\"red\">Kein Haken verf&uuml;gbar</FONT></B><BR>");
                        sqlUpdate = "INSERT INTO plrv11.zus_hk_res ";
                        sqlUpdate += " (rkr_hkk_id,rkr_platz,rkr_sanr,rkr_anlagedat,rkr_status) VALUES ";
                        sqlUpdate += " (" + rs.getString("khk_hkk_id") + ",";
                        sqlUpdate += maPlatz + "," + sANr + ",TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),10)";
                        stmtUpdate.executeUpdate(sqlUpdate);
                        out.println(" Dieser Haken wird reserviert<BR>");
                        // out.println(sqlUpdate+"<BR>");
                    }
                }
                con.rollback();
            }
            catch (Exception e) {
                out.println("Neuzuweisung fehlgeschlagen<BR>" + sqlUpdate + "<BR>" + e);
                con.rollback();
            }
        }
        out.println(ausgabe);

    }
    con.close();
%>

</CENTER>
</body>
</html>

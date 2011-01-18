<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Dezi-Melden</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.deziForm.komNrFs.focus()">
<CENTER>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();
    Connection con = oraBde.getConnection();

    con.setAutoCommit(false);

    Statement stmt = con.createStatement();
    ResultSet rs;

    int pNr = 0;
    int pin = 0;
    int maKst = 0;

    String sql = new String();
    String komNrFs = new String();

    int abNr = 0;
    int zsSys = 0;
    long artNr = 0;
    long fs = 0;

    int aendIx = 0;
    int dezi = 0;
    int j;
    int l;

// Anmeldung überprüfen, wenn fehlerhaft angemeldet, dann Zurück zu Eingabemaske
    try {
        pNr = Integer.parseInt(request.getParameter("pNr")); // Das schafft er halt manchmal nicht
    }
    catch (Exception e) {
        pNr = 0;
        out.println(e);
    }
    try {
        komNrFs = request.getParameter("komNrFs");
        abNr = Integer.parseInt(komNrFs.substring(0, 6));
        artNr = Long.parseLong(komNrFs.substring(6, 16));
        fs = Long.parseLong(komNrFs.substring(16, 27));
        zsSys = Integer.parseInt(komNrFs.substring(27));
    }
    catch (Exception e) {
        zsSys = 0;
    }

// out.println("zsSys="+zsSys+"<BR><BR>");
    sql = "SELECT ma_pnr,ma_pin,ma_recht FROM plrv11.bde_madat WHERE ma_pnr=" + pNr;
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    j = 0;
    while (rs.next()) {
        pin = rs.getInt("ma_pin");
        j++;
    }
    rs.close();

    if ((j != 1) || (request.getParameter("pin").compareTo(String.valueOf(pin)) != 0)) {
        // Falscher Benutzername/Passwort
        out.println("<BR><FONT COLOR=\"red\">Falscher Benutzername/Passwort</FONT><BR>");
    }

    if ((abNr != 0) && (artNr != 0) && (fs != 0) && (pNr != 0) && (j == 1) && (request.getParameter("pin").compareTo(String.valueOf(pin)) == 0)) {
        try {
            sql = "SELECT mal_pnr ";
            sql += "FROM plrv11.bde_ma_lodat ";
            sql += "WHERE mal_abnr=" + abNr;
            sql += " AND mal_fs   ='" + fs + "' ";
            sql += " AND mal_artnr=" + artNr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            l = 0;
            while (rs.next()) {
                l++;
                out.println("<H2><FONT COLOR='red'>Wurde bereits bemeldet von PNr " + rs.getString("mal_pnr") + "</FONT></H2>");
            }
            rs.close();
            if (l == 0) {
                // Ab 1.11.2007 nicht mehr ...
                /*
                if ((zsSys==10) && (pNr<1000)) {
                    pNr +=9000;
                }*/
                if ((zsSys == 10) || (zsSys == 0) || (zsSys == 11)) {
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR><TD COLSPAN=2 ALIGN=CENTER>Gemeldete Daten</TD></TR>");
                    out.println("<TR><TD>Personal-Nr   </TD><TD ALIGN=\"RIGHT\">" + pNr + "</TD></TR>");
                    out.println("<TR><TD>AB-Nr         </TD><TD ALIGN=\"RIGHT\">" + abNr + "</TD></TR>");
                    out.println("<TR><TD>Art-Nr        </TD><TD ALIGN=\"RIGHT\">" + artNr + "</TD></TR>");
                    out.println("<TR><TD>FS            </TD><TD ALIGN=\"RIGHT\">" + fs + "</TD></TR>");
                    out.println("<TR><TD>Zuschnitt-Sys </TD><TD ALIGN=\"RIGHT\">" + zsSys + "</TD></TR>");
                    out.println("</TABLE>");
                    // Wenn 442 <-> 432 ...
                    // 4420000000 AND 4429999999 Leder
                    // 4320000000 AND 4329999999 Stoff
                    int k = 0;
                    int leder = 0;
                    sql = "SELECT ma_kst FROM plrv11.bde_madat WHERE ma_pnr=" + pNr;
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    while (rs.next()) {
                        maKst = rs.getInt("ma_kst");
                    }
                    if ((artNr > (Long.parseLong("4420000000"))) && (artNr <= (Long.parseLong("4429999999")))) {
                        // Es handelt sich um Leder
                        sql = "SELECT kfs_abnr,kfs_artnr,kfs_fs_status,kfs_dezi,as_aend_ix ";
                        sql += "FROM plrv11.zus_kom_fs ";
                        sql += "INNER JOIN plrv11.plr_auftr_status ON kfs_abnr=as_abnr ";
                        sql += "WHERE as_status<>99 AND (kfs_fs_status<40 OR kfs_fs_status is NULL)";
                        sql += " AND kfs_abnr=" + abNr;
                        sql += " AND kfs_artnr=" + artNr;
                        sql += " AND kfs_fs=" + fs;
                        stmt.executeQuery(sql);
                        rs = stmt.getResultSet();
                        while (rs.next()) {
                            k++;
                            dezi = rs.getInt("kfs_dezi");
                            aendIx = rs.getInt("as_aend_ix");
                        }
                        rs.close();
                        leder = 1;
                    } else if ((artNr > (Long.parseLong("4320000000"))) && (artNr <= (Long.parseLong("4329999999")))) {
                        // Es handelt sich um Stoff
                        sql = "SELECT SUM(apz_tr)+SUM(apz_te),apz_tmix_fs,apz_aend_ix FROM plrv11.plr_bez_pos ";
                        sql += "INNER JOIN plrv11.plr_auftr_status ON apz_abnr=as_abnr AND apz_aend_ix=as_aend_ix ";
                        sql += "INNER JOIN plrv11.plr_art_pos      ON apz_abnr=ap_abnr AND apz_aend_ix=ap_aend_ix and apz_posnr=ap_posnr  ";
                        sql += "WHERE apz_abnr=" + abNr;
                        sql += " AND as_status <>99";
                        sql += " AND apz_tmix_fs=" + fs;
                        sql += " AND ap_syn     ='" + artNr;
                        sql += "' GROUP BY apz_tmix_fs,apz_aend_ix";
                        // out.println(sql+"<BR>");
                        stmt.executeQuery(sql);
                        rs = stmt.getResultSet();
                        while (rs.next()) {
                            k++;
                            dezi = rs.getInt(1);
                            aendIx = rs.getInt("apz_aend_ix");
                        }
                        rs.close();
                    }
                    if (k == 0) {
                        // Keine gültige Meldung
                        out.println("<BR>Gemeldete Auftrags-Nr <B><FONT SIZE=+2 COLOR=\"#FF0000\">");
                        out.println(abNr + "</FONT></B> konnte nicht gefunden werden.<BR>");
                        out.println("Meldung wurde nicht verarbeitet!<BR>");
                    } else {
                        if (leder == 1) {
                            out.println("Meldung f&uuml;r Leder<BR>");
                            // gültige Meldung
                            sql = "UPDATE plrv11.zus_kom_fs ";
                            sql += " SET kfs_fs_status=40,kfs_pnr=" + pNr;
                            sql += " WHERE kfs_abnr=" + abNr;
                            sql += " AND  kfs_artnr=" + artNr;
                            sql += " AND kfs_fs=" + fs;
                            stmt.execute(sql);
                        } else {
                            out.println("Meldung f&uuml;r Stoff<BR>");
                        }

                        // Eintrag in Meldezeiten vornehmen
                        sql = "INSERT INTO plrv11.bde_ab_mz";
                        sql += "(abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto,abm_artnr) " +
                                "VALUES (" + abNr +
                                "," + aendIx +
                                ",'" + fs +
                                "',40" +
                                ",'" + bdeZeit.getTimestamp("yyMMddHHmm") +
                                "'," + pNr +
                                ",10,'N'," + artNr + ")";
                        // out.println(sql+"<BR>");
                        stmt.executeQuery(sql);

                        // Lohndaten erstellen
                        sql = "INSERT INTO plrv11.bde_ma_lodat ";
                        sql += "(mal_pnr,mal_abnr,mal_fs,mal_dezi,mal_loart,mal_kst,mal_sendtime,mal_status,mal_artnr) VALUES (";
                        sql += pNr + "," + abNr + ",'" + fs + "'," + dezi + ",101," + maKst + ",'";
                        sql += bdeZeit.getTimestamp("yyMMddHHmm") + "',10," + artNr + ")";
                        // out.println(sql+"<BR>");
                        stmt.executeUpdate(sql);

                        out.println("<B>Meldung Erfolgreich!</B><BR>");
                        con.commit();
                    }
                } else {
                    out.println("<FONT COLOR=\"red\" SIZE=+3>Nur Cutter-Meldungen zulässig</FONT>");
                }
            } else {
                out.println("<BR>Keine Meldung erfolgt!");
            }
        }
        catch (Exception e) {
            con.rollback();
            out.println("Es ist ein Fehler aufgetreten<BR>" + e + "<BR>" + sql);
        }


    }

    if ((pNr != 0) && (j == 1) && (request.getParameter("pin").compareTo(String.valueOf(pin)) == 0)) {
        out.println("\n<H2>Dezi-Meldung</H2>");
        out.println("<TABLE BORDER=1>");
        out.println("<FORM ACTION=\"zusDeziEin.jsp\" name=\"deziForm\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"pNr\"      VALUE=\"" + request.getParameter("pNr") + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"pin\"      VALUE=\"" + request.getParameter("pin") + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"formular\" VALUE=\"deziEin\">");
        out.println("<TR BGCOLOR=#DDDDFF><TD>Kommissions-Nr und<BR>Fertigungsstufe</TD>");
        out.println("<TD ALIGN=right><INPUT TYPE=\"TEXT\"   NAME=\"komNrFs\" SIZE=\"35\"  MAXLENGTH=\"31\" onChange=\"document.deziForm.submit();\"></TD>");
        out.println("<TD ALIGN=right><INPUT TYPE=\"SUBMIT\" NAME=\"enter\" VALUE=\"OK\"></TD></TR></FORM>");
        out.println("<FORM ACTION=\"zusDeziLogin.jsp\" NAME=\"logoutForm\" METHOD=\"POST\">");
        out.println("<TR BGCOLOR=#FFDDDD><TD COLSPAN=2>Abmelden</TD><TD ALIGN=right>");
        out.println("<INPUT TYPE=\"submit\" VALUE=\"OK\"></TD></TR></FORM>");
        out.println("</TABLE>");
    }
%>
</CENTER>
</BODY>
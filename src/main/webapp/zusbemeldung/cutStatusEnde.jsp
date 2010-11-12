<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.lang.Math" %>
<%@ page import="java.math.*" %>

<html>
<head>
    <title>Statusmeldung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();


    Connection con = oraBde.getConnection();
    con.setAutoCommit(false);

    Statement stmt = con.createStatement();
    Statement stmtMa = con.createStatement();
    ResultSet rs;
    ResultSet rsMa;

    String sql = new String();
    String sqlMa = new String();
    String drucker = new String();        // Drucker

    long sammelauftrag = 0;
    long artNr = 0;
    int abNr = 0;
    int anzFs = 0;
    int fsStatus = 0;
    int team = 0;
    int anzMa = 0;
    int aendIx = 0;
    BigDecimal dezi = new BigDecimal("0.00");
    dezi.setScale(2);
    BigDecimal erg = new BigDecimal("0.00");
    erg.setScale(2);
    BigDecimal zehn = new BigDecimal("10.00");
    zehn.setScale(2);


    BigDecimal faktor = new BigDecimal("0.87");

    out.println("<CENTER><B>Statusmeldung Cutter</B><BR>");

    try {
        // Eingabe der Kommissionsnummer erfolgt?
        if ((request.getParameter("abNr") != null) &&
                (request.getParameter("artNr") != null) &&
                (request.getParameter("status") != null)) {
            artNr = Long.parseLong(request.getParameter("artNr"));
            abNr = Integer.parseInt(request.getParameter("abNr"));
            fsStatus = Integer.parseInt(request.getParameter("status"));
        }
        // Team heraussuchen
        sql = "SELECT kfs_pnr FROM plrv11.zus_kom_fs WHERE kfs_abnr=" + abNr + " AND kfs_artnr=" + artNr;
        sql += " AND  kfs_fs='10244100000' ";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        while (rs.next()) {
            team = rs.getInt("kfs_pnr");
        }

        // Gibts hier noch zu bemeldende Fertigungsstufen für diese Kommission

        sql = "SELECT COUNT(*) FROM ";
        sql += "plrv11.zus_kommission ";
        sql += "INNER JOIN plrv11.zus_kom_fs ON kom_abnr=kfs_abnr AND kom_art_nr=kfs_artnr ";
        sql += "WHERE kom_zs_sys in (10, 11) AND (kfs_fs_status<40 OR kfs_fs_status is null) AND kom_status=50 AND ";
        sql += "kom_abnr=" + abNr;
        sql += " AND  kom_art_nr=" + artNr;
        sql += " AND kfs_fs='10244100000'";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();

        while (rs.next()) {
            anzFs = rs.getInt(1);
        }
        if (anzFs > 0) {
            sql = "SELECT as_aend_ix FROM plrv11.plr_auftr_status ";
            sql += "WHERE as_status<>99 AND as_abnr=" + abNr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                aendIx = rs.getInt("as_aend_ix");
            }

            sql = "UPDATE plrv11.zus_kom_fs SET kfs_fs_status=" + fsStatus + " WHERE kfs_abnr=" + abNr;
            sql += " AND kfs_artnr=" + artNr + " AND kfs_fs='10244100000' ";
            // out.println(sql+"<BR><BR>");
            stmt.executeQuery(sql);

            // Eintrag in Meldezeiten vornehmen
            sql = "INSERT INTO plrv11.bde_ab_mz ";
            sql += "(abm_abnr,abm_aend_ix,abm_fs,abm_fs_status,abm_sendtime,abm_pnr,abm_status,abm_kz_auto,abm_artnr) VALUES (";
            sql += abNr + "," + aendIx + ",'10244100000'," + fsStatus + ",'" + bdeZeit.getTimestamp("yyMMddHHmm");
            sql += "'," + team + ",10,'N'," + artNr + ")";
            // out.println(sql+"<BR>");
            stmt.executeUpdate(sql);

            // Ermitteln der Sammelauftragsnummer (nur bei Zuschnittssystem 11)
            sql = "SELECT kom_sammel_abnr    							" +
                    "  FROM plrv11.zus_kommission 							" +
                    " WHERE kom_abnr   = " + abNr +
                    "   AND kom_art_nr = " + artNr +
                    "   AND kom_zs_sys = 11                                                          ";

            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            sammelauftrag = 0;
            while (rs.next()) {
                sammelauftrag = rs.getLong("kom_sammel_abnr");
            }

            // Sammelauftrag für Zuschnittssystem 11 vorhanden? Dann Lieferscheindaten erzeugen
            if (sammelauftrag > 0) {
                druckDateiLSLohnzuschnitt ls = new druckDateiLSLohnzuschnitt(zcd.getlsDruckPfad(), "lsPapierDatei", zcd.getlsEndung());
                // Dateiname wird auf timestamp gesetzt
                ls.setNameTimestamp();
                ls.oeffnen();
                ls.arbeitsBegleitpapiere(sammelauftrag, con);
                ls.schliessen();
                // aktivieren bedeutet: Umbenennen der Datei von soundso.tmp in
                // soundso.wiedieDateiEndnungSeinSoll
                // Somit wird verhindert, dass ein Druckprozess die Datei holt, bevor sie fertig ist.
                ls.aktiviereDatei();
                // Ausdrucken auf den im Configurations-File eingestellten Drucker
                drucker = zcd.getCutZusDrucker();
                ls.drucken(drucker);
            }

            //

            /*
           2006-10-23 Keine Lohndatensätze mehr über die Anwendung erzeugen
           if (fsStatus==40) {
               // Ermitteln der DEZI
               sql  = "SELECT sum(kfs_dezi) FROM plrv11.zus_kom_fs ";
               sql += "WHERE kfs_abnr="+abNr+" AND kfs_artnr="+artNr;
               sql += " AND kfs_fs='10244100000' ";
               stmt.executeQuery(sql);
               rs = stmt.getResultSet();
               out.println("<TABLE BORDER=1>");
               sqlMa = "SELECT ma_nname,ma_vname FROM plrv11.bde_madat WHERE ma_pnr="+team;
               rsMa = stmtMa.executeQuery(sqlMa);
               while (rsMa.next()) {
                   out.println("<TR><TD><B>Team: "+team+"</TD><TD><B>"+rsMa.getString("ma_nname")+" - "+rsMa.getString("ma_vname")+"</B></TD></TR>");
               }
               while (rs.next()) {
                   dezi  = rs.getBigDecimal(1);
                   erg   = faktor.multiply(rs.getBigDecimal(1));
                   out.println("<TR><TD>Errechnete Dezi</TD><TD>" + faktor+" * ");
                   out.println(dezi.divide(zehn,2,BigDecimal.ROUND_HALF_UP)+"=");
                   out.println(erg.divide(zehn,2,BigDecimal.ROUND_HALF_UP)+"</TD></TR>");
               //	out.println("<TR><TD>Errechnete Dezi (intern)</TD><TD>" + faktor+" * "+dezi+"="+erg+"</TD></TR>");
               }

               sql = "SELECT count(*) FROM plrv11.bde_madat WHERE ma_team="+team+" AND ma_team_kz='N' AND ma_prod='J'";
               stmt.executeQuery(sql);
               rs = stmt.getResultSet();
               int zaehler=0;
               while (rs.next()) {
                   anzMa = rs.getInt(1);
               }
               out.println("<TR><TD>Isgesammt im Team</TD><TD ALIGN=\"right\">"+anzMa+" Personen</TD></TR>");
               out.println("<TR><TD>Für jeden Mitarbeiter</TD><TD ALIGN=\"right\">");
               erg = erg.divide(new BigDecimal(anzMa),BigDecimal.ROUND_HALF_UP);

               out.println(erg.divide(zehn,1,BigDecimal.ROUND_HALF_UP)+"<BR>(intern ");
               erg = erg.setScale(0,BigDecimal.ROUND_HALF_UP);
               out.println(erg+"<BR>");
               out.println("</TD</TR>");
               // Lohndatensaetze an Host erstellen
               sqlMa = "SELECT ma_pnr FROM plrv11.bde_madat WHERE ma_team_kz='N' AND ma_team="+team;
               stmtMa.executeQuery(sqlMa);
               rsMa = stmtMa.getResultSet();
               while (rsMa.next()) {
                   sql  = "INSERT INTO plrv11.bde_ma_lodat ";
                   sql += "(mal_pnr,mal_abnr,mal_fs,mal_dezi,mal_loart,mal_kst,mal_sendtime,mal_status,mal_artnr) VALUES (";
                   sql += rsMa.getString("ma_pnr")+","+abNr+",'10244100000',";
                   sql += erg+",101,244,'"+bdeZeit.getTimestamp("yyMMddHHmm")+"',10,"+artNr+")";
                   stmt.executeUpdate(sql);
                   // out.println("<TR><TD>"+sql+"</TD></TR>");
               }
               out.println("</TABLE>");
           }
           */
            con.commit();
        }
    }
    catch (Exception e) {
        out.println("Fehlerhafte Kommissionsnummer<BR>" + e + "<BR>" + sql);
        con.rollback();
    }
    out.println("<FORM ACTION=\"cutStatusEin.jsp\" METHOD=\"POST\">");
    out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Weiter zur Statusmeldung\">");
    out.println("</FORM>");

    con.close();
%>
</CENTER>
</body>
</html>

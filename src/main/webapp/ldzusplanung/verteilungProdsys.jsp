<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Restezuordnung</title>
</head>
<BODY>
<%

    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    zusParam zp1 = new zusParam(con);

    Statement stmt = con.createStatement();
    Statement updStmt = con.createStatement();
    ResultSet rs;
    float schabFlGes = 0;
    float schabFlGesBrutto = 0;
    float flMaxCut = 0;
    float flMaxCutBrutto = 0;
    float flMaxMan = 0;
    float flMaxManBrutto = 0;
    float prozMaxCut = zp1.getWert("prozMaxCut"); // Maximaler Prozentsatz für Cutter-Bearbeitung
    float flAktCut = 0;
    int zaehler = 0;
    DecimalFormat df = new DecimalFormat("#######0.000");


    try {

        String sql = new String();
        String wheres = new String();
        String sqlUpdate = new String();

// Gesamte Schablonenfläche ermitteln
        sql = "SELECT sum(kom_qm_netto),sum(kom_qm_brutto) FROM plrv11.zus_kommission WHERE ";
        wheres = "kom_status=10 AND ";
        wheres += "kom_kz_mf<>'M' AND kom_kz_mf<>'F' AND ";
        wheres += "kom_bnr3=0 AND ";
        wheres += "kom_zs_sys <> 11  AND ";
        wheres += "kom_reserv_kz='N' AND ";
        wheres += "kom_rest_kz='N' AND ";
        wheres += "kom_werk_zuschn=10 AND ";
        wheres += "kom_kom_kz='N' AND ";
        wheres += "kom_prog NOT IN (SELECT prg_prg FROM plrv11.plr_prg_sperr) AND ";
        wheres += "kom_art_nr NOT IN (SELECT art_nr  FROM plrv11.plr_art_kopf WHERE art_sperr_kz ='J') AND ";
        wheres += "kom_sammel_abnr IS NULL ";
        sql += wheres;
// out.println(sql+"<BR><BR>");
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        while (rs.next()) {
            schabFlGes = rs.getFloat(1);
            schabFlGesBrutto = rs.getFloat(2);
        }

        flMaxCut = schabFlGes * prozMaxCut / 100;
        flMaxMan = schabFlGes - flMaxCut;
        flMaxCutBrutto = schabFlGesBrutto * prozMaxCut / 100;
        flMaxManBrutto = schabFlGesBrutto - flMaxCutBrutto;
        int aktZsSys = 0;

        out.println("<TABLE BORDER=1>");
        out.println("<TR BGCOLOR=#ffffff><TD COLSPAN=3 ALIGN=CENTER>Voreingestellte Max-Werte</TD></TR>");
        out.println("<TR BGCOLOR=#ffffff><TD>&nbsp;</TD><TD>Netto</TD><TD>Brutto</TD></TR>");
        out.println("<TR><TD>Gesamt</TD><TD ALIGN=right>" + df.format(schabFlGes) + "</TD><TD ALIGN=right>" + df.format(schabFlGesBrutto));
        out.println("</TD></TR>");
        out.println("<TR><TD>Max Cutter (" + prozMaxCut + "%)</TD><TD ALIGN=right>");
        out.println(df.format(flMaxCut) + "</TD><TD ALIGN=right>" + df.format(flMaxCutBrutto) + "</TD></TR>");
        out.println("<TR><TD>Max Manuell (" + (100 - prozMaxCut) + "%)</TD><TD ALIGN=right>" + df.format(flMaxMan) + "</TD><TD ALIGN=right>" + df.format(flMaxManBrutto));
        out.println("</TD></TR></TABLE>");

// **************  Verteilung der Aufträge auf die Produktionssysteme ****************

        sql = "SELECT kom_art_nr,kom_zs_sys,SUM(kom_qm_netto) FROM plrv11.zus_kommission WHERE ";
        sql += wheres;
        sql += "GROUP BY  kom_art_nr,kom_zs_sys ";
        sql += "ORDER BY  kom_zs_sys,3 desc";

// out.println("2<BR>"+sql+"<BR>");
        out.println("<TABLE BORDER=1>");

        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        out.println("<TR BGCOLOR=\"#ffffff\"><TD COLSPAN=4 ALIGN=CENTER>Verteilung auf Prod-Syssteme</TD></TR>");
        out.println("<TR BGCOLOR=\"#ffffff\"><TD>Bezug-Nr</TD><TD>Summe QM(Netto) insg.</TD><TD>Summe QM(Netto) pro Bezug</TD>");
        out.println("<TD>System</TD><TD>kom_zs_sys</TD></TR>");
        while (rs.next()) {
            out.println("<TR><TD ALIGN=right>" + rs.getString("kom_art_nr"));
            out.println("</TD><TD ALIGN=right>" + df.format(rs.getFloat(3) + flAktCut) + "</TD><TD ALIGN=right>");
            out.println(rs.getString(3) + "</TD>");
            aktZsSys = rs.getInt("kom_zs_sys");

            if ((aktZsSys == 10)  // Wird auf jeden Fall dem Cutter zugewiesen...
                    || ((aktZsSys == 20) && (flAktCut < flMaxCut))) { // Wird dem Cutter zugewiesen, wenn maximale Fläche nicht überschritten wurde
                sqlUpdate = "UPDATE plrv11.zus_kommission SET kom_zs_sys=10,kom_status=15 ";
                sqlUpdate += "WHERE " + wheres;
                sqlUpdate += "AND kom_art_nr=" + rs.getString("kom_art_nr");
                updStmt.executeQuery(sqlUpdate);
                out.println("<TD BGCOLOR=\"#DDFFDD\">Cutter</TD><TD>" + aktZsSys + "</TD>");
            } else {
                sqlUpdate = "UPDATE plrv11.zus_kommission SET kom_zs_sys=30,kom_status=15 ";
                sqlUpdate += "WHERE " + wheres;
                sqlUpdate += "AND kom_art_nr=" + rs.getString("kom_art_nr");
                updStmt.executeQuery(sqlUpdate);
                out.println("<TD BGCOLOR=\"#FFDDDD\">Manuell</TD><TD>" + aktZsSys + "</TD>");
            }
            out.println("</TR>");
            flAktCut += rs.getFloat(3);
        }
        out.println("</TABLE>");

// **************  Bildung der Sammelaufträge ****************

        zusParam zp = new zusParam(con);

        float sAMaxATCu = zp.getWert("SAMaxATCu");
        float sAMaxSFCu = zp.getWert("SAMaxSFCu");
        float sAMaxATMan = zp.getWert("SAMaxATMan");
        float sAMaxSFMan = zp.getWert("SAMaxSFMan");
        float sAMaxATAkt = 0;
        float sAMaxSFAkt = 0;
        String bgcolor = new String();
        String bgcolor1 = new String();
        String bgcolor2 = new String();
        String ausgabe = new String();


        long sAbNr = Long.parseLong(rbTextFormat.format('0', 10, bdeZeit.getTimestamp("MMddHHmmss"))) * 10000; // Sammel-Auftrags-Nr
        long sAbRflgNr = 0; // Sammel-Auftrags-Rflg

        char man;
        char cut;

        for (int lauf = 0; lauf <= 1; lauf++) {
            if (lauf == 0) {
                bgcolor = "#ffeeee";
                bgcolor1 = bgcolor;
                bgcolor2 = "#ffbbbb";
                out.println("<TR BGCOLOR=red><TD>Manueller Zuschnitt</TD></TR>");
                aktZsSys = 30;
                sAMaxATAkt = sAMaxATMan;
                sAMaxSFAkt = sAMaxSFMan;
            } else {
                bgcolor = "#eeffee";
                bgcolor1 = bgcolor;
                bgcolor2 = "#bbffbb";
                out.println("<TR BGCOLOR=red><TD>Cutter  Zuschnitt</TD></TR>");
                aktZsSys = 10;
                sAMaxATAkt = sAMaxATCu;
                sAMaxSFAkt = sAMaxSFCu;
            }

            sql = "SELECT kom_art_nr,sum(kom_qm_netto),sum(kom_anz_teile) FROM ";
            sql += "plrv11.zus_kommission WHERE ";
            sql += "kom_status=15 AND ";
            sql += "kom_rest_kz<>'J' AND ";
            sql += "kom_reserv_kz<>'J' AND ";
            sql += "kom_zs_sys=" + aktZsSys + " AND ";
            sql += "kom_bnr3=0 ";
            sql += "GROUP BY kom_art_nr ";
            sql += "ORDER BY kom_art_nr";

            // out.println("<BR>"+sql+"<BR>");

            String sqlAlt = new String();
            Statement stmtAlt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            ResultSet rsAlt;

            sqlAlt = "SELECT kom_sammel_abnr,kom_sammel_rflg,kom_status,kom_abnr,kom_art_nr,kom_qm_netto,kom_anz_teile FROM ";
            sqlAlt += "plrv11.zus_kommission WHERE ";
            sqlAlt += "kom_status=15 AND ";
            sqlAlt += "kom_rest_kz<>'J' AND ";
            sqlAlt += "kom_reserv_kz<>'J' AND ";
            sqlAlt += "kom_zs_sys=" + aktZsSys + " AND ";
            sqlAlt += "kom_bnr3=0 AND kom_art_nr=";

            long aktArtNr = 0;
            stmt.executeQuery(sql);

            rs = stmt.getResultSet();
            out.println("<TABLE BORDER=1>");

            int aktPos;
            int minPos;
            int maxPos;
            int anz;

            float artDurchschnittSF;
            float artNettoMenge;
            long artAnzTeile;

            float saDurchschnittSF;
            float saNettoMenge;
            long saAnzTeile;
            int saRflg = 1;

            while (rs.next()) {
                // je nachdem... grössten und kleinsten Auftrag des RS hinzufügen
                aktArtNr = rs.getLong("kom_art_nr");
                artNettoMenge = rs.getFloat(2);
                artAnzTeile = rs.getLong(3);
                artDurchschnittSF = artNettoMenge / artAnzTeile;
                sAbNr++;

                if (bgcolor.compareTo(bgcolor1) == 0) {
                    bgcolor = bgcolor2;
                } else {
                    bgcolor = bgcolor1;
                }
                out.println("<TR><TD>" + aktArtNr + "</TD><TD><TABLE BORDER=1>");

                stmtAlt.executeQuery(sqlAlt + aktArtNr + " ORDER BY kom_qm_netto DESC");
                rsAlt = stmtAlt.getResultSet();
                rsAlt.last();
                maxPos = rsAlt.getRow() + 1;
                anz = rsAlt.getRow();
                minPos = 1;
                aktPos = minPos; // Hiermit wird gesprungen
                zaehler = 1;
                saNettoMenge = 0;
                saAnzTeile = 0;
                saDurchschnittSF = 0;
                saRflg = 1;

                out.println("<TR BGCOLOR=#ddddff><TD>Pos</TD><TD>AB-Nr</TD><TD BGCOLOR=yellow>SA QM(Netto)</TD><TD BGCOLOR=yellow>");
                out.println("SA(Anz-Teile)</TD><TD BGCOLOR=#DDDDDD>Kom QN(Netto)</TD>");
                out.println("<TD BGCOLOR=#dddddd>Kom(Anz Teile)</TD><TD>DSF(SA)</TD><TD>DSF(Art)</TD>");
                out.println("<TD>SA-Nr(MaxAT-MaxDSF)</TD><TD>Vorgang</TD></TR>");
                while (zaehler <= anz) {
                    rsAlt.absolute(aktPos);
                    saNettoMenge += rsAlt.getFloat("kom_qm_netto");
                    saAnzTeile += rsAlt.getLong("kom_anz_teile");
                    saDurchschnittSF = saNettoMenge / saAnzTeile;

                    // Diesen Artikel Hinzugfügen!!
                    rsAlt.updateLong("kom_sammel_abnr", sAbNr);
                    rsAlt.updateInt("kom_sammel_rflg", saRflg);
                    rsAlt.updateInt("kom_status", 20);
                    rsAlt.updateRow();

                    out.println("<TR bgcolor=\"" + bgcolor + "\">");
                    out.println("<TD>" + aktPos + "</TD><TD>");
                    out.println(rsAlt.getInt("kom_abnr") + "</TD><TD>" + saNettoMenge + "</TD><TD>");
                    out.println(saAnzTeile + "</TD><TD>" + rsAlt.getFloat("kom_qm_netto"));
                    out.println("</TD><TD>" + rsAlt.getLong("kom_anz_teile"));
                    out.println("</TD><TD>" + df.format(saDurchschnittSF) + "</TD><TD>" + df.format(artDurchschnittSF) + "</TD>");
                    out.println("<TD>" + sAbNr + "(" + sAMaxSFAkt + "-" + sAMaxATAkt + ")</TD>");

                    if ((sAMaxSFAkt < saNettoMenge) || (sAMaxATAkt < saAnzTeile)) {
                        // Sammelauftrag ist voll
                        sAbNr++;
                        saRflg = 0;
                        if (bgcolor.compareTo(bgcolor1) == 0) {
                            bgcolor = bgcolor2;
                        } else {
                            bgcolor = bgcolor1;
                        }
                        saNettoMenge = 0;
                        saAnzTeile = 0;
                        saDurchschnittSF = 0;
                    }

                    if (saDurchschnittSF <= artDurchschnittSF) {
                        minPos++;
                        aktPos = minPos;
                        out.println("<TD BGCOLOR=green><FONT COLOR=#ffffff>Auftrag mit großer DSF</TD>");
                    } else {
                        maxPos--;
                        aktPos = maxPos;
                        out.println("<TD BGCOLOR=red>Auftrag mit kleiner DSF</TD>");
                    }

                    out.println("</TR>\n");
                    zaehler++;
                    saRflg++;
                }
                out.println("</TABLE></TD></TR>");
            }
            out.println("</TABLE>");
        }
        con.close();
    }
    catch (SQLException e) {
        out.println("Fehler<BR>" + e.getMessage() + e.getCause() + e.toString());
    }
%>
</body>
</html>

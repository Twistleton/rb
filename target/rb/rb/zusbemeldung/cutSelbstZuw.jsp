<%--
  Created by IntelliJ IDEA.
  User: Speer, Rolf
  Date: 27.07.2010
  Time: 11:00:49

  Automatische Cutter-Selbstzuweisung - JSP - Teil I (cutSelbstZuw.jsp)

  - Auswahl des Teemas und der maximalen gewünschten Menge

  Automatische Cutter-Selbstzuweisung - JSP - Teil II (cutSelbstZuwEnde2.jsp)

  - Auswahl für den Inhalt der einzelnen SAI-Datei(en)

--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Auftragszuweisung Cutter Version 2010/09/09</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <SCRIPT TYPE="text/javascript">
        function checkTeam(t) {
            if (t.value == "1") {
                alert("Wählen Sie bitte ein Team aus und drücken Sie ok");
                return false;
            } else {
                return true;
            }

        }
    </SCRIPT>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    zusParam zp = new zusParam(con);
    ResultSet rs;

    String sql = new String();
    String auswahl = new String();

    int team = 0;
    int maxmenge = 0;                                  // maximale gewünschte Menge
    int allgEinarb = 0;

    boolean gefunden = false;                // Sammelauftrag ausgewählt?
    double bezugsmenge = 0;                    // Bruttomenge des Sammelauftrags
    double summenge = 0;                    // Summe der zugewiesenen Aufträge

    long sel_sanr = 0;                  // Sammelauftragsnummer
    long sel_artnr = 0;                    // Artikelnummer (Bezug)
    long sel_charg_nr = 0;                    // Chargen-Nummer
    String sel_lief_kkz = new String();        // Lieferantenkurzkennzeichen
    int sel_zs_system = 0;

    String drucker = new String();                // Drucker

    long sammelauftrag = 0;
    long artNr = 0;
    int updates = 0;
    int anzahl_SAI = 0;                      // Anzahl Sammelaufträge für SAI-Files
    int zs_system = 0;

    con.setAutoCommit(false);            // set autocommit off

    // ArrayList für Sammelaufträge (Generics ab JDK 5.0)
// ArrayList <MeinSammelauftrag> auftragsliste = new ArrayList<MeinSammelauftrag>();
    // ArrayList für Sammelaufträge
    ArrayList auftragsliste = new ArrayList();

    String allgEinarbListe = new String();

    try {
        team = Integer.parseInt(request.getParameter("team"));

    } catch (Exception ex) {
        team = 1;
    }

    try {
        maxmenge = Integer.parseInt(request.getParameter("maxmenge"));

    } catch (Exception ex) {
        maxmenge = 180;
    }

    out.println("<font face=\"monospace\" size=\"-1\">Verbunden mit: " + oraBde.getDbName() + "</font>");
    out.println("<center>W&auml;hlen Sie bitte Ihr Team und die gew&uuml;nschte maximale Menge aus<br><p>");
    out.println("<form action=\"cutSelbstZuw.jsp\" NAME=\"teamwahl\" METHOD=\"POST\">");
    sql = "SELECT ma_nname,ma_pnr FROM plrv11.bde_madat WHERE ma_team_kz='J' ORDER BY ma_nname";
    out.println(oraBde.getHtmlSelectAllgS("team", sql, String.valueOf(team)));
    out.println("<select name=\"maxmenge\" size=\"1\">");
    for (int i = 180; i > 0; i = i - 10) {
        if (i == maxmenge) {
            auswahl = "selected";
        } else {
            auswahl = "";
        }
        out.println("<option value=\"" + i + "\" " + auswahl + " > bis " + i + " QM</option>");
    }
    out.println("</select>                 ");
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.println("</form></center><hr><center>");
    out.println("<b>Auftragszuweisung Cutter</b><br>");
    if (team != 1) {
        // Prüfen, ob noch für SAI-File gekennzeichnete Positionen noch nicht bearbeitet wurden
        sql = "SELECT kom_sammel_abnr,kom_art_nr,ap_posnr,kom_abnr,ap_sai,sak_artnr " +
                "FROM plrv11.zus_sammel_kopf " +
                "INNER JOIN plrv11.zus_kommission   ON kom_sammel_abnr = sak_sanr  AND kom_art_nr=sak_artnr " +
                "INNER JOIN plrv11.plr_art_pos      ON ap_abnr         = kom_abnr  AND ap_syn=sak_artnr AND (ap_klasse='M' OR ap_klasse='F') " +
                "INNER JOIN plrv11.plr_auftr_status ON ap_abnr         = as_abnr   AND as_aend_ix=ap_aend_ix AND as_status<>99 " +
                "WHERE sak_pnr=" + team +
                " AND ap_sai='B' order by kom_sammel_abnr,kom_art_nr,ap_posnr";

        try {
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            out.println("<TABLE BORDER=1>");
            anzahl_SAI = 0;
            while (rs.next()) {
                out.println("<TR><TD>" + rs.getString("kom_sammel_abnr"));
                out.println("</TD><TD>" + rs.getString("kom_art_nr"));
                out.println("</TD><TD>" + rs.getString("ap_posnr"));
                out.println("</TD><TD>" + rs.getString("kom_abnr"));
                out.println("</TD><TD>" + rs.getString("ap_sai"));
                out.println("</TD>");
                out.println("</TD></TR>");
                anzahl_SAI++;
                // erster Artikel-Nummer an Formular cutSelbstZuwEnde2.jsp übergeben???
                artNr = Long.parseLong(rs.getString("sak_artnr"));
            }
            rs.close();
            out.println("</TABLE>");

            // Prüfen ob noch "Altlasten" vorhanden sind
            if (anzahl_SAI > 0) {
                out.println("<br>Bitte zuerst die noch vorhandenen SAI-Dateien bearbeiten!");
                out.println("<br>Anzahl der Sammelauftr&auml;ge : " + anzahl_SAI);
                out.println("<br><br>");
                out.println("<FORM ACTION=\"cutSelbstZuwEnde2.jsp\">");
                out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"team\" VALUE=\"" + team + "\">");
                out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"auswahl\" VALUE=\"" + anzahl_SAI + "\">");
                out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"lauf\"  VALUE=\"1\">");
                out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
                out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
                out.println("</FORM>");
            } else {
                // Keine "Altlasten", dann ausführen des "Normalfalls"
                // Einarbeit des Mitarbeiters
                sql = "SELECT map_prog										" +
                        "  FROM plrv11.bde_ma_prog 						 		" +
                        " WHERE map_fs='10244100000'								" +
                        "   AND map_pnr=" + team;
                try {
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    allgEinarbListe = "<tr>";
                    while (rs.next()) {
                        allgEinarbListe += "<TD>" + rs.getString(1) + "</td>";
                        allgEinarb++;
                        if (allgEinarb % 20 == 0) {
                            allgEinarbListe += "</tr><tr>";
                        }
                    }
                    allgEinarbListe += "</TR>";

                }
                catch (SQLException sqlex) {
                    out.println(sqlex.getMessage() + "<br>" + sql + "<br>");
                    sqlex.printStackTrace();
                }
                // Selektieren der zuweisungsfähigen Aufträge; Aufträge ohne Personal-Nummer haben den Wert NULL
                // und kommen somit bei der Sortierung nach den bereits zugeordneten Aufträgen
                sql = "SELECT sak_pnr			                            			    			" +
                        "     , sak_sanr				                    	            	    			" +
                        "     , sak_artnr				                    		                			" +
                        "     , sak_ztag			                    			        		        	" +
                        "     , kom_werk_zuschn			                    			            			" +
                        "     , sum(kom_qm_brutto)	                    				    	        		" +
                        "     , sak_charg_nr		                    				               			" +
                        "     , sak_lief_kkz 				                    			    	        	" +
                        "     , sak_zs_sys				                    			                  		" +
                        "  FROM plrv11.zus_sammel_kopf					    	                          		" +
                        " INNER JOIN plrv11.zus_kommission ON kom_sammel_abnr=sak_sanr           	        	";
                if (allgEinarb > 0) {
                    sql += "INNER JOIN plrv11.bde_ma_prog ON " + team + "=map_pnr AND map_fs='10244100000' AND map_prog=kom_prog  ";
                    out.println("<BR>Eingeschr&auml;nkte Einarbeit auf die Programme:<BR><TABLE >" + allgEinarbListe + "</TABLE><BR><BR>");
                } else {
                    out.println("<BR>Das Team ist voll eingearbeitet. Keine Einschr&auml;nkungen auf bestimmte Programme<BR>");
                }
                sql += "WHERE sak_zs_sys in (10, 11)                                                   	" +
                        "         AND kom_werk_zuschn=10						                        		" +
                        "         AND (sak_pnr is null OR sak_pnr=" + request.getParameter("team") + ")      		" +
                        "         AND sak_zugew='N' 	                        						 		" +
                        "       GROUP BY sak_pnr   								                            	" +
                        "               ,sak_sanr	                            								" +
                        "               ,sak_artnr			    			                       			    " +
                        "	            ,sak_ztag	                    			    					    " +
                        "	            ,kom_werk_zuschn			                        					" +
                        "	            ,sak_charg_nr	                    				    				" +
                        "	            ,sak_lief_kkz                    	                           			" +
                        "               ,sak_zs_sys 						                               		" +
                        "       ORDER BY sak_pnr 								                            	" +
                        "               ,sak_ztag			                    					    	    " +
                        "               ,sak_artnr	    						                    		    " +
                        "	            ,sak_sanr	                                                            ";

                stmt.executeQuery(sql);
                rs = stmt.getResultSet();

                while (rs.next()) {
                    // Bruttomenge - String in double umformen
                    bezugsmenge = Double.parseDouble(rs.getString(6));

                    // ersten Sammelauftrag auswählen - unabhängig von der Menge
                    if (gefunden == false) {
                        // Kennzeichen für Auftrag gefunden auf TRUE setzen
                        gefunden = true;
                        // Angaben zum gefundenen Auftrag zwischenspeichern
                        sel_sanr = Long.parseLong(rs.getString("sak_sanr"));
                        sel_artnr = Long.parseLong(rs.getString("sak_artnr"));
                        sel_charg_nr = Long.parseLong(rs.getString("sak_charg_nr"));
                        sel_lief_kkz = rs.getString("sak_lief_kkz");
                        sel_zs_system = Integer.parseInt(rs.getString("sak_zs_sys"));
                    }
                }

                // Passender Auftrag gefunden? Dann weitere zuweisungsfähige Aufträge selektieren (gleiche Artikel-Nr.,
                // gleiche Changen-Nummer und gleiches Lieferantenkurzkennzeichen)
                if (gefunden == true) {
                    sql = " SELECT sak_pnr								" +
                            "      , sak_sanr								" +
                            "      , sak_artnr								" +
                            "      , sak_ztag								" +
                            "      , kom_werk_zuschn							" +
                            "      , sum(kom_qm_brutto) 							" +
                            "   FROM plrv11.zus_sammel_kopf							" +
                            "  INNER JOIN plrv11.zus_kommission ON kom_sammel_abnr=sak_sanr 		";
                    if (allgEinarb > 0) {
                        sql += "INNER JOIN plrv11.bde_ma_prog ON " + team + "=map_pnr AND map_fs='10244100000' AND map_prog=kom_prog ";
                    }
                    sql += " WHERE sak_zs_sys in (10, 11)						" +
                            "   AND kom_werk_zuschn=10							" +
                            "   AND (sak_pnr is null OR sak_pnr=" + request.getParameter("team") + ")		" +
                            "   AND sak_artnr=" + sel_artnr +
                            "   AND sak_zugew='N'								" +
                            "   AND sak_lief_kkz='" + sel_lief_kkz + "'" +
                            "   AND sak_charg_nr=" + sel_charg_nr +
                            " GROUP BY sak_pnr								" +
                            " 	, sak_sanr								" +
                            "	, sak_artnr								" +
                            "	, sak_ztag								" +
                            "	, kom_werk_zuschn 							" +
                            " ORDER BY sak_pnr DESC,sak_ztag,sak_artnr,sak_sanr				";

                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();

                    int i = 0;

                    while (rs.next()) {
                        sel_sanr = Long.parseLong(rs.getString("sak_sanr"));

                        // Bruttomenge - String in double umformen
                        bezugsmenge = Double.parseDouble(rs.getString(6));

                        // erster Auftrag (höchster Priorität) auswählen, sowie - bis die maximale gewünschte Menge erreicht
                        // ist - weitere Aufträge ins Array sammelauftrag einfügen
                        //
                        if ((summenge + bezugsmenge <= maxmenge) || (auftragsliste.size() == 0)) {
                            auftragsliste.add(new MeinSammelauftrag(sel_sanr, sel_artnr, sel_charg_nr, sel_lief_kkz, sel_zs_system));
                            i++;
                            summenge = summenge + bezugsmenge;
                            System.out.println(System.identityHashCode(this) + " - cutSelbstZuw.jsp - Team : " + team +
                                    " Sammelauftr.: " + sel_sanr);
                        }
                    }

                    MeinSammelauftrag s;

                    if (auftragsliste.size() == 0) {
                        out.println("Es wurden keine Sammelauftr&auml;ge ausgew&auml;!<br>");

                    } else {
                        session.setAttribute("auftragsliste", auftragsliste);
                        // Updates für die Aufträge in der Auftragsliste durchführen
                        for (int j = 0; j < auftragsliste.size(); j++) {
                            //
                            //	Generics ab JDK 5.0 verfügbar
                            //
                            //	sammelauftrag = auftragsliste.get(j).getSammelauftragsnummer();
                            //	artNr         = auftragsliste.get(j).getArtikelnummer();
                            //
                            // --------------------------------------------------------------------------
                            //
                            //	:WORKAROUND
                            //
                            s = (MeinSammelauftrag) auftragsliste.get(j);
                            sammelauftrag = s.getSammelauftragsnummer();
                            artNr = s.getArtikelnummer();
                            zs_system = s.getZuschnittssystem();

                            out.println("<table border=\"1\">");
                            out.println("<tr bgcolor=\"ddddff\">");
                            out.println("<td align=\"center\">SA-Nr</td>");
                            out.println("<td align=\"center\">FS-Aktualisiert</td>");
                            out.println("<td align=\"center\">Papiere gedruckt</td>");
                            out.println("<td align=\"center\">Host-Datei</td>");

                            drucker = mitarbeiter.getDrucker(Integer.parseInt(request.getParameter("team")), con);
                            if (drucker.compareTo("") == 0) {
                                // wenn es keinen Drucker gibt, wird standardmässig der im CONF.-File hinterlegte Drucker verwendet
                                drucker = zcd.getCutZusDrucker();
                            }

                            try {
                                out.println("<TR>");
                                // Sammelauftragskopf als "zugewiesen" markieren und die Personalnummer eintragen
                                // Jetzt "gehört" der Auftrag dem angemeldeten TEAM
                                sql = "UPDATE plrv11.zus_sammel_kopf SET sak_zugew='J',sak_pnr=" + request.getParameter("team");
                                sql += " WHERE sak_sanr=" + sammelauftrag;
                                if (stmt.executeUpdate(sql) == 0) {
                                    out.println("<TD ALIGN=\"CENTER\"><FONT COLOR=\"red\">" + sammelauftrag);
                                    out.println("nicht gefunden</FONT></TD>");
                                } else {
                                    out.println("<TD ALIGN=\"CENTER\">" + sammelauftrag + " => " + request.getParameter("team") + "</TD>");
                                }
                                // Für die zum Sammelauftrag gehörenden "Kommissions-Fertigungsstufen" wird ebenfalls die Team-Nr (=PNr)
                                // eingetragen. Das ist notwendig, weil die Kommissionsfertigungsstufen einzeln bemeldet werden (nicht
                                // der ganze Sammelauftrag). Dazu wird der Status auf 10 = gestartet gesetzt
                                // Jetzt "gehört" der Auftrag dem angemeldeten TEAM
                                sql = "UPDATE plrv11.zus_kom_fs SET kfs_pnr=" + request.getParameter("team");
                                sql += ",kfs_fs_status=10 WHERE ";
                                sql += "kfs_fs='10244100000' ";
                                sql += " AND kfs_artnr in (select kom_art_nr FROM plrv11.zus_kommission WHERE  " +
                                        "kom_sammel_abnr=" + sammelauftrag + ") ";
                                sql += " AND kfs_abnr in (select kom_abnr from plrv11.zus_kommission WHERE     " +
                                        "kom_sammel_abnr=" + sammelauftrag + ")";

                                if (stmt.executeUpdate(sql) == 0) {
                                    out.println("<td><font color=\"red\">nicht aktualisiert</TD>");
                                } else {
                                    out.println("<td align=\"CENTER\">aktualisiert</TD>");
                                }

                                // Zuerst wird geschaut, ob die Auftragspapiere bereits ausgedruckt wurden für diese Kommission
                                String kzGedruckt = new String();
                                sql = "SELECT kom_ab_gedruckt FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sammelauftrag;
                                stmt.executeQuery(sql);
                                rs = stmt.getResultSet();
                                while (rs.next()) {
                                    kzGedruckt = rs.getString("kom_ab_gedruckt");
                                }

                                if (kzGedruckt.compareTo("N") == 0) {
                                    // Ausdrucken Auftragspapiere
                                    // Das eigentliche ausdrucken wird erledigt von einer Methode in der Klasse druckDatei
                                    // Deshalb erstmal Objekt instantiieren
                                    druckDatei apd = new druckDatei(zcd.getAbpDruckPfad(), "auftragsPapierDatei", zcd.getAbpEndung());
                                    // Dateiname wird auf timestamp gesetzt
                                    apd.setNameTimestamp();
                                    apd.oeffnen();
                                    apd.arbeitsBegleitpapiere(sammelauftrag, con);
                                    apd.schliessen();
                                    // aktivieren bedeutet: Umbenennen der Datei von soundso.tmp in
                                    // soundso.wiedieDateiEndnungSeinSoll
                                    // Somit wird verhindert, dass ein Druckprozess die Datei holt, bevor sie fertig ist.
                                    apd.aktiviereDatei();
                                    // Ausdrucken auf den im Conf-File eingestellten Drucker
                                    apd.drucken(drucker);
                                    out.println("<td align=\"center\">Ja</TD>");

                                    sql = "UPDATE plrv11.zus_kommission SET ";
                                    sql += "kom_ab_gedruckt='J' WHERE kom_sammel_abnr=" + sammelauftrag;
                                    try {
                                        stmt.executeUpdate(sql);
                                    }
                                    catch (SQLException sqlex) {
                                    }
                                } else {
                                    out.println("<TD ALIGN=\"CENTER\"><FONT COLOR=\"red\">Nein</FONT></TD>");
                                }


                                // Datei an Host
                                // Hier eine Datei an den Host erstellen. Weitertransport wird von Herrn Lotzmann organisiert.
                                // Auch hier wird eine Methode verwendet.
                                bvmDatei bvm = new bvmDatei(zcd.getRueckMeldPfad(), zcd.getRueckMeldEndung());
                                bvm.ausgabe(sammelauftrag, Integer.parseInt(request.getParameter("team")), con);
                                out.println("<TD ALIGN=\"CENTER\">bereitgestellt</TD>");

                                // Artikelpositionen des Sammel-Auftrags markieren
                                // in den Artikelpositionen des Auftrags gibt es ein Kennzeichen "ap_sai". Hier wird gespeichert,
                                // ob die Position bereits in einer SAI-Datei (für den Cutter) berücksichtigt wurde oder nicht.
                                // Zuerst einmal wird das Kennzeichen für alle Positionen auf "B" gesetzt. Das bedeutet,
                                // dass die SAI-Datei für dieses Postionen jetzt gebildet werden soll "=>(B)ilden!!"

                                // Nachher werden die Positionen mit B-Selektiert. Die Ausgewählten (und bearbeiteten) werden
                                // Dann mit "G" wie "(G)ebildet" gekennzeichnet.

                                sql = "UPDATE plrv11.plr_art_pos SET ";
                                sql += " ap_sai='B'";
                                sql += " WHERE ap_syn=" + artNr;
                                sql += " AND ap_sai ='N' ";
                                sql += " AND ap_abnr IN (SELECT kom_abnr FROM plrv11.zus_kommission ";
                                sql += " WHERE kom_sammel_abnr=" + sammelauftrag + ")";
                                sql += " AND ap_aend_ix IN ";
                                sql += "(SELECT as_aend_ix ";
                                sql += " FROM plrv11.zus_kommission ";
                                sql += " INNER JOIN plrv11.plr_auftr_status ON kom_abnr=as_abnr";
                                sql += " WHERE as_status<>99)";
                                updates = stmt.executeUpdate(sql);

                                con.commit();
                                // con.rollback();
                            }
                            catch (Exception ex) {
                                out.println("Fehler " + ex.getMessage() + "<BR>" + sql);
                                ex.printStackTrace();
                                con.rollback();
                            }
                        }
                        out.println("</TABLE>");
                        out.println("Verwendeter Drucker : " + drucker + "<br>");
                        out.println("<FORM ACTION=\"cutSelbstZuwEnde2.jsp\" METHOD=\"POST\">");
                        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
                        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"lauf\"  VALUE=\"1\">");
                        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"team\"  VALUE=\"" + request.getParameter("team") + "\">");
                        out.println("<br>");
                        out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\"    VALUE=\"Weiter\">");
                        out.println("</FORM>");

                    }
                } else {
                    out.println("<br><b>Es stehen für die ausgew&auml;hlte Menge keine Aufträge zur Verfügung!</b>");
                }

            }
        }
        catch (SQLException sqlex) {

            out.println(sqlex.getMessage() + "<br>" + sql + "<br>");
        }
    }
    con.close();
%>
</CENTER>
</body>
</html>

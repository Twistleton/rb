<%--
  Created by IntelliJ IDEA.
  User: SpeerRo
  Date: 27.07.2010
  Time: 11:02:45

    Automatische Cutter-Selbstzuweisung - JSP - Teil I (cutSelbstZuw.jsp)

  - Auswahl des Teemas und der maximalen gewünschten Menge

    Automatische Cutter-Selbstzuweisung - JSP - Teil II (cutSelbstZuwEnde2.jsp)

  - Auswahl für den Inhalt der einzelnen SAI-Datei(en)



--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!--JSP- Cutter automatische Zuweisung - Teil 2 - Stand: 11.06.2008 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Vector" %>
<%@ page import="com.rolfbenz.MeinSammelauftrag" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Auftragszuweisung Cutter Version 2010/09/09</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <script type="text/javascript">
        <!--
        function hakenEntf() {
            for (x = 0; x < document.haken.length; x++) {
                if (document.haken.elements[x].name == "auswahl") {
                    document.haken.elements[x].checked = false;
                }
            }
        }
        //-->
    </script>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER><H2>Erstellung von SAI-Dateien</H2>
<%

    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();
    Connection con = oraBde.getConnection();
    con.setAutoCommit(false);
    zusParam zp = new zusParam(con);
    String sql = new String();
    String sqlUpdate = new String();
    String saiUpdate = new String();
    String dateiname = new String();
    String regel = new String();
    String bezug = new String();
    String modell = new String();
    String cutParm = new String();
    String digParm = new String();
    String sf = new String();
    String drucker = new String();
    String[] auswahl;

    StringTokenizer aufbrecher;
    Statement stmt = con.createStatement();
    Statement stmtUpdate = con.createStatement();

    ResultSet rs;

    Vector verschiedeneAbNrn = new Vector();


    // ArrayList für Sammelaufträge
    ArrayList auftragsliste = new ArrayList();

    int anzDS = 0;
    int spaetesterWechsel = 0;
    int abNr = 0;
    int menge = 0;
    int pos = 0;
    int lauf = 0;
    int updates = 0;
    int anz = 0;
    long artNr = 0;
    long sANr = 0;
    basisDatei cutter;
    druckDatei sax;

    String myTimestamp = bdeZeit.getTimestamp("MMdd-HHmmss");

    gruppenWechsel gwSANr = new gruppenWechsel();
    gruppenWechsel gwAbNr = new gruppenWechsel();
    pen bgColor1 = new pen(225, 225, 225, 255, 255, 255);
    pen bgColor2 = new pen(210, 255, 210, 230, 255, 230);
    int keineAuswahl = 0;
    auswahl = request.getParameterValues("auswahl");
    try {
        lauf = Integer.parseInt(request.getParameter("lauf"));
        regel = zp.getText("cutterStandardRegel");
        artNr = Long.parseLong(request.getParameter("artNr"));
        bezug = String.valueOf(artNr).substring(3, 8);
        anz = Integer.parseInt(request.getParameter("anz"));

    }
    catch (Exception e) {
        keineAuswahl = 1;
    }
    try {
        updates = auswahl.length;
    }
    catch (Exception e) {
        keineAuswahl = 1;
        out.println("Keine Auswahl erfolgt<BR>");
    }
    try {
        // Drucker festlegen
        drucker = mitarbeiter.getDrucker(Integer.parseInt(request.getParameter("team")), con);
        if (drucker.compareTo("") == 0) {
            // Wenn's keinen Drucker gibt, wirds Standardmäßig auf dem im Conf-File hinterlegten
            // Drucker geschickt
            drucker = zcd.getCutHilfDrucker();
        }
        out.println("Verwendeter Drucker:" + drucker + "<BR>");
        if (keineAuswahl == 0) {
            if ((auswahl.length == anz) ||                                      // Entweder alle...
                    ((auswahl.length <= (int) (anz - zp.getWert("minModellProSAI")) &&  // wenn nicht, dann maximal soviel
                            (auswahl.length >= (int) zp.getWert("normMinModellProSAI"))
                    ))
                    ) {
                // Hier wird aus den Stammdaten des Artikels herausgesucht, welches Cutter-Config-File für
                // dieses spezielle Material verwendet werden soll. In 90% der Fälle ist das immer das gleiche
                // nämlich frei_neu.ppc
                // Das wird verwendet, wenn z. B. für ein besonders dehnbares leder die Schablone 1/2 Prozent
                // kleiner sakliert werden soll.
                sql = "SELECT art_cut_parm,art_dig_parm FROM plrv11.plr_art_kopf WHERE art_nr=" + artNr;
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    if (rs.getString("art_cut_parm") != null) {
                        cutParm = rs.getString("art_cut_parm").trim();
                    } else {
                        cutParm = "";
                    }
                    if (rs.getString("art_dig_parm") != null) {
                        digParm = rs.getString("art_dig_parm").trim();
                    } else {
                        out.println("<B><FONT COLOR=\"red\">Digit-Param nicht gesetzt</FONT></B><BR>");
                        digParm = "";
                    }
                }
                rs.close();
                if (digParm.trim().compareTo("") == 0) {
                    out.println("Die Stammdaten sind für diesen Artikel nicht korrekt gepflegt<BR>");
                    out.println("Bitte in der Artikelverwaltung eine Parameter-Datei für den Cutter festlegen<BR>");
                    out.println("<BR>Deshalb wird die Standard-Regel <B>" + regel + "</B> verwendet<BR>");
                } else {
                    regel = digParm;
                    out.println("Es wird die artikelspezifische Regel <B>" + regel + "</B> verwendet<BR>");
                }
                // SAI-Datei erstellen

                for (int i = 0; i < auswahl.length; i++) {
                    aufbrecher = new StringTokenizer(auswahl[i], ";");
                    sANr = Long.parseLong(aufbrecher.nextToken());
                }

                auftragsliste = (ArrayList) session.getAttribute("auftragsliste");

                MeinSammelauftrag s;

                long sANr1 = 0;
                long sANr2 = 0;
                long sANr3 = 0;
                long sANr4 = 0;
                long sANr5 = 0;
                long sANr6 = 0;
                long sANr7 = 0;
                long sANr8 = 0;

                if (auftragsliste != null) {
                    for (int j = 0; j < auftragsliste.size(); j++) {

                        s = (MeinSammelauftrag) auftragsliste.get(j);
                        if (j == 0) {
                            sANr1 = s.getSammelauftragsnummer();
                        }
                        if (j == 1) {
                            sANr2 = s.getSammelauftragsnummer();
                        }
                        if (j == 2) {
                            sANr3 = s.getSammelauftragsnummer();
                        }
                        if (j == 3) {
                            sANr4 = s.getSammelauftragsnummer();
                        }
                        if (j == 4) {
                            sANr5 = s.getSammelauftragsnummer();
                        }
                        if (j == 5) {
                            sANr6 = s.getSammelauftragsnummer();
                        }
                        if (j == 6) {
                            sANr7 = s.getSammelauftragsnummer();
                        }
                        if (j == 7) {
                            sANr8 = s.getSammelauftragsnummer();
                        }
                    }
                }

                System.out.println(System.identityHashCode(this) + " - cutSelbstZuwEnde2.jsp - Sammelauftr. :  " + sANr1 +
                        ", " + sANr2 +
                        ", " + sANr3 +
                        ", " + sANr4 +
                        ", " + sANr5 +
                        ", " + sANr6 +
                        ", " + sANr7 +
                        ", " + sANr8);
                //
                //  Ist für diese Sammelauftragsnummern bereits ein SAI-Dateiname hinterlegt?
                //
                sql = "select max(sai_name) from plrv11.sai_table1 where sai_sanr =  " + sANr1 +
                        " or sai_sanr =  " + sANr2 +
                        " or sai_sanr =  " + sANr3 +
                        " or sai_sanr =  " + sANr4 +
                        " or sai_sanr =  " + sANr5 +
                        " or sai_sanr =  " + sANr6 +
                        " or sai_sanr =  " + sANr7 +
                        " or sai_sanr =  " + sANr8;

                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                rs.next();

                if (rs.getString(1) == null) {
                    System.out.println(System.identityHashCode(this) + " - cutSelbstZuwEnde2.jsp - Dateiname generieren ");
                    dateiname = rbTextFormat.format('0', 1, String.valueOf(Integer.parseInt(request.getParameter("team"))));
                    dateiname += "_" + myTimestamp + "_" + rbTextFormat.format('0', 2, lauf);
                } else {
                    System.out.println(System.identityHashCode(this) + " - cutSelbstZuwEnde2.jsp - Dateiname ergänzen :" + rs.getString(1));
                    lauf = Integer.parseInt(rs.getString(1).substring(14, 16));
                    lauf = lauf + 1;
                    dateiname = rs.getString(1).substring(0, 14) + rbTextFormat.format('0', 2, lauf);
                }

                cutter = new basisDatei(zcd.getCutPfad(), dateiname, zcd.getCutEndung());

                System.out.println(System.identityHashCode(this) + " - cutSelbstZuwEnde2.jsp - Zeitpunkt : " + new Date() + System.currentTimeMillis());
                System.out.println(System.identityHashCode(this) + " - cutSelbstZuwEnde2.jsp - Dateiname : " + dateiname);

                rs.close();

                // SAX-Datei erstellen - (für Annehmen der geschnittenen Bezüge)
                sax = new druckDatei(zcd.getCutHilfPfad(), bdeZeit.getTimestamp("MMddHHmmss"), zcd.getCutHilfEndung());
                lauf++;
                // Kopfsatz schreiben SAI
                cutter.oeffnen();
                cutter.ausgabe.write("**\n");
                cutter.ausgabe.write("version=" + zp.getText("version") + "\n");
                cutter.ausgabe.write("part_access=" + zp.getText("part_access") + "\n");
                cutter.ausgabe.write("type_tissu=" + zp.getText("type_tissu") + "\n");
                cutter.ausgabe.write("small_runs=0\n");
                cutter.ausgabe.write("cuir=" + bezug + "\n");
                cutter.ausgabe.write("paramdigit_name=" + zp.getText("paramdigit_name") + "\n");
                cutter.ausgabe.write("paramdigit_path=" + zp.getText("paramdigit_path") + "\n");
                // cutter.ausgabe.write("paramplc_name="  +regel                        +"\n");
                cutter.ausgabe.write("paramplc_name=frei_neu_verschnittberechnung-EL12.ppc\n");
                cutter.ausgabe.write("paramplc_path=" + zp.getText("paramplc_path") + "\n");
                cutter.ausgabe.write("paramcut_name=" + zp.getText("paramcut_name") + "\n");
                cutter.ausgabe.write("paramcut_path=" + zp.getText("paramcut_path") + "\n");

                // Kopfsatz schreiben SAX
                sax.oeffnen();
                sax.ausgabe.write("SAISAX\n");
                for (int i = 0; i < auswahl.length; i++) {
                    aufbrecher = new StringTokenizer(auswahl[i], ";");
                    sANr = Long.parseLong(aufbrecher.nextToken());
                    abNr = Integer.parseInt(aufbrecher.nextToken());
                    pos = Integer.parseInt(aufbrecher.nextToken());

                    // Artikelspositionen mit Schnittbildern einer Artikel-Position
                    sql = " SELECT sb_id                                                   	           " +
                            "      , sb_mld                                          	                   " +
                            "      , sb_pfad                                 	                           " +
                            "      , sb_cutter_sb                    	                                   " +
                            "      , kom_sammel_abnr         	                                           " +
                            "      , kom_abnr              	                                        	   " +
                            "      , ap_artnr                                                        	   " +
                            "      , ap_menge                                                	           " +
                            "      , ap_bezeichn                                      	               	   " +
                            "      , ap_syn                                                           	   " +
                            "   FROM plrv11.zus_kommission                                 		           " +
                            "  INNER JOIN plrv11.plr_art_pos      ON kom_abnr=ap_abnr AND ap_syn=kom_art_nr     " +
                            "  INNER JOIN plrv11.plr_auftr_status ON ap_abnr=as_abnr  AND ap_aend_ix=as_aend_ix " +
                            "  INNER JOIN plrv11.zus_schnittbild  ON sb_id=TO_NUMBER(SUBSTR(ap_artnr,4,6))      " +
                            "  WHERE as_status<>99 								   " +
                            "    AND kom_sammel_abnr = " + sANr +
                            "    AND kom_abnr        = " + abNr +
                            "    AND ap_posnr        = " + pos +
                            "    AND (ap_klasse='M' OR ap_klasse='F') 					   " +
                            "  ORDER BY kom_abnr,sb_id                                                          ";

                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    while (rs.next()) {
                        // in SAI-Datei
                        // out.println(rs.getString("sb_id")+"<BR>");
                        modell = rbTextFormat.format('0', 6, rs.getString("sb_id"));
                        cutter.ausgabe.write("modele_name=" + rs.getString("sb_mld") + "\n");
                        cutter.ausgabe.write("modele_path=" + rs.getString("sb_pfad") + "\n");
                        cutter.ausgabe.write("variante_name=" + rs.getString("sb_cutter_sb") + "\n");
                        cutter.ausgabe.write("variante_size=\n");
                        cutter.ausgabe.write("variante_repeat=" + (rs.getInt("ap_menge") / 100) + "\n");
                        cutter.ausgabe.write("end_of_size\n");
                        cutter.ausgabe.write("end_of_variante\n");
                        cutter.ausgabe.write("end_of_modele\n");
                        // in SAX-Datei
                        sax.ausgabe.write(dateiname.substring(0, 11) + dateiname.substring(13, 16));
                        sax.ausgabe.write(rbTextFormat.format('0', 6, abNr));
                        sax.ausgabe.write(rbTextFormat.format('0', 6, modell));
                        sax.ausgabe.write(rbTextFormat.format('0', 10, artNr));
                        sax.ausgabe.write(rbTextFormat.format(' ', 24, rs.getString("ap_bezeichn")));
                        sax.ausgabe.write(rbTextFormat.format('0', 7, rs.getString("ap_menge")));
                        sax.ausgabe.write(rbTextFormat.format('0', 10, rs.getString("ap_syn")) + "\n");
                    }
                    sqlUpdate = "UPDATE plrv11.plr_art_pos ";
                    sqlUpdate += " SET ap_sai='G' ";
                    sqlUpdate += " WHERE ap_abnr=" + abNr;
                    sqlUpdate += " AND ap_posnr=" + pos;
                    sqlUpdate += " AND ap_aend_ix IN ";
                    sqlUpdate += "(SELECT as_aend_ix ";
                    sqlUpdate += " FROM plrv11.plr_auftr_status ";
                    sqlUpdate += " WHERE as_status<>99)";
                    updates = stmtUpdate.executeUpdate(sqlUpdate);

                    // Hier hinzufügen der aktuellen AB-Nummer in einen Vector
                    if (!verschiedeneAbNrn.contains((Object) String.valueOf(abNr))) {
                        verschiedeneAbNrn.addElement((Object) String.valueOf(abNr));
                    }
                    //out.println(updates+" Artikelpositionen aktualisiert<BR>");
                }
                // Endesatz
                cutter.ausgabe.write("modele_name=LM\n");
                cutter.ausgabe.write("modele_path=" + zp.getText("modele_path") + "\n");
                cutter.ausgabe.write("variante_name=" + zp.getText("variante_name") + "\n");
                cutter.ausgabe.write("variante_size=" + zp.getText("variante_size") + "\n");
                // Vorerst mal pro SAI-File zwei Ledermuster
                cutter.ausgabe.write("variante_repeat=2\n");
                cutter.ausgabe.write("end_of_size\n");
                cutter.ausgabe.write("end_of_variante\n");
                cutter.ausgabe.write("end_of_modele\n");
                cutter.aktiviereDatei();
                cutter.schliessen();
                sax.aktiviereDatei();
                sax.schliessen();
                sax.drucken(drucker);
                out.println("<FONT COLOR=\"green\">");
                out.println("SAI-Datei wurde erstellt<BR>");
                out.println("</FONT>");
                // Tabelle pflegen mit SAI-Dateinamen/AB-Nummer-Zuordnung
                Enumeration e = verschiedeneAbNrn.elements();
                while (e.hasMoreElements()) {
                    saiUpdate = "INSERT INTO plrv11.sai_table1 ";
                    saiUpdate += "(sai_name,sai_auftrag,sai_time, sai_sanr) VALUES (";
                    saiUpdate += "'" + dateiname + "'," + e.nextElement() + ",'" + bdeZeit.getTimestamp("yyyyMMddHHmmss") + "'," + sANr + ")";
                    stmtUpdate.executeUpdate(saiUpdate);
                }
                // con.rollback();
                con.commit();
            } else {
                out.println("<FONT COLOR=\"red\">");
                out.println("<LI>Sie müssen min. " + (int) zp.getWert("normMinModellProSAI") + " auswählen<BR>");
                out.println("<LI>Die letzte SAI-Datei muss min. " + (int) zp.getWert("minModellProSAI") + " Modelle enthalten<BR>");
                out.println("</FONT>");
            }
        }
    }
    catch (Exception e) {
        e.printStackTrace();
        out.println(e);
        out.println("Test");
        con.rollback();
    }
// Markierte Artikelpositionen des aktuellen Teams selektieren
    sql = " SELECT ";
    sql += " sak_pnr,sak_sanr,kom_abnr,kom_art_nr,ap_posnr,ap_bezeichn,ap_menge,ap_sf_hw,ako_sf_hw_auftr ";
    sql += " FROM plrv11.zus_sammel_kopf ";
    sql += " INNER JOIN plrv11.zus_kommission on sak_sanr=kom_sammel_abnr ";
    sql += " INNER JOIN plrv11.plr_auftr_status ON kom_abnr=as_abnr ";
    sql += " INNER JOIN plrv11.plr_auftr_kopf ON kom_abnr=ako_abnr AND ako_aend_ix=as_aend_ix ";
    sql += " INNER JOIN plrv11.plr_art_pos ON kom_abnr=ap_abnr AND kom_art_nr=ap_syn AND as_aend_ix=ap_aend_ix ";
    sql += " WHERE as_status<>99 ";
    sql += " AND   sak_pnr = " + request.getParameter("team");
    sql += " AND (ap_klasse='M' OR ap_klasse='F')";
    sql += " AND   ap_sai  = 'B'";
    sql += " ORDER BY sak_sanr,kom_abnr,ap_posnr";
    rs = stmt.executeQuery(sql);

    anz = 0;
    while (rs.next()) {
        if (rs.isFirst()) {
            out.println("<form NAME=\"hakenRaus\">");
            out.println("<INPUT TYPE=\"button\" NAME=\"hakenRaus\" VALUE=\"Alle Häkchen entfernen\" onClick=\"hakenEntf();\">");
            out.println("</form>");
            out.println("<FORM ACTION=\"cutSelbstZuwEnde2.jsp\" NAME=\"haken\" METHOD=\"POST\">");
            out.println("<TABLE BORDER=1>");
            out.println("<TR BGCOLOR=\"#ddddff\">");
            out.println("<TH ALIGN=\"CENTER\">SA-Nr</TH>");
            out.println("<TH ALIGN=\"CENTER\">AB-Nr</TH>");
            out.println("<TH ALIGN=\"CENTER\">Pos-Nr</TH>");
            out.println("<TH ALIGN=\"CENTER\">Bez.</TH>");
            out.println("<TH ALIGN=\"CENTER\">SF-KZ</TH>");
            out.println("<TH ALIGN=\"CENTER\">Menge</TH>");
            out.println("<TH ALIGN=\"CENTER\">Auswahl</TH>");
        }

        menge = rs.getInt("ap_menge") / 100;
        if (gwAbNr.veraendert(rs.getString("kom_abnr")) == 1) {
            bgColor1.change();
        }
        out.println("<TR BGCOLOR=\"#" + bgColor1.getHtmlColor() + "\">");
        if (gwSANr.veraendert(rs.getString("sak_sanr")) == 1) {
            bgColor2.change();
        }
        out.println("<TD BGCOLOR=\"#" + bgColor2.getHtmlColor() + "\">" + rs.getString("sak_sanr"));
        out.println("<TD ALIGN=\"LEFT\">" + rs.getString("kom_abnr") + "</TD>");
        out.println("<TD ALIGN=\"RIGHT\">" + rs.getString("ap_posnr") + "</TD>");
        out.println("<TD ALIGN=\"LEFT\">" + rs.getString("ap_bezeichn") + "</TD>");
        if (rs.getString("ako_sf_hw_auftr") == "S") {
            sf = "Auftr. SF";
        }
        if (rs.getString("ap_sf_hw") == "S") {
            sf = "Pos SF";
        }
        out.println("<TD ALIGN=\"LEFT\">" + sf + "</TD>");
        out.println("<TD ALIGN=\"CENTER\">" + menge + "</TD>");
        out.print("<TD ALIGN=\"CENTER\"><INPUT TYPE=\"CHECKBOX\" NAME=\"auswahl\" VALUE=\"");
        out.print(rs.getString("sak_sanr") + ";");
        out.print(rs.getString("kom_abnr") + ";");
        out.print(rs.getString("ap_posnr") + "\" CHECKED></TD></TR>");
        anz++;
    }
    out.println("</TABLE>");
    if (anz > 0) {
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"anz\" VALUE=\"" + anz + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"lauf\" VALUE=\"" + lauf + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"artNr\" VALUE=\"" + artNr + "\">");
        out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"team\" VALUE=\"" + request.getParameter("team") + "\">");
        out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Weiter\">");

    }
    out.println("</FORM>");
    if (anz == 0) {
        out.println("<FORM ACTION=\"cutSelbstZuw.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Weiter zur Auftragszuweisung\"></FORM>");
    }
    con.close();
%>
</CENTER>
</body>
</html>

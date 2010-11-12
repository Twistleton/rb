<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<html>
<head>
    <title>QM-Erfassung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</HEAD>
<BODY BGCOLOR="#CCCCCC"
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    bdeConfigDatei bcd = new bdeConfigDatei("/etc/bdeServlet.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    bcd.verarbeiten();
    zcd.verarbeiten();

    Connection con = oraBde.getConnection();

    con.setAutoCommit(false);

    Statement stmt = con.createStatement();
    ResultSet rs;

    textDatei errorDatei = new textDatei("/tmp", "erfass.log");

    int abNr = 0;
    int prog = 0;
    int abmelden = 0;

    String sql = new String();
    String ausgabe = new String();

    int polstPNr = 0;
    int pruefGefunden = 0;
    int abGefunden = 0;
    int j = 0;
    String polstNName = new String();
    String polstVName = new String();
    long polstAP = 0;
    String pruefNName = new String();
    String pruefVName = new String();
    Date erfassDat = new Date();
    String narbErford = new String();
    String narbErkenn = new String();
    String sfCode = new String();
    String komment = new String();
    String freigabe = new String("n");
    String nichtOk = new String("n");
    String modus = new String("nix");
    String meldung = new String();
    String user = new String();
    int pin = 0;
    int dbPin = 0;
    int anmeldOk = 0;
    int anzKontr = 0;
    SimpleDateFormat df = new SimpleDateFormat("dd.MM.yyyy");

    int zaehler = 0;

// Anmeldung überprüfen, wenn fehlerhaft angemeldet, dann Zurück zu Eingabemaske
    try {
        user = request.getParameter("user");
        pin = Integer.parseInt(request.getParameter("pin"));
    }
    catch (Exception e) {
        user = null;
        pin = 0;
    }
    if (session.getAttribute("user") != null) {
        user = (String) session.getAttribute("user");
        pin = Integer.parseInt((String) session.getAttribute("pin"));
    }

    ausgabe += "<FORM NAME=\"form\" METHOD=\"POST\">";
    ausgabe += "<TABLE BORDER='1'>";

    try {
        if (request.getParameter("logoff").compareTo("Abmelden") == 0) {
            abmelden = 1;
        } else {
            abmelden = 0;
        }
    }
    catch (Exception ex) {
        abmelden = 0;
    }

    if ((user != null) && (pin != 0) && (abmelden == 0)) {
        sql = "SELECT ma_pnr,ma_pin FROM plrv11.bde_madat WHERE ma_user='" + user + "'";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        j = 0;
        while (rs.next()) {
            dbPin = rs.getInt("ma_pin");
            j++;
        }
        rs.close();
        if (pin == dbPin) {
            anmeldOk = 1;
            session.setAttribute("user", user);
            session.setAttribute("pin", String.valueOf(pin));
            out.println("onLoad='document.form.abNr.focus();'>");
            ausgabe += "Erfolgreiche Anmeldung<BR>";
        } else {
            out.println("onLoad='document.form.user.focus();'>");
            ausgabe += "<TR><TD COLSPAN='6'><FONT COLOR='red'><B>Falscher Benutzername oder falsches Passwort!</B></FONT></TD></TR>";
            session.invalidate();
        }

    } else {
        out.println("onLoad='document.form.user.focus();'>");
        session.invalidate();
    }
    out.println("<CENTER>");
    if ((j > 0) && (anmeldOk == 1)) {
        // Mitarbeiter ist sauber angemeldet
        ausgabe += "Anmeldung: " + user;
        try {
            modus = request.getParameter("modus");
        }
        catch (Exception ex) {
            ausgabe += "Keine Eingabe<BR>";
        }
        if (modus != null) {
            try {
                abNr = Integer.parseInt(request.getParameter("abNr"));
                prog = Integer.parseInt(request.getParameter("prog"));
                polstPNr = Integer.parseInt(request.getParameter("polstPNr"));
                polstNName = request.getParameter("polstNName");
                polstVName = request.getParameter("polstVName");
                polstAP = Long.parseLong(request.getParameter("polstAP"));
                pruefNName = request.getParameter("pruefNName");
                pruefVName = request.getParameter("pruefVName");
                if (request.getParameter("narbErford") != null) {
                    narbErford = "j";
                } else {
                    narbErford = "n";
                }
                if (request.getParameter("narbErkenn") != null) {
                    narbErkenn = "j";
                } else {
                    narbErkenn = "n";
                }
                try {
                    if ((request.getParameter("sfCode") != null) && (request.getParameter("sfCode") != "")) {
                        sfCode = request.getParameter("sfCode");
                        Integer.parseInt(sfCode);
                    } else {
                        sfCode = "0";
                    }
                }
                catch (Exception e) {
                    sfCode = "0";
                }
                komment = request.getParameter("komment");
                if (request.getParameter("nichtOk") != null) {
                    nichtOk = "j";
                } else {
                    nichtOk = "n";
                }

                freigabe = request.getParameter("freigabe");
                if (request.getParameter("freigabe") != null) {
                    freigabe = "j";
                } else {
                    freigabe = "n";
                }
                errorDatei.write(bdeZeit.getTimestamp("ddMMyyyyHHmmss") + " : AB:" + abNr);
                anzKontr = Integer.parseInt(request.getParameter("anzKontr"));
                if (modus.compareTo("insert") == 0) {
                    anzKontr = 1;
                    sql = "INSERT INTO plrv11.qm_endkontr ";
                    sql += "(qme_abnr,qme_prog,qme_polst_pnr,qme_polst_nname,qme_polst_vname, ";
                    sql += "qme_polst_ap,qme_pruef_nname,qme_pruef_vname,qme_erfass_dat,";
                    sql += "qme_narb_erford,qme_narb_erkenn,qme_sfcode,qme_komment,qme_freigabe,";
                    sql += "qme_nicht_ok,qme_anz_kontr) ";
                    sql += " VALUES (";
                    sql += abNr + "," + prog + "," + polstPNr + ",'" + polstNName + "','" + polstVName + "','";
                    sql += polstAP + "','" + pruefNName + "','" + pruefVName + "',TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),";
                    sql += "'" + narbErford + "','" + narbErkenn + "','" + sfCode + "','" + komment + "','" + freigabe + "','" + nichtOk + "'," + anzKontr + ")";
                    errorDatei.write("INSERT ");
                    stmt.executeUpdate(sql);
                    errorDatei.write("geschafft!\n");

                }
                if (modus.compareTo("update") == 0) {
                    sql = "UPDATE  plrv11.qm_endkontr ";
                    sql += "SET qme_pruef_nname = '" + pruefNName + "',";
                    sql += "qme_pruef_vname = '" + pruefVName + "',";
                    sql += "qme_erfass_dat  = TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),";
                    sql += "qme_narb_erford = '" + narbErford + "',";
                    sql += "qme_narb_erkenn = '" + narbErkenn + "',";
                    sql += "qme_sfcode      = '" + sfCode + "',";
                    sql += "qme_komment     = '" + komment + "',";
                    sql += "qme_freigabe    = '" + freigabe + "',";
                    sql += "qme_nicht_ok    = '" + nichtOk + "',";
                    sql += "qme_anz_kontr   =  " + (anzKontr + 1) + " WHERE qme_abnr=" + abNr;
                    errorDatei.write("UPDATE ");
                    stmt.executeUpdate(sql);
                    errorDatei.write("geschafft\n");
                }
                if (freigabe.compareTo("j") == 0) {
                    // Auftrag fertigmelden
                    sql = "UPDATE plrv11.bde_ab_fs_ma ";
                    sql += "SET abf_fs_status=40 ";
                    sql += "WHERE abf_abnr=" + abNr;
                    sql += " AND abf_fs='10245400000' ";
                    errorDatei.write("Fertigmelden " + abNr + " ");
                    stmt.executeUpdate(sql);
                    errorDatei.write("geschafft\n");
                    ausgabe += "<H2>Auftrag wurde fertig gemeldet</H2>";

                    // Rückmeldedatei für MMKS schreiben
                    qmDatei bqs = new qmDatei(zcd.getBqsPfad(), "bqsDatei", zcd.getBqsEndung());
                    bqs.setNameTimestamp();
                    bqs.oeffnen();
                    bqs.bqsDatei(abNr, 40, con); // Status auf "fertig" setzen: fs_status = 40
                    bqs.schliessen();
                    bqs.aktiviereDatei();
                } else {
                    sql = "UPDATE plrv11.bde_ab_fs_ma ";
                    sql += "SET abf_fs_status=20 ";
                    sql += "WHERE abf_abnr=" + abNr;
                    sql += " AND abf_fs='10245400000' ";
                    errorDatei.write("Störung setzen " + abNr + " ");
                    stmt.executeUpdate(sql);
                    errorDatei.write("geschafft\n");
                    ausgabe += "<H2>Auftrag bekommt Status 20</H2>";
                    // Rückmeldedatei für MMKS schreiben
                    qmDatei bqs = new qmDatei(zcd.getBqsPfad(), "bqsDatei", zcd.getBqsEndung());
                    bqs.setNameTimestamp();
                    bqs.oeffnen();
                    bqs.bqsDatei(abNr, 20, con); // Status auf "zurückgewiesen" setzen: fs_status = 20
                    bqs.schliessen();
                    bqs.aktiviereDatei();

                    // Datei erstellen "Rückweisungsprotokoll"
                    qmDatei qrw = new qmDatei(zcd.getQMPfad(), "qmRWProtokoll", zcd.getQMRWPEndung());
                    errorDatei.write(" " + abNr + " ");
                    qrw.setNameTimestamp();
                    qrw.oeffnen();
                    qrw.qmRWProtokoll(abNr, con);
                    qrw.schliessen();
                    qrw.aktiviereDatei();
                    qrw.drucken(zcd.getQMDrucker());
                }
                con.commit();
            }
            catch (Exception ex) {
                con.rollback();
                ausgabe += "<br>" + sql + "<BR>";
                ausgabe += " Fehler bei der Eingabe " + ex.getMessage();
                errorDatei.write("Fehler:" + ex.getMessage() + "\n");
                ex.printStackTrace();
            }
        }
        try {
            abNr = Integer.parseInt(request.getParameter("abNr"));
        }
        catch (Exception ex) {
            abNr = -1;
            ex.printStackTrace();
        }
        if (abNr > 0) {
            try {
                //  Polstern beendet?
                sql = "SELECT ako_prog,ako_abnr,abf_pf_platz,abf_pnr,ma_vname,ma_nname,ma_ap,abf_pnr,abf_fs_status ";
                sql += "FROM plrv11.plr_auftr_kopf ";
                sql += "INNER JOIN plrv11.plr_auftr_status ON ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix ";
                sql += "INNER JOIN plrv11.bde_ab_fs_ma ON ako_abnr=abf_abnr AND abf_aend_ix= as_aend_ix ";
                sql += "LEFT OUTER JOIN plrv11.bde_madat ON abf_pnr=ma_pnr ";
                sql += "WHERE ako_abnr=" + abNr;
                sql += " AND abf_fs='10245100000' ";
                sql += " AND as_status<>99";
                stmt.executeQuery(sql);
                // ausgabe += sql+"<BR>";
                rs = stmt.getResultSet();
                while (rs.next()) {
                    prog = rs.getInt("ako_prog");
                    abNr = rs.getInt("ako_abnr");
                    polstAP = rs.getLong("ma_ap");
                    polstPNr = rs.getInt("abf_pnr");
                    if (rs.getInt("abf_fs_status") == 40) {
                        polstNName = rs.getString("ma_vname").trim();
                        polstVName = rs.getString("ma_nname").trim();
                    } else {
                        polstPNr = 0;
                        polstNName = "unbekannt";
                        polstVName = "unbekannt";
                    }
                    abGefunden = 1;
                }
                if (abGefunden == 1) {
                    //  Endkontrolle gestartet und noch nicht beendet
                    sql = "SELECT ako_prog,ako_abnr,abf_pf_platz,abf_fs_status ";
                    sql += "FROM plrv11.plr_auftr_kopf ";
                    sql += "INNER JOIN plrv11.plr_auftr_status ON ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix ";
                    sql += "INNER JOIN plrv11.bde_ab_fs_ma ON ako_abnr=abf_abnr AND abf_aend_ix= as_aend_ix ";
                    sql += "WHERE ako_abnr=" + abNr;
                    sql += " AND abf_fs='10245400000' ";
                    sql += " AND abf_fs_status>=10 ";
                    sql += " AND as_status<>99";
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    while (rs.next()) {
                        prog = rs.getInt("ako_prog");
                        abNr = rs.getInt("ako_abnr");
                        if (rs.getInt("abf_fs_status") != 40) {
                            abGefunden = 2;
                        } else {
                            meldung = "<B><FONT COLOR=\"red\">Auftrag ist bereits fertig</FONT></B>";
                        }
                    }
                } else {
                    meldung = "<B><FONT COLOR=\"red\">Auftrag wurde nicht gefunden / Polstern noch nicht beendet</FONT></B>";

                }
                sql = "SELECT ma_vname,ma_nname ";
                sql += "FROM plrv11.bde_madat ";
                sql += "WHERE ma_user='" + user + "'";
                stmt.executeQuery(sql);
                // ausgabe += sql+"<BR>";
                rs = stmt.getResultSet();
                while (rs.next()) {
                    pruefNName = rs.getString("ma_vname").trim();
                    pruefVName = rs.getString("ma_nname").trim();
                    pruefGefunden = 1;
                }
                // Gibt es evtl. bereits einen Eintrag, der bearbeitet werden soll?
                sql = "SELECT qme_abnr,qme_prog,qme_polst_pnr,qme_polst_nname,qme_polst_vname, ";
                sql += "qme_polst_ap,qme_pruef_nname,qme_pruef_vname,qme_erfass_dat,";
                sql += "qme_narb_erford,qme_narb_erkenn,qme_sfcode,qme_komment,qme_freigabe,";
                sql += "qme_nicht_ok,qme_anz_kontr ";
                sql += "FROM plrv11.qm_endkontr ";
                sql += "WHERE qme_abnr=" + abNr;
                stmt.executeQuery(sql);
                // ausgabe += sql+"<BR>";
                rs = stmt.getResultSet();
                zaehler = 0;
                while (rs.next()) {
                    polstPNr = rs.getInt("qme_polst_pnr");
                    polstNName = rs.getString("qme_polst_nname");
                    polstVName = rs.getString("qme_polst_vname");
                    polstAP = rs.getLong("qme_polst_ap");
                    pruefNName = rs.getString("qme_pruef_nname");
                    pruefVName = rs.getString("qme_pruef_vname");
                    erfassDat = rs.getDate("qme_erfass_dat");
                    narbErford = rs.getString("qme_narb_erford");
                    narbErkenn = rs.getString("qme_narb_erkenn");
                    if (rs.getString("qme_sfcode") != null) {
                        sfCode = rs.getString("qme_sfcode");
                    } else {
                        sfCode = "";
                    }
                    if (rs.getString("qme_komment") != null) {
                        komment = rs.getString("qme_komment");
                    } else {
                        komment = "";
                    }
                    freigabe = rs.getString("qme_Freigabe");
                    nichtOk = rs.getString("qme_nicht_ok");
                    anzKontr = rs.getInt("qme_anz_kontr");
                    zaehler++;
                }
            }
            catch (Exception ex) {
                ausgabe += sql + "<BR>" + ex.getMessage();
            }
//		ausgabe +=abGefunden+"-"+pruefGefunden+"<BR>";
            if ((prog != 0) && (abGefunden == 2) && (pruefGefunden == 1)) {
                ausgabe += "<TABLE BORDER='0'><TR BGCOLOR='white'><TH>Ab-Nr.</TH><TH>Programm</TH></TR>";
                ausgabe += "<TR BGCOLOR='white'><TD ALIGN='center'>" + abNr + "</TD><TD ALIGN='center'>" + prog + "</TD></TR>";
                ausgabe += "</TABLE><TABLE BORDER='0'>";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"abNr\" VALUE=\"" + abNr + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"prog\" VALUE=\"" + prog + "\">";
                if (zaehler > 0) {
                    ausgabe += "<INPUT TYPE='hidden' NAME='modus' VALUE='update'>";

                } else {
                    ausgabe += "<INPUT TYPE='hidden' NAME='modus' VALUE='insert'>";
                }
                ausgabe += "<TR><TD>Polsterer:       </TD><TD>" + polstNName + ", " + polstVName + "</TD>";
                ausgabe += "<TD>Arbeitsplatz : " + polstAP + "</TD><TD>Personalnummer : " + polstPNr + "</TD>";
                ausgabe += "<TR><TD>Pr&uuml;fer:     </TD><TD COLSPAN='5'>" + pruefNName + ", " + pruefVName + "</TD></TR>";
                ausgabe += "<TR><TD>Nacharbeit Erforderlich</TD><TD COLSPAN='5'><INPUT TYPE=\"CHECKBOX\" NAME=\"narbErford\" VALUE=\"j\" ";
                if (narbErford.compareTo("j") == 0) ausgabe += "CHECKED ";
                ausgabe += "></TD></TR>";
                ausgabe += "<TR><TD>SF-Code   </TD><TD COLSPAN='5'><INPUT TYPE=\"TEXT\" NAME=\"sfCode\" VALUE=\"" + sfCode + "\" MAXLENGTH=\"4\" SIZE=\"4\">";
                ausgabe += "</TD></TR>";
                ausgabe += "<TR><TD>Nacharbeit Erkennbar   </TD><TD COLSPAN='5'><INPUT TYPE=\"CHECKBOX\" NAME=\"narbErkenn\" VALUE=\"j\" ";
                if (narbErkenn.compareTo("j") == 0) ausgabe += "CHECKED ";
                ausgabe += "></TD></TR>";
                ausgabe += "<TR><TD>Kommentar</TD>              <TD COLSPAN='5'><TEXTAREA NAME='komment' COLS=\"80\" ROWS=\"4\">" + komment + "</TEXTAREA></TD></TR>";
                ausgabe += "<TR><TD>Nicht in Ordnung       </TD><TD COLSPAN='5'><INPUT TYPE=\"CHECKBOX\" NAME=\"nichtOk\"  VALUE=\"j\" ";
                if (nichtOk.compareTo("j") == 0) ausgabe += "CHECKED ";
                ausgabe += "></TD></TR>";
                ausgabe += "<TR><TD>Datum</TD><TD COLSPAN='5'><INPUT TYPE=\"TEXT\" NAME=\"erfassDat\" READONLY VALUE=\"" + df.format(erfassDat) + "\" ";
                ausgabe += "></TD></TR>";
                ausgabe += "<TR><TD>Freigabe               </TD><TD COLSPAN='5'><INPUT TYPE=\"CHECKBOX\" NAME=\"freigabe\" VALUE=\"j\" ";
                if (freigabe.compareTo("j") == 0) ausgabe += "CHECKED ";
                ausgabe += "></TD></TR>";
                ausgabe += "<TR><TD>Anzahl erfolgter Kontrollen</TD><TD COLSPAN='5'>" + anzKontr + "</TD></TR>";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"anzKontr\"   VALUE=\"" + anzKontr + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"polstPNr\"   VALUE=\"" + polstPNr + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"polstVName\" VALUE=\"" + polstVName + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"polstNName\" VALUE=\"" + polstNName + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"polstAP\"    VALUE=\"" + polstAP + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"pruefVName\" VALUE=\"" + pruefVName + "\">";
                ausgabe += "<INPUT TYPE=\"hidden\" NAME=\"pruefNName\" VALUE=\"" + pruefNName + "\">";
            } else {
                ausgabe += "<TR><TD COLSPAN=\"2\">" + meldung + "</TD></TR>";
                ausgabe += "<TR><TD>AB-Nr       </TD><TD COLSPAN='5'><INPUT TYPE=\"TEXT\" NAME=\"abNr\" SIZE=\"10\" MAXLENGTH=\"6\"></TD>";
                ausgabe += "</TR>";
            }
        } else {
            ausgabe += "<TR><TD>AB-Nr       </TD><TD COLSPAN='5'><INPUT TYPE=\"TEXT\" NAME=\"abNr\" SIZE=\"10\" MAXLENGTH=\"6\"></TD></TR>";
        }
        ausgabe += "<TR><TD><INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\"></TD><TD ALIGN=\"right\"><INPUT TYPE=\"submit\" NAME=\"logoff\" VALUE=\"Abmelden\"></TD></TR>";
        ausgabe += "</FORM>";
        ausgabe += "</TABLE>";

    } else {
        // keine gscheide Anmeldung
        ausgabe += "<TR><TD COLSPAN='6' ALIGN='CENTER'><B>Anmeldung</B></TD></TR>";
        ausgabe += "<TR><TD>User  </TD><TD COLSPAN='5'><INPUT TYPE=\"TEXT\" NAME=\"user\" SIZE=\"10\" MAXLENGTH=\"10\"></TD></TR>";
        ausgabe += "<TR><TD>PIN   </TD><TD COLSPAN='5'><INPUT TYPE=\"PASSWORD\" NAME=\"pin\"  SIZE=\"6\"  MAXLENGTH=\"4\"> </TD></TR>";
        ausgabe += "<TR><TD><INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\"></TD><TD></TD></TR>";
        ausgabe += "</FORM>";
        ausgabe += "</TABLE>";
    }
    out.println(ausgabe);
    con.commit();
%>
</CENTER>
</BODY>
</HTML>

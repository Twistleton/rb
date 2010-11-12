<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.*" %>


<!--### KORREKTURBUCHUNG SAMMELAUFTRAG IMEZ/K VG=21 ###-->

<html>
<head>
    <style type="text/css" media="screen">
        <!--
        body {
            font-size: 12px;
            font-family: "Arial", Arial, sans-serif;
            color: #000000;
        }

        a:link {
            text-decoration: none;
            font-weight: bold;
            color: #000000;
        }

        a:visited {
            text-decoration: none;
            font-weight: bold;
            color: #000000;
        }

        a:hover {
            text-decoration: none;
            font-weight: bold;
            background-color: #ffffff;
        }

        a:active {
            text-decoration: none;
            font-weight: bold;
            background-color: #ff0000;
        }

        -->
    </style>
    <title>
    </title>
</head>
<body OnLoad="document.form.submit.focus();" bgcolor="#ffaeb9">
<table border="0" align="center" cellspacing="1">
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_testneu.conf");
    Connection con = oraBde.getConnection();

    String mod = request.getParameter("mod");
    String sammelAbNr = request.getParameter("sammelAbNr");
    String sakArtNr = request.getParameter("sakArtNr");
    String charge = request.getParameter("charge");
    String persNr = request.getParameter("persNr");
    String lieferant = request.getParameter("lieferant");
    String menge = request.getParameter("istmenge");
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
    String mverbrauch = request.getParameter("mverbrauch");
    String rmenge = request.getParameter("rmenge");
    String korrKz = request.getParameter("korrKz");
    String sakBuchMM = request.getParameter("sakBuchMM");
    String zsSys = request.getParameter("zsSys");
    String zbl = request.getParameter("zbl");
    float bruttosumme = 0;
    float komBrutto = 0;
    float prozAnteil = 0;
    float komgebmeng = 0;
    BigDecimal kommi = new BigDecimal("0.00");
    BigDecimal komGebuchteMenge = new BigDecimal("0.00");
    BigDecimal hostBruttoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziBruttoMenge = new BigDecimal("0.00");
    BigDecimal hostNettoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziNettoMenge = new BigDecimal("0.00");
    float istmenge = new Float(menge.replace(',', '.')).floatValue();
    String komAbNr = "";
    String komArtNr = "";

    String sql = "";
    String sql1 = "";
    String sql2 = "";
    String sql3 = "";
    String sql4 = "";
    String sql5 = "";
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    Statement stmt3;
    Statement stmt4;
    Statement stmt5;
    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    ResultSet resultSet3;
    ResultSet resultSet4;
    ResultSet resultSet5;
    ResultSet resultSet6;
    stmt = con.createStatement();
    stmt1 = con.createStatement();
    stmt2 = con.createStatement();
    stmt3 = con.createStatement();
    stmt4 = con.createStatement();
    stmt5 = con.createStatement();
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    String bmonat = "";
    int error = 0;
    float neue_istmenge = 0;
    float menge_ist = 0;
    float rueckmenge = 0;
    float mehrverbrauch = 0;
    String einzelKz = "";
    String komProg = "";
    float komNetto = 0;
    String dezi = "";

    String bruttomenge = "";
    float bruttoMenge = 0;
    float vrglmenge = 0;
    int werk = 0;
    String komKzMf = "";
    String checkvar = request.getParameter("checkvar");
    float maximalMenge = 0;
    try {
        menge_ist = new Float(menge.replace(',', '.')).floatValue();
        rueckmenge = new Float(rmenge.replace(',', '.')).floatValue();
        mehrverbrauch = new Float(mverbrauch.replace(',', '.')).floatValue();
    } catch (Exception e) {
        out.println("<br><br>Fehler:" + e);
    }

    //### Bruttomenge holen und feststellen ob Verursacherschluessel notwendig ist ###
    sql = "SELECT SUM(KOM_QM_BRUTTO)as gesamtbrutto FROM PLRV11.ZUS_KOMMISSION WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND";
    sql += " KOM_GEBUCHT_KZ='J' AND KOM_STATUS=50 AND (KOM_KZ_EINZEL='N' OR KOM_KZ_EINZEL IS NULL)";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet6 = stmt.getResultSet();

    try {
        while (resultSet6.next()) {
            bruttomenge = resultSet6.getString("gesamtbrutto");
            bruttoMenge = new Float(bruttomenge).floatValue();
        }
    } catch (SQLException e) {
        out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
        out.println("<br><br>" + e);
    }
    vrglmenge = menge_ist - rueckmenge;
    maximalMenge = 2 * bruttoMenge;

    if (mod.equals("eintrag")) {
        //### Entweder MEHRVERBRAUCH oder RUECKGABE, beide Felder duerfen nicht befuellt sein ###
        if ((mehrverbrauch != 0 && rueckmenge == 0) || (mehrverbrauch == 0 && rueckmenge != 0)) {
            if (mehrverbrauch != 0 && verkey.equals("00")) {
                if (mehrverbrauch > maximalMenge) {
                    out.println("Mengeneingabe (" + istmenge + ") ist viel viel gr&ouml;sser als Bruttomengen (" + bruttoMenge + "):&nbsp;<br><br>");
                    out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
                    out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel_korr&checkvar=checked&key=setkey&mverbrauch=" + mverbrauch + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                } else {
                    out.println("Bei Eintrag im Feld MEHRVERBRAUCH:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;<br><br>");
                    out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel_korr&key=setkey&mverbrauch=" + mverbrauch + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                }
            }
            //### ISTMenge-Rueckgabemenge immer noch groesser als Gesamt-Brutto?? -->Verursacherschluessel!! ###
            else if ((rueckmenge != 0 && verkey.equals("00")) && (vrglmenge > bruttoMenge)) {
                if (rueckmenge > maximalMenge) {
                    out.println("Bruttomenge (" + bruttoMenge + ") ist viel viel kleiner als die eingegebene R&uuml;ckgabemenge (" + rueckmenge + ")&nbsp;!<br><br>");
                    out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
                    out.println("ISTMENGE:" + menge_ist + "<br>");
                    out.println("BRUTTOMENGE:" + bruttoMenge + "<br>");
                    out.println("RUCKGABEMENGE:" + rueckmenge + "<br><br>");
                    out.println("Istmenge-rueckgabemenge=" + vrglmenge + "<br><br>");
                    out.println("Verbrauchte Menge > Bruttomenge:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben!!&nbsp;&nbsp;<br><br>");
                    out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel_korr&checkvar=checked&key=setkey2&rmenge=" + rueckmenge + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                } else {
                    out.println("ISTMENGE:" + menge_ist + "<br>");
                    out.println("BRUTTOMENGE:" + bruttoMenge + "<br>");
                    out.println("RUCKGABEMENGE:" + rueckmenge + "<br><br>");
                    out.println("Istmenge-rueckgabemenge=" + vrglmenge + "<br><br>");
                    out.println("Verbrauchte Menge > Bruttomenge:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben!!&nbsp;&nbsp;<br><br>");
                    out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel_korr&key=setkey2&rmenge=" + rueckmenge + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                }
            } else {
                //### neue Menge ermitteln ###
                if (mehrverbrauch > 0) {
                    neue_istmenge = menge_ist + mehrverbrauch;
                    out.println("<br>Neue IST-Menge:&nbsp;" + neue_istmenge + "<br>");
                } else {
                    neue_istmenge = menge_ist - rueckmenge;
                    out.println("<br>Neue IST-Menge:&nbsp;" + neue_istmenge + "<br>");
                }

                //### Update der Kommissionstabelle ###

                //### Buchungsmonat je nach Korrekturkennzeichen ###
                if (korrKz.equals("J")) {
                    bmonat = sakBuchMM;
                } else {
                    bmonat = buchungsmonat;
                }
                //out.println("<br><br>korrKz:"+korrKz+"<br><br>BMonat:"+buchungsmonat);

                //### Bruttosumme ueber alle Kommissionen ermitteln ###
                sql = "SELECT SUM(KOM_QM_BRUTTO)AS bruttosumme FROM PLRV11.ZUS_KOMMISSION WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND";
                sql += " KOM_GEBUCHT_KZ='J' AND KOM_STATUS=50 AND (KOM_KZ_EINZEL='N' OR KOM_KZ_EINZEL IS NULL)";
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                resultSet = stmt.getResultSet();
                try {
                    while (resultSet.next()) {

                        bruttosumme = resultSet.getFloat("bruttosumme");

                        if (bruttosumme == 0.0) {
                            out.println("<br><br>Alle Kommissionen des Sammelauftrags sind bereits gebucht!<br>");
                        }
                    }
                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                    out.println("<br><br>" + e);
                    error = 1;
                }


                //### Bruttosummen je Kommission ermitteln ###
                sql1 = "SELECT KOM_QM_BRUTTO,KOM_ABNR,KOM_ART_NR";
                sql1 += " FROM PLRV11.ZUS_KOMMISSION WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND";
                sql1 += " KOM_GEBUCHT_KZ='J' AND KOM_STATUS=50 AND (KOM_KZ_EINZEL='N' OR KOM_KZ_EINZEL IS NULL)";
                //out.println(sql1);
                stmt1 = con.createStatement();
                stmt1.executeQuery(sql1);
                resultSet1 = stmt1.getResultSet();
                try {
                    while (resultSet1.next()) {

                        komBrutto = resultSet1.getFloat("KOM_QM_BRUTTO");
                        komAbNr = resultSet1.getString("KOM_ABNR");
                        komArtNr = resultSet1.getString("KOM_ART_NR");

                        prozAnteil = komBrutto / bruttosumme;
                        komgebmeng = prozAnteil * neue_istmenge;

                        //### Runden der Ergebnisse ###
                        kommi = new BigDecimal(komgebmeng);
                        komGebuchteMenge = kommi.setScale(2, BigDecimal.ROUND_HALF_UP);

                        //### Eintrag der neuen Kommissionsdaten incl neuer IST-Menge ###
                        sql2 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=";
                        ;
                        sql2 += komGebuchteMenge + " WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND KOM_ABNR=" + komAbNr;
                        sql2 += " AND KOM_ART_NR=" + komArtNr;

                        try {
                            //out.println(sql2);
                            stmt2.executeQuery(sql2);
                            out.println("<br>Folgender Datensatz erfolgreich eingetragen:<br><br>");
                            out.println("Kom-ABNR:" + komAbNr + "<br>KomArtNr:" + komArtNr + "<br>BRUTTO-Menge:" + komBrutto + "<br>IST-Menge:");
                            out.println(komGebuchteMenge + "<br>");
                        } catch (SQLException e) {
                            out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql2);
                            error = 1;
                        }
                        //### Datensatz an Host generieren ###
                        if (error == 1) {
                            out.println("Fehler!");
                        } else {
                            //###HOST-Datensatz-Generierung ###
                            out.println("<br><br>Generierung des HOST-Datensatzes:");
                            sql3 = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_KZ_EINZEL,KOM_WERK_ZUSCHN,KOM_KZ_MF";
                            sql3 += " FROM PLRV11.ZUS_KOMMISSION";
                            sql3 += " WHERE  KOM_ABNR=" + komAbNr + " AND KOM_ART_NR=" + komArtNr;
                            //out.println(sql3);
                            stmt3 = con.createStatement();
                            stmt3.executeQuery(sql3);
                            resultSet3 = stmt3.getResultSet();

                            try {
                                while (resultSet3.next()) {

                                    komProg = resultSet3.getString("KOM_PROG");
                                    komNetto = resultSet3.getFloat("KOM_QM_NETTO");
                                    einzelKz = resultSet3.getString("KOM_KZ_EINZEL");
                                    werk = resultSet3.getInt("KOM_WERK_ZUSCHN");
                                    komKzMf = resultSet3.getString("KOM_KZ_MF");
                                }
                            } catch (SQLException e) {
                                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql3);
                                out.println("<br><br>" + e);
                            }

                            //### Dezis raussuchen ###
                            sql4 = "SELECT KFS_DEZI FROM PLRV11.ZUS_KOM_FS";
                            sql4 += " WHERE  KFS_ABNR=" + komAbNr + " AND KFS_ARTNR=" + komArtNr + " AND KFS_FS='10244100000'";
                            //out.println(sql4);
                            stmt4 = con.createStatement();
                            stmt4.executeQuery(sql4);
                            resultSet4 = stmt4.getResultSet();

                            try {
                                while (resultSet4.next()) {
                                    dezi = resultSet4.getString("KFS_DEZI");
                                }
                            } catch (SQLException e) {
                                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql4);
                                out.println("<br><br>" + e);
                            }


                            StringBuffer to_horst = new StringBuffer(171);
                            Date dt = new Date();
                            SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
                            String date = df.format(dt);
                            //String hostbruttomenge = String.valueOf(komBrutto);
                            String hostkomGebuchteMenge = String.valueOf(komGebuchteMenge);
                            String zeit = " ";

                            hostBruttoMenge = new BigDecimal(komBrutto);
                            bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                            String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

                            hostNettoMenge = new BigDecimal(komNetto);
                            bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                            String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

                            //### WERK-Eintrag ###
                            if (werk > 40) {
                                zsSys = String.valueOf(werk);
                            }
                            //### MF-Eintrag ###
                            if (komKzMf.equals("M") || komKzMf.equals("F")) {
                                persNr = "0349";
                            }

                            to_horst.insert(0, "0201E013");
                            to_horst.append(date);
                            to_horst.append("170RM");
                            to_horst.append(rbTextFormat.format('0', 6, komAbNr));
                            to_horst.append("LB02");
                            to_horst.append("21");
                            to_horst.append(komArtNr);
                            to_horst.append(rbTextFormat.format('0', 8, hostkomGebuchteMenge));
                            to_horst.append(rbTextFormat.format(' ', 2, verkey));
                            to_horst.append("000000");
                            to_horst.append(rbTextFormat.format('0', 4, persNr));
                            to_horst.append(schicht);
                            to_horst.append("10002030000");
                            to_horst.append(date);
                            to_horst.append(rbTextFormat.format(' ', 10, charge));
                            to_horst.append(zsSys);
                            to_horst.append(rbTextFormat.format(' ', 4, lieferant));
                            to_horst.append(rbTextFormat.format('0', 14, sammelAbNr));
                            to_horst.append(rbTextFormat.format('0', 4, buchungsmonat));
                            to_horst.append(rbTextFormat.format('0', 3, komProg));
                            to_horst.append(rbTextFormat.format('0', 11, scaledNettoMenge));
                            to_horst.append(rbTextFormat.format('0', 11, scaledBruttoMenge));
                            to_horst.append(rbTextFormat.format(' ', 7, dezi));
                            to_horst.append(rbTextFormat.format(' ', 10, zeit));
                            to_horst.append("K");
                            to_horst.append(einzelKz);
                            to_horst.append(zbl);
                            to_horst.append("\n");

                            out.println("<br>" + to_horst);

                            String datensatz = to_horst.toString();
                            //### Datei generieren ###
                            komDruckDatei buchung = new komDruckDatei("/home/zusch", "buchungsdatensatz", "BVL");
                            buchung.setNameTimestamp();
                            buchung.oeffnen();
                            buchung.satzEinfuegen(datensatz);
                            buchung.schliessen();

                            out.println("<br><br><b>Der HOST-Datensatz wurde erstellt!</b>");
                            out.println("<br><br>Laenge:" + to_horst.length() + "<br>");
                            out.println("<br><br>gebuchte Menge:" + hostkomGebuchteMenge + "<br>");
                            out.println("komBrutto:" + scaledBruttoMenge + "<br>");
                            out.println("komNetto:" + scaledNettoMenge + "<br>");
                            out.println("Werk:" + werk + "<br><br>");

                            buchung.aktiviereDatei();
                        }
                    }

                    //### Hier muss noch der Sammelauftragsstatus auf 30 gesetzt werden ###
                    if (error == 1) {
                        out.println("Fehler!");
                    } else {
                        out.println("<br><br>Sammelauftragskopfdaten eintragen!!");
                        sql5 = "UPDATE PLRV11.ZUS_SAMMEL_KOPF SET SAK_KORR_KZ='J',SAK_BUCH_MM ='" + buchungsmonat + "',SAK_MENGE_IST=";
                        sql5 += neue_istmenge + " WHERE SAK_SANR=" + sammelAbNr;

                        try {
                            //out.println(sql5);
                            stmt5.executeQuery(sql5);
                            out.println("<br>Folgender Datensatz erfolgreich eingetragen:<br><br>");
                            out.println("Sammel-ABNR:" + sammelAbNr + "<br>IST-Menge:" + menge + "<br>Korr.KZ:J<br>Buchungsmonat:" + buchungsmonat);
                            out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_sammel_korr\" method=\"post\" target=\"main\">");
                            out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
                            //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_sammel_korr\">");
                            //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                            out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
                            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");


                        } catch (SQLException e) {
                            out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql5);
                            error = 1;
                        }
                    }

                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                    out.println("<br><br>" + e);
                    error = 1;
                }
            }

        }


    }
    con.close();
%>
</body>
</html>
      


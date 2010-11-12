<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<%@ page import="java.math.BigDecimal" %>

<!--### KORREKTURBUCHUNG EINZELKOMMISSION IMEZ/K VG=21 ###-->

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
    String abNr = request.getParameter("abNr");
    String artNr = request.getParameter("artNr");
    String charge = request.getParameter("charge");
    String persNr = request.getParameter("persNr");
    String lieferant = request.getParameter("lieferant");
    String istmenge = request.getParameter("istmenge");
    String sammelAbNr = request.getParameter("sammelAbNr");
    String korrKz = request.getParameter("korrKz");
    String komBuchMM = request.getParameter("komBuchMM");
    String rmenge = request.getParameter("rmenge");
    String mverbrauch = request.getParameter("mverbrauch");
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
    String zeit = request.getParameter("zeit");
    String zsSys = request.getParameter("zsSys");
    String zbl = request.getParameter("zbl");
    String kzGebucht = "J";
    String kzEinzel = "J";
    String krit = "";
    String hinweis = "";
    try {
        krit = request.getParameter("krit");
        hinweis = request.getParameter("hinweis");
    } catch (Exception e) {
        krit = "";
        hinweis = "";
    }
    String sql = "";
    String sql1 = "";
    Statement stmt;
    Statement stmt1;
    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    stmt = con.createStatement();
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    String zeitwert = zeit.replace('.', ',');
    //float zeitwert       = new Float(zeit.replace(',','.')).floatValue();
    int werk = new Integer(request.getParameter("werk")).intValue();

    String bmonat = "";
    int error = 0;
    float neue_istmenge = 0;
    float menge_ist = 0;
    float rueckmenge = 0;
    float mehrverbrauch = 0;
    String einzelKz = "";
    String komProg = "";
    float komNetto = 0;
    float komBrutto = 0;
    String dezi = "";
    BigDecimal rund = new BigDecimal("0.00");
    BigDecimal rundmenge = new BigDecimal("0.00");
    BigDecimal hostBruttoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziBruttoMenge = new BigDecimal("0.00");
    BigDecimal hostNettoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziNettoMenge = new BigDecimal("0.00");
    BigDecimal hostZeit = new BigDecimal("0.00");
    BigDecimal bigDeziZeit = new BigDecimal("0.00");

    String bruttomenge = "";
    float bruttoMenge = 0;
    float vrglmenge = 0;
    String komKzMf = "";
    String komKzPraemie = "";
    float maximalMenge = 2 * bruttoMenge;
    String checkvar = request.getParameter("checkvar");

    try {
        menge_ist = new Float(istmenge.replace(',', '.')).floatValue();
        rueckmenge = new Float(rmenge.replace(',', '.')).floatValue();
        mehrverbrauch = new Float(mverbrauch.replace(',', '.')).floatValue();
    } catch (Exception e) {
        out.println("<br><br>Fehler:" + e);
    }

    //### Bruttomenge holen und feststellen ob Verursacherschluessel notwendig ist ###
    sql = "SELECT KOM_QM_BRUTTO FROM PLRV11.ZUS_KOMMISSION WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet2 = stmt.getResultSet();

    try {
        while (resultSet2.next()) {
            bruttomenge = resultSet2.getString("KOM_QM_BRUTTO");
            bruttoMenge = new Float(bruttomenge).floatValue();
        }
    } catch (SQLException e) {
        out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
        out.println("<br><br>" + e);
    }
    vrglmenge = menge_ist - rueckmenge;

    if (mod.equals("eintrag")) {
        //### Entweder MEHRVERBRAUCH oder RUECKGABE, beide Felder duerfen nicht befuellt sein ###
        if ((mehrverbrauch != 0 && rueckmenge == 0) || (mehrverbrauch == 0 && rueckmenge != 0)) {

            //### Bei Eintrag im Feld MEHRVERBRAUCH: Verursacherschluessel muss eingetragen werden! ###
            if ((mehrverbrauch != 0) && (verkey.equals("00")) && (!(checkvar.equals("checked")))) {
                if (mehrverbrauch > maximalMenge) {
                    out.println("Bruttomenge( " + bruttomenge + ") ist viel viel kleiner als der eingegebene Mehrverbrauch (" + mehrverbrauch + ")&nbsp;!<br><br>");
                    out.println("<font color='red'><b>Bitte Mehverbrauch-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
                    out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_kom_korr&checkvar=checked&key=setmenge&mverbrauch=" + mehrverbrauch + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                } else {
                    out.println("Bei Eintrag im Feld MEHRVERBRAUCH:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;<br><br>");
                    out.println("<f orm name=\"form\" action=\"./buchung.jsp?mod=imez_kom_korr&key=setkey&mverbrauch=" + mverbrauch + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                    //out.println("<a href=\"./buchung.jsp?mod=imez_kom_korr&key=setkey&mverbrauch="+mverbrauch);
                    //out.println("&auftr_bez_nr="+artNr+abNr+"\">");
                    //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Eingabe</a>");
                }
            }

            //### ISTMenge-Rueckgabemenge immer noch groesser als Brutto?? -->Verursacherschluessel!! ###
            else if ((rueckmenge != 0 && verkey.equals("00")) && (vrglmenge > bruttoMenge)) {
                if (rueckmenge > maximalMenge) {
                    out.println("Bruttomenge( " + bruttomenge + ") ist viel viel kleiner als die eingegebene R&uuml;ckgabemenge(" + rueckmenge + ")&nbsp;!<br><br>");
                    out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
                    out.println("ISTMENGE:" + menge_ist + "<br>");
                    out.println("BRUTTOMENGE:" + bruttoMenge + "<br>");
                    out.println("RUCKGABEMENGE:" + rueckmenge + "<br><br>");
                    out.println("Istmenge-rueckgabemenge=" + vrglmenge + "<br><br>");
                    out.println("Verbrauchte Menge > Bruttomenge:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben!!&nbsp;&nbsp;<br><br>");
                    out.println("<a href=\"./buchung.jsp?mod=imez_kom_korr&checkvar=checked&key=setkey2&rmenge=" + rueckmenge);
                    out.println("&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\">");
                    out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Eingabe</a>");
                } else {
                    out.println("ISTMENGE:" + menge_ist + "<br>");
                    out.println("BRUTTOMENGE:" + bruttoMenge + "<br>");
                    out.println("RUCKGABEMENGE:" + rueckmenge + "<br><br>");
                    out.println("Istmenge-rueckgabemenge=" + vrglmenge + "<br><br>");
                    out.println("Verbrauchte Menge > Bruttomenge:&nbsp;<br><br>");
                    out.println("Verursacherschl&uuml;ssel eingeben!!&nbsp;&nbsp;<br><br>");
                    out.println("<a href=\"./buchung.jsp?mod=imez_kom_korr&key=setkey2&rmenge=" + rueckmenge);
                    out.println("&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\">");
                    out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Eingabe</a>");
                }
            } else {
                //### neue Menge ermitteln ###
                if (mehrverbrauch > 0) {
                    neue_istmenge = menge_ist + mehrverbrauch;
                    rund = new BigDecimal(neue_istmenge);
                    rundmenge = rund.setScale(2, BigDecimal.ROUND_HALF_UP);
                    out.println("<br>Neue IST-Menge:&nbsp;" + rundmenge + "<br>");
                } else {
                    neue_istmenge = menge_ist - rueckmenge;
                    rund = new BigDecimal(neue_istmenge);
                    rundmenge = rund.setScale(2, BigDecimal.ROUND_HALF_UP);
                    out.println("<br>Neue IST-Menge:&nbsp;" + rundmenge + "<br>");
                }

                //### Update der Kommissionstabelle ###

                //### Buchungsmonat je nach Korrekturkennzeichen ###
                if (korrKz.equals("J")) {
                    bmonat = komBuchMM;
                } else {
                    bmonat = buchungsmonat;
                }
                //out.println("<br><br>BMonat:"+buchungsmonat);
                sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=" + rundmenge;
                sql += ",KOM_KZ_EINZEL='J',KOM_KZ_KORR='J',KOM_KRITERIUM='" + krit + "',KOM_HINWEIS='" + hinweis + "' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

                try {
                    //out.println(sql);
                    stmt.executeQuery(sql);
                    out.println("<br>Update[ZUS_KOMMISSION] erfolgreich eingetragen!");
                } catch (SQLException e) {
                    out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql);
                    error = 1;
                }

                //### Update der Sammelkopf-Tabelle ###
                if (error != 1) {
                    sql1 = "UPDATE PLRV11.ZUS_SAMMEL_KOPF SET SAK_CHARG_NR=" + charge + ",SAK_LIEF_KKZ='" + lieferant + "'";
                    sql1 += " WHERE SAK_SANR=" + sammelAbNr;

                    try {
                        //out.println(sql1);
                        stmt.executeQuery(sql1);
                        out.println("<br>Update[ZUS_SAMMEL_KOPF] erfolgreich eingetragen!<br><br>");
                        out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_kom_korr\" method=\"post\" target=\"main\">");
                        out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
                        //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_kom_korr\">");
                        //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                        out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
                        out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");
                    } catch (SQLException e) {
                        out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                        error = 1;
                    }
                    if (error != 1) {
                        //### HOST-Datensatz-Generierung ###
                        out.println("<br><br>Generierung des HOST-Datensatzes:");
                        sql = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_QM_BRUTTO,KOM_KZ_EINZEL,KOM_KZ_MF,KOM_KZ_PRAEMIE";
                        sql += " FROM PLRV11.ZUS_KOMMISSION";
                        sql += " WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
                        //out.println(sql);
                        stmt = con.createStatement();
                        stmt.executeQuery(sql);
                        resultSet = stmt.getResultSet();

                        try {
                            while (resultSet.next()) {

                                komProg = resultSet.getString("KOM_PROG");
                                komNetto = resultSet.getFloat("KOM_QM_NETTO");
                                komBrutto = resultSet.getFloat("KOM_QM_BRUTTO");
                                einzelKz = resultSet.getString("KOM_KZ_EINZEL");
                                komKzMf = resultSet.getString("KOM_KZ_MF");
                                komKzPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                            }
                        } catch (SQLException e) {
                            out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                            out.println("<br><br>" + e);
                        }

                        sql1 = "SELECT KFS_DEZI FROM PLRV11.ZUS_KOM_FS";
                        sql1 += " WHERE  KFS_ABNR=" + abNr + " AND KFS_ARTNR=" + artNr + " AND KFS_FS='10244100000'";
                        //out.println(sql1);
                        stmt1 = con.createStatement();
                        stmt1.executeQuery(sql1);
                        resultSet1 = stmt1.getResultSet();

                        try {
                            while (resultSet1.next()) {

                                dezi = resultSet1.getString("KFS_DEZI");
                            }
                        } catch (SQLException e) {
                            out.println("Fehler bei der Datenbankabfrage<br><br>" + sql1);
                            out.println("<br><br>" + e);
                        }

                        StringBuffer to_horst = new StringBuffer(250);
                        Date dt = new Date();
                        SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
                        String date = df.format(dt);
                        String hostmenge = String.valueOf(rundmenge);

                        hostBruttoMenge = new BigDecimal(komBrutto);
                        bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                        String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

                        hostNettoMenge = new BigDecimal(komNetto);
                        bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                        String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

                        //hostZeit              = new BigDecimal(zeitwert);
                        //bigDeziZeit           = hostZeit.setScale( 2, BigDecimal.ROUND_HALF_UP );
                        //String scaledZeit     = String.valueOf(bigDeziZeit);
                        //out.println("ZEIT:"+scaledZeit+"<br>");

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
                        to_horst.append(rbTextFormat.format('0', 6, abNr));
                        to_horst.append("LB02");
                        to_horst.append("21");
                        to_horst.append(artNr);
                        to_horst.append(rbTextFormat.format('0', 8, hostmenge));
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
                        to_horst.append(rbTextFormat.format('0', 4, bmonat));
                        to_horst.append(rbTextFormat.format('0', 3, komProg));
                        to_horst.append(rbTextFormat.format('0', 11, scaledNettoMenge));
                        to_horst.append(rbTextFormat.format('0', 11, scaledBruttoMenge));
                        to_horst.append(rbTextFormat.format(' ', 7, dezi));
                        to_horst.append(rbTextFormat.format(' ', 10, zeitwert));
                        //to_horst.append(rbTextFormat.format(' ',10,scaledZeit));
                        to_horst.append("K");
                        to_horst.append(einzelKz);
                        to_horst.append(rbTextFormat.linksb(' ', 1, zbl));
                        to_horst.append(rbTextFormat.linksb(' ', 39, krit));
                        to_horst.append(rbTextFormat.linksb(' ', 38, hinweis));
                        to_horst.append(rbTextFormat.linksb(' ', 1, komKzPraemie));
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
                        out.println("<br><br>istmenge:" + hostmenge + "<br>");
                        out.println("komBrutto:" + scaledBruttoMenge + "<br>");
                        out.println("komNetto:" + scaledNettoMenge + "<br>");
                        out.println("Werk:" + werk + "<br><br>");

                        buchung.aktiviereDatei();
                    }
                }
            }
        } else {
            //### Wenn beide Felder befuellt sind-FEHLERMELDUNG ###
            out.println("<font color=\"#ff0000\" size=\"+1\">Fehler bei der Eingabe!</font>");
            out.println("<br><br>");
            out.println("Eingabe darf nur bei 'Mehrverbrauch' ODER bei 'R&uuml;ckgabemenge' erfolgen!!<br><br>");
            out.println("<a href='javascript:history.go(-1)'>zur&uuml;ck</a>");
        }
    }

    if (mod.equals("mitkey")) {
        //### neue Menge ermitteln ###
        if (mehrverbrauch > 0) {
            neue_istmenge = menge_ist + mehrverbrauch;
            rund = new BigDecimal(neue_istmenge);
            rundmenge = rund.setScale(2, BigDecimal.ROUND_HALF_UP);
            out.println("<br>Neue IST-Menge:&nbsp;" + rundmenge + "<br>");
        } else {
            neue_istmenge = menge_ist - rueckmenge;
            rund = new BigDecimal(neue_istmenge);
            rundmenge = rund.setScale(2, BigDecimal.ROUND_HALF_UP);
            out.println("<br>Neue IST-Menge:&nbsp;" + rundmenge + "<br>");
        }

        //### Buchungsmonat je nach Korrekturkennzeichen ###
        if (korrKz.equals("J")) {
            bmonat = komBuchMM;
        } else {
            bmonat = buchungsmonat;
        }
        //### Update der Kommissionstabelle ###
        sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM=" + buchungsmonat + ",KOM_IST_MENGE=" + rundmenge;
        sql += ",KOM_KZ_EINZEL='J',KOM_KZ_KORR='J' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

        try {
            //out.println(sql);
            stmt.executeQuery(sql);
            out.println("<br>Update[ZUS_KOMMISSION] erfolgreich eingetragen!");
        } catch (SQLException e) {
            out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql);
            error = 1;
        }

        //### Update der Sammelkopf-Tabelle ###
        if (error != 1) {
            sql1 = "UPDATE PLRV11.ZUS_SAMMEL_KOPF SET SAK_CHARG_NR=" + charge + ",SAK_LIEF_KKZ='" + lieferant + "'";
            sql1 += " WHERE SAK_SANR=" + sammelAbNr;

            try {
                //out.println(sql1);
                stmt.executeQuery(sql1);
                out.println("<br>Update[ZUS_SAMMEL_KOPF] erfolgreich eingetragen!<br><br>");
                out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_kom_korr\" method=\"post\" target=\"main\">");
                out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
                //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_kom_korr\">");
                //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
                out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");

            } catch (SQLException e) {
                out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                error = 1;
            }
            if (error != 1) {
                //### HOST-Datensatz-Generierung ###
                out.println("<br><br>Generierung des HOST-Datensatzes:");
                sql = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_QM_BRUTTO,KOM_KZ_EINZEL,KOM_KZ_PRAEMIE";
                sql += " FROM PLRV11.ZUS_KOMMISSION";
                sql += " WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                resultSet = stmt.getResultSet();

                try {
                    while (resultSet.next()) {

                        komProg = resultSet.getString("KOM_PROG");
                        komNetto = resultSet.getFloat("KOM_QM_NETTO");
                        komBrutto = resultSet.getFloat("KOM_QM_BRUTTO");
                        einzelKz = resultSet.getString("KOM_KZ_EINZEL");
                        komKzPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                    }
                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                    out.println("<br><br>" + e);
                }

                sql1 = "SELECT KFS_DEZI FROM PLRV11.ZUS_KOM_FS";
                sql1 += " WHERE  KFS_ABNR=" + abNr + " AND KFS_ARTNR=" + artNr + " AND KFS_FS='10244100000'";
                //out.println(sql1);
                stmt1 = con.createStatement();
                stmt1.executeQuery(sql1);
                resultSet1 = stmt1.getResultSet();

                try {
                    while (resultSet1.next()) {

                        dezi = resultSet1.getString("KFS_DEZI");
                    }
                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql1);
                    out.println("<br><br>" + e);
                }


                StringBuffer to_horst = new StringBuffer(250);
                Date dt = new Date();
                SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
                String date = df.format(dt);
                String hostmenge = String.valueOf(rundmenge);

                hostBruttoMenge = new BigDecimal(komBrutto);
                bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

                hostNettoMenge = new BigDecimal(komNetto);
                bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

                //hostZeit              = new BigDecimal(zeitwert);
                //bigDeziZeit           = hostZeit.setScale( 2, BigDecimal.ROUND_HALF_UP );
                //String scaledZeit     = String.valueOf(bigDeziZeit);
                //out.println("ZEIT:"+scaledZeit+"<br>");

                //### WERK-Eintrag ###
                if (werk > 40) {
                    zsSys = String.valueOf(werk);
                }

                to_horst.insert(0, "0201E013");
                to_horst.append(date);
                to_horst.append("170RM");
                to_horst.append(rbTextFormat.format('0', 6, abNr));
                to_horst.append("LB02");
                to_horst.append("21");
                to_horst.append(artNr);
                to_horst.append(rbTextFormat.format('0', 8, hostmenge));
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
                to_horst.append(rbTextFormat.format('0', 4, bmonat));
                to_horst.append(rbTextFormat.format('0', 3, komProg));
                to_horst.append(rbTextFormat.format('0', 11, scaledNettoMenge));
                to_horst.append(rbTextFormat.format('0', 11, scaledBruttoMenge));
                to_horst.append(rbTextFormat.format(' ', 7, dezi));
                to_horst.append(rbTextFormat.format(' ', 10, zeitwert));
                //to_horst.append(rbTextFormat.format(' ',10,scaledZeit));
                to_horst.append("K");
                to_horst.append(einzelKz);
                to_horst.append(rbTextFormat.linksb(' ', 1, zbl));
                to_horst.append(rbTextFormat.linksb(' ', 39, krit));
                to_horst.append(rbTextFormat.linksb(' ', 38, hinweis));
                to_horst.append(rbTextFormat.linksb(' ', 1, komKzPraemie));
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
                out.println("<br><br>istmenge:" + hostmenge + "<br>");
                out.println("komBrutto:" + scaledBruttoMenge + "<br>");
                out.println("komNetto:" + scaledNettoMenge + "<br>");
                out.println("Werk:" + werk + "<br><br>");

                buchung.aktiviereDatei();
            }
        }
    }

    con.close();
%>
</body>
</html>
      


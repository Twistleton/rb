<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<%@ page import="java.math.BigDecimal" %>

<!--### BUCHUNG EINZELKOMMISSION IMEZ/H VG=21 ###-->

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
<body OnLoad="document.form.submit.focus();" bgcolor="#f0e68c">
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

    String abNr = request.getParameter("abNr");
    String artNr = request.getParameter("artNr");
    String charge = request.getParameter("charge");
    String persNr = request.getParameter("persNr");
    String lieferant = request.getParameter("lieferant");
    String menge = request.getParameter("menge");
    String zsSys = request.getParameter("zsSys");
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
    String zbl = request.getParameter("zbl");
    String krit = "";
    String hinweis = "";
    try {
        krit = request.getParameter("krit");
        hinweis = request.getParameter("hinweis");
    } catch (Exception e) {
        krit = "";
        hinweis = "";
    }
    String zeit = request.getParameter("zeit");
    String menge_brutto = request.getParameter("komBrutto");
    String sammelAbNr = request.getParameter("sammelAbNr");
    String kzGebucht = "J";
    String kzEinzel = "J";
    String sql = "";
    String sql1 = "";
    String mod = request.getParameter("mod");
    Statement stmt;
    Statement stmt1;
    ResultSet resultSet;
    ResultSet resultSet1;
    stmt = con.createStatement();
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    float bruttomenge = new Float(menge_brutto).floatValue();
    float maximalMenge = 2 * bruttomenge;
    float menge_ist = new Float(menge.replace(',', '.')).floatValue();
    String zeitwert = zeit.replace('.', ',');
    //float zeitwert       = new Float(zeit.replace(',','.')).floatValue();
    int error = 0;
    String einzelKz = "";
    String komProg = "";
    float komNetto = 0;
    String dezi = "0";
    int werk = new Integer(request.getParameter("werk")).intValue();

    BigDecimal hostBruttoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziBruttoMenge = new BigDecimal("0.00");
    BigDecimal hostNettoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziNettoMenge = new BigDecimal("0.00");
    BigDecimal hostIstMenge = new BigDecimal("0.00");
    BigDecimal bigDeziIstMenge = new BigDecimal("0.00");
    BigDecimal hostZeit = new BigDecimal("0.00");
    BigDecimal bigDeziZeit = new BigDecimal("0.00");
    String komKzMf = "";
    String komKzPraemie = "";
    String checkvar = request.getParameter("checkvar");

    if (mod.equals("eintrag")) {

        //### Bei IST-Menge > BRUTTO-Menge:Verursacherschluessel muss eingetragen werden! ###
        if ((menge_ist > bruttomenge) && (verkey.equals("00")) && (!(checkvar.equals("checked")))) {
            if (menge_ist > maximalMenge) {
                out.println("Bruttomenge( " + bruttomenge + ") ist viel viel kleiner als der eingegebene IST-Verbrauch (" + menge_ist + ")&nbsp;!<br><br>");
                out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
                out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_kom&key=setmenge&IstMenge=" + menge_ist + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
                out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
            } else {
                out.println("Bruttomenge(" + bruttomenge + ") kleiner als IST-Verbrauch(" + menge_ist + ")&nbsp;!<br><br>");
                out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;<br><br>");
                out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_kom&key=setkey&IstMenge=" + menge_ist + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
                out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
                //out.println("<a href=\"./buchung.jsp?mod=imez_kom&key=setkey&IstMenge="+menge_ist);
                //out.println("&auftr_bez_nr="+artNr+abNr+"\">");
                //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Eingabe</a>");
            }
        } else if ((menge_ist > bruttomenge) && (verkey.equals("00"))) {
            out.println("Bruttomenge(" + bruttomenge + ") kleiner als IST-Verbrauch(" + menge_ist + ")&nbsp;!<br><br>");
            out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;<br><br>");
            out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_kom&checkvar=checked&key=setkey&IstMenge=" + menge_ist + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
        } else if ((menge_ist > maximalMenge) && (!(checkvar.equals("checked")))) {
            out.println("Bruttomenge( " + bruttomenge + ") ist viel viel kleiner als der eingegebene IST-Verbrauch (" + menge_ist + ")&nbsp;!<br><br>");
            out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen!</b></font>&nbsp;&nbsp;<br><br>");
            out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_kom&key=setmenge1&IstMenge=" + menge_ist + "&auftr_bez_nr=" + artNr + abNr + "&hinweis=" + hinweis + "&krit=" + krit + "\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"Hoppla,zur&uuml;ck zur Eingabe!!\"></input></form>");
            out.println("<form name=\"form\" action=\"./buchung_kom_imezh.jsp?mod=eintrag&menge=" + menge_ist + "&artNr=" + artNr + "&hinweis=" + hinweis + "&krit=" + krit + "&abNr=" + abNr + "&lieferant=" + lieferant + "&verkey=" + verkey + "&schicht=" + schicht + "&charge=" + charge + "&werk=" + werk + "&zeit=" + zeit + "&komBrutto=" + menge_brutto + "&sammelAbNr=" + sammelAbNr + "&zsSys=" + zsSys + "&checkvar=checked\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"Weiter,das ist schon richtig so!!\"></input></form>");
        } else {
            //### Update der Kommissionstabelle ###
            sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=" + menge_ist;
            sql += ",KOM_KZ_EINZEL='J',KOM_KRITERIUM='" + krit + "',KOM_HINWEIS='" + hinweis + "' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

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
                    out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_kom\" method=\"post\" target=\"main\">");
                    out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
                    //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_kom\">");
                    //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                    out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
                    out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");

                } catch (SQLException e) {
                    out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                    error = 1;
                }
                if (error != 1) {
                    //###HOST-Datensatz-Generierung ###
                    out.println("<br><br>Generierung des HOST-Datensatzes:");
                    sql = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_KZ_EINZEL,KOM_KZ_MF,KOM_KZ_PRAEMIE";
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
                            einzelKz = resultSet.getString("KOM_KZ_EINZEL");
                            komKzMf = resultSet.getString("KOM_KZ_MF");
                            komKzPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                        }
                    } catch (SQLException e) {
                        out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                        out.println("<br><br>" + e);
                    }

                    //### Dezis raussuchen ###
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

                    hostBruttoMenge = new BigDecimal(bruttomenge);
                    bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                    String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

                    hostNettoMenge = new BigDecimal(komNetto);
                    bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                    String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

                    hostIstMenge = new BigDecimal(menge_ist);
                    bigDeziIstMenge = hostIstMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                    String scaledIstMenge = String.valueOf(bigDeziIstMenge);

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
                    to_horst.append(rbTextFormat.format('0', 8, scaledIstMenge));
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
                    to_horst.append(rbTextFormat.format('0', 7, dezi));
                    to_horst.append(rbTextFormat.format(' ', 10, zeitwert));
                    //to_horst.append(rbTextFormat.format(' ',10,scaledZeit));
                    to_horst.append(" ");
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
                    out.println("<br><br>istmenge:" + scaledIstMenge + "<br>");
                    out.println("komBrutto:" + scaledBruttoMenge + "<br>");
                    out.println("komNetto:" + scaledNettoMenge + "<br>");
                    out.println("Werk:" + werk + "<br><br>");
                    buchung.aktiviereDatei();
                }
            }

        }
    }

    if (mod.equals("mitkey")) {
        out.println("Mitkey");
        //### Update der Kommissionstabelle ###
        sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=" + menge_ist;
        sql += ",KOM_KZ_EINZEL='J' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

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
                out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_kom\" method=\"post\" target=\"main\">");
                out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
                //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_kom\">");
                //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
                out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");
            } catch (SQLException e) {
                out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                error = 1;
            }
            if (error != 1) {
                //###HOST-Datensatz-Generierung ###
                out.println("<br><br>Generierung des HOST-Datensatzes:");
                sql = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_KZ_EINZEL,KOM_KZ_PRAEMIE";
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
                        einzelKz = resultSet.getString("KOM_KZ_EINZEL");
                        komKzPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                    }
                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                    out.println("<br><br>" + e);
                }

                //### Dezis raussuchen ###
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

                hostBruttoMenge = new BigDecimal(bruttomenge);
                bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

                hostNettoMenge = new BigDecimal(komNetto);
                bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

                hostIstMenge = new BigDecimal(menge_ist);
                bigDeziIstMenge = hostIstMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
                String scaledIstMenge = String.valueOf(bigDeziIstMenge);

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
                to_horst.append(rbTextFormat.format('0', 8, scaledIstMenge));
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
                to_horst.append(rbTextFormat.format(' ', 10, zeitwert));
                //to_horst.append(rbTextFormat.format(' ',10,scaledZeit));
                to_horst.append(" ");
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
                out.println("<br><br>istmenge:" + scaledIstMenge + "<br>");
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
      


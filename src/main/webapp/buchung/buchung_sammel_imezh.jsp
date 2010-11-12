<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.*" %>

<!--### BUCHUNG SAMMELAUFTRAG IMEZ/H VG=21 ###-->

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

    String sammelAbNr = request.getParameter("sammelAbNr");
    String sakArtNr = request.getParameter("sakArtNr");
    String charge = request.getParameter("charge");
    String persNr = request.getParameter("persNr");
    String lieferant = request.getParameter("lieferant");
    String menge = request.getParameter("istmenge");
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
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
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    Statement stmt3;
    Statement stmt4;
    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    ResultSet resultSet3;
    ResultSet resultSet4;
    stmt = con.createStatement();
    stmt1 = con.createStatement();
    stmt2 = con.createStatement();
    stmt3 = con.createStatement();
    stmt4 = con.createStatement();
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    int error = 0;
    String einzelKz = "";
    String komProg = "";
    float komNetto = 0;
    String dezi = "";
    int werk = 0;
    String komKzMf = "";
    String checkvar = request.getParameter("checkvar");


    //### Bruttosumme ueber alle Kommissionen ermitteln ###
    sql = "SELECT SUM(KOM_QM_BRUTTO)AS bruttosumme FROM PLRV11.ZUS_KOMMISSION WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND";
    sql += " KOM_GEBUCHT_KZ<>'J' AND KOM_STATUS=50 AND (KOM_KZ_EINZEL='N' OR KOM_KZ_EINZEL IS NULL)";
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
    float maximalMenge = 2 * bruttosumme;

    if (bruttosumme < istmenge && verkey.equals("00") && (!(checkvar.equals("checked")))) {
        if (istmenge > maximalMenge) {
            out.println("Mengeneingabe (" + istmenge + ") ist viel viel gr&ouml;sser als Bruttomengen (" + bruttosumme + "):&nbsp;<br><br>");
            out.println("<font color='red'><b>Bitte Mengen-Eingabe &uuml;berpr&uuml;fen und Verursacherschl&uuml;ssel eingeben:</b></font>&nbsp;&nbsp;<br><br>");
            out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel&key=setmenge&IstMenge=" + istmenge + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
        } else {
            out.println("Bei MEHRVERBRAUCH:&nbsp;<br><br>");
            out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;<br><br>");
            out.println("<form name=\"form\" action=\"./buchung.jsp?mod=imez_sammel&key=setkey&IstMenge=" + istmenge + "&auftr_bez_nr=" + sammelAbNr + "\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"Eingabe\"></input></form>");
        }
    } else {

        //### Bruttosummen je Kommission ermitteln ###
        sql = "SELECT KOM_QM_BRUTTO,KOM_ABNR,KOM_ART_NR FROM PLRV11.ZUS_KOMMISSION WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND";
        sql += " KOM_GEBUCHT_KZ<>'J' AND KOM_STATUS=50 AND (KOM_KZ_EINZEL='N' OR KOM_KZ_EINZEL IS NULL)";
        //out.println(sql);
        stmt = con.createStatement();
        stmt.executeQuery(sql);
        resultSet = stmt.getResultSet();
        try {
            while (resultSet.next()) {

                komBrutto = resultSet.getFloat("KOM_QM_BRUTTO");
                komAbNr = resultSet.getString("KOM_ABNR");
                komArtNr = resultSet.getString("KOM_ART_NR");

                prozAnteil = komBrutto / bruttosumme;
                komgebmeng = prozAnteil * istmenge;

                //### Runden der Ergebnisse ###
                kommi = new BigDecimal(komgebmeng);
                komGebuchteMenge = kommi.setScale(2, BigDecimal.ROUND_HALF_UP);

                //### Eintrag der neuen Kommissionsdaten incl neuer IST-Menge ###
                sql1 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=";
                sql1 += komGebuchteMenge + " WHERE KOM_SAMMEL_ABNR=" + sammelAbNr + " AND KOM_ABNR=" + komAbNr;
                sql1 += " AND KOM_ART_NR=" + komArtNr;

                try {
                    //out.println(sql1);
                    stmt1.executeQuery(sql1);
                    out.println("<br>Folgender Datensatz erfolgreich eingetragen:<br><br>");
                    out.println("Kom-ABNR:" + komAbNr + "<br>KomArtNr:" + komArtNr + "<br>BRUTTO-Menge:" + komBrutto + "<br>IST-Menge:");
                    out.println(komGebuchteMenge + "<br>");
                } catch (SQLException e) {
                    out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                    error = 1;
                }
                //### Datensatz an Host generieren ###
                if (error == 1) {
                    out.println("Fehler!");
                } else {
                    //###HOST-Datensatz-Generierung ###
                    out.println("<br><br>Generierung des HOST-Datensatzes:");
                    sql2 = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_KZ_EINZEL,KOM_WERK_ZUSCHN,KOM_KZ_MF";
                    sql2 += " FROM PLRV11.ZUS_KOMMISSION";
                    sql2 += " WHERE  KOM_ABNR=" + komAbNr + " AND KOM_ART_NR=" + komArtNr;
                    //out.println(sql2);
                    stmt2 = con.createStatement();
                    stmt2.executeQuery(sql2);
                    resultSet2 = stmt2.getResultSet();

                    try {
                        while (resultSet2.next()) {

                            komProg = resultSet2.getString("KOM_PROG");
                            komNetto = resultSet2.getFloat("KOM_QM_NETTO");
                            einzelKz = resultSet2.getString("KOM_KZ_EINZEL");
                            werk = resultSet2.getInt("KOM_WERK_ZUSCHN");
                            komKzMf = resultSet2.getString("KOM_KZ_MF");
                        }
                    } catch (SQLException e) {
                        out.println("Fehler bei der Datenbankabfrage<br><br>" + sql2);
                        out.println("<br><br>" + e);
                    }

                    //### Dezis raussuchen ###
                    sql3 = "SELECT KFS_DEZI FROM PLRV11.ZUS_KOM_FS";
                    sql3 += " WHERE  KFS_ABNR=" + komAbNr + " AND KFS_ARTNR=" + komArtNr + " AND KFS_FS='10244100000'";
                    //out.println(sql3);
                    stmt3 = con.createStatement();
                    stmt3.executeQuery(sql3);
                    resultSet3 = stmt3.getResultSet();

                    try {
                        while (resultSet3.next()) {
                            dezi = resultSet3.getString("KFS_DEZI");
                        }
                    } catch (SQLException e) {
                        out.println("Fehler bei der Datenbankabfrage<br><br>" + sql3);
                        out.println("<br><br>" + e);
                    }

                    StringBuffer to_horst = new StringBuffer(171);
                    Date dt = new Date();
                    SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
                    String date = df.format(dt);
                    String zeit = " ";
                    //String hostbruttomenge = String.valueOf(komBrutto);
                    String hostkomGebuchteMenge = String.valueOf(komGebuchteMenge);

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
                    to_horst.append(" ");
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
                out.println("<br>Sammelauftragstatus auf 30 setzen!!");
                sql4 = "UPDATE PLRV11.ZUS_SAMMEL_KOPF SET SAK_STATUS=30,SAK_BUCH_MM='" + buchungsmonat + "',SAK_MENGE_IST=";
                sql4 += istmenge + " WHERE SAK_SANR=" + sammelAbNr;

                try {
                    //out.println(sql4);
                    stmt4.executeQuery(sql4);
                    out.println("<br>Folgender Datensatz erfolgreich eingetragen:<br><br>");
                    out.println("Sammel-ABNR:" + sammelAbNr + "<br>IST-Menge:" + menge + "<br>Status-Neu:30<br>Buchungsmonat:" + buchungsmonat);
                } catch (SQLException e) {
                    out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql4);
                    error = 1;
                }
            }

        } catch (SQLException e) {
            out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
            out.println("<br><br>" + e);
            error = 1;
        }

        out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=imez_sammel\" method=\"post\" target=\"main\">");
        out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
        //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=imez_sammel\">");
        //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
        out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
        out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");

    }

    con.close();
%>
</body>
</html>
      


<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<%@ page import="java.math.BigDecimal" %>


<!--### BUCHUNG EINZELKOMMISSION LMEZ/H VG=30,31 ###-->

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
<body OnLoad="document.form.submit.focus();" bgcolor="#9ac0cd">
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
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
    String zeit = request.getParameter("zeit");
    String vorgang = request.getParameter("vorgang");
    String zsSys = request.getParameter("zsSys");
    String zbl = request.getParameter("zbl");
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
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
    stmt = con.createStatement();
    int error = 0;
    String einzelKz = "";
    String komProg = "";
    float komNetto = 0;
    float komBrutto = 0;
    String dezi = "";
    float newistmenge = new Float(istmenge.replace(',', '.')).floatValue();
    String zeitwert = zeit.replace('.', ',');
    //float zeitwert                = new Float(zeit.replace(',','.')).floatValue();
    int werk = new Integer(request.getParameter("werk")).intValue();
    BigDecimal hostBruttoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziBruttoMenge = new BigDecimal("0.00");
    BigDecimal hostNettoMenge = new BigDecimal("0.00");
    BigDecimal bigDeziNettoMenge = new BigDecimal("0.00");
    BigDecimal hostIstMenge = new BigDecimal("0.00");
    BigDecimal bigDeziIstMenge = new BigDecimal("0.00");
    BigDecimal hostZeit = new BigDecimal("0.00");
    BigDecimal bigDeziZeit = new BigDecimal("0.00");
    String komKzPraemie = "";

    if (mod.equals("eintrag")) {

        if (newistmenge == 0.0) {
            out.println("<b>Hoppla, keine Eingabe im Feld Verbrauch!?</b><br><br>");
            out.println("Bitte Eingabe korrigieren!<br><br>");
            out.println("<form name=\"form\">");
            out.println("<input type=\"button\" name=\"submit\" value=\"schnell zur&uuml;ck\" onClick=\"history.back()\"></form>");
        } else {
            out.println("<br>Verbrauch:&nbsp;" + istmenge + "<br>");
            out.println("<form name=\"form\" action=\"./buchung_eingabe.jsp?mod=lmez_kom\" method=\"post\" target=\"main\">");
            out.println("<input name=\"submit\" type=\"submit\" value=\"weitere Buchung\"></input></form>");
            //out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=lmez_kom\">");
            //out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
            out.println("<br><br><a href=\"http://172.17.16.7:8080/zusbemeldung/pufferMeldung.jsp\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");

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

            hostBruttoMenge = new BigDecimal(komBrutto);
            bigDeziBruttoMenge = hostBruttoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
            String scaledBruttoMenge = String.valueOf(bigDeziBruttoMenge);

            hostNettoMenge = new BigDecimal(komNetto);
            bigDeziNettoMenge = hostNettoMenge.setScale(2, BigDecimal.ROUND_HALF_UP);
            String scaledNettoMenge = String.valueOf(bigDeziNettoMenge);

            hostIstMenge = new BigDecimal(newistmenge);
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
            to_horst.append(vorgang);
            to_horst.append(artNr);
            to_horst.append(rbTextFormat.format('0', 8, scaledIstMenge));
            to_horst.append(rbTextFormat.format(' ', 2, verkey));
            to_horst.append(abNr);
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
    con.close();
%>
</body>
</html>
      


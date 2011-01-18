<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


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
<body bgcolor="#ddddFF">
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
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    String kzGebucht = "J";
    String kzEinzel = "J";
    String sql = "";
    String sql1 = "";
    Statement stmt;
    ResultSet resultSet;
    stmt = con.createStatement();
    int error = 0;
    String einzelKz = "";
    String komProg = "";
    String komNetto = "";
    String komBrutto = "";
    String dezi = "";

    if (mod.equals("eintrag")) {

        out.println("<br>Neue IST-Menge:&nbsp;" + istmenge + "<br>");

        //### Update der Kommissionstabelle ###
        sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM='" + buchungsmonat + "',KOM_IST_MENGE=" + istmenge;
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
                out.println("<br>Update[ZUS_SAMMEL_KOPF] erfolgreich eingetragen!");
                out.println("<br><br><a href=\"./buchung_eingabe.jsp?mod=lmez_kom\">");
                out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weitere Buchung</a>");
                out.println("<br><br><a href=\"http://172.17.5.66:8080/buchung/\" target=\"_top\">");
                out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;Ende</a>");

            } catch (SQLException e) {
                out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                error = 1;
            }
            if (error != 1) {
                //### HOST-Datensatz-Generierung ###
                out.println("<br><br>Generierung des HOST-Datensatzes!!");
                sql = "SELECT KOM_PROG,KOM_QM_NETTO,KOM_QM_BRUTTO,KOM_KZ_EINZEL,KFS_DEZI";
                sql += " FROM PLRV11.ZUS_KOMMISSION LEFT JOIN PLRV11.ZUS_KOM_FS ON KOM_ABNR=KFS_ABNR";
                sql += "  WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr + " AND KFS_ARTNR=" + artNr;
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                resultSet = stmt.getResultSet();

                try {
                    while (resultSet.next()) {

                        komProg = resultSet.getString("KOM_PROG");
                        komNetto = resultSet.getString("KOM_QM_NETTO");
                        komBrutto = resultSet.getString("KOM_QM_BRUTTO");
                        einzelKz = resultSet.getString("KOM_KZ_EINZEL");
                        dezi = resultSet.getString("KFS_DEZI");
                    }
                } catch (SQLException e) {
                    out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                    out.println("<br><br>" + e);
                }

                StringBuffer to_horst = new StringBuffer(170);
                Date dt = new Date();
                SimpleDateFormat df = new SimpleDateFormat("yyyyMMddHHmmss");
                String date = df.format(dt);

                to_horst.insert(0, "0201E013");
                to_horst.append(date);
                to_horst.append("170RM");
                to_horst.append(abNr);
                to_horst.append("LB02");
                to_horst.append(vorgang);
                to_horst.append(artNr);
                to_horst.append(rbTextFormat.format(' ', 7, istmenge));
                to_horst.append(rbTextFormat.format(' ', 2, verkey));
                to_horst.append(abNr);
                to_horst.append(rbTextFormat.format(' ', 4, persNr));
                to_horst.append(schicht);
                to_horst.append("10002030000");
                to_horst.append(date);
                to_horst.append(rbTextFormat.format(' ', 10, charge));
                to_horst.append(zsSys);
                to_horst.append(rbTextFormat.format(' ', 4, lieferant));
                to_horst.append(rbTextFormat.format(' ', 14, sammelAbNr));
                to_horst.append(rbTextFormat.format('0', 4, buchungsmonat));
                to_horst.append(rbTextFormat.format('0', 3, komProg));
                to_horst.append(rbTextFormat.format(' ', 10, komNetto));
                to_horst.append(rbTextFormat.format(' ', 10, komBrutto));
                to_horst.append(rbTextFormat.format(' ', 7, dezi));
                to_horst.append(rbTextFormat.format(' ', 10, zeit));
                to_horst.append(" ");
                to_horst.append(einzelKz);

                out.println("<br>" + to_horst);

                String datensatz = to_horst.toString();
                //### Datei generieren ###
                komDruckDatei buchung = new komDruckDatei("/tmp", "buchungsdatensatz", "BVL");
                buchung.setNameTimestamp();
                buchung.oeffnen();
                buchung.satzEinfuegen(datensatz);
                buchung.schliessen();

                out.println("<br><br><b>Der HOST-Datensatz wurde erstellt!</b>");
                buchung.aktiviereDatei();
            }
        }
    }

    con.close();
%>
</body>
</html>
      


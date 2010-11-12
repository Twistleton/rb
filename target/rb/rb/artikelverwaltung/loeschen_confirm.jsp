<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">
<table border="0" align="center">
    <tr>
        <td align="center">
            <font color="#ff0000">
                <b>
                    WARNUNG
                </b>
                <br>
            </font>
            <b>
                Sie sind dabei, folgenden Eintrag endg&uuml;ltig zu l&ouml;schen:
            </b>
        </td>
    </tr>
</table>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    long artNr = 0;
    String artBez = "";
    String artSperrKz = "";
    String artLiefKkz = "";
    String artCutFhg = "";
    String artManZs = "";
    long azsArtNr = 0;
    int azsBezTyp = 0;
    String azsBezMat = "";
    int azsProzAntt = 0;
    String typ = "";
    int restId = 0;
    long restLagerOrt = 0;

    String artnr = request.getParameter("artnr");

    //#####----Die Variable 'var' wird vom vorherigen Formular uebernommen und regelt Rest bzw. Artikelanzeige---#####
    String var = request.getParameter("var");

    //#####---Restanzeige  ---#####
    if (var.equals("rest")) {
        restId = new Integer(request.getParameter("artID")).intValue();

        sql = "SELECT RES_ART_NR,RES_QM_BRUTTO,RES_RES_LAGERORT,RES_STATUS,RES_ID  FROM PLRV11.ZUS_REST_RESERV";
        sql += " WHERE RES_ART_NR=" + artnr + " AND RES_ID=" + restId;

        //out.println(sql);
        stmt = con.createStatement();
        stmt.executeQuery(sql);
        resultSet = stmt.getResultSet();

        typ = "rest";

        out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
        out.println("<tr><td align=\"center\"><b>Artikelnummer</b></td>");
        out.println("<td align=\"center\"><b>Bruttomenge[qm]</b></td>");
        out.println("<td align=\"center\"><b>Lagerort</b></td>");
        out.println("<td align=\"center\"><b>Status</b></td></tr>");

        try {
            resultSet.next();

            long restArtNr = resultSet.getLong("RES_ART_NR");
            float restMenge = resultSet.getFloat("RES_QM_BRUTTO");
            int restStatus = resultSet.getInt("RES_STATUS");
            restLagerOrt = resultSet.getLong("RES_RES_LAGERORT");

            String lagerort = "" + restLagerOrt;
            String lager1 = lagerort.substring(0, 8);
            String lager2 = lagerort.substring(8);

            String artNR = "" + restArtNr;
            String artnr1 = artNR.substring(0, 3);
            String artnr2 = artNR.substring(3, 8);
            String artnr3 = artNR.substring(8);

            out.println("<tr><td align=\"center\">" + artnr1 + "." + artnr2 + "." + artnr3 + "</td>");
            out.println("<td align=\"center\">" + restMenge + "</td>");
            out.println("<td align=\"center\">" + lager1 + "." + lager2 + "</td>");
            out.println("<td align=\"center\">" + restStatus + "</td></tr>");
            out.println("</tr>");
        } catch (SQLException e) {
            out.println("Fehler beim Auslesen der Daten!<br>");
            out.println(e);
        }
    }
    //#####---Artikelanzeige---#####
    else if (var.equals("artikel")) {
        sql = "SELECT * FROM PLRV11.PLR_ART_KOPF  where ART_NR=" + artnr;
        //out.println(sql);

        typ = "artikel";
        stmt = con.createStatement();
        stmt.executeQuery(sql);
        resultSet = stmt.getResultSet();

        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"210\"><col width=\"210\"></colgroup>");

        try {
            resultSet.next();

            artNr = resultSet.getLong("ART_NR");
            artBez = resultSet.getString("ART_BEZ");
            artSperrKz = resultSet.getString("ART_SPERR_KZ");
            artLiefKkz = resultSet.getString("ART_LIEF_KKZ");
            artCutFhg = resultSet.getString("ART_CUT_FHG");
            artManZs = resultSet.getString("ART_MAN_ZS");

            out.println("<tr><td>Artikelnummer</td><td align=\"center\">" + artNr + "</td></tr>");
            out.println("<tr><td>Bezeichnung</td><td align=\"center\">" + artBez + "</td></tr>");

            if (artSperrKz.equals("N")) {
                out.println("<tr><td>Gesperrt</td><td bgcolor=\"#00ff00\" align=\"center\">Nein</td></tr>");
            } else {
                out.println("<tr><td>Gesperrt</td><td bgcolor=\"red\" align=\"center\">Ja</td></tr>");
            }

            if (artLiefKkz.equals(" ")) {
                out.println("<tr><td>Lieferant</td><td align=\"center\">-</td></tr>");
            } else {
                out.println("<tr><td>Lieferant</td><td align=\"center\">" + artLiefKkz + "</td></tr>");
            }
            out.println("<tr><td>Cutterf&auml;hig</td><td align=\"center\">" + artCutFhg + "</td></tr>");
            out.println("<tr><td>Manueller Zuschnitt</td><td align=\"center\">" + artManZs + "</td></tr></table>");

        } catch (SQLException e) {
            out.println("Fehler:");
            out.println(e);
        }

        sql = "SELECT * FROM PLRV11.PLR_ART_ZUSAM where AZS_ART_NR=" + artnr;
        //out.println(sql);
        stmt = con.createStatement();
        stmt.executeQuery(sql);
        resultSet = stmt.getResultSet();

        out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        //out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
        out.println("<colgroup><col width=\"140\"><col width=\"140\"><col width=\"140\"></colgroup>");
        out.println("<tr><td align=\"center\">Materialtyp</td><td align=\"center\">Bezeichnung</td>");
        out.println("<td align=\"center\">Anteil&nbsp;[%]</td></tr>");

        try {
            while (resultSet.next()) {

                azsArtNr = resultSet.getLong("AZS_ART_NR");
                azsBezTyp = resultSet.getInt("AZS_Bez_Typ");
                azsBezMat = resultSet.getString("AZS_BEZ_MAT");
                azsProzAntt = resultSet.getInt("AZS_PROZ_ANTT");

                out.println("<tr><td align=\"center\">" + azsBezTyp + "</td>");
                out.println("<td align=\"center\">" + azsBezMat + "</td>");
                out.println("<td align=\"center\">" + azsProzAntt + "</td></tr>");
            }

        } catch (SQLException e) {
            out.println("Fehler:");
            out.println(e);
        }
    } else {
        out.println("Fehler!Kein L&ouml;schkennzeichen &uuml;bergeben!!");
    }

    out.println("</table>");
    con.close();
%>
<table border="0" align="center">
    <tr>
        <td><b>Endg&uuml;ltig l&ouml;schen??&nbsp;</b></td>
    </tr>
    <tr>
        <td>
            <form action="./loeschen.jsp?artNr=<%=artnr%>&var=<%=typ%>&artID=<%=restId%>&lagerort=<%=restLagerOrt%>"
                  method="post">
        </td>
    </tr>
    <tr>
        <td>
            <input type="hidden" name="delete" value="1"></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="Ja,l&ouml;schen!!"></input>
        </td>
    </tr>
    </form>
    <tr>
        <td>
            <form action="./loeschen.jsp?artNr=<%=artnr%>&var=<%=typ%>&artID=<%=restId%>&lagerort=<%=restLagerOrt%>"
                  method="post">
        </td>
    </tr>
    <tr>
        <td>
            <input type="hidden" name="delete" value="0"></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="Wenn ich es recht bedenke..."></input>
        </td>
    </tr>
    </form>
</table>
</body>
</html>
      
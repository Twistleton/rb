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
        <td align="center">&nbsp;</td>
    </tr>
</table>
<div align="center">
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

        long lagerort = new Long(request.getParameter("lagerort")).longValue();
        int artID = new Integer(request.getParameter("artID")).intValue();
        String artnr = request.getParameter("artNr");
        String sent = request.getParameter("sent");
        String delete = request.getParameter("delete");
        String typ = request.getParameter("var");

        //#####---Variante 1:Loeschen von Resten---#####
        if (typ.equals("rest")) {
            if (delete.equals("1")) {
                //#####---Erst DB-Eintrag loeschen....---#####
                sql = "DELETE FROM PLRV11.ZUS_REST_RESERV WHERE RES_ART_NR='" + artnr + "' AND RES_ID=" + artID;

                try {
                    //out.println(sql);
                    stmt = con.createStatement();
                    stmt.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim L&ouml;schen des Datensatzes:&nbsp;" + e + "<p>");
                }
                out.println("Datensatz gel&ouml;scht!<br>");

                //#####---...dann Pufferplatz freigeben...---#####
                sql = "UPDATE PLRV11.BDE_PUFPL SET PP_KZ='N' WHERE PP_PF_PLATZ=" + lagerort;
                //out.println(sql);

                try {
                    //out.println(sql);
                    stmt = con.createStatement();
                    stmt.executeQuery(sql);
                    out.println("Pufferplatz erfolgreich freigegeben!<br>");
                } catch (SQLException e) {
                    out.println("Fehler bei der Pufferplatzfreigabe:&nbsp;" + e + "<p>");
                }
                out.println("<a href=\"./blank.html\">weiter</a>");
            }
            //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
            else if (delete.equals("0")) {
                out.println("Das ging gerade nochmal gut:<br>Datensatz <b>NICHT</b> gel&ouml;scht!");
                out.println("<a href=\"./blank.html\">weiter</a>");
            } else {
                out.println("Fehler beim L&ouml;schen:Kein L&ouml;schparameter &uuml;bergeben!<br>");
            }
        }
        //#####---Variante2: Kompletten Artikel loeschen---#####
        else if (typ.equals("artikel")) {
            if (delete.equals("1")) {
                //#####---Erst die Kopfdaten loeschen....---#####
                sql = "DELETE FROM PLRV11.PLR_ART_KOPF WHERE ART_NR='" + artnr + "'";

                try {
                    //out.println(sql);
                    stmt = con.createStatement();
                    stmt.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim L&ouml;schen des Kopf-Datensatzes:&nbsp;" + e + "<p>");
                }

                //#####---...dann die Materialdaten loeschen---#####
                sql = "DELETE FROM PLRV11.PLR_ART_ZUSAM WHERE AZS_ART_NR='" + artnr + "'";

                try {
                    //out.println(sql);
                    stmt = con.createStatement();
                    stmt.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim L&ouml;schen des Material-Datensatzes:&nbsp;" + e + "<p>");
                }
                out.println("Datensatz gel&ouml;scht!<br>");
                out.println("<a href=\"./blank.html\">weiter</a>");
            }
            //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
            else if (delete.equals("0")) {
                out.println("Das ging gerade nochmal gut:<br>Datensatz <b>NICHT</b> gel&ouml;scht!<br>");
                out.println("<a href=\"./blank.html\">weiter</a>");
            } else {
                out.println("Fehler beim L&ouml;schen:Kein L&ouml;schparameter &uuml;bergeben!<br>");
            }
        } else {
            out.println("Fehler bei der L&ouml;schparameter&uuml;bergabe!<br>");
        }

        con.close();
    %>
</div>
</body>
</html>
      
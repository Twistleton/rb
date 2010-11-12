<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

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

    String abNr = request.getParameter("abNr");
    String artNr = request.getParameter("artNr");
    String charge = request.getParameter("charge");
    String lieferant = request.getParameter("lieferant");
    String menge = request.getParameter("menge");
    String schicht = request.getParameter("schicht");
    String verkey = request.getParameter("verkey");
    String zeit = request.getParameter("zeit");
    String menge_brutto = request.getParameter("komBrutto");
    String sammelAbNr = request.getParameter("sammelAbNr");
    String kzGebucht = "J";
    String kzEinzel = "J";
    String sql = "";
    String sql1 = "";
    String mod = request.getParameter("mod");
    Statement stmt;
    ResultSet resultSet;
    stmt = con.createStatement();
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    float bruttomenge = 0;
    bruttomenge = new Float(menge_brutto).floatValue();
    float menge_ist = 0;
    menge_ist = new Float(menge).floatValue();
    int error = 0;


    if (mod.equals("kom_imezh")) {

        //### Bei IST-Menge > BRUTTO-Menge:Verursacherschluessel muss eingetragen werden! ###
        if (menge_ist > bruttomenge) {
            out.println("<form name=\"form\" action=\"./buchung_insert.jsp?mod=mitkey\" method=\"post\" target=\"main\">");
            out.println("Bruttomenge(" + bruttomenge + ") kleiner als IST-Verbrauch(" + menge_ist + ")&nbsp;!<br><br>");
            out.println("Verursacherschl&uuml;ssel eingeben:&nbsp;&nbsp;");
            out.println("<input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\" value=\"00\"></input>&nbsp;");
            out.println("<input type=\"hidden\" name=\"abNr\" value=" + abNr + "></input>");
            out.println("<input type=\"hidden\" name=\"artNr\" value=" + artNr + "></input>");
            out.println("<input type=\"hidden\" name=\"charge\" value=" + charge + "></input>");
            out.println("<input type=\"hidden\" name=\"lieferant\" value=" + lieferant + "></input>");
            out.println("<input type=\"hidden\" name=\"menge\" value=" + menge + "></input>");
            out.println("<input type=\"hidden\" name=\"schicht\" value=" + schicht + "></input>");
            out.println("<input type=\"hidden\" name=\"zeit\" value=" + zeit + "></input>");
            out.println("<input type=\"hidden\" name=\"komBrutto\" value=" + menge_brutto + "></input>");
            out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=" + sammelAbNr + "></input>");
            out.println("<input type=\"submit\" value=\"OK\"></form>");
        } else {
            //### Update der Kommissionstabelle ###
            sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_GEBUCHT_KZ='J',KOM_BUCH_MM=" + buchungsmonat + ",KOM_IST_MENGE=" + menge;
            sql += ",KOM_KZ_EINZEL='J' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

            try {
                //out.println(sql);
                stmt.executeQuery(sql);
                out.println("Update[ZUS_KOMMISSION] erfolgreich eingetragen!");
                out.println("<br><br><a href=\"./details.jsp\">zur&uuml;ck</a>");
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
                    out.println("Update[ZUS_SAMMEL_KOPF] erfolgreich eingetragen!");
                    out.println("<br><br><a href=\"./details.jsp\">zur&uuml;ck</a>");
                } catch (SQLException e) {
                    out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<br>" + sql1);
                    error = 1;
                }
                if (error != 1) {
                    //###HOST-Datensatz-Generierung
                    out.println("<br><br>Hier wird noch der Host-Datensatz generiert!!");
                }
            }

        }
    }

    if (mod.equals("mitkey")) {
        out.println("Mitkey");

    }

    con.close();
%>
</body>
</html>
      


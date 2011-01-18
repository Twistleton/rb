<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head></head>
<body>
<div align="center">
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt;
        Statement stmt1;
        Statement stmt2;
        String sql;

        String artnr = request.getParameter("ART_NR");
        String artnr_start = "442";
        String artnr_end = "00";
        String artnr_gesamt = artnr_start + artnr + artnr_end;
        String art_lief_kkz = request.getParameter("ART_LIEF_KKZ");
        String art_charge = request.getParameter("ART_CHARGE");
        String artnr_orig = request.getParameter("ART_NR_ORIG");
        String art_lief_kkz_orig = request.getParameter("ART_LIEF_KKZ_ORIG");
        String art_charge_orig = request.getParameter("ART_CHARGE_ORIG");

        int error = 0;
        int artnr_error = 0;
        int test_artnr = 0;
        int test_charge = 0;
        int charge_error = 0;

        try {
            test_artnr = new Integer(artnr).intValue();
        } catch (Exception e) {
            artnr_error = 1;
        }
        try {
            test_charge = new Integer(art_charge).intValue();
        } catch (Exception e) {
            charge_error = 1;
        }

        //#####---Pruefen, ob Artikelkopfdaten korrekt eingegeben wurden---#####
        if (artnr.equals("") || art_lief_kkz.equals("") || art_charge.equals("")) {
            //out.println("Eingabefehler bei den ZBL-Daten!!<br>");
            error = 1;
        }

//#####---Stouuurz!! Wenn alle Eingaben korrekt-->Datenbankeintrag---#####
        if (error != 1 && artnr_error != 1 && charge_error != 1) {
            out.println("<br><br>&Auml;nderungen in Ordnung-Datenbankverbindung wird ge&ouml;ffnet...<br>");
            out.println("<img src=\"./ampel-gruen-blink_40.gif\" title=\"Hoppla!\"><br>");
            //#####---Update---#####
            sql = "Update PLRV11.ZUS_ZBL SET ZBL_TNR=" + artnr_gesamt + ",ZBL_LIEF_KKZ='" + art_lief_kkz + "',ZBL_CHARG_NR=" + art_charge + " WHERE ZBL_TNR=" + artnr_orig + " AND ZBL_LIEF_KKZ='" + art_lief_kkz_orig + "' AND ZBL_CHARG_NR=" + art_charge_orig;

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("...der Datensatz wurde ge&auml;ndert!<br>");
                out.println("<br><a href=\"./zbl_anzeigen.jsp\">zur ZBL-Liste</a>");
            } catch (SQLException e) {
                out.println("Fehler beim &Auml;ndern des Datensatzes:&nbsp;" + e + "<p>");
                error = 1;
            }
            con.close();

        }

//#####---Bei Fehleingabe history.back-Button---#####
        else {
            out.println("<img src=\"./achtung.jpg\" title=\"Hoppla!\">");
            out.println("<font color=\"#ff0000\"><h2><b>Fehler bei der ZBL-&Auml;nderung:</b></h2></font>");
            if (charge_error == 1) {
                out.println("Im Charge-Feld muss eine Zahl stehen.<br>Ihre Eingabe: <b>" + art_charge + "</b><br><br>");
            }
            if (artnr_error == 1) {
                out.println("Im Artikelnummer-Feld muss eine Zahl stehen.<br>Ihre Eingabe: <b>" + artnr + "</b><br><br>");
            }
            if (charge_error != 1 && artnr_error != 1) {
                out.println("Alle Felder m&uuml;ssen ausgef&uuml;llt sein.<br><br>");
            }
            out.println("<input type=\"button\" name=\"Verweis\" value=\"zur&uuml;ck zur Eingabe\" onClick=\"history.back()\">");
        }

    %>
</div>
</body>
</html>
    
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
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();
    String sql = "";
    long sbID = 0;
    String matKZ = "";
    int anlJahr = 0;
    int lfdNr = 0;
    long hkkID = 0;
    Statement stmt;
    ResultSet resultSet;

    String delete = request.getParameter("delete");
    String typ = request.getParameter("typ");
    sbID = new Long(request.getParameter("ID")).longValue();
    matKZ = request.getParameter("matKZ");
    anlJahr = new Integer(request.getParameter("anlJahr")).intValue();
    lfdNr = new Integer(request.getParameter("lfdNr")).intValue();

    //#####---Variante 1:Loeschen von ZSBs---#####
    if (typ.equals("zsb")) {
        if (delete.equals("1")) {
            //#####---Erst DB-Eintrag loeschen....---#####
            sql = "DELETE FROM PLRV11.ZUS_SCHNITTBILD WHERE SB_ID=" + sbID + " AND SB_CUTTER_SB='" + matKZ + "' AND SB_ANL_JAHR=" + anlJahr;

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des ZSB-Datensatzes:&nbsp;" + e + "<p>");
            }
            out.println("ZSB-Datensatz gel&ouml;scht!Haken zu diesem Schnittbild wurden nicht gel&ouml;scht!<br>");

            //#####---...dann die Verknuepfungsdaten---#####
            sql = "DELETE FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + sbID;

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Verkn&uuml;pfungs-Datensatzes:&nbsp;" + e + "<p>");
            }
            out.println("Verkn&uuml;pfungsdatens&auml;tze erfolgreich gel&ouml;scht!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");

        }
        //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
        else if (delete.equals("0")) {
            out.println("Das ging gerade nochmal gut:<br>Datensatz <b>NICHT</b> gel&ouml;scht!");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        } else {
            out.println("Fehler beim L&ouml;schen des ZSB:Kein L&ouml;schparameter &uuml;bergeben!<br>");
        }
    }

    //#####---Variante2: Kompletten Haken loeschen---#####
    else if (typ.equals("haken")) {
        if (delete.equals("1")) {
            //#####---Erst die Kopfdaten loeschen....---#####
            hkkID = new Long(request.getParameter("hkkID")).longValue();
            sql = "DELETE FROM PLRV11.ZUS_HAKEN_KOPF WHERE HKK_ID=" + hkkID + " AND";
            sql += " HKK_MAT_KZ='" + matKZ + "' AND HKK_ANL_JAHR=" + anlJahr;

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Hakenkopf-Datensatzes:&nbsp;" + e + "<p>");
            }

            //#####---...dann die Details---#####
            sql = "DELETE FROM PLRV11.ZUS_HAKEN_DETAIL WHERE HKD_ID=" + hkkID + " AND HKD_ANL_JAHR=" + anlJahr + " AND HKD_MAT_KZ='" + matKZ + "'";

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Hakendetail-Datensatzes:&nbsp;" + e + "<p>");
            }

            //#####---...dann die Verknuepfung---#####
            sql = "DELETE FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_HKK_ID=" + hkkID + " AND VKN_HKK_MAT_KZ='" + matKZ + "'";

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Verkn&uuml;pfungs-Datensatzes:&nbsp;" + e + "<p>");
            }
            out.println("Datens&auml;tze erfolgreich gel&ouml;scht!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        }
        //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
        else if (delete.equals("0")) {
            out.println("Das ging gerade nochmal gut:<br>Datensatz <b>NICHT</b> gel&ouml;scht!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        }
    }

    //#####---Variante2a: Verknuepfung entfernen---#####
    else if (typ.equals("haken_vkn")) {
        if (delete.equals("1")) {
            //#####---Verknuepfung entfernen---#####
            hkkID = new Long(request.getParameter("hkkID")).longValue();
            sql = "DELETE FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_HKK_ID=" + hkkID + " AND VKN_SB_ID=" + sbID + " AND VKN_HKK_MAT_KZ='" + matKZ + "'";

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Verkn&uuml;pfungs-Datensatzes:&nbsp;" + e + "<p>");
            }
            out.println("Verkn&uuml;pfung erfolgreich entfernt!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        }
        //#####---'Doch-nicht-loeschen-Button' gedrueckt---#####
        else if (delete.equals("0")) {
            out.println("Das ging gerade nochmal gut:<br>Datensatz <b>NICHT</b> gel&ouml;scht!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        }
    }


    //#####---Variante3: Unterhaken loeschen---#####
    else if (typ.equals("haken_detail")) {
        if (delete.equals("1")) {
            hkkID = new Long(request.getParameter("hkkID")).longValue();

            //#####---Details loeschen---ANLAUFJAHR im deletestring entfernt(12.04.05 RS)#####
            sql = "DELETE FROM PLRV11.ZUS_HAKEN_DETAIL WHERE HKD_ID=" + hkkID + " AND";
            sql += " HKD_MAT_KZ='" + matKZ + "' AND HKD_LFD_NR=" + lfdNr;

            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
            } catch (SQLException e) {
                out.println("Fehler beim L&ouml;schen des Haken-Detail-Datensatzes:&nbsp;" + e + "<p>");
            }

            out.println("Haken gel&ouml;scht!<br>");
            out.println("<br><br><a href=\"./blank.html\">weiter</a>");
        } else {
            out.println("Fehler beim L&ouml;schen:Kein L&ouml;schparameter &uuml;bergeben!<br>");
        }
    } else {
        out.println("Fehler bei der L&ouml;schparameter&uuml;bergabe!<br>");
    }

    con.close();
%>
</body>
</html>
      
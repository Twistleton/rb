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
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();
    String sql = "";
    String sbID = "";
    String typ = "";
    int restId = 0;
    long restLagerOrt = 0;
    String anlJahr = "";
    String auslDat = "";
    String gueltKz = "";
    String matKZ = "";
    String pfad = "";
    String regel = "";
    String mdl = "";
    String userID = "";
    String aendDat = "";
    String jahr = "";
    String monat = "";
    String tag = "";
    String uhrzeit = "";
    long hakenID = 0;
    String hkkID = "";
    long hakenNr = 0;
    String hakenBez = "";
    int hakenProg = 0;
    long standort = 0;
    long aktPlatz = 0;
    long reservAbnr = 0;
    int lfdNr = 0;
    String anzahl = "";
    Statement stmt;
    stmt = con.createStatement();
    ResultSet resultSet;

    //#####---Die Variable 'var' wird vom vorherigen Formular uebernommen und regelt ZSB bzw. Hakenanzeige---#####
    String var = request.getParameter("var");

    //#####---ZSB-Anzeige---#####
    if (var.equals("zsb")) {
        //#####---Variable typ wird per Link an loeschen.jsp weitergegeben---#####
        typ = "zsb";

        sbID = request.getParameter("sbID");

        sql = "SELECT SB_ANL_JAHR,SB_AUSL_DAT,SB_CUTTER_SB,SB_PFAD,SB_REGEL,SB_MLD FROM PLRV11.ZUS_SCHNITTBILD WHERE SB_ID=" + sbID;
        //out.println(sql);
        resultSet = stmt.executeQuery(sql);

        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");

        try {
            resultSet.next();

            anlJahr = resultSet.getString("SB_ANL_JAHR");
            auslDat = resultSet.getString("SB_AUSL_DAT");
            matKZ = resultSet.getString("SB_CUTTER_SB");
            pfad = resultSet.getString("SB_PFAD");
            regel = resultSet.getString("SB_REGEL");
            mdl = resultSet.getString("SB_MLD");

            out.println("<tr><td>ZSB-NR.</td><td>" + sbID + "</td></tr>");
            out.println("<tr><td>Anlaufjahr</td><td>" + anlJahr + "</td></tr>");
            if (auslDat == null) {
                out.println("<tr><td>Auslaufdatum</td><td>-</td></tr>");
            } else {
                String newauslDat = auslDat.substring(0, 10);
                out.println("<tr><td>Auslaufdatum</td><td>" + newauslDat + "</td></tr>");
            }
            out.println("<tr><td>Cutter SB</td><td>" + sbID + matKZ + "</td></tr>");
            out.println("<tr><td>Pfad</td><td>" + pfad + "</td></tr>");
            out.println("<tr><td>Regel</td><td>" + regel + "</td></tr>");
            out.println("<tr><td>MDL</td><td>" + mdl + "</td></tr>");
            out.println("</table>");

        } catch (SQLException e) {
            out.println("Fehler beim Auslesen der Daten aus Tabelle ZUS_SCHNITTBILD!<br>");
            out.println(e);
        }
    }

    //#####---Hakenanzeige---#####
    else if (var.equals("haken")) {
        //#####---Variable typ wird per Link an loeschen.jsp weitergegeben---#####
        typ = "haken";

        //sbID  = request.getParameter("sbID");
        hkkID = request.getParameter("hkkID");
        matKZ = request.getParameter("matKZ");

        sql = "SELECT * FROM PLRV11.zus_haken_kopf where HKK_ID=" + hkkID + " AND HKK_MAT_KZ='" + matKZ + "'";
        resultSet = stmt.executeQuery(sql);
        //out.println(sql);
        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");

        try {
            resultSet.next();

            hakenBez = resultSet.getString("HKK_BEZ");
            hakenProg = resultSet.getInt("HKK_PROG");
            anlJahr = resultSet.getString("HKK_ANL_JAHR");
            sbID = resultSet.getString("HKK_SB_ID");

            out.println("<tr><td>Haken-NR.</td><td>" + matKZ + "-" + hkkID + "</td></tr>");
            out.println("<tr><td>Anlaufjahr</td><td>" + anlJahr + "</td></tr>");
            out.println("<tr><td>Bezeichnung</td><td>" + hakenBez + "</td></tr>");
            out.println("<tr><td>Programm</td><td>" + hakenProg + "</td></tr>");
            out.println("</tr>");

        } catch (SQLException e) {
            out.println("Hakennummer nicht gefunden!<br>");
            out.println(e);
        }

        sql = "SELECT COUNT(HKD_LFD_NR)AS COUNT FROM PLRV11.zus_haken_detail WHERE HKD_ID=" + hkkID + " AND";
        sql += " HKD_MAT_KZ='" + matKZ + "' AND HKD_ANL_JAHR=" + anlJahr;

        //out.println(sql);
        resultSet = stmt.executeQuery(sql);

        try {
            resultSet.next();
            anzahl = resultSet.getString("COUNT");
            out.println("<tr><td>Anzahl Haken:&nbsp;</td><td>" + anzahl + "</td></tr>");
        } catch (SQLException e) {
            out.println("Hakennummer nicht gefunden!<br>");
            out.println(e);
        }
        out.println("</table>");
    }

    //#####---Haken-Detail-Anzeige---#####
    else if (var.equals("haken_detail")) {
        //#####---Variable typ wird per Link an loeschen.jsp weitergegeben---#####
        typ = "haken_detail";

        //sbID  = request.getParameter("sbID");
        sbID = "0";
        hkkID = request.getParameter("hkkID");
        matKZ = request.getParameter("matKZ");
        lfdNr = new Integer(request.getParameter("lfdNr")).intValue();

        sql = "SELECT * FROM PLRV11.zus_haken_kopf where HKK_ID=" + hkkID + " AND HKK_MAT_KZ='" + matKZ + "'";
        resultSet = stmt.executeQuery(sql);
        //out.println(sql);
        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");

        try {
            resultSet.next();

            hakenBez = resultSet.getString("HKK_BEZ");
            hakenProg = resultSet.getInt("HKK_PROG");
            anlJahr = resultSet.getString("HKK_ANL_JAHR");

            out.println("<tr><td>Haken-NR.</td><td>" + matKZ + "-" + hkkID + "</td></tr>");
            out.println("<tr><td>Anlaufjahr</td><td>" + anlJahr + "</td></tr>");
            out.println("<tr><td>Bezeichnung</td><td>" + hakenBez + "</td></tr>");
            out.println("<tr><td>Programm</td><td>" + hakenProg + "</td></tr>");
            out.println("</tr>");

        } catch (SQLException e) {
            out.println("Hakennummer nicht gefunden!<br>");
            out.println(e);
        }

        out.println("<tr><td>Lfd.Nr des Hakens:&nbsp;</td><td>" + lfdNr + "</td></tr></table>");
    }
    //#####---Haken-Verknuepfung entfernen---#####
    else if (var.equals("vkn")) {
        //#####---Variable typ wird per Link an loeschen.jsp weitergegeben---#####
        typ = "haken_vkn";

        sbID = request.getParameter("sbID");
        hkkID = request.getParameter("hkkID");
        matKZ = request.getParameter("matKZ");
        anlJahr = "2004";

        out.println("<div align=\"center\"><b>");
        out.println("Hiermit wird jedoch nur die Verkn&uuml;pfung entfernt, der Haken selbst wird nicht gel&ouml;scht!!</b></div>");
    } else {
        out.println("Fehler!Kein L&ouml;schkennzeichen &uuml;bergeben!!");
    }

    con.close();
%>
<table border="0" align="center">
    <tr>
        <td align="center"><b>Endg&uuml;ltig l&ouml;schen??&nbsp;</b></td>
    </tr>
    <tr>
        <td>
            <form action="./loeschen.jsp?typ=<%=typ%>&anlJahr=<%=anlJahr%>&ID=<%=sbID%>&matKZ=<%=matKZ%>&hkkID=<%=hkkID%>&lfdNr=<%=lfdNr%>"
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
            <form action="./loeschen.jsp?typ=<%=typ%>&anlJahr=<%=anlJahr%>&ID=<%=sbID%>&matKZ=<%=matKZ%>&hkkID=<%=hkkID%>&lfdNr=<%=lfdNr%>"
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
      
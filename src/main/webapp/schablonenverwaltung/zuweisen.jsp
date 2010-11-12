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
        <td>&nbsp;</td>
    </tr>
</table>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();
    String sql;
    String artSperrKz;
    Statement stmt;
    stmt = con.createStatement();
    ResultSet resultSet;

    String art = request.getParameter("art");
    String lfdNr = request.getParameter("lfdNr");
    String hakenID = request.getParameter("hkkid");
    String anlJahr = request.getParameter("anlJahr");
    String matKz = request.getParameter("matKz");
    String sbID = request.getParameter("sbID");

    String nummer = "";

    //#####---Standort bearbeiten---#####
    if (art.equals("standort")) {

        out.println("<form action=\"./zuweisen.jsp?art=standort_eintrag&hkkid=" + hakenID + "&anlJahr=" + anlJahr + "&lfdNr=" + lfdNr + "&matKz=" + matKz + "\" method=\"post\">");
        out.println("<table border=\"0\" align=\"center\"><tr><td><b>Lagerort eintragen:</b></td></tr></table>");
        out.println("<table border=\"1\" align=\"center\"><tr><td align=\"center\">Puffer</td>");
        out.println("<td><input type=\"text\" name=\"standort1\" size=\"8\" maxlength=\"8\" value=\"10244500\"></input></td>");
        out.println("<td><input type=\"text\" name=\"nummer\" size=\"3\" maxlength=\"3\" value=\"\"></input></td>");
        out.println("</tr></table>");
        out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"&Uuml;bernehmen\"></input>");
        out.println("</td></tr></table></form>");
    }

    //#####---STandort eintragen---#####
    else if (art.equals("standort_eintrag")) {

        nummer = request.getParameter("nummer");
        sql = "UPDATE PLRV11.ZUS_HAKEN_DETAIL SET HKD_STANDORT=10244500" + nummer + " WHERE";
        sql += " HKD_ANL_JAHR=" + anlJahr + " AND HKD_MAT_KZ='" + matKz + "' AND HKD_LFD_NR=" + lfdNr + " AND HKD_ID=" + hakenID;

        //out.println(sql);
        stmt.executeQuery(sql);
        out.println("Lagerort eingetragen!");
        out.println("<br><br><a href=\"./details.jsp?art=haken_solo&hkk_id=" + hakenID + "&mat=" + matKz + "\">weiter</a>");

    }
    //#####---Aktuellen Platz bearbeiten---#####
    else if (art.equals("platz")) {

        out.println(" <form action=\"./zuweisen.jsp?art=platz_eintrag&hkkid=" + hakenID + "&anlJahr=" + anlJahr + "&lfdNr=" + lfdNr + "&matKz=" + matKz + "\" method=\"post\">");
        out.println("<table border=\"0\" align=\"center\"><tr><td><b>Platz zuweisen:</b></td></tr></table>");
        out.println("<table border=\"1\" align=\"center\"><tr><td align=\"center\">Platz</td>");
        out.println("<td><input type=\"text\" name=\"nummer\" size=\"11\" maxlength=\"11\" value=\"\"></input></td>");
        out.println("</tr></table>");
        out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"&Uuml;bernehmen\"></input>");
        out.println("</td></tr></table></form>");

    }

    //#####---Platz eintragen---#####
    else if (art.equals("platz_eintrag")) {

        nummer = request.getParameter("nummer");
        sql = "UPDATE PLRV11.ZUS_HAKEN_DETAIL SET HKD_AKT_PLATZ=" + nummer + " WHERE";
        sql += " HKD_ANL_JAHR=" + anlJahr + " AND HKD_MAT_KZ='" + matKz + "' AND HKD_LFD_NR=" + lfdNr + " AND HKD_ID=" + hakenID;
        //out.println(sql);
        stmt.executeQuery(sql);

        out.println("Aktueller Platz gesetzt!");
        out.println("<br><br><a href=\"./details.jsp?art=haken_solo&hkk_id=" + hakenID + "&mat=" + matKz + "\">weiter</a>");
    }

    //#####---Reservieren(ABNR)---#####
    else if (art.equals("reserv")) {

        out.println(" <form action=\"./zuweisen.jsp?art=reserv_eintrag&hkkid=" + hakenID + "&anlJahr=" + anlJahr + "&lfdNr=" + lfdNr + "&matKz=" + matKz + "\" method=\"post\">");
        out.println("<table border=\"0\" align=\"center\"><tr><td><b>Reservieren:</b></td></tr></table>");
        out.println("<table border=\"1\" align=\"center\"><tr><td align=\"center\">AB-NR</td>");
        out.println("<td><input type=\"text\" name=\"nummer\" size=\"6\" maxlength=\"6\" value=\"\"></input></td>");
        out.println("</tr></table>");
        out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"Reservieren\"></input>");
        out.println("</td></tr></table></form>");
    }
    //#####---Reservierung eintragen---#####
    else if (art.equals("reserv_eintrag")) {

        nummer = request.getParameter("nummer");
        sql = "UPDATE PLRV11.ZUS_HAKEN_DETAIL SET HKD_RESERV_ABNR=" + nummer + " WHERE";
        sql += " HKD_ANL_JAHR=" + anlJahr + " AND HKD_MAT_KZ='" + matKz + "' AND HKD_LFD_NR=" + lfdNr + " AND HKD_ID=" + hakenID;
        //out.println(sql);
        stmt.executeQuery(sql);

        out.println("Haken reserviert!");
        out.println("<br><br><a href=\"./details.jsp?art=haken_solo&hkk_id=" + hakenID + "&mat=" + matKz + "\">weiter</a>");
    } else {
        out.println("B&ouml;ser Fehler:Kein Kennzeichen &uuml;bergeben!!");
    }
    con.close();
%>

</body>
</html>

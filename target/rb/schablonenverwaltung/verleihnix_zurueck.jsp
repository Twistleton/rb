<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#ddddff">

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();

    String pNr = request.getParameter("pNr");

    String sql = "";
    String sql1 = "";
    String sql2 = "";
    String hkkBez = "";
    String hkdId = "";
    String hkdLfdNr = "";
    String hkdMatKz = "";
    String hkdAktPlatz = "";
    String hkdStandort = "";
    String hkdAusleihDat = "";
    String HAKEN = "";

    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    stmt = con.createStatement();
    stmt1 = con.createStatement();

    if (pNr.equals("alle")) {
        out.println("<table border=\"0\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<tr><td><h3>E N T L I E H E N E&nbsp;&nbsp;&nbsp;H A K E N</h3></td></tr></table>");
        out.println("<div align=\"center\"><h3>Personalnummer:&nbsp;<font color=\"blue\">" + pNr + "</font></h3></div>");
        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#7fff00\">");
        out.println("<colgroup><col width=\"130\"><col width=\"100\"><col width=\"380\"><col width=\"150\">");
        out.println("</colgroup>");
        out.println("<tr>");
        out.println("<td><b>Aktueller Platz</b></td>");
        out.println("<td><b>Haken</b></td><td><b>Bezeichnung</b></td>");
        out.println("<td><b>Leihdatum</b></td></tr>");


        sql = "SELECT HKD_ID,HKD_MAT_KZ,HKD_LFD_NR,HKD_AKT_PLATZ,HKD_STANDORT,HKD_LEIH_DAT FROM PLRV11.ZUS_HAKEN_DETAIL WHERE HKD_MAT_KZ='L'  AND(HKD_AKT_PLATZ IS NOT NULL OR HKD_AKT_PLATZ<>0) ORDER BY HKD_AKT_PLATZ,HKD_ID";
        //out.println(sql);

        //stmt      = con.createStatement();
        resultSet = stmt.executeQuery(sql);

        try {
            while (resultSet.next()) {
                hkdId = resultSet.getString("HKD_ID");
                hkdMatKz = resultSet.getString("HKD_MAT_KZ");
                hkdLfdNr = resultSet.getString("HKD_LFD_NR");
                hkdAktPlatz = resultSet.getString("HKD_AKT_PLATZ");
                hkdStandort = resultSet.getString("HKD_STANDORT");
                hkdAusleihDat = resultSet.getString("HKD_LEIH_DAT");

                //#####---Hakenbezeichnung ziehen---#####
                sql1 = "SELECT HKK_BEZ FROM PLRV11.ZUS_HAKEN_KOPF WHERE HKK_ID=" + hkdId;
                //out.println(sql1);
                //stmt1      = con.createStatement();
                resultSet1 = stmt1.executeQuery(sql1);
                try {
                    resultSet1.next();
                    hkkBez = resultSet1.getString("HKK_BEZ");
                } catch (SQLException e) {
                    out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
                }

                HAKEN = rbTextFormat.format('0', 8, hkdId);

                out.println("<form action=\"./verleihnix_zurueck_eintrag.jsp?pNr=" + pNr + "\" method=\"post\">");
                out.println("<tr>");
                out.println("<td>" + hkdAktPlatz + "</td>");
                out.println("<td>" + HAKEN + "</td><td>" + hkkBez + "</td>");
                out.println("<td>" + hkdAusleihDat + "</td>");
                out.println("</tr>");

                //out.println("<tr><td>&nbsp;</td></tr>");
            }
            out.println("</table>");
            /*out.println("<table border=\"0\" align=\"center\"><tr><td></td></tr><tr><td align=\"center\">");
                  out.println("<input type=\"submit\" value=\"Markierte Haken zur&uuml;ckgeben\"></input>");
              out.println("</td></tr></table></form>");*/

        } catch (SQLException e) {
            out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
        }

    } else {
        out.println("<table border=\"0\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<tr><td><h3>H A K E N&nbsp;&nbsp;&nbsp;R &Uuml; C K G A B E</h3></td></tr></table>");
        out.println("<div align=\"center\"><h3>Personalnummer:&nbsp;<font color=\"blue\">" + pNr + "</font></h3></div>");

        sql = "SELECT HKD_ID,HKD_MAT_KZ,HKD_LFD_NR,HKD_STANDORT FROM PLRV11.ZUS_HAKEN_DETAIL WHERE HKD_AKT_PLATZ=" + pNr + " ORDER BY HKD_MAT_KZ,HKD_ID";
        //out.println(sql);

        //stmt      = con.createStatement();
        resultSet = stmt.executeQuery(sql);

        try {
            while (resultSet.next()) {
                hkdId = resultSet.getString("HKD_ID");
                hkdMatKz = resultSet.getString("HKD_MAT_KZ");
                hkdLfdNr = resultSet.getString("HKD_LFD_NR");
                hkdStandort = resultSet.getString("HKD_STANDORT");

                //#####---Hakenbezeichnung ziehen---#####
                sql1 = "SELECT HKK_BEZ FROM PLRV11.ZUS_HAKEN_KOPF WHERE HKK_ID=" + hkdId;
                //out.println(sql1);
                //stmt1      = con.createStatement();
                resultSet1 = stmt1.executeQuery(sql1);
                try {
                    resultSet1.next();
                    hkkBez = resultSet1.getString("HKK_BEZ");
                } catch (SQLException e) {
                    out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
                }

                HAKEN = rbTextFormat.format('0', 8, hkdId);

                out.println("<form action=\"./verleihnix_zurueck_eintrag.jsp?pNr=" + pNr + "\" method=\"post\">");
                out.println("<table border=\"1\" align=\"center\" bgcolor=\"#7fff00\">");
                out.println("<colgroup><col width=\"150\"><col width=\"100\"><col width=\"300\"><col width=\"50\">");
                out.println("</colgroup>");
                out.println("<tr>");
                out.println("<td><b>Haken:&nbsp;" + HAKEN + "</b></td>");
                out.println("<td><b>Material:&nbsp;" + hkdMatKz + "</b></td><td><b>Bezeichnung:&nbsp;" + hkkBez + "</b></td>");
                out.println("<td align=\"center\"><input type=\"checkbox\" name=\"haken\" value=\"" + hkdId + ";" + hkdLfdNr + ";" + hkdMatKz + ";" + hkdStandort + "\">");
                //out.println("</td><td>"+hkdId+";"+hkdLfdNr+";"+hkdMatKz+";"+hkdStandort);
                out.println("</td></tr></table>");

                out.println("<table border=\"0\" align=\"center\"><tr><td></td></tr></table>");
            }

            out.println("<table border=\"0\" align=\"center\"><tr><td></td></tr><tr><td align=\"center\">");
            out.println("<input type=\"submit\" value=\"Markierte Haken zur&uuml;ckgeben\"></input>");
            out.println("</td></tr></table></form>");

        } catch (SQLException e) {
            out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
        }
    }
    con.close();


%>

</body>
</html>
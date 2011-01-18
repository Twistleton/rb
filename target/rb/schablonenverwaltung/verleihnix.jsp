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

    String zsb = request.getParameter("zsb");

    String sql = "";
    String sql1 = "";
    String sql2 = "";
    String hkkBez = "";
    String hkkId = "";
    String hkkMat = "";
    String hakenId = "";
    String lfdNr = "";
    String standort = "";
    String reservAbnr = "";
    String aktPlatz = "";
    String hkdMatKz = "";
    String HAKEN = "";

    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    int zaehler = 1;

    out.println("<table border=\"0\" align=\"center\" bgcolor=\"#ffffff\">");
    out.println("<tr><td><h3>H A K E N&nbsp;&nbsp;&nbsp;A U S L E I H E N</h3></td></tr></table>");
    out.println("<div align=\"center\"><h3>Zuschnitt-Schnittbild:&nbsp;<font color=\"blue\">" + zsb + "</font></h3></div>");

    //### AN DIESER STELLE WIRD ENTSCHIEDEN,DASS NUR 'L'-HAKEN ENTLIEHEN WERDEN KOENNEN(where-clause)-BEI BEDARF AENDERN ###
    sql = "SELECT VKN_HKK_ID,VKN_HKK_MAT_KZ FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='L' ORDER BY VKN_HKK_MAT_KZ,VKN_HKK_ID";
    //out.println(sql);

    stmt = con.createStatement();
    resultSet = stmt.executeQuery(sql);

    try {
        while (resultSet.next()) {
            hkkId = resultSet.getString("VKN_HKK_ID");
            hkkMat = resultSet.getString("VKN_HKK_MAT_KZ");

            HAKEN = rbTextFormat.format('0', 8, hkkId);
            //#####---Hakenbezeichnung ziehen---#####
            sql1 = "SELECT HKK_BEZ FROM PLRV11.ZUS_HAKEN_KOPF WHERE HKK_ID=" + hkkId;
            //out.println(sql1);
            stmt1 = con.createStatement();
            resultSet1 = stmt1.executeQuery(sql1);
            try {
                resultSet1.next();
                hkkBez = resultSet1.getString("HKK_BEZ");
            } catch (SQLException e) {
                out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
            }

            //#####---Einzelne Haken ziehen---#####
            sql2 = "SELECT * FROM PLRV11.zus_haken_detail WHERE HKD_ID=" + hkkId + " AND HKD_MAT_KZ='" + hkkMat + "' AND(HKD_AKT_PLATZ IS NULL";
            sql2 += " OR HKD_AKT_PLATZ=0)";
            //out.println(sql2);
            stmt2 = con.createStatement();
            resultSet2 = stmt2.executeQuery(sql2);
            try {
                /*out.println("<form action=\"./verleihnix_persnr.jsp\" method=\"post\">");
                   out.println("<table border=\"1\" align=\"center\" bgcolor=\"#c0c0c0\">");
                   out.println("<colgroup><col width=\"150\"><col width=\"100\"><col width=\"300\">");
                   out.println("</colgroup>");
                   out.println("<tr>");
                   out.println("<td><b>Haken:&nbsp;"+HAKEN+"</b></td>");
                   out.println("<td><b>Material:&nbsp;"+hkkMat+"</b></td><td><b>Bezeichnung:&nbsp;"+hkkBez+"</b></td></tr></table>");*/

                while (resultSet2.next()) {
                    hakenId = resultSet2.getString("HKD_ID");
                    lfdNr = resultSet2.getString("HKD_LFD_NR");
                    standort = resultSet2.getString("HKD_STANDORT");
                    reservAbnr = resultSet2.getString("HKD_RESERV_ABNR");
                    aktPlatz = resultSet2.getString("HKD_AKT_PLATZ");
                    hkdMatKz = resultSet2.getString("HKD_MAT_KZ");

                    out.println("<form action=\"./verleihnix_persnr.jsp\" method=\"post\">");
                    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#c0c0c0\">");
                    out.println("<colgroup><col width=\"150\"><col width=\"100\"><col width=\"300\">");
                    out.println("</colgroup>");
                    out.println("<tr>");
                    out.println("<td><b>Haken:&nbsp;" + HAKEN + "</b></td>");
                    out.println("<td><b>Material:&nbsp;" + hkkMat + "</b></td><td><b>Bezeichnung:&nbsp;" + hkkBez + "</b></td></tr></table>");
                    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#7fff00\">");
                    out.println("<colgroup><col width=\"150\"><col width=\"100\"><col width=\"300\">");
                    out.println("</colgroup>");
                    out.println("<tr>");
                    out.println("<td>" + lfdNr + "</td>");
                    out.println("<td>" + standort + "</td>");
                    out.println("<td align=\"center\"><input type=\"checkbox\" name=\"haken\" value=\"" + hakenId + ";" + lfdNr + ";" + hkdMatKz + "\">");
                    out.println("</td></tr></table>");
                    out.println("<table border=\"0\" align=\"center\"><tr><td></td></tr></table>");
                }
            } catch (SQLException e) {
                out.println("Haken-ID nicht gefunden!&nbsp;" + e + "<br>" + sql2);
            }

            //out.println("</table>");
        }
        out.println("<table border=\"0\" align=\"center\"><tr><td></td></tr><tr><td align=\"center\">");
        out.println("<font color=\"red\"><b>Personalnummer eingeben:</b></font>&nbsp;&nbsp;<input type=\"text\" name=\"pNr\"size=\"4\" maxlength=\"4\" value=\"0\">");
        out.println("</input></td></tr><tr><td align=\"center\">");
        out.println("<input type=\"submit\" value=\"Markierte Haken ausleihen\"></input>");
        out.println("</td></tr></table></form>");
    } catch (SQLException e) {
        out.println("Fehler!!&nbsp;" + e + "<br>" + sql1);
    }

    con.close();


%>

</body>
</html>
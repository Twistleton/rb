<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head></head>
<body bgcolor="#eeeeee">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();
    String sql;
    String sql1;
    Statement stmt;
    Statement stmt1;
    ResultSet resultSet;
    ResultSet resultSet2;
    stmt = con.createStatement();
    stmt1 = con.createStatement();

    String hakenID = "";
    String hkk_bez = "";
    String haken = "";
    String hkkAnzahl = "";

    //#####---Formularuebergabedaten[prog,mat]---#####
    String prog = request.getParameter("prog");
    String mat = request.getParameter("mat");

    int count = 0;
    int proglength = 0;
    int hakenlength = 0;
    int strlen = 0;
    String eins = "";
    String zwei = "";
    String new_prog = "";

    count = prog.length();

    if (count == 3) {
        eins = prog.substring(0, 1);
        if (eins.equals("0")) {
            zwei = prog.substring(1, 2);
            if (zwei.equals("0")) {
                new_prog = prog.substring(2, 3);
            } else {
                new_prog = prog.substring(1, 3);
            }
        } else {
            new_prog = prog;
        }
    } else if (count == 2) {
        eins = prog.substring(0, 1);
        if (eins.equals("0")) {
            new_prog = prog.substring(1, 2);
        } else {
            new_prog = prog;
        }
    } else if (count == 1) {
        eins = prog.substring(0, 1);
        if (eins.equals("0")) {
            out.println("Fehler:Das Programm 0 existiert nicht!");
        } else {
            new_prog = prog;
        }
    } else {
        out.println("Fehleingabe!");
    }
    //out.println(prog+","+new_prog);

    proglength = new_prog.length();
    if (proglength == 1) {
        hakenlength = 6;
    } else if (proglength == 2) {
        hakenlength = 7;
    } else if (proglength == 3) {
        hakenlength = 8;
    }

    sql = "SELECT DISTINCT VKN_HKK_ID,HKK_BEZ FROM PLRV11.ZUS_VKN_HKK_ZSB LEFT JOIN PLRV11.ZUS_HAKEN_KOPF ON";
    sql += " VKN_HKK_ID = HKK_ID WHERE VKN_SB_ID LIKE '" + new_prog + "%'AND VKN_HKK_MAT_KZ ='" + mat + "' AND HKK_MAT_KZ ='" + mat + "' ORDER BY VKN_HKK_ID ASC";
    resultSet = stmt.executeQuery(sql);
//out.println(sql);


    try {
        out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr>");
        out.println("<tr><td>&nbsp;");
        //out.println("<a href=\"./druckausgabe.jsp?prog="+prog+"&mat="+mat+"\">");
        //out.println("<img src=\"./img/drucken.jpg\" border=\"0\"></a></td></tr></table>");
        out.println("</td></tr></table>");
        out.println("<table cellpadding=\"5\" border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"50\"><col width=\"50\"><col width=\"50\"><col width=\"500\"></colgroup>");
        out.println("<tr bgcolor=\"#c0c0c0\"><td align=\"center\"><b>Programm<br>" + new_prog + "</b></td>");
        out.println("<td><b>Material:&nbsp;" + mat + "</b></td><td>&nbsp;</td><td>&nbsp;</td></tr>");
        out.println("<tr><td><b>Material</b></td><td width=\"130\"><b>Haken</b></td>");
        out.println("<td width=\"50\"><b>S&auml;tze</b></td><td><b>Bezeichnung</b></td></tr>");

        while (resultSet.next()) {
            hakenID = resultSet.getString("VKN_HKK_ID");
            hkk_bez = resultSet.getString("HKK_BEZ");

            strlen = hakenID.length();

            if (strlen == 6) {
                haken = "00" + hakenID;
            } else if (strlen == 7) {
                haken = "0" + hakenID;
            } else {
                haken = hakenID;
            }


            if (strlen == hakenlength) {
                out.println("<tr>");
                out.println("<td>" + mat + "</td>");
                out.println("<td>" + haken + "</td>");

                //#####---Entsprechende Hakenanzahl aussuchen und anzeigen---#####
                sql1 = "SELECT COUNT(HKD_LFD_NR) AS HKK_COUNT FROM PLRV11.ZUS_HAKEN_DETAIL WHERE HKD_ID=" + hakenID;
                sql1 += " and HKD_MAT_KZ='" + mat + "'";

                resultSet2 = stmt1.executeQuery(sql1);

                try {
                    while (resultSet2.next()) {
                        hkkAnzahl = resultSet2.getString("HKK_COUNT");
                        out.println("<td align=\"center\">" + hkkAnzahl + "</td>");
                    }
                } catch (SQLException e) {
                    out.println("Fehler beim Auslesen aus Hakendetailtabelle!!&nbsp;" + e + "<p>");
                }
                out.println("<td>" + hkk_bez + "</td></tr>");
            }
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen aus Tabelle ZUS_VKN_HKK_ZSB!!&nbsp;" + e + "<p>");
    }
    out.println("</table>");
    con.close();
%>

</body>
</html>

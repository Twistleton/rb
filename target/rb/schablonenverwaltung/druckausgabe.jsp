<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();
    String sql;
    String sql1;
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    ResultSet resultSet;
    ResultSet resultSet2;
    stmt = con.createStatement();
    stmt1 = con.createStatement();
    stmt2 = con.createStatement();
    String modNr = "";
    String modBez = "";
    String modell = "";
    String zsb = "";
    String hakenID = "";
    String haken = "";
    String plrmodell = "";

    //#####---Formularuebergabedaten[prog,mat]---#####
    int programm = new Integer(request.getParameter("prog")).intValue();
    String material = request.getParameter("mat");

    //#####---Speicherort /tmp, Dateiendung .hkl---#####
    komDruckDatei kdd = new komDruckDatei("/tmp", "komdruckdatei", "hkl");

    //out.println(sql);
    //kdd.setNameTimestamp();
    kdd.oeffnen();
    kdd.satzEinfuegen("HAKLIS " + programm + " " + material + "\n");

    sql = "SELECT MOD_NR,MOD_BEZ FROM PLRV11.PLR_MODELL WHERE MOD_PROG=" + programm + " ORDER BY MOD_NR ";
    resultSet = stmt.executeQuery(sql);

    try {
        while (resultSet.next()) {
            modNr = resultSet.getString("MOD_NR");
            modBez = resultSet.getString("MOD_BEZ");
            int strlen = modNr.length();

            if (strlen == 5) {
                //modell = modNr.substring(1,5);
                modell = "00" + modNr;
                zsb = modNr.substring(0, 4);
            } else if (strlen == 6) {
                modell = modNr.substring(2, 6);
                //modell = "0"+modNr;
                zsb = modNr.substring(0, 5);
            } else {
                modell = modNr.substring(3, 7);
                zsb = modNr.substring(0, 6);
            }

            //#####---Letzte Ziffer-British Standard oder nicht---#####
            String nullodereins = modell.substring(3);

            //#####---British Standard nicht anzeigen---#####
            if (nullodereins.equals("0")) {
                //#####---Letzte Ziffer(=0) nicht anzeigen---#####
                plrmodell = modell.substring(0, 3);
                kdd.satzEinfuegen(plrmodell);
                kdd.satzEinfuegen(modBez);
                int modbezstrlen = modBez.length();
                int rest = 50 - modbezstrlen;
                int zahl;

                for (zahl = 1; zahl <= rest; zahl++) {
                    kdd.satzEinfuegen(" ");
                }

                //#####---Entsprechende Haken aussuchen und anzeigen---#####
                sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + material + "'";

                resultSet2 = stmt1.executeQuery(sql1);
                try {
                    while (resultSet2.next()) {
                        hakenID = resultSet2.getString("VKN_HKK_ID");
                        int hakenstrlen = hakenID.length();
                        if (hakenstrlen == 8) {
                            haken = hakenID.substring(5);
                            kdd.satzEinfuegen(haken);
                        } else if (hakenstrlen == 7) {
                            haken = hakenID.substring(4);
                            kdd.satzEinfuegen(haken);
                        } else if (hakenstrlen == 6) {
                            haken = hakenID.substring(3);
                            kdd.satzEinfuegen(haken);
                        }
                    }
                } catch (SQLException e) {
                    out.println("Fehler beim Auslesen aus der Verkn&uuml;pfungstabelle!!&nbsp;" + e + "<p>");
                }
                kdd.satzEinfuegen("\n");
            }
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Modellnummern!!&nbsp;" + e + "<p>");
    }
    kdd.schliessen();
    out.println("<b>Die Hakenliste wurde gedruckt!</b>");
    kdd.aktiviereDatei();
    kdd.drucken("detec16220");
    out.println("<br><br><a href=\"./hakenliste_eingabe.html\">weiter</a>");

    con.close();
%>

</body>
</html>
    
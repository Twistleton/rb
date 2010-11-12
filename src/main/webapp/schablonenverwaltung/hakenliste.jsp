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

    //#####---Formularuebergabedaten[prog,mat]---#####
    String programm = request.getParameter("prog");
    String programm1 = "";
    String material = request.getParameter("mat");

    String modNr = "";
    String modBez = "";
    String modell = "";
    String zsb = "";
    String hakenID = "";
    String haken = "";
    String plrmodell = "";

    sql = "SELECT MOD_NR,MOD_BEZ FROM PLRV11.PLR_MODELL WHERE MOD_PROG=" + programm + " ORDER BY MOD_NR ";
    resultSet = stmt.executeQuery(sql);
    //out.println(sql+"<br>");

    try {
        int proglen = programm.length();

        if (proglen == 2) {
            programm1 = "0" + programm;
        } else if (proglen == 1) {
            programm1 = "00" + programm;
        } else {
            programm1 = programm;
        }

        out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr>");
        out.println("<tr><td>");
        out.println("<a href=\"./druckausgabe.jsp?prog=" + programm + "&mat=" + material + "\">");
        out.println("<img src=\"./img/drucken.jpg\" border=\"0\"></a></td></tr></table>");
        out.println("<table cellpadding=\"5\" border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
        out.println("<colgroup><col width=\"50\"><col width=\"280\"><col width=\"230\"></colgroup>");
        out.println("<tr bgcolor=\"#c0c0c0\"><td align=\"center\"><b>Programm<br>" + programm1 + "</b></td>");
        out.println("<td><b>Material:&nbsp;" + material + "</b></td><td>&nbsp;</td></tr>");
        out.println("<tr><td><b>Modell</b></td><td><b>Bezeichnung</b></td><td><b>Hakennummern</b></td></tr>");


        while (resultSet.next()) {
            modNr = resultSet.getString("MOD_NR");
            modBez = resultSet.getString("MOD_BEZ");
            int strlen = modNr.length();

            if (strlen == 5) {
                modell = modNr.substring(1, 5);
                //modell = "00"+modNr;
                zsb = modNr.substring(0, 4);
                //out.println("<br>"+zsb);
            } else if (strlen == 6) {
                modell = modNr.substring(2, 6);
                //modell = "0"+modNr;
                zsb = modNr.substring(0, 5);
            } else {
                modell = modNr.substring(3, 7);
                zsb = modNr.substring(0, 6);
            }
            //out.println("proglen:"+proglen+"<br>");

            if (proglen != 1 && !(programm1.equals("001"))) {
                //#####---Letzte Ziffer-British Standard oder nicht ---#####
                String nullodereins = modell.substring(3);
                //out.println("nullodereins:"+nullodereins+"<br>Strlen:"+strlen+"<br>");

                //### NOCH NE AUSNAHME: Prog. 625-kein Modell mit Endziffer o, nur 3 und 4...ANzeige wird fuer Hakenliste benoetigt
                if (programm1.equals("625")) {
                    //#####---British Standard nicht anzeigen---#####
                    if (nullodereins.equals("0") || nullodereins.equals("3") || strlen == 5) {
                        //#####---Letzte Ziffer(=0) nicht anzeigen---#####
                        //out.println("nanu?");

                        plrmodell = modell.substring(0, 3);
                        out.println("<tr>");
                        if (strlen == 5) {
                            out.println("<td>" + plrmodell + "</td>");
                        } else {
                            out.println("<td>" + plrmodell + "</td>");
                        }
                        out.println("<td>" + modBez + "</td>");
                        out.println("<td>");

                        //#####---Entsprechende Haken aussuchen und anzeigen---#####
                        sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + material + "'";
                        resultSet2 = stmt1.executeQuery(sql1);
                        //out.println(sql1+"<br>");

                        try {
                            while (resultSet2.next()) {
                                hakenID = resultSet2.getString("VKN_HKK_ID");
                                int hakenstrlen = hakenID.length();
                                if (hakenstrlen == 8) {
                                    haken = hakenID.substring(5);
                                    out.println(haken + "&nbsp;");
                                } else if (hakenstrlen == 7) {
                                    haken = hakenID.substring(4);
                                    out.println(haken + "&nbsp;");
                                } else if (hakenstrlen == 6) {
                                    haken = hakenID.substring(3);
                                    out.println(haken + "&nbsp;");
                                }
                            }
                        } catch (SQLException e) {
                            out.println("Fehler beim Auslesen aus Verkn&uuml;pfungstabelle!!&nbsp;" + e + "<p>");
                        }
                        out.println("&nbsp;</td></tr>");
                    }
                } else {
                    //#####---British Standard nicht anzeigen---#####
                    if (nullodereins.equals("0") || nullodereins.equals("6") || strlen == 5) {
                        //#####---Letzte Ziffer(=0) nicht anzeigen---#####
                        //out.println("nanu?");

                        plrmodell = modell.substring(0, 3);
                        out.println("<tr>");
                        if (strlen == 5) {
                            out.println("<td>" + plrmodell + "</td>");
                        } else {
                            out.println("<td>" + plrmodell + "</td>");
                        }
                        out.println("<td>" + modBez + "</td>");
                        out.println("<td>");

                        //#####---Entsprechende Haken aussuchen und anzeigen---#####
                        sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + material + "'";
                        resultSet2 = stmt1.executeQuery(sql1);
                        //out.println(sql1+"<br>");

                        try {
                            while (resultSet2.next()) {
                                hakenID = resultSet2.getString("VKN_HKK_ID");
                                int hakenstrlen = hakenID.length();
                                if (hakenstrlen == 8) {
                                    haken = hakenID.substring(5);
                                    out.println(haken + "&nbsp;");
                                } else if (hakenstrlen == 7) {
                                    haken = hakenID.substring(4);
                                    out.println(haken + "&nbsp;");
                                } else if (hakenstrlen == 6) {
                                    haken = hakenID.substring(3);
                                    out.println(haken + "&nbsp;");
                                }
                            }
                        } catch (SQLException e) {
                            out.println("Fehler beim Auslesen aus Verkn&uuml;pfungstabelle!!&nbsp;" + e + "<p>");
                        }
                        out.println("&nbsp;</td></tr>");
                    }
                }
            }
            //###---EGO-Abteilung---###
            else {
                //#####---Letzte Ziffer-British Standard oder nicht ---#####
                String nullodereins = modell.substring(3);

                //#####---British Standard nicht anzeigen---#####
                //if(nullodereins.equals("0") || strlen ==5){
                //#####--Bei Material Z wieder was spezielles, nur letzte Ziffer=0 anzeigen---#####
                if (material.equals("Z")) {
                    if (nullodereins.equals("0")) {
                        //#####---Letzte Ziffer(=1) nicht anzeigen---#####
                        plrmodell = modell.substring(0, 3);
                        //out.println("OJE");
                        int modellnumber = new Integer(plrmodell).intValue();

/*if(!(modellnumber<23 || (modellnumber>44 && modellnumber<49)||(modellnumber>53 && modellnumber<57)||(modellnumber>59 && modellnumber<162)||(modellnumber>169 && modellnumber<172)||(modellnumber>278 && modellnumber<285)||(modellnumber>299 && modellnumber<300)||(modellnumber>407 && modellnumber<444)||(modellnumber>444 && modellnumber<505)||(modellnumber>510 && modellnumber<517)||(modellnumber>524 && modellnumber<539)||(modellnumber>544 && modellnumber<576)||(modellnumber>590 && modellnumber<595)||(modellnumber>597 && modellnumber<601)||(modellnumber>602 && modellnumber<606)||(modellnumber>610 && modellnumber<632))){
*/
//11.01.07
                        if (!(modellnumber < 30 || (modellnumber > 44 && modellnumber < 49) || (modellnumber > 123 && modellnumber < 162) || (modellnumber > 290 && modellnumber < 292) || (modellnumber > 329 && modellnumber < 331) || (modellnumber > 331 && modellnumber < 333) || (modellnumber > 344 && modellnumber < 395) || (modellnumber > 419 && modellnumber < 444) || (modellnumber > 444 && modellnumber < 524) || (modellnumber > 524 && modellnumber < 539) || (modellnumber > 544 && modellnumber < 574) || (modellnumber > 609 && modellnumber < 870) || (modellnumber > 879 && modellnumber < 882) || (modellnumber > 897 && modellnumber < 900) || (modellnumber > 915 && modellnumber < 918) || (modellnumber > 933 && modellnumber < 936) || (modellnumber > 951 && modellnumber < 968) || (modellnumber > 999))) {

                            out.println("<tr><td>" + plrmodell + "</td>");
                            out.println("<td>" + modBez + "</td>");
                            out.println("<td>");

                            //#####---Entsprechende Haken aussuchen und anzeigen---#####
                            sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + material + "'";
                            resultSet2 = stmt1.executeQuery(sql1);

                            try {
                                while (resultSet2.next()) {
                                    hakenID = resultSet2.getString("VKN_HKK_ID");
                                    int hakenstrlen = hakenID.length();
                                    if (hakenstrlen == 8) {
                                        haken = hakenID.substring(5);
                                        out.println(haken + "&nbsp;");
                                    } else if (hakenstrlen == 7) {
                                        haken = hakenID.substring(4);
                                        out.println(haken + "&nbsp;");
                                    } else if (hakenstrlen == 6) {
                                        haken = hakenID.substring(3);
                                        out.println(haken + "&nbsp;");
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("Fehler beim Auslesen aus Verkn&uuml;pfungstabelle!!&nbsp;" + e + "<p>");
                            }
                            out.println("&nbsp;</td></tr>");
                        }
                    }
                } else {
                    if (nullodereins.equals("0") || nullodereins.equals("3") || nullodereins.equals("4") || nullodereins.equals("2") || nullodereins.equals("6")) {
                        //#####---Letzte Ziffer(=1) nicht anzeigen---#####
                        plrmodell = modell.substring(0, 3);
                        //out.println("<tr>");
                        int modellnumber = new Integer(plrmodell).intValue();
//11.01.07
                        if (!(modellnumber < 30 || (modellnumber > 44 && modellnumber < 49) || (modellnumber > 123 && modellnumber < 162) || (modellnumber > 290 && modellnumber < 292) || (modellnumber > 329 && modellnumber < 331) || (modellnumber > 331 && modellnumber < 333) || (modellnumber > 344 && modellnumber < 395) || (modellnumber > 419 && modellnumber < 444) || (modellnumber > 444 && modellnumber < 524) || (modellnumber > 524 && modellnumber < 539) || (modellnumber > 544 && modellnumber < 574) || (modellnumber > 609 && modellnumber < 870) || (modellnumber > 879 && modellnumber < 882) || (modellnumber > 897 && modellnumber < 900) || (modellnumber > 915 && modellnumber < 918) || (modellnumber > 933 && modellnumber < 936) || (modellnumber > 951 && modellnumber < 968) || (modellnumber > 999))) {

/*if(!(modellnumber<23 || (modellnumber>44 && modellnumber<49)||(modellnumber>53 && modellnumber<172)||(modellnumber>285 && modellnumber<320)||(modellnumber>343 && modellnumber<345)||(modellnumber>404 && modellnumber<505)||(modellnumber>510 && modellnumber<517)||(modellnumber>524 && modellnumber<539)||(modellnumber>544 && modellnumber<576)||(modellnumber>590 && modellnumber<595)||(modellnumber>597 && modellnumber<601)||(modellnumber>602 && modellnumber<606)||(modellnumber>610 && modellnumber<632))){
*/
                            out.println("<tr><td>" + plrmodell + "</td>");
                            out.println("<td>" + modBez + "</td>");
                            out.println("<td>");

                            //#####---Entsprechende Haken aussuchen und anzeigen---#####
                            sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + material + "'";
                            resultSet2 = stmt1.executeQuery(sql1);

                            try {
                                while (resultSet2.next()) {
                                    hakenID = resultSet2.getString("VKN_HKK_ID");
                                    int hakenstrlen = hakenID.length();
                                    if (hakenstrlen == 8) {
                                        haken = hakenID.substring(5);
                                        out.println(haken + "&nbsp;");
                                    } else if (hakenstrlen == 7) {
                                        haken = hakenID.substring(4);
                                        out.println(haken + "&nbsp;");
                                    } else if (hakenstrlen == 6) {
                                        haken = hakenID.substring(3);
                                        out.println(haken + "&nbsp;");
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("Fehler beim Auslesen aus Verkn&uuml;pfungstabelle!!&nbsp;" + e + "<p>");
                            }
                            out.println("&nbsp;</td></tr>");
                        }
                    }
                }
            }
            //###---Ende-EGO-Abteilung---###
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen aus plr_modell!!&nbsp;" + e + "<p>");
    }
    out.println("</table>");

    con.close();
%>

</body>
</html>

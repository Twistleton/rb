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
    String sql2;
    String sql3;
    String sql4;
    String mdl = "NULL";
    Statement stmt;
    Statement stmt1;
    Statement stmt5;

    ResultSet resultSet;
    ResultSet resultSet1;
    ResultSet resultSet2;
    ResultSet resultSet3;


    stmt = con.createStatement();
    stmt1 = con.createStatement();
    stmt5 = con.createStatement();

    //#####---Auswahlvariable-was wird angelegt?---#####
    String art = request.getParameter("art");

    //#####---Zuschnitt-Schnittbild anlegen---#####
    if (art.equals("zsb")) {

        long zsb = new Long(request.getParameter("zsb")).longValue();
        int anl_jahr = new Integer(request.getParameter("anl_jahr")).intValue();
        String ausl_dat_tag = request.getParameter("ausl_dat_tag");
        String ausl_dat_monat = request.getParameter("ausl_dat_monat");
        String ausl_dat_jahr = request.getParameter("ausl_dat_jahr");
        int material = new Integer(request.getParameter("material")).intValue();
        String pfad = request.getParameter("pfad");
        String regel = request.getParameter("regel");
        try {
            mdl = request.getParameter("mdl");
        } catch (Exception e) {
            out.println("Der Eintrag im Feld MDL fehlt!!<p>");
        }
        String user = request.getRemoteUser();
        String auslaufdatum = ausl_dat_jahr + "-" + ausl_dat_monat + "-" + ausl_dat_tag;
        String datString = "";
        int error = 0;
        int gueltKz = 1;

        if (auslaufdatum.equals("0000-00-00")) {
            datString = "NULL";
        } else {
            datString = "TO_DATE('" + auslaufdatum + "','YYYY-MM-DD')";
        }

        sql = "INSERT INTO PLRV11.ZUS_SCHNITTBILD (SB_ID,SB_ANL_JAHR,SB_AUSL_DAT,SB_GUELT_KZ,SB_CUTTER_SB,SB_PFAD,SB_REGEL,SB_MLD,"
                + "SB_USER_ID,SB_AEND_DAT) "
                + " VALUES("
                + zsb
                + "," + anl_jahr
                + "," + datString
                + "," + gueltKz
                + "," + material
                + ",'" + pfad + "'"
                + ",'" + regel + "'"
                + ",'" + mdl + "'"
                + ",'" + user + "'"
                + ",Sysdate"
                + ")";

        try {
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            out.println("Zuschnitt-Schnittbild erfolgreich eingetragen!<br>");
            out.println("<br><br><a href=\"./details.jsp?art=zsb&zsb_id=" + zsb + "\">weiter</a>");

        } catch (SQLException e) {
            out.println("Fehler beim Einf&uuml;gen des ZSB-Datensatzes:&nbsp;" + e + "<p>");
        }
    }

    //#####---Haken anlegen (kopieren)---#####
    else if (art.equals("haken")) {

        long zsb = new Long(request.getParameter("zsb")).longValue();
        long hakenID = new Long(request.getParameter("hkk_id")).longValue();
        int anl_jahr = new Integer(request.getParameter("anl_jahr")).intValue();
        String hakenMat = request.getParameter("hkk_material");
        String hakenBez = request.getParameter("hkk_bez");
        int hakenProg = new Integer(request.getParameter("hkk_prog")).intValue();
        String user = request.getRemoteUser();
        int error = 0;
        int lfdNr = 1;

        //#####---Erst die Hakenkopfdaten---#####
        sql = "INSERT INTO PLRV11.ZUS_HAKEN_KOPF (HKK_SB_ID,HKK_ANL_JAHR,HKK_MAT_KZ,HKK_ID,HKK_USER_ID,HKK_AEND_DAT,HKK_BEZ,HKK_PROG)"
                + " VALUES("
                + zsb
                + "," + anl_jahr
                + ",'" + hakenMat + "'"
                + "," + hakenID
                + ",'" + user + "'"
                + ",Sysdate"
                + ",'" + hakenBez + "'"
                + ",'" + hakenProg + "'"
                + ")";
        try {
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            out.println("Hakenkopfdaten erfolgreich eingetragen!<br>");

        } catch (SQLException e) {
            out.println("Fehler beim Einf&uuml;gen des Hakenkopf-Datensatzes:&nbsp;" + e + "<p>");
            error = 1;
        }
        if (error != 1) {

            //#####---Dann die Hakendetaildaten---#####
            sql = "INSERT INTO PLRV11.ZUS_HAKEN_DETAIL (HKD_ID,HKD_ANL_JAHR,HKD_MAT_KZ,HKD_LFD_NR)"
                    + " VALUES("
                    + hakenID
                    + "," + anl_jahr
                    + ",'" + hakenMat + "'"
                    + "," + lfdNr
                    + ")";
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("Detail-Haken erfolgreich eingetragen!<br>");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Haken-Detail-Datensatzes:&nbsp;" + e + "<p>");
                error = 1;
            }

            //##### --dann kommt der Eintrag in die Verknuepfungstabelle---#####
            sql = "INSERT INTO PLRV11.ZUS_VKN_HKK_ZSB (VKN_HKK_ID,VKN_HKK_MAT_KZ,VKN_SB_ID)"
                    + " VALUES("
                    + hakenID
                    + ",'" + hakenMat
                    + "'," + zsb
                    + ")";
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("ZSB-Haken-Verkn&uuml;pfung erfolgreich eingetragen!");
                out.println("<br><br><a href=\"./details.jsp?art=haken&hkkid=" + hakenID + "&sbID=" + zsb + "&matKz=" + hakenMat + "\">weiter</a>");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Verkn&uuml;pfungs-Datensatzes:&nbsp;" + e + "<p>");
                error = 1;
            }
        } else {
            out.println("Fehler beim Datenbankeintrag!!");
        }
    }

    //#####---Komplett neuen physischen Haken anlegen(Detailtabelle)---#####
    else if (art.equals("haken_neu")) {

        //long zsb         = new Long(request.getParameter("zsb")).longValue();
        long hakenID = new Long(request.getParameter("hkkid")).longValue();
        int anlJahr = new Integer(request.getParameter("anlJahr")).intValue();
        String hakenMat = request.getParameter("hakenMat");
        String hakenBez = request.getParameter("hakenBez");
        int hakenProg = new Integer(request.getParameter("hakenProg")).intValue();
        int error = 0;
        int lfdNr = 1;
        int max = 0;

        //#####---LfdNr des neuen Hakens ermitteln---#####
        //sql  = "SELECT MAX(HKD_LFD_NR) AS MAX_NR FROM PLRV11.ZUS_HAKEN_DETAIL";
        //sql += " WHERE HKD_ID="+hakenID+" AND HKD_ANL_JAHR="+anlJahr+" AND HKD_MAT_KZ='"+hakenMat+"'";
        //### ANL_JAHR aus select-string entfernt--19.09.05 RS ###
        sql = "SELECT MAX(HKD_LFD_NR) AS MAX_NR FROM PLRV11.ZUS_HAKEN_DETAIL";
        sql += " WHERE HKD_ID=" + hakenID + " AND HKD_MAT_KZ='" + hakenMat + "'";
        resultSet = stmt.executeQuery(sql);

        try {
            resultSet.next();
            max = resultSet.getInt("MAX_NR");
            //out.println("max:"+max+"<br>");
            lfdNr = max + 1;
            //out.println("neue LfdNr:"+lfdNr);
            //out.println("Haken erfolgreich eingetragen!");
        } catch (SQLException e) {
            out.println("Fehler beim Bestimmen der LfdNr:&nbsp;" + e + "<p>");
            error = 1;
        }
        if (error != 1) {
            //#####--Eintrag in Hakendetail-Tabelle---#####
            sql = "INSERT INTO PLRV11.ZUS_HAKEN_DETAIL (HKD_ID,HKD_ANL_JAHR,HKD_MAT_KZ,HKD_LFD_NR)"
                    + " VALUES("
                    + hakenID
                    + "," + anlJahr
                    + ",'" + hakenMat + "'"
                    + "," + lfdNr
                    + ")";
            try {
                //out.println(sql);
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("Neuer Haken erfolgreich eingetragen!");
                out.println("<br><br><a href=\"./details.jsp?art=haken&hkkid=" + hakenID + "&matKz=" + hakenMat + "\">weiter</a>");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Haken-Detail-Datensatzes:&nbsp;" + e + "<p>");
                error = 1;
            }
        } else {
            out.println("Fehler beim Datenbankeintrag!!");
        }
    }

    //#####---Bereits bestehenden Haken einem ZSB zuordnen---#####
    else if (art.equals("haken_spezial")) {

        String hkkID = request.getParameter("hkk_id");
        String mat = hkkID.substring(0, 1);
        String hak = hkkID.substring(2);
        String zsb = request.getParameter("zsb");
        String bez = "";
        String anjahr = "";
        String hkprog = "";
        String hkommentar = "";


        sql = "SELECT HKK_BEZ,HKK_ANL_JAHR,HKK_PROG,HKK_KOMMENTAR FROM PLRV11.ZUS_HAKEN_KOPF";
        sql += " WHERE HKK_ID=" + hak + " AND HKK_MAT_KZ='" + mat + "'";
        resultSet = stmt.executeQuery(sql);

        try {
            resultSet.next();
            bez = resultSet.getString("HKK_BEZ");
            anjahr = resultSet.getString("HKK_ANL_JAHR");
            hkprog = resultSet.getString("HKK_PROG");
            hkommentar = resultSet.getString("HKK_KOMMENTAR");

        } catch (SQLException e) {
            out.println("Fehler beim Auslesen der Daten aus Tabelle ZUS_HAKEN_KOPF:&nbsp;" + e + "<p>");
            //error = 1;
        }

        out.println("<form action=\"./updaten.jsp?art=haken_spezial\" method=\"post\">");
        out.println("<h3 align=\"center\">Haken hinzuf&uuml;gen:</h3></td></tr></table>");

        out.println("<table border=\"1\" align=\"center\" bgcolor=\"#eeeeee\">");

        out.println("<tr><td align=\"center\">Zuschnitt-SB</td><td>");
        out.println("<input type=\"text\" name=\"zsb\" size=\"6\" maxlength=\"6\" value=" + zsb + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Haken-ID</td><td>");
        out.println("<input type=\"text\" name=\"hkk_id\" size=\"8\" maxlength=\"8\" value=" + hak + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Material</td><td>");
        out.println("<input type=\"text\" name=\"hkk_material\" size=\"1\"  value=" + mat + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Anlaufjahr</td><td>");
        out.println("<input type=\"text\" name=\"anl_jahr\" size=\"4\"maxlength=\"4\" value=" + anjahr + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Bezeichnung</td><td>");
        out.println("<input type=\"text\" name=\"hkk_bez\" size=\"30\" maxlength=\"50\" value=" + bez + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Programm</td><td>");
        out.println("<input type=\"text\" name=\"hkk_prog\" size=\"3\" maxlength=\"3\" value=" + hkprog + " readonly></input></td></tr>");
        out.println("<tr><td align=\"center\">Kommentar</td><td>");
        out.println("<input type=\"text\" name=\"hkk_kommentar\" size=\"30\" maxlength=\"100\" value=" + hkommentar + " readonly></input>");
        out.println("</td></tr>");
        out.println("</table>");
        out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"&Uuml;bernehmen\"></input>");
        out.println("</td></tr></table></form>");
    }

    //#####---Alle Haken eines Materials kopieren---Stouurz!!#####
    else if (art.equals("alle_haken_kopieren")) {

        String zsb = request.getParameter("zsb");
        String von_mat = request.getParameter("von_mat");
        String nach_mat = request.getParameter("nach_mat");
        String user = request.getRemoteUser();
        out.println(zsb + "<br>");
        out.println(user + "<br>");
        out.println(von_mat + "<br>");
        out.println(nach_mat + "<br>");

        //#####---Entsprechende Haken aussuchen(Verknuepfungstabelle)
        sql1 = "SELECT VKN_HKK_ID FROM PLRV11.ZUS_VKN_HKK_ZSB WHERE VKN_SB_ID=" + zsb + " AND VKN_HKK_MAT_KZ='" + von_mat + "'";
        resultSet1 = stmt5.executeQuery(sql1);
        out.println(sql1);
        try {
            while (resultSet1.next()) {
                String hakenID = resultSet1.getString("VKN_HKK_ID");
                out.println("Tab. VKN-HKK_ID:" + hakenID + "<br>");

                //##### --Hier kommt der Eintrag in die Verknuepfungstabelle!!!
                sql2 = "INSERT INTO PLRV11.ZUS_VKN_HKK_ZSB (VKN_HKK_ID,VKN_HKK_MAT_KZ,VKN_SB_ID)"
                        + " VALUES("
                        + hakenID
                        + ",'" + nach_mat
                        + "'," + zsb
                        + ")";
                try {
                    //out.println(sql2);
                    stmt1.executeQuery(sql2);
                    out.println("ZSB-Haken-Verknuepfung erfolgreich eingetragen:" + nach_mat + "-" + hakenID + "<br>");
                    //out.println("<br><br><a href=\"./details.jsp?art=zsb&zsb_id="+zsb+"\">weiter</a>");

                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
                }

            }
        } catch (SQLException e) {
            out.println("Fehler:HKK_ID in Verkn&uuml;pfungstabelle nicht vorhanden!!&nbsp;" + e + "<p>");
        }

        out.println("<br><br><a href=\"./details.jsp?art=zsb&zsb_id=" + zsb + "\">weiter</a>");
    }

    con.close();
%>

</body>
</html>
    
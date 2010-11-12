<!--JSP-Import-Files-->
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
    Statement stmt;
    ResultSet resultSet;
    stmt = con.createStatement();
    String user = request.getRemoteUser();

    String art = request.getParameter("art");

    //######---Zuschnitt-Schnittbild-Update---#####
    if (art.equals("zsb")) {
        long zsb = new Long(request.getParameter("zsb")).longValue();
        int anl_jahr = new Integer(request.getParameter("anl_jahr")).intValue();
        String ausl_dat_tag = "00";
        String ausl_dat_monat = "00";
        String ausl_dat_jahr = "0000";
        ausl_dat_tag = request.getParameter("ausl_dat_tag");
        ausl_dat_monat = request.getParameter("ausl_dat_monat");
        ausl_dat_jahr = request.getParameter("ausl_dat_jahr");
        int material = new Integer(request.getParameter("material")).intValue();
        String pfad = request.getParameter("pfad");
        String regel = request.getParameter("regel");
        String mdl = request.getParameter("mdl");
        String auslaufdatum = ausl_dat_jahr + "-" + ausl_dat_monat + "-" + ausl_dat_tag;
        String datString = "";

        if (auslaufdatum.equals("0000-00-00")) {
            datString = "NULL";
        } else {
            datString = "TO_DATE('" + auslaufdatum + "','YYYY-MM-DD')";
        }

        sql = "UPDATE PLRV11.ZUS_SCHNITTBILD SET SB_AUSL_DAT=" + datString + ",SB_CUTTER_SB=" + material + ",SB_PFAD='" + pfad + "',";
        sql += "SB_REGEL='" + regel + "',SB_MLD='" + mdl + "',SB_USER_ID='" + user + "',SB_AEND_DAT=SYSDATE WHERE SB_ID=" + zsb;

        try {
            out.println(sql);
            stmt.executeQuery(sql);
            out.println("Update des ZSB erfolgreich eingetragen!");
            out.println("<br><br><a href=\"./details.jsp?art=zsb&zsb_id=" + zsb + "\">zur&uuml;ck</a>");

        } catch (SQLException e) {
            out.println("Fehler beim Updaten des ZSB-Datensatzes:&nbsp;" + e + "<p>");
        }
    }

    //######---Haken-Update---#####
    else if (art.equals("haken")) {
        //long zsb         = new Long(request.getParameter("zsb")).longValue();
        long hakenID = new Long(request.getParameter("hkk_id")).longValue();
        int anl_jahr = new Integer(request.getParameter("anl_jahr")).intValue();
        String hakenMat = request.getParameter("hkk_material");
        String hakenBez = request.getParameter("hkk_bez");
        int hakenProg = new Integer(request.getParameter("hkk_prog")).intValue();
        String kommentar = request.getParameter("hkk_kommentar");

        sql = "UPDATE PLRV11.ZUS_HAKEN_KOPF SET HKK_BEZ='" + hakenBez + "',HKK_PROG=" + hakenProg + ",";
        sql += " HKK_KOMMENTAR='" + kommentar + "',HKK_USER_ID='" + user + "',HKK_AEND_DAT=SYSDATE WHERE HKK_ID=" + hakenID + " AND HKK_MAT_KZ='" + hakenMat + "'";

        try {
            //out.println(sql);
            stmt.executeQuery(sql);
            out.println("Update des Hakens erfolgreich eingetragen!");
            out.println("<br><br><a href=\"./details.jsp?art=haken&hkkid=" + hakenID + "&matKz=" + hakenMat + "\">zur&uuml;ck</a>");

        } catch (SQLException e) {
            out.println("Fehler beim Updaten des Haken-Datensatzes:&nbsp;" + e + "<p>");
        }
    }

    //######---Haken-Neueintrag---#####
    else if (art.equals("haken_spezial")) {
        long zsb = new Long(request.getParameter("zsb")).longValue();
        long hakenID = new Long(request.getParameter("hkk_id")).longValue();
        int anl_jahr = new Integer(request.getParameter("anl_jahr")).intValue();
        String hakenMat = request.getParameter("hkk_material");
        String hakenBez = request.getParameter("hkk_bez");
        int hakenProg = new Integer(request.getParameter("hkk_prog")).intValue();
        String kommentar = request.getParameter("hkk_kommentar");
        int error = 0;

        //sql = "INSERT INTO PLRV11.ZUS_HAKEN_KOPF (HKK_SB_ID,HKK_ANL_JAHR,HKK_MAT_KZ,HKK_ID,HKK_USER_ID,HKK_AEND_DAT,HKK_BEZ,HKK_PROG)"
        //       	   + " VALUES("
        //          + zsb
        //         + ","+anl_jahr
        //        + ",'"+hakenMat+"'"
        //	   + ","+hakenID
        //          + ",'"+user+"'"
        //         + ",Sysdate"
        //	   + ",'"+hakenBez+"'"
        //	   + ","+hakenProg
        //	   + ")";
        //try
        //{
        //   //out.println(sql);
        //   stmt.executeQuery(sql);
        //   out.println("Hakenkopfdaten erfolgreich eingetragen!<br>");
        //out.println("<br><br><a href=\"./details.jsp?art=haken&hkkid="+hakenID+"&sbID="+zsb+"&matKz="+hakenMat+"\">weiter</a>");
        //} catch(SQLException e) {
        //    out.println("Fehler beim Einf&uuml;gen des Datensatzes in Tabelle ZUS_HAKEN_KOPF:&nbsp;"+e+"<p>");
        //    error = 1;
        //  }
        if (error != 1) {
            //##### --Hier kommt der Eintrag in die Verknuepfungstabelle!!!
            sql = "INSERT INTO PLRV11.ZUS_VKN_HKK_ZSB (VKN_HKK_ID,VKN_HKK_MAT_KZ,VKN_SB_ID)"
                    + " VALUES("
                    + hakenID
                    + ",'" + hakenMat
                    + "'," + zsb
                    + ")";
            try {
                //out.println(sql);
                stmt.executeQuery(sql);
                out.println("<br>ZSB-Haken-Verknuepfung erfolgreich eingetragen!<br>");
                out.println("<br><br><a href=\"./details.jsp?art=zsb&zsb_id=" + zsb + "\">weiter</a>");

            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Verk&uuml;pfungs-Datensatzes:&nbsp;" + e + "<p>");
            }
        }

    }

    con.close();
%>

</body>
</html>
    
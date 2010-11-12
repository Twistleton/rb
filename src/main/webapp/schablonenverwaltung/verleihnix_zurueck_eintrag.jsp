<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#ddddff">

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();

    String[] haken = request.getParameterValues("haken");
    String pNr = request.getParameter("pNr");

    String hkdMatKz = "";
    String hkLfdNr = "";
    String hkId = "";
    String hkStandort = "";

    String sql = "";
    String sqlReserv = "";
    String sqlUpdate = "";
    String naechsterPlatz = "";
    long neueSaNr = 0;
    ResultSet resultSet;
    ResultSet rsReserv;

    Statement stmt;

    if (haken == null) {
        out.println("<br>Ein altes chinesisches Sprichwort sagt:");
        out.println("<i>'Wer einen Haken zur&uuml;ckgeben will, mu&szlig; zuerst einen Haken anhaken.'</i>");
        out.println("<br><br><a href=\"javascript:history.back()\">zur&uuml;ck</a>");
    }
    /*else{
           for (int i=0;i<haken.length;i++){
             StringTokenizer seperator = new StringTokenizer(haken[i],new String(";"));
             hkdId    = seperator.nextToken();
             hkdLfdNr = seperator.nextToken();
             hkdMatKz = seperator.nextToken();

             sql  = "UPDATE PLRV11.ZUS_HAKEN_DETAIL SET HKD_AKT_PLATZ=NULL,HKD_LEIH_DAT=NULL WHERE HKD_AKT_PLATZ="+pNr+" AND";
             sql += " HKD_MAT_KZ='"+hkdMatKz+"' AND HKD_LFD_NR="+hkdLfdNr+" AND HKD_ID="+hkdId;
             out.println(sql);

             stmt  = con.createStatement();

             try{
               stmt.executeQuery(sql);
               out.println("<br>Haken "+hkdId+" ist jetzt wieder da, wo er hingeh&ouml;rt.");

             } catch(SQLException e) {
                     out.println("Fehler beim Datenbank-Update:&nbsp;"+e+"<br>"+sql);
                   }
               }
           out.println("<br><br><a href=\"./index.html\" target=\"_top\">weiter</a>");
         }*/

    else {
        for (int i = 0; i < haken.length; i++) {
            StringTokenizer seperator = new StringTokenizer(haken[i], new String(";"));
            hkId = seperator.nextToken();
            hkLfdNr = seperator.nextToken();
            hkdMatKz = seperator.nextToken();
            hkStandort = seperator.nextToken();

            Statement stmtReserv = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            Statement stmtUpdate = con.createStatement();


            // Wird der Haken von einem anderen Mitarbeiter benoetigt?
            sqlReserv = "SELECT rkr_sanr,rkr_hkk_id,rkr_platz,rkr_status ";
            sqlReserv += "FROM plrv11.zus_hk_res ";
            sqlReserv += "WHERE rkr_hkk_Id=" + hkId;
            sqlReserv += " AND rkr_status=10 ";
            sqlReserv += " ORDER BY rkr_anlagedat";

            stmtReserv.executeQuery(sqlReserv);
            rsReserv = stmtReserv.getResultSet();
            int zaehler = 0;

            naechsterPlatz = "NULL";

            while (rsReserv.next() && (zaehler < 1)) {
                neueSaNr = rsReserv.getLong("rkr_sanr");
                naechsterPlatz = rsReserv.getString("rkr_platz");

                // Status der Reservierung auf 40 setzen
                rsReserv.updateInt("rkr_status", 40);
                rsReserv.updateRow();
                zaehler++;
            }
            rsReserv.close();

            // Haken-Details aktualisieren:ACHTUNG:HAKN MATERIAL FEST CODIERT;MUSS GEAENDERT WERDEN FALLS DAS AUCH FUER STOFF GILT
            // ##############################################################
            sqlUpdate = "UPDATE plrv11.zus_haken_detail SET ";
            sqlUpdate += "hkd_akt_platz=" + naechsterPlatz + " WHERE ";
            sqlUpdate += "hkd_id=" + hkId;
            sqlUpdate += " AND hkd_lfd_nr=" + hkLfdNr;
            sqlUpdate += " AND HKD_MAT_KZ='L'";

            stmtUpdate.executeUpdate(sqlUpdate);

            if (naechsterPlatz.compareTo("NULL") != 0) {
                // Bei den Kommissonshaken des evtl. gefundenen neuen Mitarbeiters Detail-Daten eintragen
                sqlUpdate = "UPDATE plrv11.zus_kom_hk ";
                sqlUpdate += "SET khk_lfd_nr  =" + hkLfdNr;
                sqlUpdate += ",   khk_standort=" + hkStandort;
                sqlUpdate += ",   khk_akt_pltz=" + naechsterPlatz;
                sqlUpdate += " WHERE khk_abnr IN ";
                sqlUpdate += " (SELECT kom_abnr FROM plrv11.zus_kommission ";
                sqlUpdate += " WHERE kom_sammel_abnr=" + neueSaNr + ")";
                sqlUpdate += " AND khk_hkk_id=" + hkId;

                out.println("<H2>Weitergabe des Hakens an Platz <b><font color=\"blue\"> " + naechsterPlatz + "</font></b></H2><BR>");
                stmtUpdate.executeUpdate(sqlUpdate);

            } else {
                out.println("Der Haken kommt jetzt wieder ins Lager.<BR>");
                //out.println("<br>"+sqlUpdate);
            }
        }
        out.println("<br><br><a href=\"./index.html\" target=\"_top\">weiter</a>");
    }

    con.close();
%>

</body>
</html>

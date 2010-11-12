<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Paket-Knacker</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000"
      vlink="#FF0000">
<CENTER>
    <h1><font color="#007FFF"> PAKETAUFTR&Auml;GE ZUM UMPLANEN</font></h1>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        String sAbNrn = new String();
        String zeile = new String();
        Statement stmt = con.createStatement();
        ResultSet rs;

        boolean i = false;    //Anzahl Datensätze > 1
        boolean g1 = false;    //Anzahl Auftäge/Paket > 1
        int altPNr = 0;    //Person zum 1. Paketauftrag
        int altProg = 0;    //Programm zum 1. Paketauftrag
        long altPlatz = 0;    //alter PFR-Platz zum 1. Paketauftrag

        try { // Auswahl eines Paketes (zum Knacken) über "OK" und UPDATE
            if (request.getParameter("paket") != null) {
                out.println("Paket mit: " + request.getParameter("paket") + " ausgew&auml;hlt und freigesetzt<BR>");
                sql = "UPDATE plrv11.bde_ab_fs_ma set abf_pf_platz='           ' where ";
                sql += "abf_pf_platz='" + request.getParameter("platz") + "' AND ";
                sql += "abf_pnr=" + request.getParameter("pnr") + " AND abf_prog=" + request.getParameter("prog");
                // out.println(sql+"<BR>");
                stmt.executeUpdate(sql);
                con.commit();
            }
        }
        catch (Exception ex) {
            out.println(ex.getMessage() + "<BR>");
        }

        try { // Anzeige aller zugewiesenen Paket-Aufträge
            out.println("<TABLE BORDER=\"1\">");
            out.println("<TR BGCOLOR=\"#ffdddd\"><TH>ABNR</TH><TH>Puffer</TH><TH>PROG</TH><TH>FS_STATUS</TH><TH>Person</TH>");
            out.println("<TH>Trennen</TH></TR>");

            sql = " SELECT abf_abnr, abf_pf_platz, abf_prog, abf_fs_status, abf_pnr FROM plrv11.bde_ab_fs_ma ";
            sql += " WHERE substr(abf_pf_platz,1,1)<>' ' and abf_fs_status between 5 and 30 ";
            sql += " ORDER BY abf_pf_platz,abf_pnr,abf_prog";
            // out.println(sql);
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                if (altPNr == rs.getInt("abf_pnr") && altProg == rs.getInt("abf_prog") &&
                        altPlatz == Long.parseLong(rs.getString("abf_pf_platz"))) { //2. bzw. 3. Auftrag/Paket
                    sAbNrn += rs.getString("abf_abnr") + "<BR>";
                    zeile = "<TR> <TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + sAbNrn;
                    zeile += "</TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"#007FFF\">" + rs.getString("abf_pf_platz");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_prog");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_fs_status");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_pnr");
                    zeile += "</TD><FORM NAME=\"knacken\" METHOD=\"POST\"><TD>";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"paket\" VALUE=\"" + rs.getString("abf_abnr") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"platz\" VALUE=\"" + rs.getString("abf_pf_platz") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"pnr\"   VALUE=\"" + rs.getString("abf_pnr") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"prog\"  VALUE=\"" + rs.getString("abf_prog") + "\">";
                    zeile += "<INPUT TYPE=\"submit\" NAME=\"knacken\" VALUE=\"OK\"></FORM></TD></TR>";
                    g1 = true; //Paket erkannt
                } else { //neues Paket
                    if (g1) {
                        out.println(zeile); //Ausgabe Paketzeile > 1 Auftrag
                        zeile = "";
                        g1 = false;
                    } else {
                        if (i) {
                            out.println(zeile); //Ausgabe Paketzeile = 1 Auftrag
                            zeile = "";
                        }
                    }
                    //Init mit 1.ABNR zum Paket
                    sAbNrn = rs.getString("abf_abnr") + "<BR>";
                    zeile = "<TR> <TD ALIGN=\"RIGHT\">" + sAbNrn;
                    zeile += "</TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"#007FFF\">" + rs.getString("abf_pf_platz");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_prog");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_fs_status");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("abf_pnr");
                    zeile += "</TD><FORM NAME=\"knacken\" METHOD=\"POST\"><TD>";
                    //Übergabe an Formular .. Parameter
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"paket\" VALUE=\"" + rs.getString("abf_abnr") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"platz\" VALUE=\"" + rs.getString("abf_pf_platz") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"pnr\"   VALUE=\"" + rs.getString("abf_pnr") + "\">";
                    zeile += "<INPUT TYPE=\"hidden\" NAME=\"prog\"  VALUE=\"" + rs.getString("abf_prog") + "\">";
                    zeile += "<INPUT TYPE=\"submit\" NAME=\"knacken\" VALUE=\"OK\"></FORM></TD></TR>";
                }
                //alte Daten zum Vergleich festhalten
                altPNr = rs.getInt("abf_pnr");
                try {
                    altPlatz = Long.parseLong(rs.getString("abf_pf_platz"));
                }
                catch (Exception ex) {
                    altPlatz = -1;
                }
                altProg = rs.getInt("abf_prog");
                //Datensatzzähler
                i = true; //1. Datensatz verarbeitet
            }
            if (zeile != "") { //letzte Zeile ausgeben
                out.println(zeile);
            }
            out.println("</TABLE>");

        }
        catch (Exception e) {
            out.println("Rausgeflogen " + e.getMessage());
        }
        con.close();
    %>
</CENTER>
</body>
</html>

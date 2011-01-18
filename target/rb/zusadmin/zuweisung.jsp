<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <title>Zuweisung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        boolean trace_on = false;            // Anzeigen der Zwischenschritte

        String sql = new String();
        String verfahren = new String();
        long sANr = 0;
        int team = 0;
        int pNr = 0;
        int i = 0;

        Connection con = oraBde.getConnection();
        Statement stmt = con.createStatement();
        ResultSet rs;

        if (trace_on == true) {
            out.println("Übergabe-Parameter verfahren: " + request.getParameter("verfahren"));
            out.println("Übergabe-Parameter team     : " + request.getParameter("team"));
            out.println("Übergabe-Parameter pNr      : " + request.getParameter("pNr"));
            out.println("Übergabe-Parameter sANr     : " + request.getParameter("sANr"));
        }

        if (request.getParameter("sANr") != null) {
            try {
                sANr = Long.parseLong(request.getParameter("sANr"));
                try {
                    pNr = Integer.parseInt(request.getParameter("pNr"));
                }
                catch (NumberFormatException nfe) {
                    pNr = 0;
                }

                try {
                    team = Integer.parseInt(request.getParameter("team"));
                }
                catch (NumberFormatException nfe) {

                    team = 0;
                }

                try {
                    verfahren = request.getParameter("verfahren");

                }
                catch (Exception ex) {

                    verfahren = "";
                }

                if (verfahren == null) {
                    verfahren = "";
                }

                if (trace_on == true) {
                    out.println("<hr>");
                    out.println("<br>Übergabe-Parameter verfahren: " + verfahren);
                    out.println("<br>Übergabe-Parameter team     : " + team);
                    out.println("<br>Übergabe-Parameter pNr      : " + pNr);
                    out.println("<br>Übergabe-Parameter sANr     : " + sANr);
                }
                if (verfahren.equals("CUTTER")) {
                    sql = "SELECT COUNT(*) FROM plrv11.bde_madat WHERE ma_kst=244 AND ma_pnr=" + team;

                    // Team 1 ist "kein Team" - daher Team -1
                    if (team == 1) {
                        team--;
                    }
                    pNr = team;
                } else {
                    sql = "SELECT COUNT(*) FROM plrv11.bde_madat WHERE ma_kst=244 AND ma_team_kz='N' AND ma_pnr=" + pNr;
                }

                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    i = rs.getInt(1);
                }
                if ((i == 1) || (pNr == 0)) {
                    sql = " UPDATE plrv11.zus_sammel_kopf ";
                    if (pNr != 0) {
                        sql += " SET sak_pnr=" + pNr;
                    } else {
                        sql += " SET sak_pnr=NULL";
                    }
                    sql += " WHERE sak_sanr=" + sANr;
                    // out.println(sql+"<BR>");
                    stmt.executeUpdate(sql);
                    out.println("<B>Zuweisung erfolgreich</B>");
                } else {
                    out.println("<FONT COLOR=\"red\"><BR>Es wurde ein ung&uuml;ltiger Mitarbeiter eingetragen</FONT></B><BR>");
                }

            }
            catch (Exception e) {
                out.println("<CENTER><FONT COLOR=\"red\">Fehlerhafte Eingabe!<BR>");
                out.println(e + "</FONT></CENTER>");
            }
        } else {
            out.println("Ung&uuml;ltige Sammel-Auftragsnummer");
        }
        con.close();
    %>
    <FORM ACTION="zusPuffer.jsp" METHOD="GET">
        <INPUT TYPE="submit" NAME="weiter" value="weiter");
    </FORM>
</CENTER>
</body>
</html>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>Puffermeldung Zuschnitt</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.gestAnmeld.abNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();
    Connection con = oraBde.getConnection();
    con.setAutoCommit(false);
    Statement stmt = con.createStatement();
    ResultSet rs;
    String ausgabe = new String();
    String sql = new String();
    String sqlUpdate = new String();

    int abNr = 0;
    int anzPW = 0;
    long pfPlatz = 0;
    long pfFS = 0;
    long pfNr = 0;
    int pfZone = 0;
    int aendIx = 0;

    java.util.Date datum = new java.util.Date();

    out.println("<CENTER><h1>Gestell Anmeldung</h1><BR>");
    out.println("<TABLE BORDER=1>");
    out.println("<FORM ACTION=\"gestellAnmeldung.jsp\" NAME=\"gestAnmeld\" METHOD=\"POST\">");
    out.println("<TR><TD ALIGN=\"CENTER\" >Auftrags-Nr</TD><TD ALIGN=\"CENTER\">Anzahl Polsterwagen</TD><TD>&nbsp;</TD></TR>");
    out.println("<TR><TD ALIGN=\"CENTER\"><INPUT TYPE=\"text\"   NAME=\"abNr\"  SIZE=\"8\" MAXLENGTH=\"6\"></TD>");
    out.println("<TD ALIGN=\"CENTER\">    <INPUT TYPE=\"text\"   NAME=\"anzPW\" SIZE=\"3\" MAXLENGTH=\"1\" VALUE=\"1\"></TD>");
    out.println("<TD ALIGN=\"CENTER\">    <INPUT TYPE=\"submit\" NAME=\"ok\"    VALUE=\"OK\"></TD>");
    out.println("</TR>");
    out.println("<TR><TD COLSPAN=\"3\" ALIGN=\"CENTER\">");
    if ((request.getParameter("abNr") != null) &&
            (request.getParameter("anzPW") != null)) {
        try {
            abNr = Integer.parseInt(request.getParameter("abNr").trim());
            anzPW = Integer.parseInt(request.getParameter("anzPW").trim());

            // Nachschauen in VOPO-Puffer
            sql = "SELECT pp_pf_platz,pp_pfnr,pp_pfzone,pp_abnr,pp_ab2,pp_ab3 ";
            sql += " FROM plrv11.bde_pufpl ";
            sql += " WHERE (pp_abnr =" + abNr;
            sql += " OR    pp_ab2=" + abNr;
            sql += " OR    pp_ab3=" + abNr;
            sql += " ) AND pp_pfnr='10144200' AND  pp_kz='J'";

            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                pfPlatz = rs.getLong("pp_pf_platz");
            }
            rs.close();
            ausgabe += "<span style=\"font-size:2000%; color:#0000FF;\" >";
            if (pfPlatz != 0) {
                ausgabe += String.valueOf(pfPlatz).substring(7, 9);

                sql = "SELECT as_aend_ix ";
                sql += "FROM plrv11.plr_auftr_status ";
                sql += "WHERE as_abnr=" + abNr;
                sql += " AND as_status<>99";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    aendIx = rs.getInt("as_aend_ix");
                }
                rs.close();
                sqlUpdate = "UPDATE plrv11.plr_auftr_kopf ";
                sqlUpdate += "SET ako_anz_powa=" + anzPW;
                sqlUpdate += " WHERE ako_abnr=" + abNr;
                sqlUpdate += " AND ako_aend_ix=" + aendIx;

                try {
                    stmt.executeUpdate(sqlUpdate);
                }
                catch (SQLException sqlex) {
                    out.println("Fehler:" + sqlex.getMessage());
                }
            } else {
                ausgabe += "N.g.";
            }
            ausgabe += "</span>";
            ausgabe += "<BR><span style=\"font-size:50px; color:#0000FF;\" >";
            ausgabe += abNr + "</SPAN>";
            con.commit();
        }
        catch (Exception ex) {
            out.println(ex.getMessage());
            ex.printStackTrace();
            ausgabe = " Keine Eingabe erfolgt";
            con.rollback();
        }
    }
    out.println(ausgabe + "</TD></TR></FORM></TABLE></CENTER>");

%>
</body>
</html>

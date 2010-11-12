<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <title>Lieferant/Charge Ändern</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.liefCharg.sammelAbNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    String sql = new String();
    String sqlUpdate = new String();
    String lkk = new String();

    int puffer = 0;
    long sANr = 0;
    long artNr = 0;
    long chargNr = 0;
    long platzNr = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    if ((request.getParameter("sANr") != null)) {
        try {
            sANr = Long.parseLong(request.getParameter("sANr"));
            sql = "SELECT sak_artnr,sak_charg_nr,sak_lief_kkz,sak_platz";
            sql += " FROM plrv11.zus_sammel_kopf ";
            sql += " WHERE sak_sanr=" + sANr;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                artNr = rs.getLong("sak_artnr");
                chargNr = rs.getLong("sak_charg_nr");
                lkk = rs.getString("sak_lief_kkz");
                platzNr = rs.getLong("sak_platz");
            }
            out.println("<CENTER><B>Lieferant/Charge &auml;ndern</B><BR>");
            out.println("<TABLE BORDER=1>");
            out.println("<FORM ACTION=\"liefChargeAus.jsp\" NAME=\"liefCharg\" METHOD=\"POST\">");
            out.println("<TR><TD>Sammel-Auftrag  </TD><TD ALIGN=\"right\">");
            out.println(sANr + "<INPUT TYPE=\"hidden\" NAME=\"sANr\" VALUE=\"" + sANr + "\"></TD></TR>");
            out.println("<TR><TD>Pufferplatz     </TD><TD ALIGN=\"right\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"platzNrPre\" VALUE=\"" + String.valueOf(platzNr).substring(0, 8) + "\">");
            out.println("<INPUT TYPE=\"text\" NAME=\"platzNr\" VALUE=\"" + String.valueOf(platzNr).substring(8) + "\" SIZE=\"3\" MAXLENGTH=\"3\"></TD></TR>");
            out.println("<TR><TD>Lieferant       </TD><TD ALIGN=\"right\">");
            out.println("<INPUT TYPE=\"text\" NAME=\"lkk\" SIZE=\"4\"   MAXLENGTH=\"4\" VALUE=\"" + lkk + "\"></TD></TR>");
            out.println("<TR><TD>Charge          </TD><TD ALIGN=\"right\">");
            out.println("<INPUT TYPE=\"text\" NAME=\"chargNr\" SIZE=\"10\"  MAXLENGTH=\"10\" VALUE=\"" + chargNr + "\"></TD></TR>");
            out.println("<TR><TD>&nbsp;          </TD><TD ALIGN=\"right\">");
            out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
            out.println("</FORM></TABLE></CENTER>");
        }
        catch (Exception e) {
            out.println(e);
            out.println("<CENTER><B><FONT COLOR=\"red\">Fehlerhafte Eingabe ist nicht vollstaendig</FONT></B></CENTER><BR>");
        }
    }
    con.close();
%>
</body>
</html>

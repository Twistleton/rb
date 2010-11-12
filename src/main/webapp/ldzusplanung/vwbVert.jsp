<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Zuschnitt-Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.rueckForm.komArtAbNr.focus()"
">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String wert = new String();
    int abNr = 0;
    long artNr = 0;

    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    if (request.getParameter("komArtAbNr") != null) {
        try {
            abNr = Integer.parseInt(request.getParameter("komArtAbNr").substring(1, 10));
            artNr = Long.parseLong(request.getParameter("komArtAbNr").substring(10, 16));
            sql = "UPDATE plrv11.zus_kommission SET kom_kom_kz='N',kom_status=0,kom_tagesmenge_dat=NULL,";
            sql += "kom_rest_kz='N',kom_reserv_kz='N' WHERE ";
            sql += "kom_abnr=" + abNr;
            sql += " AND kom_art_nr=" + artNr;

            stmt.executeUpdate(sql);
            out.println("<CENTER><FONT COLOR=\"green\">Daten verarbeitet<br>" + sql + "</FONT></CENTER>");
        }
        catch (Exception e) {
            out.println("<CENTER><FONT COLOR=\"red\">");
            out.println("Fehlerhafte Eingabe!<BR>Änderung nicht durchgef&uuml;hrt!<BR>" +
                    e.getMessage() + "</FONT></CENTER>");
        }
    }
    sql = "select kom_werk_zuschn,kom_werk_zuschn from plrv11.zus_kommission WHERE kom_werk_zuschn>10 GROUP BY kom_werk_zuschn";
    out.println("<CENTER><B>Bereitstell-Listen für verlängerte Werkbank</B><BR>");
    out.println("<TABLE BORDER=1>");
    out.println("<FORM ACTION=\"vwbListeDruck.jsp\" NAME=\"vwbDruckForm\" METHOD=\"POST\">");
    out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Werk</TH><TH>Zuschnitt-Tag</TH><TH>&nbsp</TH></TR>");
    out.println("<TR><TD>");
    out.println(oraBde.getHtmlSelect("werk", sql, ""));
    out.println("</TD><TD>");
    out.println("<INPUT TYPE=\"text\" NAME=\"zusTag\" SIZE=\"5\" MAXLENGTH=\\4\">");
    out.println("</TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
    out.println("</FORM></TABLE></CENTER>");
    con.close();

%>
</body>
</html>

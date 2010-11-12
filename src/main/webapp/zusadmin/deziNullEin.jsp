<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Dezi auf Null Setzen</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.formular.komNr.focus()">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        Connection con = oraBde.getConnection();
        Statement stmt = con.createStatement();

        String komNrFs = new String();
        String sql = new String();

        int abNr = 0;
        int updates = 0;

        long artNr = 0;
        long fs = 0;
        int melden = 0;

        try {
            komNrFs = request.getParameter("komNr");
            artNr = Long.parseLong(komNrFs.substring(0, 10));
            abNr = Integer.parseInt(komNrFs.substring(10, 16));
        }
        catch (Exception e) {
            abNr = 0;
            artNr = 0;
        }

        if ((abNr != 0) || (artNr != 0)) {
            // Kommission Null setzen
            sql = "UPDATE plrv11.zus_kom_fs SET kfs_dezi=0";
            sql += " WHERE kfs_abnr =" + abNr;
            sql += " AND   kfs_artnr=" + artNr;
            sql += " AND   kfs_fs   ='10244100000'";
            sql += " AND   kfs_fs_status<40";
            // out.println(sql+"<BR>");
            updates = stmt.executeUpdate(sql);
            if (updates > 0) {
                out.println("<B>Dezi der Kommission " + artNr + abNr + " wurden auf Null gesetzt</B><BR>");
            } else {
                out.println("<FONT COLOR=\"red\"><B>Es wurde keine Gueltige Kommission gefunden</B></FONT><BR>");
            }
        }

        out.println("<B>Dezi auf Null setzen f&uuml;r Kommission</B><BR>");
        out.println("<TABLE BORDER=1>");
        out.println("<FORM NAME=\"formular\" ACTION=\"deziNullEin.jsp\" METHOD=\"POST\">");
        out.println("<TR><TD>Kommissions-Nr</TD><TD ALIGN=\"right\">");
        out.println("<INPUT TYPE=\"hidden\"   NAME=\"melden\" VALUE=\"1\">");
        out.println("<INPUT TYPE=\"TEXT\"    NAME=\"komNr\"  SIZE=\"16\" MAXLENGTH=\"16\"></TD></TR>");
        out.println("<TR><TD COLSPAN=2 ALIGN=\"CENTER\">");
        out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
        out.println("</FORM>");
        out.println("</TABLE>");
    %>
</CENTER>
</body>
</html>

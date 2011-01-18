<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Statusmeldung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.komForm.komNr.focus()">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        out.println("<B>Statusmeldung Cutter</B><BR>");
        out.println("<TABLE BORDER=1>");
        out.println("<FORM NAME=\"komForm\" ACTION=\"cutStatus.jsp\" METHOD=\"POST\">");
        out.println("<TR><TD>Kommissions-Nr</TD><TD ALIGN=\"right\">");
        out.println("<INPUT TYPE=\"TEXT\"    NAME=\"komNr\" SIZE=\"16\" MAXLENGTH=\"16\"></TD></TR>");
        out.println("<TR><TD COLSPAN=2 ALIGN=\"CENTER\">");
        out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
        out.println("</FORM>");
        out.println("</TABLE>");
    %>
</CENTER>
</body>
</html>

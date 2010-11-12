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
      onLoad="document.pufMeld.sammelAbNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    String sqlUpdate = new String();
    String lkk = new String();

    int puffer = 0;
    long sANr = 0;
    long artNr = 0;
    long chargNr = 0;
    long platzNr = 0;
    int anz = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    if ((request.getParameter("sANr") != null) &&
            (request.getParameter("chargNr") != null) &&
            (request.getParameter("lkk") != null) &&
            (request.getParameter("platzNr") != null) &&
            (request.getParameter("platzNrPre") != null)) {
        try {
            sANr = Long.parseLong(request.getParameter("sANr"));
            chargNr = Long.parseLong(request.getParameter("chargNr"));
            lkk = request.getParameter("lkk");
            platzNr = Long.parseLong(request.getParameter("platzNrPre") + request.getParameter("platzNr"));
            sqlUpdate = "UPDATE plrv11.zus_sammel_kopf ";
            sqlUpdate += "SET sak_lief_kkz='" + lkk;
            sqlUpdate += "',sak_charg_nr=" + chargNr;
            sqlUpdate += ",sak_platz=" + platzNr;
            sqlUpdate += " WHERE sak_sanr=" + sANr;
            // out.println(sqlUpdate+"<BR>");
            anz = stmt.executeUpdate(sqlUpdate);
            out.println("Es wurden " + anz + " Datens&auml;tze ver&auml;ndert");
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

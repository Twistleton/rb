<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Dezi-Melden</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.deziForm.komNrFs.focus()">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt = con.createStatement();
        ResultSet rs;

        String sql = new String();
        String komNrFs = new String();

        int maRech = 0;


        sql = "SELECT ma_pnr,ma_pin,ma_recht FROM plrv11.bde_madat WHERE ma_pnr=" + pNr;
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        while (rs.next()) {
            maRecht = rs.getInt("ma_recht");
        }
        rs.close();
        if (maRecht > 40) {
            out.println("<A HREF=\"\">Anzeige Puffer</A>");
        }


    %>
</CENTER>
</BODY>
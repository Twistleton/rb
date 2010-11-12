<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Umplanung Zuschnitt</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();

        String sql = new String();
        int pNr = 0;
        long sANr = 0;

        Connection con = oraBde.getConnection();
        Statement stmt = con.createStatement();
        ResultSet rs;
        if ((request.getParameter("pNr") != null) &&
                (request.getParameter("sANr") != null)) {
            try {
                int updates = 0;
                pNr = Integer.parseInt(request.getParameter("pNr"));
                sANr = Long.parseLong(request.getParameter("sANr"));
                sql = "UPDATE plrv11.zus_kom_fs SET kfs_pnr=" + pNr;
                sql += " WHERE kfs_fs_status<40 AND kfs_abnr IN ";
                sql += "(SELECT kom_sammel_abnr FROM plrv11.zus_kommission where kom_sammel_abnr=" + sANr + ")";
                updates = stmt.executeUpdate(sql);
                if (updates != 0) {
                    out.println("Umplanung erfolgt<BR>");
                } else {
                    out.println("<TABLE><TR BGCOLOR=\"red\"><TD>Umplanung fehlgeschlagen!</TD></TR>");
                    out.println("<TR><TD>Keine relevanten Mitarbeiter gefunden</TD></TR></TABLE>");
                }
            }
            catch (Exception e) {
                out.println("<TABLE><TR BGCOLOR=\"red\"><TD>Fehlgeschlagen!</TD></TR>");
                out.println("<TR><TD>" + e.getMessage() + "</TD></TR>");
                out.println("<TR><TD>" + sql + "</TD></TR></TABLE>");
            }
        }
        con.close();
    %>

</CENTER>
</body>
</html>

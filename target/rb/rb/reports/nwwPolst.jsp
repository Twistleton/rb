<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>
<html>
<head>
    <title>Auswertung</title>
    <link rel=stylesheet type="text/css" href="../zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER><H1>Nettowarenwert Polsterei</H1>
    <%
        String confDatei = "/etc/zusJsp.conf";
        out.println("<H2>Aktueller Tag</H2>");
        out.println(nwwStatistik.tabelleFuellen(confDatei, 0, 0, "html"));
        String rueck = new String();
        zusConfigDatei zcd = new zusConfigDatei(confDatei);
        zcd.verarbeiten();
        try {
            bdeDb oraBde = new bdeDb(confDatei);
            Connection con = oraBde.getConnection();
            DecimalFormat df = new DecimalFormat("#######0.00");
            con.setAutoCommit(false);
            Statement stmt = con.createStatement();
            ResultSet rs;
            String sql = new String();
            out.println("<H2>Historie</H2><TABLE BORDER=1>");
            sql = "SELECT TO_CHAR(nww_dat,'DD.MM.YYYY'),nww_fabt,nww_se,nww_nww FROM plrv11.plr_stat_nww ORDER BY nww_dat DESC";
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            out.println("<TR><TH>Datum</TH><TH>Fabt</TH><TH>SE</TH><TH>NettoWW</TH></TR>\n");

            while (rs.next()) {
                out.println("<TR><TD>" + rs.getString(1));
                out.println("</TD><TD>" + rs.getString("nww_fabt"));
                out.println("</TD><TD>" + rs.getString("nww_se"));
                out.println("</TD><TD align=\"right\">" + df.format(rs.getFloat("nww_nww")));
                out.println("</TD></TR>\n");
            }
            out.println("</TR>");
        }
        catch (Exception e) {

        }


    %>
</CENTER>
</body>
</html>

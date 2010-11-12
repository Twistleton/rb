<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Einarbeitsliste</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        String sql = new String();
        Statement stmt = con.createStatement();
        ResultSet rs;
        int i = 0;

        try {
            sql = " SELECT ma_pnr,ma_vname,ma_nname,ma_kst FROM plrv11.bde_madat WHERE ";
            sql += " ma_pnr=" + request.getParameter("pNr");
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                out.println("<H2>Einarbeitsliste f&uuml;r " + rs.getString("ma_nname").trim() + ",");
                out.println(rs.getString("ma_vname").trim() + "</H2>");
            }
            sql = " SELECT map_pnr,map_prog,map_fs FROM plrv11.bde_ma_prog WHERE ";
            sql += " map_pnr=" + request.getParameter("pNr");
            sql += " ORDER BY map_fs,map_prog";
            // out.println(sql);
            out.println("<TABLE BORDER=\"1\">");
            out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Programm</TH><TH>Fertigungsstufe</TH></TR>");
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                out.println("<TR><TD ALIGN=\"RIGHT\">" + rs.getString("map_prog"));
                out.println("</TD><TD ALIGN=\"RIGHT\">" + rs.getString("map_fs"));
                out.println("</TD></TR>");
            }

            out.println("</TABLE>");
        }
        catch (Exception e) {
        }

        con.close();
    %>
</CENTER>
</body>
</html>

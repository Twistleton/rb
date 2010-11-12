<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Vector" %>

<html>
<head>
    <title>Einarbeit</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%

        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();

        Connection con = oraBde.getConnection();

        String sql = new String();
        String sqlMa = new String();
        Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        Statement stmtMa = con.createStatement();
        ResultSet rs;
        ResultSet rsMa;
        int anzDs = 0;
        sql = "select count(*) from plrv11.bde_ma_prog WHERE map_fs='10243100000'";
        rs = stmt.executeQuery(sql);
        while (rs.next()) {
            anzDs = rs.getInt(1);
        }

        sql = "select map_prog from plrv11.bde_ma_prog WHERE map_fs='10243100000' group by map_prog order by map_prog";
        rs = stmt.executeQuery(sql);
        int lauf = 0;
        out.println("<TABLE BORDER=\"1\"><TR><TD><TABLE BORDER=1>");
        while (rs.next()) {

            out.println("<TR><TD>" + rbTextFormat.format('0', 3, rs.getString("map_prog")) + "</TD><TD>");
            sqlMa = "SELECT ma_nname,ma_vname ";
            sqlMa += "FROM plrv11.bde_madat INNER JOIN plrv11.bde_ma_prog ON ma_pnr=map_pnr ";
            sqlMa += "WHERE map_fs='10243100000' ";
            sqlMa += "AND map_prog=" + rs.getString("map_prog");
            sqlMa += " ORDER BY ma_nname";
            rsMa = stmtMa.executeQuery(sqlMa);
            while (rsMa.next()) {
                out.println(rsMa.getString("ma_nname") + "," + rsMa.getString("ma_vname") + ";");
                lauf++;

            }
            out.println("</TD></TR>");

            if (lauf >= ((anzDs / 1))) {
                out.println("</TABLE></TD><TD><TABLE BORDER=1>");
                lauf = 0;
            }

        }
        out.println("</TABLE></TD></TR></TABLE>");
        stmt.close();
        con.close();

    %>
</CENTER>
</body>
</html>


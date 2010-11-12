<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>R&uuml;ckmeldung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.rueckForm.komArtAbNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String user = new String();
    int abNr = 0;
    int i = 0;
    long sANr = 0;

    Connection con = oraBde.getConnection();
    con.setAutoCommit(false);
    Statement stmt = con.createStatement();
    ResultSet rs;

    if (request.getParameter("abNr") != null) {
        try {
            user = request.getRemoteUser();
            abNr = Integer.parseInt(request.getParameter("abNr"));

            sql = "SELECT kom_ab_gedruckt,kom_sammel_abnr FROM plrv11.zus_kommission ";
            sql += " WHERE kom_abnr=" + abNr;

            rs = stmt.executeQuery(sql);
            i = 0;
            while (rs.next()) {
                if (rs.getString("kom_ab_gedruckt").compareTo("J") == 0) {
                    i++;
                }
                sANr = rs.getLong("kom_sammel_abnr");
            }
            out.println("<B>Angemeldeter Benutzer:" + user + "</B><BR>");
            if ((i == 0) || (user.compareTo("admin") == 0) || (user.compareTo("u98c") == 0)) {

                out.println("<H2>Auftrag l&ouml;schen " + abNr + "</H2><BR>");

                sql = "DELETE FROM plrv11.zus_kommission WHERE kom_abnr=" + abNr;
                i = stmt.executeUpdate(sql);
                out.println(i + " Kommissionen gel&ouml;scht<BR>");

                // Handelt es sich um eine Reservierung oder einen Rest

                sql = "DELETE FROM plrv11.zus_kom_hk WHERE ";
                sql += "khk_abnr=" + abNr;
                i = stmt.executeUpdate(sql);
                out.println(i + " Kommissions-Haken gel&ouml;scht<BR>");

                sql = "DELETE FROM plrv11.zus_kom_fs WHERE ";
                sql += "kfs_abnr=" + abNr;
                i = stmt.executeUpdate(sql);
                out.println(i + " Kommissions-FS gel&ouml;scht<BR>");


                sql = "SELECT COUNT(*) FROM plrv11.zus_kommission";
                sql += " WHERE kom_sammel_abnr=" + sANr;
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    i = rs.getInt(1);
                }
                if (i == 0) {
                    sql = "DELETE FROM plrv11.zus_sammel_kopf WHERE sak_sanr=" + sANr;
                    stmt.executeUpdate(sql);
                    out.println("Zugehöriger Sammel-Auftrag wurde gelöscht<BR>");
                    sql = "DELETE FROM plrv11.zus_sammel_hk WHERE shk_sanr=" + sANr;
                    stmt.executeUpdate(sql);
                    out.println("Zugehörige Sammel-Auftrags-Haken wurden gelöscht<BR>");
                }


                // Wenn es sich um einen Rest/eine Reservierung handelt....
                sql = "UPDATE plrv11.zus_rest_reserv SET ";
                sql += "res_status=0 WHERE ";
                sql += "res_abnr=" + abNr;
                out.println(stmt.executeUpdate(sql) + " Reservierungen auf Status 0 gesetzt<BR>");

                con.commit();
            } else {
                out.println("Dieser Auftrag wird nicht gel&ouml;scht, weil die Auftragspapiere schon gedruckt wurden");
            }
        }
        catch (Exception e) {
            out.println("<CENTER><FONT COLOR=\"red\">Fehlerhafte Eingabe!<BR>");
            out.println(e + "</FONT></CENTER>");
            con.rollback();
        }
    }
    con.close();

%>
</body>
</html>

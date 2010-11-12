<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Team-Verwaltung</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String wert = new String();
    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    String team = new String();
    String maPNr = new String();
    try {
        if (request.getParameter("team") != null) {
            team = request.getParameter("team");
        } else {
            team = "1";
        }
    }
    catch (NullPointerException npe) {
        team = "";
    }

    if (request.getParameter("modus") != null) {
        try {
            if (request.getParameter("maPNr") != null) {
                maPNr = request.getParameter("maPNr");

                if (request.getParameter("modus").compareTo("ausTeam") == 0) {
                    try {
                        sql = "UPDATE plrv11.bde_madat SET ma_team=1";
                        sql += " WHERE ma_pnr=" + maPNr;
                        stmt.executeUpdate(sql);
                    }
                    catch (Exception e) {
                        out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
                    }
                }
                if (request.getParameter("modus").compareTo("zuTeam") == 0) {
                    try {
                        sql = "UPDATE plrv11.bde_madat SET ma_team=" + team;
                        sql += " WHERE ma_pnr=" + maPNr;
                        stmt.executeUpdate(sql);
                    }
                    catch (Exception e) {
                        out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
                    }
                }
                if (request.getParameter("modus").compareTo("prod") == 0) {
                    try {
                        sql = "UPDATE plrv11.bde_madat SET ma_prod='" + request.getParameter("prod");
                        sql += "' WHERE ma_pnr=" + maPNr;
                        stmt.executeUpdate(sql);
                    }
                    catch (Exception e) {
                        out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
                    }
                }
            }
        }
        catch (NullPointerException npe) {
            team = "";
        }
    }
    out.println("<CENTER><H2>Verwaltung der Team-Zugeh&ouml;rigkeit</H2><HR>");
    out.println("<TABLE><TR><TD>Team</TD><TD><FORM ACTION=\"teamVerw.jsp\" METHOD=\"POST\" NAME=\"tabwahl\">");

    sql = "SELECT ma_nname,ma_pnr FROM plrv11.bde_madat WHERE ma_team_kz='J' ORDER BY ma_nname";
    out.println(oraBde.getHtmlSelectAllgS("team", sql, team));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.print("</FORM></TD></TR></TABLE><HR>");

    sql = "SELECT ma_pnr,ma_nname,ma_vname,ma_prod FROM plrv11.bde_madat WHERE ma_pnr>1 AND ma_team=" + team + "ORDER BY ma_nname,ma_vname";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    if (team.compareTo("1") != 0) {
        out.println("<TABLE BORDER=1>");
        out.println("<TR BGCOLOR=\"#ddddff\"><TD ALIGN=CENTER>Personal-Nr</TD><TD ALIGN=CENTER>Vorname</TD><TD ALIGN=CENTER>Nachname</TD>");
        out.println("<TD>&nbsp;</TD><TD>&nbsp;</TD></TR>");
    }

    while ((rs.next()) && (team.compareTo("1") != 0)) {
        out.println("<FORM ACTION=\"teamVerw.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"team\"  VALUE=\"" + team + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"ausTeam\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"maPNr\" VALUE=\"" + rs.getString("ma_pnr") + "\">");
        if (rs.getString("ma_prod").compareTo("N") == 0) {
            out.println("<TR BGCOLOR=\"#ffdddd\">");
        } else {
            out.println("<TR BGCOLOR=\"#ddffdd\">");
        }
        out.println("<TD>" + rs.getString("ma_pnr") + "</TD><TD>" + rs.getString("ma_vname").trim());
        out.println("</TD><TD>" + rs.getString("ma_nname").trim() + "</TD>");
        out.println("</TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Aus Team entfernen\"></TD></FORM>\n");
        out.println("<TD><FORM ACTION=\"teamVerw.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"prod\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"team\"  VALUE=\"" + team + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"maPNr\"  VALUE=\"" + rs.getString("ma_pnr") + "\">");
        if (rs.getString("ma_prod").compareTo("N") == 0) {
            out.println("<INPUT TYPE=\"hidden\" NAME=\"prod\"  VALUE=\"J\">");
            out.println("<INPUT TYPE=\"submit\" NAME=\"ok\"    VALUE=\"Aktivieren.\">");
        } else {
            out.println("<INPUT TYPE=\"hidden\" NAME=\"prod\"  VALUE=\"N\">");
            out.println("<INPUT TYPE=\"submit\" NAME=\"ok\"    VALUE=\"Inaktivieren\">");
        }
        out.println("</FORM></TD></TR>");

    }
    if (team.compareTo("1") != 0) {
        out.println("<FORM ACTION=\"teamVerw.jsp\" METHOD=\"POST\" NAME=\"neu\">");
        out.println("<TABLE BORDER=1><TR><TD COLSPAN=5 BGCOLOR=\"#ddddff\" ALIGN=\"CENTER\">Neues Team Mitglied</TD></TR>");
        out.println("<TR><TD>");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"zuTeam\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"team\"  VALUE=\"" + team + "\">");
        sql = "SELECT CONCAT(ma_pnr,CONCAT(' ',ma_nname)),ma_pnr FROM plrv11.bde_madat ";
        sql += "INNER JOIN plrv11.bde_apdat on ma_ap=ap_platznr ";
        sql += "WHERE ap_fs='10244100000' AND ma_team_kz='N' AND ma_team<>" + team + " ORDER BY ma_pnr";
        out.println(oraBde.getHtmlSelectAllgS("maPNr", sql, ""));
        out.println("</TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Zu Team hinzuf&uuml;gen\"></TD></TR>");
        out.println("</TABLE></FORM></CENTER>");
    }
    con.close();

%>
</body>
</html>

<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Pflege von Text-Attributen</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER><H2>Pflege vom Text-Attributen</H2>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        String sql = new String();
        String wert = new String();
        float wertFl = 0;
        String tatWert = new String();
        int admin = 0;

        Connection con = oraBde.getConnection();
        Statement stmt = con.createStatement();
        ResultSet rs;

        try {
            if (request.getParameter("admin").compareTo("1") == 0) {
                admin = 1;
            }
        }
        catch (Exception e) {
            admin = 0;
        }
        if (request.getParameter("modus") != null) {
            if (request.getParameter("modus").compareTo("update") == 0) {
                try {
                    sql = "UPDATE plrv11.zus_textAttr SET tat_beschr='";
                    sql += request.getParameter("tatBeschr") + "', tat_wert='";
                    sql += request.getParameter("tatWert") + "' ";
                    sql += " WHERE tat_nr=" + request.getParameter("tatNr");
                    stmt.executeUpdate(sql);
                }
                catch (Exception e) {
                    out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT><BR>");
                    out.println(e.getMessage() + "<BR>" + sql);
                }
            }

            if (request.getParameter("modus").compareTo("einfuegen") == 0) {
                try {
                    sql = "INSERT INTO plrv11.zus_textAttr (tat_nr,tat_grp,tat_beschr,tat_wert) VALUES (";
                    sql += Integer.parseInt(request.getParameter("tatNr")) + ",";
                    sql += Integer.parseInt(request.getParameter("tatGrp")) + ",'";
                    sql += request.getParameter("tatBeschr") + "','";
                    sql += request.getParameter("tatWert") + "')";
                    stmt.executeUpdate(sql);
                }
                catch (Exception e) {
                    out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT><BR>");
                    out.println(e.getMessage());
                    out.println("<BR>" + sql);
                }
            }
            if (request.getParameter("modus").compareTo("loeschen") == 0) {
                try {
                    sql = "DELETE FROM plrv11.zus_textAttr WHERE tat_nr=";
                    sql += Integer.parseInt(request.getParameter("tatNr"));
                    stmt.executeUpdate(sql);
                }
                catch (Exception e) {
                    out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT><BR>");
                    out.println(e.getMessage());
                }

            }
        }

        int tatNr = 0;
        int tatGrp = 0;
        try {
            if (request.getParameter("tatGrp") != null) {
                tatGrp = Integer.parseInt(request.getParameter("tatGrp"));
            } else {
                tatGrp = 1;
            }
        }
        catch (NullPointerException npe) {
            tatGrp = 1;
        }

        if (admin == 1) {
            out.println("Werte-Gruppe");
            out.println("<FORM ACTION=\"textAttribute.jsp\" METHOD=\"POST\" NAME=\"grpwahl\">");
            sql = "select tat_grp,tat_grp from plrv11.zus_textAttr group by tat_grp  ORDER BY 1";
            out.println(oraBde.getHtmlSelectAllgS("tatGrp", sql, String.valueOf(tatGrp)));
            out.println("<INPUT TYPE=\"hidden\" NAME=\"admin\" VALUE=\"" + admin + "\">");
            out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
            out.print("</FORM><HR>");

            sql = "SELECT max(tat_nr) FROM plrv11.zus_textAttr";
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                tatNr = rs.getInt(1);
            }
            tatNr++;

            out.println("<FORM ACTION=\"textAttribute.jsp\" METHOD=\"POST\" NAME=\"neu\">");
            out.println("<TABLE BORDER=1><TR><TD COLSPAN=65 BGCOLOR=\"#ffdddd\" ALIGN=\"CENTER\">Neuer Eintrag</TD></TR>");
            out.println("<TR BGCOLOR=#ffdddd><TD>Attribut-Nr</TD><TD>Gruppe</TD>");
            out.println("<TD>Beschreibung</TD><TD>Wert</TD><TD>&nbsp;</TD></TR>");
            out.println("<TR><TD><INPUT TYPE=\"hidden\"     NAME=\"modus\"      VALUE=\"einfuegen\">");
            out.println("<INPUT TYPE=\"TEXT\"   NAME=\"tatNr\"      VALUE=\"" + tatNr + "\" SIZE=8 MAXLENGTH=8></TD>");
            out.println("<TD><INPUT TYPE=\"TEXT\"   NAME=\"tatGrp\"     VALUE=\"" + tatGrp + "\" SIZE=5 MAXLENGTH=5></TD>");
            out.println("<TD><INPUT TYPE=\"TEXT\"   NAME=\"tatBeschr\"  SIZE=20 MAXLENGTH=100></TD>");
            out.println("<TD><INPUT TYPE=\"TEXT\"   NAME=\"tatWert\"    SIZE=20 MAXLENGTH=300></TD>");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"admin\"    VALUE=\"" + admin + "\">");
            out.println("<TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Hinzuf&uuml;gen\"></TD></TR>");
            out.println("</TABLE></FORM>");
        }
        sql = "SELECT tat_nr,tat_grp,tat_beschr,tat_wert,tat_aktiv FROM plrv11.zus_textAttr WHERE tat_grp=" + tatGrp + " ORDER BY tat_beschr ";

        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        out.println("<TABLE BORDER=1>");
        out.println("<TR BGCOLOR=\"#ddddff\"><TD>Beschreibung</TD><TD>Wert</TD><TD COLSPAN=\"2\">&nbsp;</TD></TR>");

        while (rs.next()) {
            out.println("<FORM ACTION=\"textAttribute.jsp\" METHOD=\"POST\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\"      VALUE=\"update\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"tatNr\"      VALUE=\"" + rs.getString("tat_nr") + "\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"tatGrp\"     VALUE=\"" + rs.getString("tat_grp") + "\">");
            out.println("<TR><TD>");
            if (admin == 1) {
                out.println("<INPUT TYPE=\"TEXT\"   NAME=\"tatBeschr\"");
                out.println(" VALUE=\"" + rs.getString("tat_beschr") + "\" SIZE=20 MAXLENGTH=100>");
            } else {
                out.println("<INPUT TYPE=\"hidden\" NAME=\"tatBeschr\"");
                out.println(" VALUE=\"" + rs.getString("tat_beschr") + "\">");
                out.println(rs.getString("tat_beschr"));
            }
            out.println("</TD>");
            if (rs.getString("tat_wert") == null) {
                tatWert = "";
            } else {
                tatWert = rs.getString("tat_wert");
            }
            out.println("<TD><INPUT TYPE=\"TEXT\"   NAME=\"tatWert\"    VALUE=\"" + tatWert + "\"   SIZE=20 MAXLENGTH=300></TD>");
            out.println("<TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"&Auml;ndern\"></TD>");
            if (admin == 1) {
                out.println("<TD></FORM>");
                out.println("<FORM ACTION=\"textAttribute.jsp\" METHOD=\"POST\" NAME=\"loesch\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"loeschen\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"tatNr\"   VALUE=\"" + rs.getString("tat_nr") + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"tatGrp\"  VALUE=\"" + rs.getString("tat_grp") + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"admin\"  VALUE=\"" + admin + "\">");
                out.println("<INPUT TYPE=\"SUBMIT\"  NAME=\"weg\"    VALUE=\"L&ouml;schen\">");
                out.println("</TD>");
            }
            out.println("</TR>");
            out.println("</FORM>");
        }

        con.close();

    %>
</CENTER>
</body>
</html>

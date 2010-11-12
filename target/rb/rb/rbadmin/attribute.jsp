<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Pflege von Attributen</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.neu.attrNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

    String sql = new String();
    String wert = new String();
    float wertFl = 0;

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    if (request.getParameter("modus") != null) {
        if (request.getParameter("modus").compareTo("update") == 0) {
            try {
                sql = "UPDATE plrv11.plr_attrAttr SET att_bez='";
                sql += request.getParameter("bez") + "'";
                if (request.getParameter("kennz") != null) {
                    sql += ",att_kennz=1";
                } else {
                    sql += ",att_kennz=0";
                }
                if (request.getParameter("aktiv") != null) {
                    sql += ",att_aktiv=1";
                } else {
                    sql += ",att_aktiv=0";
                }
                sql += " WHERE att_tabname='" + request.getParameter("tabName") + "' AND att_attr=" + request.getParameter("attrNr");
                stmt.executeUpdate(sql);
            }
            catch (Exception e) {
                out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
            }

        }
        if (request.getParameter("modus").compareTo("einfuegen") == 0) {
            try {
                sql = "INSERT INTO plrv11.plr_attrAttr (att_tabname,att_attr,att_bez,att_kennz,att_aktiv) VALUES ('";
                sql += request.getParameter("tabName") + "',";
                sql += request.getParameter("attrNr") + ",'";
                sql += request.getParameter("bez") + "',";
                if (request.getParameter("kennz") != null) {
                    sql += "1,";
                } else {
                    sql += "0,";
                }
                if (request.getParameter("aktiv") != null) {
                    sql += "1)";
                } else {
                    sql += "0)";
                }
                stmt.executeUpdate(sql);
            }
            catch (Exception e) {
                out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
            }

        }
        if (request.getParameter("modus").compareTo("loeschen") == 0) {
            try {
                sql = "DELETE FROM plrv11.plr_attrAttr WHERE att_tabName='" + request.getParameter("tabName") + "' AND att_attr=";
                sql += request.getParameter("attrNr");
                stmt.executeUpdate(sql);
            }
            catch (Exception e) {
                out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
            }

        }
    }


    String tabName = new String();
    try {
        if (request.getParameter("tabName") != null) {
            tabName = "WHERE att_tabname='" + request.getParameter("tabName") + "'";
        } else {
            tabName = "";
        }
    }
    catch (NullPointerException npe) {
        tabName = "";
    }

    out.println("<FORM ACTION=\"attribute.jsp\" METHOD=\"POST\" NAME=\"tabwahl\">");
    String tabSelect = new String();
    try {
        if (request.getParameter("tabName") != null) {
            tabSelect = request.getParameter("tabName");
        } else {
            tabSelect = "";
        }
    }
    catch (NullPointerException npe) {
        tabSelect = "";
    }

    out.println(oraBde.getHtmlSelectAllgS("tabName", "select att_tabname,att_tabname from plrv11.plr_attrAttr group by att_tabname  ORDER BY 1", tabSelect));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.print("</FORM><HR>");


    out.println("<FORM ACTION=\"attribute.jsp\" METHOD=\"POST\" NAME=\"neu\">");
    out.println("<TABLE BORDER=1><TR><TD COLSPAN=5 BGCOLOR=\"#ffdddd\" ALIGN=\"CENTER\">Neuer Eintrag</TD></TR>");
    out.println("<TR><TD><INPUT TYPE=\"text\" NAME=\"tabName\" VALUE=\"" + request.getParameter("tabName") + "\" SIZE=\"15\" MAXLENGTH=\"15\"></TD>");
    out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"einfuegen\">");
    out.println("<TD><INPUT TYPE=\"text\" NAME=\"attrNr\" SIZE=\"5\" MAXLENGTH=\"15\"></TD>");
    out.println("<TD><INPUT TYPE=\"text\" NAME=\"bez\"    SIZE=\"50\" MAXLENGTH=\"100\"></TD>");
    out.println("<TD><INPUT TYPE=\"checkbox\" NAME=\"kennz\" VALUE=\"1\"></TD>");
    out.println("<TD><INPUT TYPE=\"checkbox\" NAME=\"aktiv\" VALUE=\"1\"></TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
    out.println("</TABLE></FORM>");
    out.println("</TABLE>");

    sql = "SELECT att_tabname,att_attr,att_bez,att_kennz,att_aktiv FROM plrv11.plr_attrAttr " + tabName + " ORDER BY att_attr ";

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\"><TD>TabName</TD><TD>Attr-Nr</TD><TD>Attr-Bez</TD><TD>Kennz</TD><TD>Aktiv</TD></TR>");
    while (rs.next()) {
        out.println("<FORM ACTION=\"attribute.jsp\" METHOD=\"POST\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\"  VALUE=\"update\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"tabName\"VALUE=\"" + rs.getString("att_tabname") + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"attrNr\"VALUE=\"" + rs.getString("att_attr") + "\">");
        out.println("<TR><TD>" + rs.getString("att_tabname") + "</TD>");
        out.println("<TD>" + rs.getString("att_attr") + "</TD>");
        out.println("<TD><INPUT TYPE=\"text\" NAME=\"bez\"  SIZE=50 MAXLENGTH=100 VALUE=\"" + rs.getString("att_bez") + "\"></TD>");
        out.println("<TD><INPUT TYPE=\"checkbox\" NAME=\"kennz\" VALUE=\"1\"");
        if (rs.getInt("att_kennz") == 1) {
            out.println(" CHECKED ");
        }
        out.println("></TD>");

        out.println("<TD><INPUT TYPE=\"checkbox\" NAME=\"aktiv\" VALUE=\"1\" ");
        if (rs.getInt("att_aktiv") == 1) {
            out.println(" CHECKED ");
        }
        out.println("></TD>");
        out.println("<TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"&Auml;ndern\"></TD><TD></FORM>");
        out.println("<FORM ACTION=\"attribute.jsp\" METHOD=\"POST\" NAME=\"loesch\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"modus\" VALUE=\"loeschen\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"tabName\" VALUE=\"" + rs.getString("att_tabName") + "\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"attrNr\"  VALUE=\"" + rs.getString("att_attr") + "\">");
        out.println("<INPUT TYPE=\"SUBMIT\"  NAME=\"weg\"     VALUE=\"L&ouml;schen\">");

        out.println("</TD></TR>");
        out.println("</FORM>");

    }
    con.close();

%>
</body>
</html>

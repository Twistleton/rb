<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Zuschnitt-Navigation</title>
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

    if (request.getParameter("name") != null) {
        wert = request.getParameter("wert").replace(',', '.');
        try {
            wertFl = Float.valueOf(wert).floatValue();
            sql = "UPDATE plrv11.zus_param SET zup_wert=" + wertFl + " WHERE zup_name='" + request.getParameter("name") + "'";
            stmt.executeUpdate(sql);
        }
        catch (Exception e) {
            out.println("<FONT COLOR=red>Fehlerhafte Eingabe!<BR>Änderung nicht durchfeführt!</FONT>");
        }
    }


    sql = "SELECT zup_name,zup_wert,zup_komment FROM plrv11.zus_param ORDER BY zup_name";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\"><TD>Parameter-Name</TD><TD>Wert</TD><TD>Kommentar</TD><TD>&nbsp;</TD></TR>");

    while (rs.next()) {
        out.println("<FORM ACTION=\"stammdaten.jsp\" METHOD=\"POST\">");
        out.println("<TR><TD><INPUT TYPE=\"HIDDEN\" NAME=\"name\" VALUE=\"" + rs.getString("zup_name") + "\">" + rs.getString("zup_name"));
        out.println("</TD><TD><INPUT TYPE=\"text\" NAME=\"wert\" SIZE=15 MAXLENGTH=15 VALUE=\"" + rs.getString("zup_wert") + "\">");
        out.println("</TD><TD>" + rs.getString("zup_komment"));
        out.println("</TD><TD><INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"&Auml;ndern\"></TD></TR>");
        out.println("</FORM>");
    }
    out.println("</TABLE>");
    con.close();
%>
</body>
</html>

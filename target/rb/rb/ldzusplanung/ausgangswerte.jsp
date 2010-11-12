<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Ausgangswerte</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;
    Date datum = new Date();
    String sql = new String();
    zusParam zp = new zusParam(con);
    int aktFabt = 0;

    float optiFakt = zp.getWert("optiFakt");
    float zuschnFabtDiff = zp.getWert("zuschnFabtDiff");

    sql = "SELECT fab_fab_tag FROM plrv11.plr_fabkal_dat WHERE FAB_DATUM=TO_CHAR(CURRENT_DATE,'DDMMYY')";
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        aktFabt = rs.getInt("fab_fab_tag") + (int) zuschnFabtDiff;
    }
%>
<FORM METHOD="POST" ACTION="optiTagesmenge.jsp">
    <TABLE BORDER=1>
        <%
            int fabt2 = aktFabt + (int) zp.getWert("fabtAufschlag");
            out.println("<TR><TD>Zuschnitt-Fab-Tag 1</TD><TD><INPUT NAME=\"fabt1\" VALUE=\"" + aktFabt);
            out.println("\"  TYPE=\"text\" SIZE=\"4\" MAXLENGTH=\"4\"></TD></TR>");
            out.println("<TR><TD>Zuschnitt-Fab-Tag 2</TD><TD><INPUT NAME=\"fabt2\" VALUE=\"" + fabt2);
            out.println("\"  TYPE=\"text\" SIZE=\"4\" MAXLENGTH=\"4\"></TD></TR>");
            out.println("<TR><TD>Optimierungsfaktor   </TD><TD><INPUT NAME=\"optifakt\"");
            out.println("TYPE=\"text\" SIZE=\"4\" MAXLENGTH=\"4\" VALUE=\"" + optiFakt + "\"></TD></TR>");
        %>
        <TR>
            <TD><INPUT TYPE="SUBMIT" NAME="ok" VALUE="OK"></TD>
        </TR>
    </TABLE>
</FORM>
<TABLE BORDER=1>
    <TR BGCOLOR="#ddddff">
        <TD COLSPAN=3 ALIGN=CENTER><B>Stammdaten</B></TD>
    </TR>
    <TR BGCOLOR="#ddddff">
        <TD>Parameter-Name</TD>
        <TD>Wert</TD>
        <TD>Kommentar</TD>
    </TR>
    <%
        sql = "SELECT zup_name,zup_wert,zup_komment FROM plrv11.zus_param ORDER BY zup_name";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        while (rs.next()) {
            out.println("<TR><TD>" + rs.getString("zup_name"));
            out.println("</TD><TD>" + rs.getString("zup_wert"));
            out.println("</TD><TD>" + rs.getString("zup_komment"));
            out.println("</TD></TR>");
        }
    %>
</TABLE>
</body>
</html>
      

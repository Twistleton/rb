<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.rolfbenz.*" %>


<html>
<head>
    <title>Resteverwaltung Eingabe</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<FORM METHOD="POST" ACTION="resteZuordnung.jsp">
    <TABLE BORDER=1>
        <TR>
            <TD COLSPAN=2>Reste-Ausnutzung muss liegen zwischen...</TD>
        </TR>
        <%
            bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
            Connection con = oraBde.getConnection();
            zusParam zp = new zusParam(con);
            out.println("<TR><TD>minimal</TD><TD><INPUT NAME=\"mvMin\" TYPE=\"text\"");
            out.println(" SIZE=\"2\" MAXLENGTH=\"2\" VALUE=\"" + zp.getWert("restMin") + "\">Prozent</TD></TR>");
            out.println("<TR><TD>maximal</TD><TD><INPUT NAME=\"mvMax\" TYPE=\"text\"");
            out.println("SIZE=\"2\" MAXLENGTH=\"2\" VALUE=\"" + zp.getWert("restMax") + "\">Prozent</TD></TR>");
        %>
        <TR>
            <TD><INPUT TYPE="SUBMIT" NAME="ok" VALUE="OK"></TD>
        </TR>
    </TABLE>
</FORM>
</body>
</html>
      

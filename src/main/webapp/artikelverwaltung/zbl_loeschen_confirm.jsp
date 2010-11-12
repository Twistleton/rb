<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">
<table border="0" align="center">
    <tr>
        <td align="center">
            <font color="#ff0000">
                <b>
                    WARNUNG
                </b>
                <br>
            </font>
            <b>
                Sie sind dabei, folgenden ZBL-Eintrag endg&uuml;ltig zu l&ouml;schen:
            </b>
        </td>
    </tr>
</table>
<%
    String artnr = request.getParameter("artnr");
    String lief_kkz = request.getParameter("lief_kkz");
    String charge = request.getParameter("charge");

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr style=\"background-color:#d0d0d0;\"><td align=\"center\"><b>Leder-Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Lieferanten-Kurzkennzeichen</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td></tr>");
    out.println("<tr><td align=\"center\">" + artnr + "</td>");
    out.println("<td align=\"center\">" + lief_kkz + "</td>");
    out.println("<td align=\"center\">" + charge + "</td></tr>");
    out.println("</table>");
%>
<table border="0" align="center">
    <tr>
        <td align="center">&nbsp;</td>
    </tr>
    <tr>
        <td align="center"><b>
            <div title="F&uuml;r immer,ewig und alle Zeit l&ouml;schen">Endg&uuml;ltig l&ouml;schen??&nbsp;</div>
        </b></td>
    </tr>
    <tr>
        <td>
            <form action="./zbl_loeschen.jsp?artNr=<%=artnr%>&lief_kkz=<%=lief_kkz%>&charge=<%=charge%>" method="post">
        </td>
    </tr>
    <tr>
        <td>
            <input type="hidden" name="delete" value="1"></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="Ja aber sicher!"></input>
        </td>
    </tr>
    </form>
    <tr>
        <td>
            <form action="./zbl_loeschen.jsp?artNr=<%=artnr%>&lief_kkz=<%=lief_kkz%>&charge=<%=charge%>" method="post">
        </td>
    </tr>
    <tr>
        <td>
            <input type="hidden" name="delete" value="0"></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="Hab's mir anders &uuml;berlegt..."></input>
        </td>
    </tr>
    </form>
</table>
</body>
</html>
      
<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center">
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>
<%
    String artnr = request.getParameter("artnr");
    String art_lief_kkz = request.getParameter("lief_kkz");
    String art_charge = request.getParameter("charge");
    String newartnr1 = artnr.substring(0, 3);
    String newartnr2 = artnr.substring(3, 8);
    String newartnr3 = artnr.substring(8);

    out.println("<center><h2>ZBL bearbeiten</h2></center>");
    out.println("<form action=\"./zbl_update.jsp\" method=\"post\">");
    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");
    out.println("<tr style=\"background-color:#d0d0d0;\"><td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Lieferanten-Kurzkennzeichen</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<tr><td align=\"center\">");
    out.println("<input type=\"text\" name=\"leder\" size=\"3\" maxlength=\"3\" value=\"442\" readonly></input>");
    out.println("<input type=\"text\" name=\"ART_NR\" size=\"5\" maxlength=\"5\" value=\"" + newartnr2 + "\"></input>");
    out.println("<input type=\"text\" name=\"leder_end\" size=\"2\" maxlength=\"2\" value=\"00\" readonly></input></td>");
    out.println("<input type=\"hidden\" name=\"ART_NR_ORIG\"  value=\"" + artnr + "\"></input>");
    out.println("<input type=\"hidden\" name=\"ART_LIEF_KKZ_ORIG\"  value=\"" + art_lief_kkz + "\"></input>");
    out.println("<input type=\"hidden\" name=\"ART_CHARGE_ORIG\"  value=\"" + art_charge + "\"></input>");
    out.println("<td align=\"center\"><input type=\"text\" name=\"ART_LIEF_KKZ\" size=\"5\" maxlength=\"4\" value=\"" + art_lief_kkz + "\"</td>");
    out.println("<td align=\"center\"><input type=\"text\" name=\"ART_CHARGE\" size=\"5\" maxlength=\"5\" value=\"" + art_charge + "\"></td></tr></table>");
    out.println("<table border=\"0\" align=\"center\">");
    out.println("<tr><td align=\"center\"><input type=\"submit\" value=\"&Auml;nderung &uuml;bernehmen\"></input></td></tr></table></form>");
%>
</body>
</html>
      
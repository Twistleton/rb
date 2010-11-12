<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#ddddff">

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_test.conf");
    Connection con = oraBde.getConnection();

    String[] haken = request.getParameterValues("haken");
    String pNr = request.getParameter("pNr");

    String hkdMatKz = "";
    String hkdLfdNr = "";
    String hkdId = "";

    String sql = "";
    ResultSet resultSet;
    Statement stmt;

    if (haken == null) {
        out.println("<br>Ein altes chinesisches Sprichwort sagt:");
        out.println("<i>'Wer einen Haken ausleihen will, mu&szlig; zuerst einen Haken anhaken.'</i>");
        out.println("<br><br><a href=\"javascript:history.back()\">zur&uuml;ck</a>");
    } else if (pNr.equals("0") || pNr.equals("")) {
        out.println("<br>Eingabe der Personalnummer nicht vergessen!!");
        out.println("<br><br><a href=\"javascript:history.back()\">zur&uuml;ck</a>");
    } else {
        for (int i = 0; i < haken.length; i++) {
            StringTokenizer seperator = new StringTokenizer(haken[i], new String(";"));
            hkdId = seperator.nextToken();
            hkdLfdNr = seperator.nextToken();
            hkdMatKz = seperator.nextToken();

            sql = "UPDATE PLRV11.ZUS_HAKEN_DETAIL SET HKD_AKT_PLATZ=" + pNr + ",HKD_LEIH_DAT=SYSDATE WHERE";
            sql += " HKD_MAT_KZ='" + hkdMatKz + "' AND HKD_LFD_NR=" + hkdLfdNr + " AND HKD_ID=" + hkdId;
            //out.println(sql);

            stmt = con.createStatement();

            try {
                stmt.executeQuery(sql);
                out.println("<br>Haken " + hkdId + " ausgeliehen!");

            } catch (SQLException e) {
                out.println("Fehler beim Datenbank-Update:&nbsp;" + e + "<br>" + sql);
            }
        }
        out.println("<br><br><a href=\"./index.html\" target=\"_top\">weiter</a>");
    }

    con.close();
%>

</body>
</html>

<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<%
    String zsb = request.getParameter("zsb");
    String anlJahr = request.getParameter("anlJahr");
    String prog = request.getParameter("prog");
    Date datum = new Date();
    String date = datum + "";
    String jahr = date.substring(24, 28);
%>
<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FF0000" alink="#FF0000" vlink="#FF0000">

<form action="./anlegen.jsp?art=haken" method="post">
    <table border="0" align="center">
        <tr>
            <td>
                <b>Haken-Neueintrag:</b>
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <tr>
            <td align="center">Zuschnitt-SB</td>
            <td>
                <input type="text" name="zsb" size="6" maxlength="6" value=<%=zsb%> readonly></input>
            </td>
        </tr>

        <tr>
            <td align="center">Haken-ID</td>
            <td>
                <input type="text" name="hkk_id" size="8" maxlength="8"></input>
            </td>
        </tr>
        <tr>
            <td align="center">Material</td>
            <td>
                <select size="1" name="hkk_material">
                    <option value="L" selected>Leder</option>
                    <option value="S">Stoff</option>
                    <option value="Z">Leinen-Zuschnitt</option>
                </select>
            </td>
        </tr>
        <tr>
            <td align="center">Anlaufjahr</td>
            <td>
                <input type="text" name="anl_jahr" size="4" maxlength="4" value=<%=anlJahr%> readonly></input>
            </td>
        </tr>
        <tr>
            <td align="center">Bezeichnung</td>
            <td>
                <input type="text" name="hkk_bez" size="30" maxlength="50"</input>
            </td>
        </tr>
        <tr>
            <td align="center">Programm</td>
            <td>
                <input type="text" name="hkk_prog" size="3" maxlength="3" value=<%=prog%>></input>
            </td>
        </tr>
        <tr>
            <td align="center">Pufferplatz</td>
            <td>
                <input type="text" name="hkk_puf_pl1" size="8" maxlength="8" value="10244500" readonly></input>
                <input type="text" name="hkk_puf_pl2" size="3" maxlength="3" value="000"></input>
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <tr>
            <td>
                <input type="submit" value="Hinzuf&uuml;gen"></input>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
      
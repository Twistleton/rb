<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      OnLoad="document.form.ART_NR.focus();">

<form name="form" action="./zbl_anlegen.jsp" method="post">
    <table border="0" align="center">
        <tr>
            <td>
                <h2><b>ZBL-Neueintrag:</b></h2>
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <tr style="background-color:#d0d0d0;">
            <td align="left">Artikelnummer</td>
            <td>
                <input type="text" name="leder" size="3" maxlength="3" value="442" readonly></input>
                <input type="text" name="ART_NR" size="5" maxlength="5"></input>
                <input type="text" name="leder_end" size="2" maxlength="2" value="00" readonly></input>
            </td>
        </tr>
        <tr style="background-color:#d0d0d0;">
            <td align="left">Lieferanten-Kurzkennzeichen</td>
            <td><input type="text" name="ART_LIEF_KKZ" size="3" maxlength="3"></input>
            </td>
        </tr>
        <tr style="background-color:#d0d0d0;">
            <td align="left">Charge</td>
            <td><input type="text" name="ART_CHARGE" size="4" maxlength="4"></input>
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
      
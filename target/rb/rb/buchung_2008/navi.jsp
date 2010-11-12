<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <style type="text/css" media="screen">
        <!--
        body {
            font-size: 12px;
            font-family: "Arial", Arial, sans-serif;
            color: #000000;
        }

        -->
    </style>
    <title>
    </title>
</head>
<body OnLoad="document.form.auftr_bez_nr.focus();" bgcolor="#ddddFF">
<table border="0" align="center" cellspacing="1">
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <b>
                Einzelkommission:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Buchung"
                   onClick="parent.frames[1].location.href='./buchung_eingabe.jsp?mod=imez_kom'">
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Korrektur"
                   onClick="parent.frames[1].location.href='./buchung_eingabe.jsp?mod=imez_kom_korr'">
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Mehrverbrauch"
                   onClick="parent.frames[1].location.href='./buchung_eingabe.jsp?mod=lmez_kom'">
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <b>
                Sammelauftrag:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Buchung"
                   onClick="parent.frames[1].location.href='./buchung_eingabe.jsp?mod=imez_sammel'">
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Korrektur"
                   onClick="parent.frames[1].location.href='./buchung_eingabe.jsp?mod=imez_sammel_korr'">
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <form name="form" action="./praemienkz_setzen.jsp" method="post" target="main">
            <td align="center">
                <b>
                    Kennzeichen Pr&auml;mie:
                </b>
            </td>
    </tr>
    <tr>
        <td align="center">
            <input type="text" name="auftr_bez_nr" size="16" maxlength="16"></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="auf 'N' setzen">
            </input>
        </td>
        </form>
    </tr>
</table>
</body>
</html>
      


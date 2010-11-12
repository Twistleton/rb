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
<body bgcolor="#ddddFF" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center" cellspacing="1">
    <tr>
        <td align="center">
            <b>
                Neu anlegen:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Artikel" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anlegen_maske.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="ZBL" style="width:150px;"
                   onClick="parent.frames[2].location.href='./zbl_anlegen_maske.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Rohstoffe" style="width:150px;"
                   onClick="parent.frames[2].location.href='./bezmat_maske.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <b>
                Anzeigen:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Artikelliste" style="width:150px;"
                   onClick="self.location.href='./navi_browse.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="ZBL-Liste" style="width:150px;"
                   onClick="parent.frames[2].location.href='./zbl_anzeigen.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Rohstoffliste" style="width:150px;"
                   onClick="parent.frames[2].location.href='./bezmat_anzeigen.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Resteverwaltung" style="width:150px;"
                   onClick="parent.frames[2].location.href='./resteverw.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Reste-Liste" style="width:150px;"
                   onClick="parent.frames[2].location.href='./gleiche_reste.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Reservierungen" style="width:150px;"
                   onClick="parent.frames[2].location.href='./reservierungsverw.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="ZS Allgemein" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anzeige_allgemein.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="ZS Cutter" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anzeige_cutter.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="ZS Manuell" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anzeige_manuell.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <b>
                (Ent)Sperren:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Gesp. Programme" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anzeige_gesp_prog.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Programm sperren" style="width:150px;"
                   onClick="parent.frames[2].location.href='./prog_sperrmaske.jsp'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Gesperrte Artikel" style="width:150px;"
                   onClick="parent.frames[2].location.href='./anzeige_gesperrte.jsp'">
        </td>
    </tr>
</table>
</body>
</html>
      
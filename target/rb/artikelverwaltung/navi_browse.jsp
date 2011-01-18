<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>
    </title>
</head>
<body bgcolor="#ddddff" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center" cellspacing="1">
    <form action="./anzeigen.jsp" method="post" target="main">
        <tr>
            <td align="center">
                <input type="hidden" name="sent" value="1"></input>
                <input type="hidden" name="sel" value="j"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <b>
                    Artikelnummer:
                </b>
            </td>
        </tr>
        <tr>
            <td align="center">
                <%
                    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
                    Connection con = oraBde.getConnection();
                    out.println(oraBde.getHtmlSelectAllg("ART_NR", "SELECT ART_NR,ART_NR FROM PLRV11.PLR_ART_KOPF", " "));
                    con.close();
                %>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="submit" value="Details anzeigen"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <font size="-2">
                    <a href="./navi.jsp" target="_self">
                        Artikelliste ausblenden
                    </a>
                </font>
            </td>
        </tr>
    </form>
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
            <input type="button" name="Verweis" value="Reservierungen" style="width:150px;"
                   onClick="parent.frames[2].location.href='./reservierungsverw.jsp'">
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
      
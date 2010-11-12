<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<style type="text/css">
    p {
        margin-left: 12px;
    }
</style>
<P>
    <BR>
    <B>Allgemein</B><BR>
    <B>Stammdaten</B><BR>
    <A HREF="textAttribute.jsp?tatGrp=2" target="haupt">Buchungsmonat</A><BR>
    <br><B>&Uuml;bersicht</B><BR>
    <A HREF="../zusbemeldung/arbeitsVorrat.jsp" target="haupt">Arbeitsvorrat</A><BR>
    <A HREF="../zusbemeldung/arbeitsVorratKum.jsp" target="haupt">Arbeitsvorrat Kumuliert</A><BR>
    <A HREF="../zusbemeldung/inKommission.jsp" target="haupt">in Kommissionierung</A><BR>
    <A HREF="zusPuffer.jsp" target="haupt">Puffer-Übersicht</A><BR>
    <A HREF="inArbeit.jsp" target="haupt">In Arbeit</A><BR>
    <A HREF="imUmlauf.jsp" target="haupt">Im Umlauf</A><BR>
    <A HREF="unfertige.jsp" target="haupt">Unfertige</A><BR>
    <br><B>Dezi</B><BR>
    <A HREF="deziNullEin.jsp" target="haupt">Dezi auf Null setzen</A><BR>
    <A HREF="../zusbemeldung/zusDeziLogin.jsp" target="haupt">Dezi-Melden</A><BR>
    <br><B>Cutter</B><BR>
    <A HREF="../zusbemeldung/teamVerw.jsp" target="haupt">Team-Verwaltung</A><BR>
    <A HREF="../zusbemeldung/cutSelbstZuw.jsp" target="haupt">Selbstzuweisung</A><BR>
    <A HREF="../zusbemeldung/cutStatusEin.jsp" target="haupt">Cutter Statusmeldung</A><BR>
    <A HREF="cutTeamWechselEin.jsp" target="haupt">Team-Wechsel</A><BR>
    <br></P>

<P>

<FORM ACTION="../zusbemeldung/auftrInfo.jsp" METHOD="POST" TARGET="haupt"><P>
    <TABLE BORDER=1>
        <TR>
            <TH>Auftragsinfo</TH>
        </TR>
        <TR>
            <TD>
                <INPUT TYPE="text" NAME="abNr" SIZE="6" MAXLENGTH="6">
                <INPUT TYPE="submit" NAME="ok" VALUE="OK">
            </TD>
        </TR>
    </TABLE>
</FORM>
<br><B>Buchung</B><BR>
<A HREF="../buchung/" target="_SELF\">Buchung</A><BR>
</body>
</html>

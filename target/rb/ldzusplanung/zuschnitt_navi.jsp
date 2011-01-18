<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();
    long aktArtikel = 0;
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
%>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Zuschnitt-Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#0000FF" alink="#0000FF" vlink="#0000FF">
<A HREF="doppeltListe.jsp" target="haupt">Doppelte Auftr&auml;ge</A><BR>
<A HREF="../zusbemeldung/pufferVorrat.jsp" target="haupt">Puffer&uuml;bersicht</A><BR>
<A HREF="komBilden.jsp" target="haupt">Kom.-Anlegen</A><BR>
<A HREF="ausgangswerte.jsp" target="haupt">Optimierung Tagesmenge</A><BR><BR>
<A HREF="rueckSetz.jsp" target="haupt">Tagesmenge r&uuml;cksetzen</A><BR><BR>
<A HREF="resteEingabe.jsp" target="haupt">Reste Zuordnen</A><BR><BR>
<B>Bereitstellung</B><BR>
Reste<BR>
<%
    sql = "select kom_werk_zuschn from plrv11.zus_kommission GROUP BY kom_werk_zuschn ORDER BY kom_werk_zuschn";
    stmt.executeQuery(sql);
    ResultSet rs = stmt.getResultSet();
    while (rs.next()) {
        out.println("<A HREF=\"restListeDruck.jsp?werk=");
        out.println(rs.getString("kom_werk_zuschn") + "\" target=\"haupt\" >" + rs.getString("kom_werk_zuschn") + "</A>");
    }
%>
<BR>
Reserv.<BR>
<%
    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    while (rs.next()) {
        out.println("<A HREF=\"reservListeDruck.jsp?werk=");
        out.println(rs.getString("kom_werk_zuschn") + "\" target=\"haupt\">" + rs.getString("kom_werk_zuschn") + "</A>");
    }
%>
<BR>
<A HREF="sfListeDruck.jsp" target="haupt">Sonder-Fert.</A><BR>
<A HREF="LohnzuschnittListeDruck.jsp" target="haupt">Lohnzuschnitt</A><BR>
<A HREF="mfListeDruck.jsp" target="haupt">Metragen/Fahnen</A><BR>

<FORM NAME="farblichPassend" METHOD="POST" ACTION="fpListeDruck.jsp" target="haupt">
    <TABLE BORDER=1>
        <TR>
        <TR>
            <TH COLSPAN=2>Farblich passend</TH>
        </TR>
        <TR>
            <TD><INPUT TYPE="text" NAME="fabt" SIZE="4" MAXLENGTH="4"><INPUT TYPE="SUBMIT" NAME="ok" value="OK"></TD>
        </TR>
    </TABLE>
</FORM>
<A HREF="vwbVert.jsp" target="haupt">verl. Werkbank</A><BR>
<A HREF="zugabeListeDruck.jsp" target="haupt">Lederzugabe</A><BR><BR>

<A HREF="verteilungProdsys.jsp" target="haupt">Verteilung der Tagesmenge</A><BR><BR>
<A HREF="manListeDruck.jsp" target="haupt">Manuell Bereitstellen</A><BR>
<A HREF="cutListeDruck.jsp" target="haupt">Cutter Bereitstellen</A><BR>

<FORM NAME="gesperrt" METHOD="POST" ACTION="sperrAllgListeDruck.jsp" target="haupt">
    <TABLE BORDER=1>
        <TR>
        <TR>
            <TH COLSPAN=2>Gesperrte...</TH>
        </TR>
        <TR>
            <TD><SELECT NAME="sperr">
                <OPTION VALUE="prog">Prog
                <OPTION VALUE="art">Art
            </SELECT></TD>
            <TD><INPUT TYPE="text" NAME="fabt" SIZE="4" MAXLENGTH="4"><INPUT TYPE="SUBMIT" NAME="ok" value="OK"></TD>
        </TR>
    </TABLE>
</FORM>
<A HREF="rueckMeld.jsp" target="haupt">R&uuml;ckmeldung</A><BR><BR>
Stammdaten<BR>
<A HREF="stammdaten.jsp" target="haupt">Stammdatenpflege</A><BR><BR>
<A HREF="fehlendeBez.jsp" target="haupt">Fehlende Bez&uuml;ge</A><BR><BR>

<FORM NAME="auftrAbfrage" METHOD="POST" ACTION="../zusbemeldung/auftrInfo.jsp" target="haupt">
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
<A HREF="../zusbemeldung/arbeitsVorrat.jsp" target="haupt">Arbeitsvorrat</A><BR>
<A HREF="../zusbemeldung/arbeitsVorratKum.jsp" target="haupt">Arbeitsvorrat Kum.</A><BR>
<A HREF="../zusbemeldung/inKommission.jsp" target="haupt">In Kommissionierung</A><BR>
<%
    con.close();
%>
</body>
</html>

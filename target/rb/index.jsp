<html>
<title>rbsv0007 Server</title>
<style type="text/css">
    <!--
    body {
        color: #000000;
        background-color: #FFFFFF;
        font-family: monospace, Arial, "Times New Roman", Times;
        font-size: 16px;
        margin-left: 20px;
    }

    A:link {
        color: blue
    }

    A:visited {
        color: blue
    }

    title {
        font-family: monspace, Arial;
        margin-left: 100px;
    }

    td {
        color: #000000;
        font-family: monospace, Arial, "Times New Roman", Times;
        font-size: 16px;
    }

    p.right {

        margin-left: 90px;
    }

    p.ip {
        font-weight: bold;
        font-size: 12px;
        margin-right: 10px;
    }

    p.foot {
        color: red;
        margin-right: 10px;
        font-family: "Courier New", Courier;
        font-size: 16px;
    }

    -->
</style>
<body>
<object data="rbsv0007.jpg"
        width="100%" height="17%"
        type="image/jpg"
        title="Logo">Logo</object>
<p align="right" class="ip">Ihre IP-Adresse lautet: <%= request.getRemoteAddr() %>
</p>

<p class="right">

<h2>Willkommen auf dem rbsv0007 Server</h2>
Folgende Anwendungen stehen hier bereit<br>


<table border="1" width="98%" align="center">
    <thead>
    <tr>
        <th width="30%">Anwendung</th>
        <th width="70%">Beschreibung</th>
    </tr>
    </thead>
    <tbody>
      <tr>
        <td><a href="/bde/pufferMaske">Puffermaske</a></td>
        <td>Puffermaske</td>
    </tr>
      <tr>
        <td><a href="/bde/bde.html">BDE-Stammdaten</a></td>
        <td>BDE-Stammdatenverwaltung</td>
    </tr>
      <tr>
        <td><a href="/bde/bde?modul=nae&formular=deziLogin">Sondernaht/Einschlaufen</a></td>
        <td>Sondernaht/Einschlaufen</td>
    </tr>
    <tr>
        <td><a href="/rb/artikelverwaltung/index.html">Artikelverwaltung</a></td>
        <td>Artikelverwaltung</td>
    </tr>
    <tr>
        <td><a href="/rb/auftragsinfo/auftragsinfo.html">Auftragsinfo</a></td>
        <td>Auftragsinfo zur Kundenauftr&auml;gen</td>
    </tr>
    <tr>
        <td><a href="/rb/buchung/index.html">Buchung</a></td>
        <td>Lederbuchung</td>
    </tr>
    <tr>
        <td><a href="/rb/cps/CPSmelden.jsp">cps</a></td>
        <td>Auftragsanmeldung CPS</td>
    </tr>
    <tr>
        <td><a href="/rb/ef/EFmelden.jsp">ef</a></td>
        <td>Auftragsanmeldung EFP</td>
    </tr>
    <tr>
        <td><a href="/rb/hs/HSmelden.jsp">hs</a></td>
        <td>Auftragsanmeldung HS</td>
    </tr>
    <tr>
        <td><a href="/rb/ldzusplanung/zuschnitt.html">Lederzuschnitt</a></td>
        <td>Planung Lederzuschnitt</td>
    </tr>
    <tr>
        <td><a href="/rb/meldung/gestellAnmeldung.jsp">Gestellanmeldung</a></td>
        <td>Gestellanmeldung</td>
    </tr>
    <tr>
        <td><a href="/rb/naeherei/naeEin.jsp">Statusmeldung N&auml;herei</a></td>
        <td>Selbstzuweisung N&auml;herei</td>
    </tr>
    <tr>
        <td><a href="/rb/polsterei/polDeziLogin.jsp">Polsterei/Verpacken</a></td>
        <td>Polsterei/Verpacken</td>
    </tr>
    <tr>
        <td><a href="/rb/qm/index.jsp">QM Selbstzuweisung</a></td>
        <td>Selbstzuweisung Auftrag</td>
    </tr>
    <tr>
        <td><a href="/rb/qm/qmUebersicht.jsp">QM &Uuml;bersicht</a></td>
        <td>&Uuml;bersicht von Qualit&auml;tsdaten</td>
    </tr>
    <tr>
        <td><a href="/rb/qm/qmErfassung.jsp">QM Erfassung</a></td>
        <td>Erfassung von Qualit&auml;tsdaten</td>
    </tr>
    <tr>
        <td><a href="/rb/rbadmin/attribute.jsp">rbadmin</a></td>
        <td>rbadmin</td>
    </tr>
    <tr>
        <td><a href="/rb/reports/einarbeit.jsp">reports</a></td>
        <td>reports</td>
    </tr>
    <tr>
        <td><a href="/rb/schablonenverwaltung/index.html">schablonenverwaltung</a></td>
        <td>schablonenverwaltung</td>
    </tr>
    <tr>
        <td><a href="/rb/tools/paketKnacker1.jsp">Paketauftr&auml;ge auflösen</a></td>
        <td>Paketauftr&auml;ge aufl&ouml;sen</td>
    </tr>
    <tr>
        <td><a href="/rb/zusadmin/zusAdmin.html">zusadmin</a></td>
        <td>Administration Lederzuschnitt</td>
    </tr>
    <tr>
        <td><a href="/rb/zusbemeldung/cutSelbstZuw.jsp">zusbemeldung</a></td>
        <td>zusbemeldung</td>
    </tr>
    <tr>
        <td bgcolor="#87ceeb"><a href="http://applserv.rolf-benz.de/">applserv-Server</a></td>
        <td>bisheriger Anwendungsserver</td>
    </tr>
    <tr>
        <td bgcolor="#87ceeb"><a href="http://applserv2.huels-group.net:8080/">applserv2-Server</a></td>
        <td>applserv2-Server mit den Anwendungen Avisierung Veyhl, Auftragsinfo/Archiv</td>
    </tr>
    </tbody>
</table>
</p>
<p align="right" class="foot">
    Stand 15.11.2010
</p>
</body>
</html>

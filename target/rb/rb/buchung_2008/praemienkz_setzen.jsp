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

        a:link {
            text-decoration: none;
            font-weight: bold;
            color: #000000;
        }

        a:visited {
            text-decoration: none;
            font-weight: bold;
            color: #000000;
        }

        a:hover {
            text-decoration: none;
            font-weight: bold;
            background-color: #ffffff;
        }

        a:active {
            text-decoration: none;
            font-weight: bold;
            background-color: #ff0000;
        }

        -->
    </style>
    <title>
    </title>
</head>
<body OnLoad="document.form.submit.focus();" bgcolor="#ddddFF" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_testneu.conf");
    Connection con = oraBde.getConnection();

    String nummer = request.getParameter("auftr_bez_nr");

    //### eingescannte Kombinationsnummer aus Artikelnummer + Auftragsnummer trennen ###
    String artNr = "";
    String abNr = "";

    try {
        artNr = nummer.substring(0, 10);
        abNr = nummer.substring(10);
    } catch (Exception e) {
        out.println("<br>FEHLER bei der Eingabe!!<br>" + e);
    }
    String sql = "";
    int hatsfunktioniert = 0;
    Statement stmt;

    sql = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_KZ_PRAEMIE='N' WHERE KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;

    try {
        //out.println(sql);
        stmt = con.createStatement();
        hatsfunktioniert = stmt.executeUpdate(sql);

        if (hatsfunktioniert == 1) {
            out.println("<h2>Kennzeichen Pr&auml;mienentlohnung auf <font color=\"#ff0000\"><b>'N'</b></font> gesetzt!<h2>");
        } else {
            out.println("<font color=\"#ff0000\" size=\"+1\">Fehler beim Setzen des Pr&auml;mienkennzeichens!</font><br><br>");
            out.println("Der Datensatz mit<br><br>");
            out.println("Artikelnummer=<b>" + artNr + "</b><br>ABNr.=<b>" + abNr + "</b>");
            out.println("<br><br>existiert nicht.<br>");
        }
    } catch (SQLException e) {
        out.println("<br><br>Fehler beim Setzen des Pr&auml;mienkennzeichens!!<br>" + e + "<br>" + sql);
    }

    con.close();

%>
<br>

<form name="form" action="./index.html" target="_top" method="post" target="main">
    <input name="submit" type="submit" value="Weiter">
    </input>
</form>
<!--<font size="+1">
          <a href="./index.html" target="_top">
        <img src="./pfeil.gif" border="0">
        weiter
          </a>
        </font>-->
</body>
</html>
      


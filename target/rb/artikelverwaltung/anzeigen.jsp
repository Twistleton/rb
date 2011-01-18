<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center">
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    long artNr = 0;
    String artBez = "";
    String artSperrKz = "";
    String artLiefKkz = "";
    String artCutFhg = "";
    String artManZs = "";
    long azsArtNr = 0;
    int azsBezTyp = 0;
    String azsBezMat = "";
    int azsProzAntt = 0;
    String cutKennz = "";
    String cutkennz = "";
    String artnr;
    String artnr1 = "";
    String artnr2 = "";
    String artnr3 = "";
    String newartnr = "";
    String newartnr1 = "";
    String zuschnittsys = "";
    String zsArt = "";
    String cutterparameter = "";
    String digitparameter = "";
    String sel = request.getParameter("sel");

    //######---Wenn die Artikelnummer aus der Auswahlliste kommt:fuenfstellig---#####
    if (sel.equals("j")) {
        artnr = request.getParameter("ART_NR");
    }
    //#####---Kommt die Art.Nr. vom Eingabefeld: dreiteilige Eingabe->drei versch. Teilnummern---#####
    else {
        //artnr1 = request.getParameter("ART_NR1");
        artnr2 = request.getParameter("ART_NR2");
        int zahl = Integer.valueOf(artnr2).intValue();
        if (zahl >= 30000) {
            //out.println("Leder:"+zahl);
            artnr1 = "442";
        } else {
            //out.println("Stoff:"+zahl);
            artnr1 = "432";
        }
        //artnr3 = request.getParameter("ART_NR3");
        artnr3 = "00";
        artnr = artnr1 + artnr2 + artnr3;
        //out.println("<br>Artikelnummer:"+artnr);
    }
    String sent = request.getParameter("sent");

    if (sent != null)
        if (sent.equals("1")) {

            sql = "SELECT * FROM PLRV11.PLR_ART_KOPF  where ART_NR=" + artnr;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
            out.println("<colgroup><col width=\"210\"><col width=\"210\"></colgroup>");

            try {
                resultSet.next();

                artNr = resultSet.getLong("ART_NR");
                artBez = resultSet.getString("ART_BEZ");
                artSperrKz = resultSet.getString("ART_SPERR_KZ");
                artLiefKkz = resultSet.getString("ART_LIEF_KKZ");
                //artCutFhg   = resultSet.getString("ART_CUT_FHG");
                //artManZs    = resultSet.getString("ART_MAN_ZS");
                zuschnittsys = resultSet.getString("ART_ZS_SYS");
                cutterparameter = resultSet.getString("ART_CUT_PARM");
                digitparameter = resultSet.getString("ART_DIG_PARM");

                /*if (artManZs.equals("J")){
                  cutKennz = "Cutterf&auml;hig setzen";
                }
                else
                {
                  cutKennz = "Manuellen Zuschnitt setzen";
                }*/

                if (zuschnittsys.equals("10")) {
                    zsArt = "Cutter";
                } else if (zuschnittsys.equals("30")) {
                    zsArt = "Manuell";
                } else if (zuschnittsys.equals("20")) {
                    zsArt = "Cutter/Manuell";
                } else if (zuschnittsys.equals("11")) {
                    zsArt = "Lohnzuschnitt";
                }


                newartnr = "" + artNr;
                newartnr1 = artnr.substring(0, 3);
                String newartnr2 = artnr.substring(3, 8);
                String newartnr3 = artnr.substring(8);

                out.println("<tr><td>Artikelnummer</td><td align=\"center\">" + newartnr1 + "." + newartnr2 + "." + newartnr3 + "</td></tr>");
                out.println("<tr><td>Bezeichnung</td><td align=\"center\">");
                out.println("<a href=\"./bezedit.jsp?artnr=" + artNr + "\">" + artBez + "</a></td></tr>");

                if (artSperrKz.equals("N")) {
                    out.println("<tr><td>Gesperrt</td><td bgcolor=\"#00ff00\" align=\"center\">Nein</td></tr>");
                } else {
                    out.println("<tr><td>Gesperrt</td><td bgcolor=\"red\" align=\"center\">Ja</td></tr>");
                }

                /*if (artLiefKkz.equals(" ")) {
                  out.println("<tr><td>Lieferant</td><td align=\"center\">-</td></tr>");
                }
                else{
                  out.println("<tr><td>Lieferant</td><td align=\"center\">"+artLiefKkz+"</td></tr>");
                }*/
                out.println("<tr><td>Zuschnittsystem</td><td align=\"center\">" + zsArt + "</td></tr>");
                //out.println("<tr><td>Manueller Zuschnitt</td><td align=\"center\">"+artManZs+"</td></tr></table>");
                out.println("<tr><td>Cutterparameter</td><td align=\"center\">");
                out.println("<a href=\"./prmedit.jsp?artnr=" + artNr + "\">" + cutterparameter + "</a></td></tr>");
                out.println("<tr><td>Digitparameter</td><td align=\"center\">");
                out.println("<a href=\"./prmedit.jsp?artnr=" + artNr + "\">" + digitparameter + "</a></td></tr>");
                out.println("</table>");

            } catch (SQLException e) {
                out.println("Artikelnummer nicht gefunden!<br>");
                out.println(e);
            }

            sql = "SELECT * FROM PLRV11.PLR_ART_ZUSAM where AZS_ART_NR=" + artnr;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
            out.println("<colgroup><col width=\"140\"><col width=\"140\"><col width=\"140\"></colgroup>");
            out.println("<tr><td align=\"center\">Materialtyp</td><td align=\"center\">Bezeichnung</td>");
            out.println("<td align=\"center\">Anteil&nbsp;[%]</td></tr>");

            try {
                while (resultSet.next()) {

                    azsArtNr = resultSet.getLong("AZS_ART_NR");
                    azsBezTyp = resultSet.getInt("AZS_Bez_Typ");
                    azsBezMat = resultSet.getString("AZS_BEZ_MAT");
                    azsProzAntt = resultSet.getInt("AZS_PROZ_ANTT");

                    out.println("<tr><td align=\"center\">" + azsBezTyp + "</td>");
                    out.println("<td align=\"center\">" + azsBezMat + "</td>");
                    out.println("<td align=\"center\">" + azsProzAntt + "</td></tr>");
                }

            } catch (SQLException e) {
                out.println("Artikelnummer nicht gefunden!<br>");
                out.println(e);
            }
        }
    out.println("</table>");
    sent = null;
    con.close();
%>
<table border="0" align="center">
    <tr>
        <td>
            <a href="./sperren.jsp?artnr=<%=artnr%>&sperrkz=<%=artSperrKz%>" target="main">(Ent)Sperren</a>
        </td>
        <td>&nbsp;</td>
        <td>
            <a href="cutsetzen.jsp?artnr=<%=artnr%>&cutkennz=30" target="main">ZS Manuell</a>
        </td>
        <td>&nbsp;</td>
        <td>
            <a href="cutsetzen.jsp?artnr=<%=artnr%>&cutkennz=10" target="main">ZS Cutter</a>
        </td>
        <td>&nbsp;</td>
        <td>
            <a href="cutsetzen.jsp?artnr=<%=artnr%>&cutkennz=20" target="main">ZS Cutter/Manuell</a>
        </td>
        <td>&nbsp;</td>
        <td>
            <a href="cutsetzen.jsp?artnr=<%=artnr%>&cutkennz=11" target="main">ZS Lohnzuschnitt</a>
        </td>
        <td>&nbsp;</td>
        <td>
            <a href="loeschen_confirm.jsp?artnr=<%=artnr%>&var=artikel" target="main">L&ouml;schen</a>
        </td>
        <!--<td>&nbsp;</td>
            <td>
          <a href="prioset.jsp" target="main">Priorisierung &auml;ndern</a>
	      </td>-->
    </tr>
</table>
<%
    //#####---Bei Stoffen(432) keine Reservierung- bzw. Reste-Eingabemoeglichkeit...---#####
    if (newartnr1.equals("432")) {
        out.println(" <hr>");
    }
    //#####---Aber bei Leder(442) schon....---#####
    else {
        out.println("<hr>");
        out.println("<table border=\"0\" align=\"center\"><tr>");
        out.println("<td><a href=\"./rest.jsp?artnr=" + artnr + "\" target=\"main\">Rest anlegen</a></td><td>&nbsp;</td>");
        out.println("<td><a href=\"reservierung.jsp?artnr=" + artnr + "\" target=\"main\">Reservieren</a></td></tr>");
        out.println("</tr></table>");
    }
%>

</body>
</html>
      

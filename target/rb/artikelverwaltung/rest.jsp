<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<div align="center">
    <b>Rest anlegen:</b>
</div>
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
    long restArtNr = 0;
    long restLagerOrt = 0;
    float restMenge = 0;
    int restStatus = 0;
    int restId = 0;
    String charge = "";
    String liefkkz = "";
    String lief = "";
    String charge_out = "";
    String fungi = "";
    int buendel = 0;
    String bem = "";
    String bem1 = "";
    int count = 0;
    String zuschnittsys = "";
    String zsArt = "";

    String artnr = request.getParameter("artnr");
    String sent = request.getParameter("sent");


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
        //artCutFhg  = resultSet.getString("ART_CUT_FHG");
        //artManZs   = resultSet.getString("ART_MAN_ZS");
        zuschnittsys = resultSet.getString("ART_ZS_SYS");

        if (zuschnittsys.equals("10")) {
            zsArt = "Cutter";
        } else if (zuschnittsys.equals("30")) {
            zsArt = "Manuell";
        } else if (zuschnittsys.equals("20")) {
            zsArt = "Cutter/Manuell";
        }

        String newartnr = "" + artNr;
        String newartnr1 = artnr.substring(0, 3);
        String newartnr2 = artnr.substring(3, 8);
        String newartnr3 = artnr.substring(8);

        out.println("<tr><td>Artikelnummer</td><td align=\"center\">" + newartnr1 + "." + newartnr2 + "." + newartnr3 + "</td></tr>");
        out.println("<tr><td>Bezeichnung</td><td align=\"center\">" + artBez + "</td></tr>");

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

    } catch (SQLException e) {
        out.println("Artikelnummer nicht gefunden!<br>");
        out.println(e);
    }

    //#####---Hier wurde einst die Zusammensetzung angezeigt-deprecated---#####
    /*sql = "SELECT * FROM PLRV11.PLR_ART_ZUSAM where AZS_ART_NR="+artnr;
       //out.println(sql);
       prepStmt  = myDBAccess.prepareStatement(sql);
       resultSet = myDBAccess.preparedSelectStatement(prepStmt);

       out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
       out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
       out.println("<colgroup><col width=\"140\"><col width=\"140\"><col width=\"140\"></colgroup>");
       out.println("<tr><td align=\"center\">Materialtyp</td><td align=\"center\">Bezeichnung</td>");
           out.println("<td align=\"center\">Anteil&nbsp;[%]</td></tr>");

         try
         {
             while(resultSet.next()){

           azsArtNr    = resultSet.getLong("AZS_ART_NR");
           azsBezTyp   = resultSet.getInt("AZS_Bez_Typ");
               azsBezMat   = resultSet.getString("AZS_BEZ_MAT");
               azsProzAntt = resultSet.getInt("AZS_PROZ_ANTT");

               out.println("<tr><td align=\"center\">"+azsBezTyp+"</td>");
               out.println("<td align=\"center\">"+azsBezMat+"</td>");
               out.println("<td align=\"center\">"+azsProzAntt+"</td></tr>");
             }

         } catch(SQLException e) {
                   out.println("Artikelnummer nicht gefunden!<br>");
             out.println(e);
           }

          out.println("</table>");*/
%>
<form action="./rest_anlegen.jsp" method="post">
    <table border="0" align="center">
        <tr>
            <td align="center">
                Lieferant:&nbsp;
            </td>
            <td>
                <input type="text" name="liefkkz" size="4" maxlength="4" value=""></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                Charge:&nbsp;
            </td>
            <td>
                <input type="text" name="charge" size="10" maxlength="10" value=""></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                Brutto-Menge:&nbsp;
            </td>
            <td>
                <input type="text" name="menge" size="6" maxlength="6" value=""></input>
                &nbsp;[qm]
            </td>
        </tr>
        <tr>
            <td align="center">
                Lagerort:&nbsp;
            </td>
            <td>
                <!--<%
		  String selString ="SELECT PP_PF_PLATZ,PP_PF_PLATZ FROM PLRV11.BDE_PUFPL WHERE PP_PFNR=10244300 ORDER BY 1";
		  out.println(oraBde.getHtmlSelectAllg("lagerort",selString," "));
%>-->
                <input type="text" name="XXX" size="8" maxlength="8" value="10244300 " readonly></input>
                <input type="text" name="lagernr" size="3" maxlength="3" value=" "></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                Bemerkung:&nbsp;
            </td>
            <td>
                <input type="text" name="comment" size="11" maxlength="50" value="-"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                Fungizid ausger&uuml;stet:
            </td>
            <td><select size="1" name="fungizid">
                <option value="J">J</option>
                <option value="N" selected>N</option>
            </select>
            </td>
        </tr>
        <tr>
            <td align="center">
                B&uuml;ndelklasse:
            </td>
            <td><select size="1" name="buendel">
                <option value="0" selected>0</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
            </select>
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <tr>
            <td>
                <input type="submit" value="Rest anlegen"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="hidden" name="ART_NR" value="<%=artNr%>"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="hidden" name="ART_SPERR_KZ" value="<%=artSperrKz%>"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="hidden" name="ART_ZS_SYS" value="<%=zuschnittsys%>"></input>
            </td>
        </tr>
    </table>
</form>
<hr>
<table border="0" align="center">
    <tr>
        <td align="center">
            <b>
                Bereits angelegte Reste f&uuml;r diesen Artikel:
            </b>
        </td>
    </tr>
</table>
<%
    //#####---Nur Reste anzeigen, daher die WHERE-Bedingung---###
    sql = "SELECT RES_CHARG_NR,RES_QM_BRUTTO,RES_FUNGIZID,RES_BEMERK,RES_RES_LAGERORT,RES_STATUS,RES_ID,RES_LIEF_KKZ,RES_BUENDEL FROM PLRV11.ZUS_REST_RESERV";
    sql += " WHERE RES_REST_KZ='J' AND RES_ART_NR=" + artnr + " ORDER BY RES_ART_NR";

    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    out.println("<table border=\"0\" align=\"center\"><tr><td>&nbsp;</td></tr></table>");
    out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\" cellspacing=\"5\">");

    out.println("<tr><td align=\"center\"><b>Artikelnummer</b></td>");
    out.println("<td align=\"center\"><b>Brutto[qm]</b></td>");
    out.println("<td align=\"center\"><b>Charge</b></td>");
    out.println("<td align=\"center\"><b>Lieferant</b></td>");
    out.println("<td align=\"center\"><b>Lagerort</b></td>");
    out.println("<td align=\"center\"><b>Fungizid</b></td>");
    out.println("<td align=\"center\"><b>B&uuml;ndelkl.</b></td>");
    out.println("<td align=\"center\"><b>Bem.</b></td>");
    out.println("<td align=\"center\"><b>Status</b></td>");
    out.println("<td align=\"center\"><b>Aktion</b></td></tr>");

    try {
        while (resultSet.next()) {

            restMenge = resultSet.getFloat("RES_QM_BRUTTO");
            restStatus = resultSet.getInt("RES_STATUS");
            restLagerOrt = resultSet.getLong("RES_RES_LAGERORT");
            restId = resultSet.getInt("RES_ID");
            charge = resultSet.getString("RES_CHARG_NR");
            fungi = resultSet.getString("RES_FUNGIZID");
            bem = resultSet.getString("RES_BEMERK");
            liefkkz = resultSet.getString("RES_LIEF_KKZ");
            buendel = resultSet.getInt("RES_BUENDEL");

            String lagerort = "" + restLagerOrt;
            String lager1 = lagerort.substring(0, 8);
            String lager2 = lagerort.substring(8);

            String artnr1 = artnr.substring(0, 3);
            String artnr2 = artnr.substring(3, 8);
            String artnr3 = artnr.substring(8);
            //out.println(artnr1+"."+artnr2+"."+artnr3+"<br>");

            try {
                count = bem.length();

                if (count <= 10) {
                    bem1 = bem;
                } else {
                    bem1 = bem.substring(0, 10);
                }

            } catch (Exception e) {
                //out.println("<br>");
                //out.println(e);
            }

            if (charge != null) {
                charge_out = charge;
            } else {
                charge_out = "-";
            }

            if (liefkkz != null) {
                lief = liefkkz;
            } else {
                lief = "-";
            }

            out.println("<tr><td align=\"center\">" + artnr1 + "." + artnr2 + "." + artnr3 + "</td>");
            out.println("<td align=\"center\">" + restMenge + "</td>");
            out.println("<td align=\"center\">" + charge_out + "</td>");
            out.println("<td align=\"center\">" + lief + "</td>");
            out.println("<td align=\"center\">" + lager1 + "." + lager2 + "</td>");
            out.println("<td align=\"center\">" + fungi + "</td>");
            out.println("<td align=\"center\">" + buendel + "</td>");
            out.println("<td align=\"center\">" + bem1 + "</td>");
            out.println("<td align=\"center\">" + restStatus + "</td>");
            out.println("<td align=\"center\" bgcolor=\"red\">");
            out.println("<a href=\"./loeschen_confirm.jsp?artnr=" + artnr + "&artID=" + restId + "&var=rest\">L&ouml;schen</a>");
            out.println("</td>");
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Daten!<br>");
        out.println(e);
    }
    out.println("</tr></table>");
    con.close();
%>

</body>
</html>
      
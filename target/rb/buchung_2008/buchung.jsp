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

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp_testneu.conf");
    Connection con = oraBde.getConnection();

    String mod = request.getParameter("mod");
    String nummer = request.getParameter("auftr_bez_nr");
    String vorgang = "";
    String buchungsart = "";

    //### eingescannte Kombinationsnummer aus Artikelnummer + Auftragsnummer trennen (bei Kommissionen) ###

    String artNr = nummer.substring(0, 10);
    String abNr = nummer.substring(10);
    String sakArtNr = "";
    String sql = "";
    String sql1 = "";
    Statement stmt;
    Statement stmt1;
    ResultSet resultSet;
    ResultSet resultSet1;
    int hatsfunktioniert = 0;
    zusParam zp = new zusParam(con);
    String buchungsmonat = zp.getText("buchungsMonat");
    komStatus ks = new komStatus(con);
    String gebucht = "";
    int status = 0;
    String komBrutto = "";
    String anz_werk = "";
    int werk = 0;
    String istmenge = "";
    String sammelAbNr = "";
    String personalNr = "";
    String zuschnittSys = "";
    String charge = "";
    String lieferant = "";
    String zbl = "";
    String komPraemie = "";
    String hinweis = "";
    String krit = "";
    String zs = "";
    String korrKz = "";
    String komBuchMM = "";
    String spezial = "";
    String spezial1 = "";
    String spezial2 = "";
    String mverbrauch = "";
    String rmenge = "";
    String sakBuchMM = "";
    String bmonat = "";
    String checkvar = "";
    String artikel_anfang = artNr.substring(3, 5);
    String artikel_ende = artNr.substring(5, 8);
    //out.println("ARTIKEL:"+artikel_anfang+"."+artikel_ende);

    //### Buchungsartunterscheidungen ###

    if (mod.equals("imez_kom")) {
        //### fuer die Ueberpruefungsroutine des Verursacherschluessels ###
        String key = request.getParameter("key");
        //### wenn Verursacherschluessel eingegeben werden muss:Uebergabewert 'setkey', ansonsten 'nixkey'
        if (key.equals("setkey")) {
            spezial = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setmenge")) {
            spezial1 = "#ff0000";
            spezial = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            checkvar = "checked";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen/Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setmenge1")) {
            spezial1 = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            checkvar = "checked";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen:</font></h2></center>");
        } else {
            spezial = "#faebd7";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        }

        vorgang = "Buchung Einzelkommission";
        buchungsart = "IMEZ/H VG=21";
        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
        out.println("<tr><td align=\"center\"><b>" + vorgang + "</b></td></tr>");
        out.println("<tr><td align=\"center\"><font color=\"#0000cd\"><b>[" + buchungsart + "]</b></font></td></tr></table>");
        status = ks.getKomStatus(abNr, artNr);
        gebucht = ks.getKomGebucht(abNr, artNr);
        //out.println("stat:"+status);
        //out.println("geb.:"+gebucht);

        //### Bedingung fuer Einzelbuchung dieses Typs: Status=50 und KOM_GEBUCHT_KZ=N ###

        if (status == 50 && gebucht.equals("N")) {
            sql = "SELECT KOM_QM_BRUTTO,KOM_SAMMEL_ABNR,KOM_WERK_ZUSCHN,SAK_PNR,SAK_ZS_SYS,";
            sql += "SAK_CHARG_NR,SAK_LIEF_KKZ,SAK_ZBL,KOM_KZ_PRAEMIE FROM PLRV11.ZUS_KOMMISSION";
            sql += " LEFT JOIN PLRV11.ZUS_SAMMEL_KOPF ON KOM_SAMMEL_ABNR = SAK_SANR WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<form name=\"form\" action=\"./buchung_kom_imezh.jsp?mod=eintrag\" method=\"post\" target=\"main\">");
            out.println("<input type=\"hidden\" name=\"abNr\" value=" + abNr + "></input>");
            out.println("<input type=\"hidden\" name=\"artNr\" value=" + artNr + "></input>");
            out.println("<input type=\"hidden\" name=\"checkvar\" value=" + checkvar + "></input>");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" cellspacing=\"1\" bgcolor=\"#faebd7\"> ");
            out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
            out.println("<tr><td>Auftragsnummer</td>");
            out.println("<td>" + abNr + "</td></tr>");
            out.println("<tr><td>Artikelnummer</td>");
            out.println("<td>" + artikel_anfang + "." + artikel_ende + "</td></tr>");
            //out.println("<td>"+artNr+"</td></tr>");

            try {
                while (resultSet.next()) {

                    komPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                    komBrutto = resultSet.getString("KOM_QM_BRUTTO");
                    sammelAbNr = resultSet.getString("KOM_SAMMEL_ABNR");
                    werk = resultSet.getInt("KOM_WERK_ZUSCHN");
                    personalNr = resultSet.getString("SAK_PNR");
                    zuschnittSys = resultSet.getString("SAK_ZS_SYS");
                    charge = resultSet.getString("SAK_CHARG_NR");
                    zbl = resultSet.getString("SAK_ZBL");
                    lieferant = resultSet.getString("SAK_LIEF_KKZ");

                    if (zuschnittSys.equals("30")) {
                        zs = "[manuell]";
                    }
                    if (zuschnittSys.equals("10")) {
                        zs = "[cutter]";
                    }
                    if (zuschnittSys.equals("20")) {
                        zs = "[sonst]";
                    }
                    if (personalNr == null) {
                        personalNr = "0000";
                    }
                    if (werk > 40) {
                        anz_werk = "Werk:<font color=\"red\">" + werk + "</font>";
                    } else {
                        anz_werk = "&nbsp";
                    }
                    out.println("<tr><td>Sammelauftragsnummer</td>");
                    out.println("<td>" + sammelAbNr + "</td></tr>");
                    out.println("<tr><td>Personalnummer</td>");
                    out.println("<td><input type=\"text\" name=\"persNr\" value=" + personalNr + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Zuschnittsystem</td>");
                    out.println("<td>" + zuschnittSys + "&nbsp;" + zs + "&nbsp;" + anz_werk + "</td></tr>");
                    out.println("<tr><td>Charge</td>");
                    out.println("<td><input type=\"text\" name=\"charge\" value=" + charge + " size=\"10\" maxlength=\"10\"></input></td></tr>");
                    out.println("<tr><td>Lieferant</td>");
                    out.println("<td><input type=\"text\" name=\"lieferant\" value=" + lieferant + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Buchungsmonat</td>");
                    out.println("<td>" + buchungsmonat + "</td></tr>");
                    out.println("<tr><td>IST Menge Kommission</td>");
                    out.println("<td bgcolor=" + spezial1 + "><input type=\"text\" name=\"menge\" size=\"7\" maxlength=\"7\" value=\"" + istmenge + "\">&nbsp;qm</input>");
                    out.println("</td></tr>");
                    out.println("<tr><td>Verursacherschl&uuml;ssel</td>");
                    out.println("<td bgcolor=" + spezial + "><input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\"value=\"00\">");
                    out.println("</input>&nbsp;");
                    out.println("<tr><td>Kriterium</td>");
                    out.println("<td><input type=\"text\" name=\"krit\" value=\"" + krit + "\" size=\"20\" maxlength=\"39\">");
                    out.println("</input>&nbsp;");
                    out.println("<tr><td>Hinweis</td>");
                    out.println("<td><input type=\"text\" name=\"hinweis\" value=\"" + hinweis + "\" size=\"20\" maxlength=\"38\">");
                    out.println("</input>&nbsp;");
                    out.println("<input type=\"hidden\" name=\"schicht\" value=\"0\"></input>");
                    out.println("<input type=\"hidden\" name=\"komBrutto\" value=\"" + komBrutto + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=" + sammelAbNr + "></input>");
                    out.println("<input type=\"hidden\" name=\"zsSys\" value=" + zuschnittSys + "></input>");
                    out.println("<input type=\"hidden\" name=\"werk\" value=" + werk + "></input>");
                    out.println("<input type=\"hidden\" name=\"zbl\" value=" + zbl + "></input>");
                    out.println("</td></tr>");

                    if (komPraemie.equals("N")) {
                        out.println("<tr><td>Gebrauchte Zeit</td>");
                        out.println("<td><input type=\"text\" name=\"zeit\" size=\"10\" maxlength=\"10\" value=\"0\"></input>&nbsp;");
                        out.println("</td></tr>");
                    } else {
                        out.println("<input type=\"hidden\" name=\"zeit\" size=\"10\" maxlength=\"10\" value=\"0\"></input>");
                    }
                    out.println("</table>");
                    out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
                    out.println("<tr><td>&nbsp;</td></tr>");
                    out.println("<tr><td><input type=\"submit\" value=\"Werte &uuml;bernehmen\"></td></tr></table></form>");
                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                out.println("<br><br>" + e);
            }
        }

        //### Bei falschen Parametern fuer Einzelbuchung dieses Typs:FEHLERMELDUNG ###

        else {
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font color=\"#ff0000\" size=\"+1\">Fehler ! Kommission nicht zur Einzelbuchung vorgesehen!!</font>");
            out.println("</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Falsche Parameter f&uuml;r IMEZ/H VG=21:</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Artikelnummer=<b>" + artNr + "</b></td></tr><tr><td>ABNr.=<b>" + abNr + "</b></td></tr>");
            out.println("<tr><td>Status=<b>" + status + "</b></td></tr><tr><td>KZ Gebucht=<b>" + gebucht + "</b></td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font size=\"+1\"><a href=\"./index.html\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weiter</a></font></td></tr></table>");
        }
    }
    if (mod.equals("imez_kom_korr")) {
        //out.println("<body bgcolor=\"#ffaeb9\" OnLoad=\"document.form.rmenge.focus();\">");
        //out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
        //out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        //### fuer die Ueberpruefungsroutine des Verursacherschluessels ###
        String key = request.getParameter("key");
        //### wenn Verursacherschluessel eingegeben werden muss:Uebergabewert 'setkey', ansonsten 'nixkey'
        if (key.equals("setkey")) {
            spezial = "#ff0000";
            mverbrauch = request.getParameter("mverbrauch");
            rmenge = "0";
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setkey2")) {
            spezial = "#ff0000";
            rmenge = request.getParameter("rmenge");
            mverbrauch = "0";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setmenge")) {
            spezial1 = "#ff0000";
            spezial = "#ff0000";
            mverbrauch = request.getParameter("mverbrauch");
            rmenge = "0";
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            checkvar = "checked";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen/Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setmenge1")) {
            spezial1 = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            hinweis = request.getParameter("hinweis");
            krit = request.getParameter("krit");
            checkvar = "checked";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen:</font></h2></center>");
        } else {
            spezial = "#faebd7";
            mverbrauch = "0";
            rmenge = "0";
            out.println("<body bgcolor=\"#ffaeb9\" OnLoad=\"document.form.rmenge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        }

        vorgang = "Korrekturbuchung Einzelkommission";
        buchungsart = "IMEZ/K VG=21";
        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
        out.println("<tr><td align=\"center\"><b>" + vorgang + "</b></td></tr>");
        out.println("<tr><td align=\"center\"><font color=\"#0000cd\"><b>[" + buchungsart + "]</b></font></td></tr></table>");
        status = ks.getKomStatus(abNr, artNr);
        gebucht = ks.getKomGebucht(abNr, artNr);
        //out.println(status);

        //### Bedingung fuer Einzelbuchung dieses Typs: Status=50 und KOM_GEBUCHT_KZ=J ###

        if (status == 50 && gebucht.equals("J")) {
            sql = "SELECT KOM_SAMMEL_ABNR,KOM_IST_MENGE,KOM_WERK_ZUSCHN,SAK_PNR,SAK_ZS_SYS,";
            sql += "SAK_CHARG_NR,SAK_LIEF_KKZ,SAK_ZBL,KOM_KZ_PRAEMIE,KOM_KZ_KORR,KOM_BUCH_MM FROM PLRV11.ZUS_KOMMISSION";
            sql += " LEFT JOIN PLRV11.ZUS_SAMMEL_KOPF ON KOM_SAMMEL_ABNR = SAK_SANR WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<form name=\"form\" action=\"./buchung_kom_imezk.jsp?mod=eintrag\" method=\"post\" target=\"main\">");
            out.println("<input type=\"hidden\" name=\"abNr\" value=" + abNr + "></input>");
            out.println("<input type=\"hidden\" name=\"artNr\" value=" + artNr + "></input>");
            out.println("<input type=\"hidden\" name=\"checkvar\" value=" + checkvar + "></input>");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" cellspacing=\"1\" bgcolor=\"#faebd7\"> ");
            out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
            out.println("<tr><td>Auftragsnummer</td>");
            out.println("<td>" + abNr + "</td></tr>");
            out.println("<tr><td>Artikelnummer</td>");
            out.println("<td>" + artikel_anfang + "." + artikel_ende + "</td></tr>");
            //out.println("<td>"+artNr+"</td></tr>");

            try {
                while (resultSet.next()) {

                    komPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                    sammelAbNr = resultSet.getString("KOM_SAMMEL_ABNR");
                    istmenge = resultSet.getString("KOM_IST_MENGE");
                    werk = resultSet.getInt("KOM_WERK_ZUSCHN");
                    personalNr = resultSet.getString("SAK_PNR");
                    zuschnittSys = resultSet.getString("SAK_ZS_SYS");
                    charge = resultSet.getString("SAK_CHARG_NR");
                    lieferant = resultSet.getString("SAK_LIEF_KKZ");
                    zbl = resultSet.getString("SAK_ZBL");
                    korrKz = resultSet.getString("KOM_KZ_KORR");
                    komBuchMM = resultSet.getString("KOM_BUCH_MM");

                    if (zuschnittSys.equals("30")) {
                        zs = "[manuell]";
                    }
                    if (zuschnittSys.equals("10")) {
                        zs = "[cutter]";
                    }
                    if (zuschnittSys.equals("20")) {
                        zs = "[sonst]";
                    }
                    if (personalNr == null) {
                        personalNr = "0000";
                    }
                    if (werk > 40) {
                        anz_werk = "Werk:<font color=\"red\">" + werk + "</font>";
                    } else {
                        anz_werk = "&nbsp";
                    }
                    out.println("<tr><td>Sammelauftragsnummer</td>");
                    out.println("<td>" + sammelAbNr + "</td></tr>");
                    out.println("<tr><td>Personalnummer</td>");
                    out.println("<td><input type=\"text\" name=\"persNr\" value=" + personalNr + " size=\"4\" maxlength=\"4\" readonly>");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Zuschnittsystem</td>");
                    out.println("<td>" + zuschnittSys + "&nbsp;" + zs + "&nbsp;" + anz_werk + "</td></tr>");
                    out.println("<tr><td>Charge</td>");
                    out.println("<td><input type=\"text\" name=\"charge\" value=" + charge + " size=\"10\" maxlength=\"10\"></input></td></tr>");
                    out.println("<tr><td>Lieferant</td>");
                    out.println("<td><input type=\"text\" name=\"lieferant\" value=" + lieferant + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Buchungsmonat</td>");
                    out.println("<td>" + buchungsmonat + "</td></tr>");
                    out.println("<tr><td>IST Menge Kommission</td>");
                    out.println("<td>" + istmenge + "&nbsp;qm</td></tr>");
                    out.println("<tr><td>Mehrverbrauch</td>");
                    out.println("<td bgcolor=" + spezial1 + "><input type=\"text\" name=\"mverbrauch\"size=\"7\"maxlength=\"7\"value=\"" + mverbrauch + "\">&nbsp;qm");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>R&uuml;ckgabemenge</td>");
                    out.println("<td><input type=\"text\" name=\"rmenge\" size=\"7\" maxlength=\"7\"value=\"" + rmenge + "\"&nbsp;qm></input></td></tr>");
                    out.println("<tr><td>Verursacherschl&uuml;ssel</td>");
                    out.println("<td bgcolor=" + spezial + "><input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\"value=\"00\">");
                    out.println("</input>&nbsp;");
                    out.println("<tr><td>Kriterium</td>");
                    out.println("<td><input type=\"text\" name=\"krit\" value=\"" + krit + "\" size=\"20\" maxlength=\"40\">");
                    out.println("</input>&nbsp;");
                    out.println("<tr><td>Hinweis</td>");
                    out.println("<td><input type=\"text\" name=\"hinweis\" value=\"" + hinweis + "\" size=\"20\" maxlength=\"39\">");
                    out.println("</input>&nbsp;");
                    out.println("<input type=\"hidden\" name=\"schicht\" value=\"0\"></input>");
                    //out.println("<input type=\"hidden\" name=\"komBrutto\" value=\""+komBrutto+"\"></input>");
                    out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=\"" + sammelAbNr + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"istmenge\" value=\"" + istmenge + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"korrKz\" value=\"" + korrKz + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"komBuchMM\" value=\"" + komBuchMM + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"zsSys\" value=\"" + zuschnittSys + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"werk\" value=\"" + werk + "\"></input>");
                    out.println("<input type=\"hidden\" name=\"zbl\" value=\"" + zbl + "\"></input>");
                    out.println("</td></tr>");

                    if (komPraemie.equals("N")) {
                        out.println("<tr><td>Gebrauchte Zeit</td>");
                        out.println("<td><input type=\"text\" name=\"zeit\" size=\"10\" maxlength=\"10\"value=\"0\"></input>&nbsp;");
                        out.println("</td></tr>");
                    } else {
                        out.println("<input type=\"hidden\" name=\"zeit\" value=\"0\"></input>&nbsp;");
                    }
                    out.println("</table>");
                    out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
                    out.println("<tr><td>&nbsp;</td></tr>");
                    out.println("<tr><td><input type=\"submit\" value=\"Werte &uuml;bernehmen\"></td></tr></table></form>");
                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                out.println("<br><br>" + e);
            }
        }

        //### Bei falschen Parametern fuer Einzelbuchung dieses Typs:FEHLERMELDUNG ###

        else {
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font color=\"#ff0000\" size=\"+1\">Fehler ! Kommission nicht zur Korrekturbuchung vorgesehen!!</font>");
            out.println("</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Falsche Parameter f&uuml;r IMEZ/K VG=21:</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Artikelnummer=<b>" + artNr + "</b></td></tr><tr><td>ABNr.=<b>" + abNr + "</b></td></tr>");
            out.println("<tr><td>Status=<b>" + status + "</b></td></tr><tr><td>KZ Gebucht=<b>" + gebucht + "</b></td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font size=\"+1\"><a href=\"./index.html\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weiter</a></font></td></tr></table>");
        }

    }
    if (mod.equals("lmez_kom")) {
        out.println("<body bgcolor=\"#9ac0cd\" OnLoad=\"document.form.istmenge.focus();\">");
        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
        out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        vorgang = "Buchung Einzelkommission";
        buchungsart = "LMEZ/H VG=30,31";
        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
        out.println("<tr><td align=\"center\"><b>" + vorgang + "</b></td></tr>");
        out.println("<tr><td align=\"center\"><font color=\"#0000cd\"><b>[" + buchungsart + "]</b></font></td></tr></table>");
        status = ks.getKomStatus(abNr, artNr);
        gebucht = ks.getKomGebucht(abNr, artNr);

        //### Bedingung fuer Einzelbuchung dieses Typs: Status=50 ###

        if (status == 50) {
            sql = "SELECT KOM_SAMMEL_ABNR,KOM_IST_MENGE,KOM_WERK_ZUSCHN,SAK_PNR,SAK_ZS_SYS,";
            sql += "SAK_CHARG_NR,SAK_LIEF_KKZ,SAK_ZBL,KOM_KZ_PRAEMIE,KOM_KZ_KORR,KOM_BUCH_MM FROM PLRV11.ZUS_KOMMISSION";
            sql += " LEFT JOIN PLRV11.ZUS_SAMMEL_KOPF ON KOM_SAMMEL_ABNR = SAK_SANR WHERE  KOM_ABNR=" + abNr + " AND KOM_ART_NR=" + artNr;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<form name=\"form\" action=\"./buchung_kom_lmezh.jsp?mod=eintrag\" method=\"post\" target=\"main\">");
            out.println("<input type=\"hidden\" name=\"abNr\" value=" + abNr + "></input>");
            out.println("<input type=\"hidden\" name=\"artNr\" value=" + artNr + "></input>");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" cellspacing=\"1\" bgcolor=\"#faebd7\"> ");
            out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
            out.println("<tr><td>Auftragsnummer</td>");
            out.println("<td>" + abNr + "</td></tr>");
            out.println("<tr><td>Artikelnummer</td>");
            out.println("<td>" + artikel_anfang + "." + artikel_ende + "</td></tr>");
            //out.println("<td>"+artNr+"</td></tr>");

            try {
                while (resultSet.next()) {

                    komPraemie = resultSet.getString("KOM_KZ_PRAEMIE");
                    sammelAbNr = resultSet.getString("KOM_SAMMEL_ABNR");
                    istmenge = resultSet.getString("KOM_IST_MENGE");
                    werk = resultSet.getInt("KOM_WERK_ZUSCHN");
                    personalNr = resultSet.getString("SAK_PNR");
                    zuschnittSys = resultSet.getString("SAK_ZS_SYS");
                    charge = resultSet.getString("SAK_CHARG_NR");
                    lieferant = resultSet.getString("SAK_LIEF_KKZ");
                    zbl = resultSet.getString("SAK_ZBL");
                    korrKz = resultSet.getString("KOM_KZ_KORR");
                    komBuchMM = resultSet.getString("KOM_BUCH_MM");

                    if (zuschnittSys.equals("30")) {
                        zs = "[manuell]";
                    }
                    if (zuschnittSys.equals("10")) {
                        zs = "[cutter]";
                    }
                    if (zuschnittSys.equals("20")) {
                        zs = "[sonst]";
                    }
                    if (personalNr == null) {
                        personalNr = "0000";
                    }
                    if (werk > 40) {
                        anz_werk = "Werk:<font color=\"red\">" + werk + "</font>";
                    } else {
                        anz_werk = "&nbsp";
                    }
                    out.println("<tr><td>Sammelauftragsnummer</td>");
                    out.println("<td>" + sammelAbNr + "</td></tr>");
                    out.println("<tr><td>Personalnummer</td>");
                    out.println("<td><input type=\"text\" name=\"persNr\" value=" + personalNr + " size=\"4\" maxlength=\"4\" readonly>");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Zuschnittsystem</td>");
                    out.println("<td>" + zuschnittSys + "&nbsp;" + zs + "&nbsp;" + anz_werk + "</td></tr>");
                    out.println("<tr><td>Charge</td>");
                    out.println("<td><input type=\"text\" name=\"charge\" value=" + charge + " size=\"10\" maxlength=\"10\"></input></td></tr>");
                    out.println("<tr><td>Lieferant</td>");
                    out.println("<td><input type=\"text\" name=\"lieferant\" value=" + lieferant + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Buchungsmonat</td>");
                    out.println("<td>" + buchungsmonat + "</td></tr>");
                    out.println("<tr><td>Verbrauch</td>");
                    out.println("<td><input type=\"text\" name=\"istmenge\"size=\"7\"maxlength=\"7\"value=\"0\">&nbsp;qm</input>");
                    out.println("</td></tr>");
                    out.println("<tr><td>Vorgangsart</td>");
                    out.println("<td><select size=\"1\" name=\"vorgang\"><option value=\"30\" selected>30</option>");
                    out.println("<option value=\"31\">31</option></select></td><tr>");
                    out.println("<tr><td>Verursacherschl&uuml;ssel</td>");
                    out.println("<td><select size=\"1\" name=\"verkey\"><option value=\"01\" selected>01</option>");
                    out.println("<option value=\"02\">02</option><option value=\"03\">03</option><option value=\"04\">04</option>");
                    out.println("<option value=\"05\">05</option><option value=\"06\">06</option><option value=\"07\">07</option>");
                    out.println("<option value=\"08\">08</option><option value=\"09\">09</option>");
                    out.println("</select>");
                    out.println("<tr><td>Kriterium</td>");
                    out.println("<td><input type=\"text\" name=\"krit\" size=\"20\" maxlength=\"40\">");
                    out.println("</input>&nbsp;");
                    out.println("<tr><td>Hinweis</td>");
                    out.println("<td><input type=\"text\" name=\"hinweis\" size=\"20\" maxlength=\"39\">");
                    out.println("</input>&nbsp;");
                    //out.println("<td><input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\"value=\"00\"></input>&nbsp;");
                    //out.println("<input type=\"hidden\" name=\"komBrutto\" value=\""+komBrutto+"\"></input>");
                    out.println("<input type=\"hidden\" name=\"schicht\" value=\"0\"></input>");
                    out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=" + sammelAbNr + "></input>");
                    out.println("<input type=\"hidden\" name=\"zsSys\" value=" + zuschnittSys + "></input>");
                    out.println("<input type=\"hidden\" name=\"werk\" value=" + werk + "></input>");
                    out.println("<input type=\"hidden\" name=\"zbl\" value=" + zbl + "></input>");
                    out.println("</td></tr>");

                    if (komPraemie.equals("N")) {
                        out.println("<tr><td>Gebrauchte Zeit</td>");
                        out.println("<td><input type=\"text\" name=\"zeit\" size=\"10\" maxlength=\"10\"value=\"0\"></input>&nbsp;");
                        out.println("</td></tr>");
                    } else {
                        out.println("<input type=\"hidden\" name=\"zeit\" value=\"0\"></input>&nbsp;");
                    }
                    out.println("</table>");
                    out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
                    out.println("<tr><td>&nbsp;</td></tr>");
                    out.println("<tr><td><input type=\"submit\" value=\"Werte &uuml;bernehmen\"></td></tr></table></form>");
                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                out.println("<br><br>" + e);
            }
        }

        //### Bei falschen Parametern fuer Einzelbuchung dieses Typs:FEHLERMELDUNG ###

        else {
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>");
            out.println("<font color=\"#ff0000\" size=\"+1\">Fehler ! Kommission nicht zur Buchung LMEZ vorgesehen!!</font>");
            out.println("</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Falsche Parameter f&uuml;r LMEZ/H VG=30,31:</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Artikelnummer=<b>" + artNr + "</b></td></tr><tr><td>ABNr.=<b>" + abNr + "</b></td></tr>");
            out.println("<tr><td>Status=<b>" + status + "</b></td></tr><tr><td>KZ Gebucht=<b>" + gebucht + "</b></td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font size=\"+1\"><a href=\"./index.html\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weiter</a></font></td></tr></table>");
        }
    }
    if (mod.equals("imez_sammel")) {
        //### fuer die Ueberpruefungsroutine des Verursacherschluessels ###
        String key = request.getParameter("key");
        //### wenn Verursacherschluessel eingegeben werden muss:Uebergabewert 'setkey', ansonsten 'nixkey'
        if (key.equals("setkey")) {
            spezial = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<h2>Verursacherschl&uuml;ssel eingeben:<h2>");
        } else if (key.equals("setmenge")) {
            spezial1 = "#ff0000";
            spezial = "#ff0000";
            istmenge = request.getParameter("IstMenge");
            checkvar = "checked";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.menge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen/Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else {
            spezial = "#faebd7";
            out.println("<body bgcolor=\"#f0e68c\" OnLoad=\"document.form.istmenge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        }

        vorgang = "Buchung Sammelauftrag";
        buchungsart = "IMEZ/H VG=21";
        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
        out.println("<tr><td align=\"center\"><b>" + vorgang + "</b></td></tr>");
        out.println("<tr><td align=\"center\"><font color=\"#0000cd\"><b>[" + buchungsart + "]</b></font></td></tr></table>");
        sakArtNr = ks.getSakArtNr(nummer);
        status = ks.getSakStatus(nummer, sakArtNr);
        String sakartikel_anfang = sakArtNr.substring(3, 5);
        String sakartikel_ende = sakArtNr.substring(5, 8);
        //out.println("<br>Status:"+status);
        //out.println("<br>ARTNR:"+sakArtNr);

        //### Bedingung fuer Einzelbuchung dieses Typs: Status=10 ###

        if (status == 10) {
            sql1 = "SELECT KOM_ABNR,KOM_QM_NETTO,KOM_QM_BRUTTO,KOM_IST_MENGE,KOM_GEBUCHT_KZ,KOM_WERK_ZUSCHN";
            sql1 += " FROM PLRV11.ZUS_KOMMISSION WHERE  KOM_SAMMEL_ABNR=" + nummer;
            //out.println(sql1);
            stmt1 = con.createStatement();
            stmt1.executeQuery(sql1);
            resultSet1 = stmt1.getResultSet();

            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"><tr> ");
            out.println("<td>");
            out.println("<table border=\"1\" bgcolor=\"white\">");
            out.println("<tr><td><b>KomAbNr:</b></td></tr><tr><td><b>Brutto:</b></td></tr>");
            out.println("<tr><td><b>Gebucht:</b></td></tr><tr><td><b>Werk:</b></table></td>");


            try {
                while (resultSet1.next()) {

                    String komAbNr = resultSet1.getString("KOM_ABNR");
                    komBrutto = resultSet1.getString("KOM_QM_BRUTTO");
                    String komNetto = resultSet1.getString("KOM_QM_NETTO");
                    String komIstMenge = resultSet1.getString("KOM_IST_MENGE");
                    String komGebuchtKz = resultSet1.getString("KOM_GEBUCHT_KZ");
                    werk = resultSet1.getInt("KOM_WERK_ZUSCHN");

                    out.println("<td>");
                    out.println("<table border=\"1\" bgcolor=\"white\">");
                    out.println("<tr><td>" + komAbNr + "</td></tr><tr><td>" + komBrutto + "</td></tr>");
                    if (komGebuchtKz.equals("J")) {
                        out.println("<tr><td><b><font color=\"red\">" + komGebuchtKz + "</b></font></td></tr><tr><td>" + werk + "</td></tr></table></td>");
                    } else {
                        out.println("<tr><td><b><font color=\"green\">" + komGebuchtKz + "</b></font></td></tr><tr><td>" + werk + "</td></tr></table></td>");
                    }

                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql1);
                out.println("<br><br>" + e);
            }
            out.println("</tr></table>");


            sql = "SELECT SAK_PNR,SAK_ZS_SYS,SAK_CHARG_NR,SAK_LIEF_KKZ,SAK_ZBL";
            sql += " FROM PLRV11.ZUS_SAMMEL_KOPF WHERE  SAK_SANR=" + nummer;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<form name=\"form\" action=\"./buchung_sammel_imezh.jsp\" method=\"post\" target=\"main\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" cellspacing=\"1\" bgcolor=\"#faebd7\"> ");
            out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
            out.println("<tr><td>Sammelauftragsnummer</td>");
            out.println("<td>" + nummer + "</td></tr>");
            out.println("<tr><td>Artikelnummer</td>");
            out.println("<td>" + sakartikel_anfang + "." + sakartikel_ende + "</td></tr>");
            //out.println("<td>"+sakArtNr+"</td></tr>");

            try {
                while (resultSet.next()) {

                    personalNr = resultSet.getString("SAK_PNR");
                    zuschnittSys = resultSet.getString("SAK_ZS_SYS");
                    charge = resultSet.getString("SAK_CHARG_NR");
                    lieferant = resultSet.getString("SAK_LIEF_KKZ");
                    zbl = resultSet.getString("SAK_ZBL");

                    if (zuschnittSys.equals("30")) {
                        zs = "[manuell]";
                    }
                    if (zuschnittSys.equals("10")) {
                        zs = "[cutter]";
                    }
                    if (zuschnittSys.equals("20")) {
                        zs = "[sonst]";
                    }

                    if (personalNr == null) {
                        personalNr = "0000";
                    }

                    out.println("<tr><td>Personalnummer</td>");
                    out.println("<td><input type=\"text\" name=\"persNr\" value=" + personalNr + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Zuschnittsystem</td>");
                    out.println("<td>" + zuschnittSys + "&nbsp;" + zs + "</td></tr>");
                    out.println("<tr><td>Charge</td>");
                    out.println("<td><input type=\"text\" name=\"charge\" value=" + charge + " size=\"10\" maxlength=\"10\"></input></td></tr>");
                    out.println("<tr><td>Lieferant</td>");
                    out.println("<td><input type=\"text\" name=\"lieferant\" value=" + lieferant + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Buchungsmonat</td>");
                    out.println("<td>" + buchungsmonat + "</td></tr>");
                    out.println("<tr><td>IST Menge Sammelauftrag</td>");
                    out.println("<td bgcolor=" + spezial1 + "><input type=\"text\" name=\"istmenge\"size=\"7\"maxlength=\"7\"value=\"" + istmenge + "\">&nbsp;qm</input>");
                    out.println("</td></tr>");
                    out.println("<tr><td>Vorgangsart</td>");
                    out.println("<td>21</td></tr>");
                    out.println("<tr><td>Verursacherschl&uuml;ssel</td>");
                    out.println("<td bgcolor=" + spezial + "><input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\"value=\"00\">");
                    out.println("</input>&nbsp;");
                    out.println("<input type=\"hidden\" name=\"schicht\" value=\"0\"></input>");
                    out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=" + nummer + "></input>");
                    out.println("<input type=\"hidden\" name=\"sakArtNr\" value=" + sakArtNr + "></input>");
                    out.println("<input type=\"hidden\" name=\"zsSys\" value=" + zuschnittSys + "></input>");
                    out.println("<input type=\"hidden\" name=\"werk\" value=" + werk + "></input>");
                    out.println("<input type=\"hidden\" name=\"checkvar\" value=" + checkvar + "></input>");
                    out.println("<input type=\"hidden\" name=\"zbl\" value=" + zbl + "></input>");
                    out.println("</td></tr>");
                    out.println("</table>");
                    out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
                    out.println("<tr><td>&nbsp;</td></tr>");
                    out.println("<tr><td><input type=\"submit\" value=\"Werte &uuml;bernehmen\"></td></tr></table></form>");
                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                out.println("<br><br>" + e);
            }
        }

        //### Bei falschen Parametern fuer Einzelbuchung dieses Typs:FEHLERMELDUNG ###

        else {
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>");
            out.println("<font color=\"#ff0000\" size=\"+1\">Fehler ! Sammelauftrag nicht zur Sammelauftragsbuchung vorgesehen!!</font>");
            out.println("</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Falsche Parameter f&uuml;r IMEZ/H VG=21:</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Sammelauftragsnummer=<b>" + nummer + "</b></td></tr>");
            out.println("<tr><td>Artikelnummer=<b>" + sakArtNr + "</b></td></tr>");
            out.println("<tr><td>Status=<b>" + status + "</b></td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font size=\"+1\"><a href=\"./index.html\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weiter</a></font></td></tr></table>");
        }
    }
    if (mod.equals("imez_sammel_korr")) {

        vorgang = "Korrekturbuchung Sammelauftrag";
        buchungsart = "IMEZ/K VG=21";
        //### fuer die Ueberpruefungsroutine des Verursacherschluessels ###
        String key = request.getParameter("key");
        //### wenn Verursacherschluessel eingegeben werden muss:Uebergabewert 'setkey', ansonsten 'nixkey'
        if (key.equals("setkey")) {
            spezial = "#ff0000";
            spezial1 = "#ff0000";
            mverbrauch = request.getParameter("mverbrauch");
            rmenge = "0";
            out.println("<body bgcolor=\"#ffaeb9\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen/Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else if (key.equals("setkey2")) {
            spezial = "#ff0000";
            spezial2 = "#ff0000";
            rmenge = request.getParameter("rmenge");
            mverbrauch = "0";
            out.println("<body bgcolor=\"#ffaeb9\" OnLoad=\"document.form.verkey.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
            out.println("<center><h2><font color=\"#ff0000\">Menge &uuml;berpr&uuml;fen/Verursacherschl&uuml;ssel eingeben:</font></h2></center>");
        } else {
            spezial = "#faebd7";
            mverbrauch = "0";
            rmenge = "0";
            out.println("<body bgcolor=\"#ffaeb9\" OnLoad=\"document.form.rmenge.focus();\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\">");
            out.println("<tr><td align=\"center\">&nbsp;</td></tr></table>");
        }

        out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
        out.println("<tr><td align=\"center\"><b>" + vorgang + "</b></td></tr>");
        out.println("<tr><td align=\"center\"><font color=\"#0000cd\"><b>[" + buchungsart + "]</b></font></td></tr></table>");
        sakArtNr = ks.getSakArtNr(nummer);
        String sakartikel_anfang = sakArtNr.substring(3, 5);
        String sakartikel_ende = sakArtNr.substring(5, 8);
        status = ks.getSakStatus(nummer, sakArtNr);
        //out.println("<br>Status:"+status);
        //out.println("<br>"+artNr);
        //### Bedingung fuer Einzelbuchung dieses Typs: Status=30 ###

        if (status == 30) {
            sql1 = "SELECT KOM_ABNR,KOM_QM_NETTO,KOM_QM_BRUTTO,KOM_IST_MENGE,KOM_GEBUCHT_KZ,KOM_WERK_ZUSCHN";
            sql1 += " FROM PLRV11.ZUS_KOMMISSION WHERE  KOM_SAMMEL_ABNR=" + nummer;
            //out.println(sql1);
            stmt1 = con.createStatement();
            stmt1.executeQuery(sql1);
            resultSet1 = stmt1.getResultSet();

            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"><tr> ");
            out.println("<td>");
            out.println("<table border=\"1\" bgcolor=\"white\">");
            out.println("<tr><td><b>KomAbNr:</b></td></tr><tr><td><b>Brutto:</b></td></tr>");
            out.println("<tr><td><b>IST:</b></td></tr><tr><td><b>Werk:</b></td></tr></table></td>");


            try {
                while (resultSet1.next()) {

                    String komAbNr = resultSet1.getString("KOM_ABNR");
                    komBrutto = resultSet1.getString("KOM_QM_BRUTTO");
                    String komNetto = resultSet1.getString("KOM_QM_NETTO");
                    String komIstMenge = resultSet1.getString("KOM_IST_MENGE");
                    String komGebuchtKz = resultSet1.getString("KOM_GEBUCHT_KZ");
                    werk = resultSet1.getInt("KOM_WERK_ZUSCHN");

                    out.println("<td>");
                    out.println("<table border=\"1\" bgcolor=\"white\">");
                    out.println("<tr><td>" + komAbNr + "</td></tr><tr><td>" + komBrutto + "</td></tr>");
                    out.println("<tr><td>" + komIstMenge + "</td></tr><tr><td>" + werk + "</td></tr></table></td>");

                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql1);
                out.println("<br><br>" + e);
            }
            out.println("</tr></table>");

            sql = "SELECT SAK_PNR,SAK_ZS_SYS,SAK_CHARG_NR,SAK_LIEF_KKZ,SAK_MENGE_IST,SAK_BUCH_MM,SAK_KORR_KZ,SAK_ZBL";
            sql += " FROM PLRV11.ZUS_SAMMEL_KOPF WHERE  SAK_SANR=" + nummer;
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            resultSet = stmt.getResultSet();

            out.println("<form name=\"form\" action=\"./buchung_sammel_imezk.jsp?mod=eintrag\" method=\"post\" target=\"main\">");
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr></table>");
            out.println("<table border=\"1\" align=\"center\" cellspacing=\"1\" bgcolor=\"#faebd7\"> ");
            out.println("<colgroup><col width=\"200\"><col width=\"200\"></colgroup>");
            out.println("<tr><td>Sammelauftragsnummer</td>");
            out.println("<td>" + nummer + "</td></tr>");
            out.println("<tr><td>Artikelnummer</td>");
            out.println("<td>" + sakartikel_anfang + "." + sakartikel_ende + "</td></tr>");
            //out.println("<td>"+sakArtNr+"</td></tr>");

            try {
                while (resultSet.next()) {

                    personalNr = resultSet.getString("SAK_PNR");
                    zuschnittSys = resultSet.getString("SAK_ZS_SYS");
                    charge = resultSet.getString("SAK_CHARG_NR");
                    lieferant = resultSet.getString("SAK_LIEF_KKZ");
                    istmenge = resultSet.getString("SAK_MENGE_IST");
                    sakBuchMM = resultSet.getString("SAK_BUCH_MM");
                    korrKz = resultSet.getString("SAK_KORR_KZ");
                    zbl = resultSet.getString("SAK_ZBL");

                    if (zuschnittSys.equals("30")) {
                        zs = "[manuell]";
                    }
                    if (zuschnittSys.equals("10")) {
                        zs = "[cutter]";
                    }
                    if (zuschnittSys.equals("20")) {
                        zs = "[sonst]";
                    }

                    if (korrKz.equals("J")) {
                        bmonat = sakBuchMM;
                    } else {
                        bmonat = buchungsmonat;
                    }
                    if (personalNr == null) {
                        personalNr = "0000";
                    }

                    out.println("<tr><td>Personalnummer</td>");
                    out.println("<td><input type=\"text\" name=\"persNr\" value=" + personalNr + " size=\"4\" maxlength=\"4\"readonly>");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Zuschnittsystem</td>");
                    out.println("<td>" + zuschnittSys + "&nbsp;" + zs + "</td></tr>");
                    out.println("<tr><td>Charge</td>");
                    out.println("<td><input type=\"text\" name=\"charge\" value=" + charge + " size=\"10\" maxlength=\"10\"></input></td></tr>");
                    out.println("<tr><td>Lieferant</td>");
                    out.println("<td><input type=\"text\" name=\"lieferant\" value=" + lieferant + " size=\"4\" maxlength=\"4\">");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>Buchungsmonat</td>");
                    out.println("<td>" + bmonat + "</td></tr>");
                    out.println("<tr><td>IST Menge Sammelauftrag</td>");
                    out.println("<td><input type=\"text\" name=\"istmenge\"size=\"7\"maxlength=\"7\"value=\"" + istmenge + "\" readonly>");
                    out.println("&nbsp;qm</input>");
                    out.println("<tr><td>Mehrverbrauch</td>");
                    out.println("<td bgcolor=" + spezial1 + "><input type=\"text\" name=\"mverbrauch\"size=\"7\"maxlength=\"7\"value=\"" + mverbrauch + "\">&nbsp;qm");
                    out.println("</input></td></tr>");
                    out.println("<tr><td>R&uuml;ckgabemenge</td>");
                    out.println("<td bgcolor=" + spezial2 + "><input type=\"text\" name=\"rmenge\" size=\"7\" maxlength=\"7\"value=\"" + rmenge + "\"></input></td></tr>");
                    out.println("</td></tr>");
                    out.println("<tr><td>Vorgangsart</td>");
                    out.println("<td>21</td></tr>");
                    out.println("<tr><td>Verursacherschl&uuml;ssel</td>");
                    out.println("<td bgcolor=" + spezial + "><input type=\"text\" name=\"verkey\" size=\"2\" maxlength=\"2\"value=\"00\">");
                    out.println("</input>&nbsp;");
                    out.println("<input type=\"hidden\" name=\"schicht\" value=\"0\"></input>");
                    out.println("<input type=\"hidden\" name=\"sammelAbNr\" value=" + nummer + "></input>");
                    out.println("<input type=\"hidden\" name=\"sakArtNr\" value=" + sakArtNr + "></input>");
                    out.println("<input type=\"hidden\" name=\"sakBuchMM\" value=" + bmonat + "></input>");
                    out.println("<input type=\"hidden\" name=\"korrKz\" value=" + korrKz + "></input>");
                    out.println("<input type=\"hidden\" name=\"zsSys\" value=" + zuschnittSys + "></input>");
                    out.println("<input type=\"hidden\" name=\"werk\" value=" + werk + "></input>");
                    out.println("<input type=\"hidden\" name=\"checkvar\" value=" + checkvar + "></input>");
                    out.println("<input type=\"hidden\" name=\"zbl\" value=" + zbl + "></input>");
                    out.println("</td></tr>");
                    out.println("</table>");
                    out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
                    out.println("<tr><td>&nbsp;</td></tr>");
                    out.println("<tr><td><input type=\"submit\" value=\"Werte &uuml;bernehmen\"></td></tr></table></form>");
                }
            } catch (SQLException e) {
                out.println("Fehler bei der Datenbankabfrage<br><br>" + sql);
                out.println("<br><br>" + e);
            }
        }

        //### Bei falschen Parametern fuer Einzelbuchung dieses Typs:FEHLERMELDUNG ###

        else {
            out.println("<table border=\"0\" align=\"center\" cellspacing=\"1\"> ");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font color=\"#ff0000\" size=\"+1\">Fehler!Sammelauftrag nicht zur Korrekturbuchung vorgesehen!!</font>");
            out.println("</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Falsche Parameter f&uuml;r IMEZ/K VG=21:</td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td>Sammelauftragsnummer=<b>" + nummer + "</b></td></tr>");
            out.println("<tr><td>Artikelnummer=<b>" + sakArtNr + "</b></td></tr>");
            out.println("<tr><td>Status=<b>" + status + "</b></td></tr>");
            out.println("<tr><td>&nbsp;</td></tr>");
            out.println("<tr><td><font size=\"+1\"><a href=\"./index.html\" target=\"_top\">");
            out.println("<img src=\"./pfeil.gif\" border=\"0\">&nbsp;weiter</a></font></td></tr></table>");
        }
    }

    con.close();
%>
</body>
</html>
      


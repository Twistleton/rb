<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Arrays" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Kommissionierpapiere</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000"
      vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        String zeile = new String();
        String einheit = new String();
        String[] mt = new String[5]; //Materialtypen aus PLR_KOMMSYS
        String[] me = new String[31];//Masseinheiten vom HOST
//select distinct mt_me zeigt heute nur 10 und 20 an
        me[10] = "ST";
        me[20] = "M";
        me[30] = "QM";

        Statement stmt = con.createStatement();
        ResultSet rs, rs2, rs3;

        boolean einzel = true;

        try { // Auswahl eines Kommissioniersystems auftragsbezogen ...
            if (request.getParameter("abnr") != null && request.getParameter("kommsys") != null) {
                out.println("<h2><font color=\"#007FFF\">Auswertung ABNR=" + request.getParameter("abnr"));
                out.println(" &uuml;ber Kommissioniersystem=" + request.getParameter("kommsys") + "</font></h2>");
                out.println("<form method=post>");
                out.println("<table border=1 bgcolor=\"#007fff\">");
                out.println("<td><input type=\"submit\" name=\"abnr\" VALUE=\"beenden\"></td></table></form>");
                //prüft Gültigkeit der Eingabe
                sql = "select dok_dok_id from plrv11.bde_auftr_dok where ";
                sql += "dok_abnr=" + request.getParameter("abnr") + " and dok_dok_id=" + request.getParameter("kommsys");
                //out.println(sql+"<BR>");
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                //nur 1 DS pro DOK_ID
                while (rs.next()) {
                    //Kopfdaten zusammenstellen
                    sql = "SELECT ako_abnr, ako_fabt_pps, ako_prog, ako_prior,";
                    sql += "ako_se, ako_kunde, ako_werk_naht, ako_lfg, ako_kz_pg,";
                    sql += "ako_sf_hw_auftr, ako_aart2, ako_aart3 FROM plrv11.plr_auftr_kopf";
                    sql += " where ako_abnr=" + request.getParameter("abnr");
                    // out.println(sql+"<BR>");
                    stmt.executeQuery(sql);
                    rs2 = stmt.getResultSet();
                    out.println("<h1>AuftragsKopfdaten</h1>");
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR BGCOLOR=\"#ffdddd\"><TH>ABNR</TH><TH>FABT</TH><TH>PROG</TH><TH>PRIO</TH><TH>SE</TH>");
                    out.println("<TH>Kunde</TH><TH>Werk NA</TH><TH>LG</TH><TH>KZ P/G</TH><TH>KZ SF</TH><TH>A2</TH>");
                    out.println("<TH>A3</TH></TR>");
                    //nur 1 DS pro ABNR
                    while (rs2.next()) {
                        zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs2.getString("ako_abnr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_fabt_pps");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_prog");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_prior");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_se");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_kunde");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_werk_naht");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_lfg");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_kz_pg");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_sf_hw_auftr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_aart2");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ako_aart3");
                        zeile += "</TD></TR>";
                        out.println(zeile);
                    }
                    out.println("</TABLE>");

                    // Positionsdaten zusammenstellen
                    sql = "SELECT ap_abnr, ap_posnr, ap_menge, ap_me, ap_bezeichn,";
                    sql += "ap_artnr, ap_bezug, ap_bezbez, ap_vera_hw, ap_schw_grad, ap_holz_farbe,";
                    sql += "ap_klasse, ap_sf_hw from plrv11.plr_art_pos";
                    sql += " where ap_abnr=" + request.getParameter("abnr");
                    // out.println(sql+"<BR>");
                    stmt.executeQuery(sql);
                    rs2 = stmt.getResultSet();

                    out.println("<h1>ArtikelPositionen</h1>");
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR BGCOLOR=\"#ffdddd\">");
                    out.println("<TH>ABNR</TH><TH>POS</TH><TH>Menge</TH><TH>ME</TH><TH>Bezeichnung</TH>");
                    out.println("<TH>ART-Nr.</TH><TH>BezugNr</TH><TH>BezugName</TH>");
                    out.println("<TH>Verarb. HW</TH><TH>SCHW.Grad</TH><TH>Holzfarbe</TH>");
                    out.println("<TH>Klasse</TH><TH>SF</TH></TR>");
                    //mehrere Positionen sind möglich ...
                    while (rs2.next()) {
                        zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs2.getString("ap_abnr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_posnr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getFloat("ap_menge") / 100;
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_me");
                        zeile += "</TD><TD ALIGN=\"LEFT\">" + rs2.getString("ap_bezeichn");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_artnr");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_bezug");
                        zeile += "</TD><TD ALIGN=\"LEFT\">" + rs2.getString("ap_bezbez");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_vera_hw");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_schw_grad");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_holz_farbe");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_klasse");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("ap_sf_hw");
                        zeile += "</TD></TR>";
                        out.println(zeile);
                    }
                    out.println("</TABLE>");

                    //Ermitteln der Materialtypen
                    sql = "SELECT KOM_MT_TYP FROM plrv11.BDE_KOMMSYS WHERE KOM_DOK_ID =" + request.getParameter("kommsys");
                    //out.println(sql+"<BR>");
                    stmt.executeQuery(sql);
                    rs2 = stmt.getResultSet();
                    out.println("<h1>MaterialPositionen</h1>");
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR BGCOLOR=\"#ffdddd\"><TH>ABNR</TH>");
                    einzel = Boolean.valueOf(request.getParameter("matpos")).booleanValue();
                    if (einzel) {
                        out.println("<TH>POS</TH>");
                    }
                    out.println("<TH>Menge</TH><TH>ME</TH><TH>TeileNr.</TH><TH>Bezeichnung</TH>");
                    out.println("<TH>L&auml;nge</TH><TH>Breite</TH><TH>Tiefe</TH></TR>");
                    //nur 1 DS pro DOK_ID
                    while (rs2.next()) {
                        //out.println("Materialtypen:"+rs.getString("kom_mt_typ"));
                        //Arrays.fill(mt,null);
                        //mt = rs2.getString("kom_mt_typ").split(",",5);
                        //mehrere Materialtypen sind möglich ...
                        //for (int i=0; i<mt.length; i++) {
                        if (einzel) {
                            sql = "SELECT mt_abnr, mt_posnr,mt_menge, mt_me, mt_teilenr, mt_bezeichn,";
                            sql += " mt_laenge, mt_breite, mt_tiefe from plrv11.plr_mat_dat";
                            sql += " where mt_abnr=" + request.getParameter("abnr");
                            sql += " and mt_mat_typ in (" + rs2.getString("kom_mt_typ") + ")";
                            sql += " order by mt_posnr, mt_teilenr";
                        } else {
                            sql = "SELECT mt_abnr,sum(mt_menge),mt_me,mt_teilenr,mt_bezeichn,";
                            sql += "mt_laenge, mt_breite, mt_tiefe from plrv11.plr_mat_dat";
                            sql += " where mt_abnr=" + request.getParameter("abnr");
                            sql += " and mt_mat_typ in (" + rs2.getString("kom_mt_typ") + ")";
                            sql += " group by mt_abnr,mt_me,mt_teilenr,mt_bezeichn,mt_laenge,mt_breite,mt_tiefe";
                            sql += " order by mt_teilenr";
                        }
                        //out.println("Materialanzeige :"+request.getParameter("matpos")+"<BR>");
                        stmt.executeQuery(sql);
                        rs3 = stmt.getResultSet();
                        while (rs3.next()) {
                            zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs3.getString("mt_abnr");
                            if (einzel) {
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getString("mt_posnr");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getFloat("mt_menge") / 100;
                            } else {
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getFloat("sum(mt_menge)") / 100;
                            }
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + me[rs3.getInt("mt_me")];
                            zeile += "</TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"#00AFFF\">" + rs3.getString("mt_teilenr");
                            zeile += "</TD><TD ALIGN=\"LEFT\">" + rs3.getString("mt_bezeichn");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getString("mt_laenge");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getString("mt_breite");
                            zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs3.getString("mt_tiefe");
                            zeile += "</TD></TR>";
                            out.println(zeile);
                        }
                        //}
                    }
                    out.println("</TABLE>");
                }
            } else {
                //Kopflayout Rolf Benz
                out.println("<table  width=100% align=\"center\">");
                out.println("<tr>");
                out.println("<td align=\"left\"><img src=\"/rb-logo.gif\"></td>");
                out.println("<td align=center bgcolor=\"#007FFF\">");
                out.println("<font FACE=\"ARIAL\" SIZE=\"5\"><b>KOM-Belege zu einem Auftrag</b></font></td>");
                out.println("<td align=\"right\">" + bdeZeit.getTimestamp("dd.MM.yyyy") + "</td>");
                out.println("</tr>");
                out.println("</table>");
                out.println("</p><hr><p>");
                // AB-Nr-Eingabefeld
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr><td align=center>");
                out.println("<form method=post>ABNR :");
                out.println("<input type=\"text\" name=\"abnr\" tabindex=\"1\" size=\"6\" maxlength=\"6\">");
                out.println("Belegauswahl : <select name=\"kommsys\" size=\"1\">");
                //out.println("<option value=14>P.Anh&auml;nger</option>");
                out.println("<option value=38>Gestell</option>");
                out.println("<option value=41>VOPO</option>");
                out.println("<option value=43>POL</option>");
                out.println("<option value=44>Rote K&uuml;bel</option></select>");
                out.println("Materialposition : <select name=\"matpos\" size=\"1\">");
                out.println("<option value=\"true\">Einzeln</option>");
                out.println("<option value=\"false\">Summe</option></select>");
                out.println("<input type=\"submit\" name=\"auswahl\" VALUE=\"OK\">");
                out.println("</td></tr></form></TABLE>");
                out.println("</p><hr><p>");
            }
        }
        catch (Exception ex) {
            out.println("---nix ausgew&auml;hlt---" + ex.getMessage() + "<BR>");
            ex.printStackTrace();
        }
        con.close();
    %>
</CENTER>
</body>
</html>

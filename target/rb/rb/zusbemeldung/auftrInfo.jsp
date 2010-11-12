<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <title>R&uuml;ckmeldung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.rueckForm.komArtAbNr.focus()"
">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    String sql = new String();
    ResultSet rs;
    int abNr = 0;
    int status = 0;
    int werk = 0;

    DecimalFormat df = new DecimalFormat("#######0.00");
    if (request.getParameter("abNr") != null) {
        try {
            abNr = Integer.parseInt(request.getParameter("abNr"));

            sql = "SELECT ";
            sql += "ako_fabt_pps,ako_fabt_zuschn,ako_werk_naht,ako_werk_polst,ako_se,";
            sql += "ako_bnr3,ako_prog,ako_werk_zuschn,ako_sf_hw_auftr ";
            sql += "from plrv11.plr_auftr_kopf,plrv11.plr_auftr_status where ako_abnr=" + abNr;
            sql += " AND ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix AND as_status<>99";
            // out.println(sql);
            out.println("<H2>Information &uuml;ber Auftrag " + abNr + "</H2>");
            out.println("<TABLE BORDER=1>");
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                out.println("<TR><TD>Programm</TD><TD>");
                out.println(rs.getString("ako_prog") + "</TD>");
                out.println("<TD>Sitzeinheiten</TD><TD>");
                out.println(rs.getString("ako_se") + "</TD>");
                if (rs.getString("ako_sf_hw_auftr").compareTo("S") == 0) {
                    out.println("<TD BGCOLOR=\"red\">Sonderfertigung Auftr</TD>");
                    out.println("<TD BGCOLOR=\"red\">" + rs.getString("ako_sf_hw_auftr") + "</TD>");
                } else {
                    out.println("<TD>Sonderfertigung Auftr</TD>");
                    out.println("<TD>" + rs.getString("ako_sf_hw_auftr") + "</TD>");
                }

                out.println("<TD>B&uuml;ndelnummer</TD><TD>");
                out.println(rs.getString("ako_bnr3") + "</TD></TR>");
                out.println("<TR><TD>Fabt Zuschnitt</TD><TD>");
                out.println(rs.getString("ako_fabt_zuschn") + "</TD><TD></TD><TD></TD><TD></TD><TD></TD>");
                out.println("<TD>Werk Zuschnitt</TD><TD>");
                out.println(rs.getString("ako_werk_zuschn") + "</TD></TR>");
                out.println("<TR><TD>&nbsp;</TD><TD>");
                out.println("&nbsp;</TD>");
                out.println("<TD></TD><TD></TD><TD></TD><TD></TD><TD>Werk Naht</TD><TD>");
                out.println(rs.getString("ako_werk_naht") + "</TD></TR>");
                out.println("<TR><TD>Fabt Polstern</TD><TD>");
                out.println(rs.getString("ako_fabt_pps") + "</TD><TD></TD><TD></TD><TD></TD><TD></TD>");
                out.println("<TD>Werk Polstern</TD><TD>");
                out.println(rs.getString("ako_werk_polst") + "</TD></TR>");
                werk = rs.getInt("ako_werk_zuschn");
            }
            out.println("</TABLE>");
            // Auftragspositionen
            sql = "SELECT ";
            sql += "ap_posnr,ap_menge,ap_artnr,ap_bezeichn,ap_bezug ";
            sql += "from plrv11.plr_art_pos,plrv11.plr_auftr_status where ap_abnr=" + abNr;
            sql += " AND ap_abnr=as_abnr AND ap_aend_ix=as_aend_ix AND as_status<>99 ";
            sql += " ORDER BY ap_posnr";
            out.println("<TABLE BORDER=1>");
            rs = stmt.executeQuery(sql);
            out.println("<TR BGCOLOR=\"ffdddd\"><TH ALIGN=\"CENTER\" COLSPAN=\"9\">Auftrags-Positionen</TH></TR>");
            out.println("<TR BGCOLOR=\"ddddff\">");
            out.println("<TD ALIGN=\"CENTER\" >Pos</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Menge</TD>");
            out.println("<TD ALIGN=\"CENTER\" COLSPAN=\"3\">Modell-Nr</TD>");
            out.println("<TD COLSPAN=\"3\">Modell-Bez</TD>");
            out.println("<TD>Bezugs-Nr (VK)</TD></TR>");
            while (rs.next()) {
                out.println("<TR><TD>" + rs.getString("ap_posnr") + "</TD><TD>");
                out.println((rs.getInt("ap_menge") / 100) + "</TD><TD COLSPAN=\"3\" ALIGN=\"CENTER\">");
                out.print(rs.getString("ap_artnr").substring(3, 6) + ".");
                out.print(rs.getString("ap_artnr").substring(6, 9) + ".");
                out.print(rs.getString("ap_artnr").substring(9));
                out.println("</TD><TD COLSPAN=\"3\" ALIGN=\"CENTER\">");
                out.println(rs.getString("ap_bezeichn") + "</TD><TD ALIGN=\"CENTER\">");
                out.print(rs.getString("ap_bezug").substring(3, 5) + ".");
                out.println(rs.getString("ap_bezug").substring(5, 8) + "</TD></TR>");
            }
//		out.println("</TABLE>");

            // Kommissionen
            sql = "SELECT ";
            sql += "kom_sammel_abnr,kom_art_nr,art_bez,kom_zs_sys,kom_gebucht_kz,kom_status,kom_ab_gedruckt ";
            sql += "FROM plrv11.zus_kommission,plrv11.plr_art_kopf where kom_abnr=" + abNr;
            sql += " AND kom_art_nr=art_nr ";
            sql += " ORDER BY kom_art_nr";
//		out.println("<TABLE BORDER=1>");
            rs = stmt.executeQuery(sql);
            out.println("<TR BGCOLOR=\"ffdddd\"><TH ALIGN=\"CENTER\" COLSPAN=\"9\">Kommissionen</TH></TR>");
            out.println("<TR BGCOLOR=\"ddddff\">");
            out.println("<TD ALIGN=\"CENTER\">S-AbNr</TD>");
            out.println("<TD ALIGN=\"CENTER\">Bezugs-Nr<BR>(Lager)</TD>");
            out.println("<TD ALIGN=\"CENTER\" COLSPAN=\"3\">Bezugs-Bez</TD>");
            out.println("<TD ALIGN=\"CENTER\">ZS-Sys</TD>");
            out.println("<TD ALIGN=\"CENTER\">Status</TD>");
            out.println("<TD ALIGN=\"CENTER\">KZ-Gebucht</TD>");
            out.println("<TD ALIGN=\"CENTER\">Papiere Gedruckt</TD></TR>");
            while (rs.next()) {
                status = rs.getInt("kom_status");

                out.println("<TR><TD><A HREF=\"../zusadmin/zusSammelAbNrAus.jsp?sANr=");
                out.println(rs.getString("kom_sammel_abnr") + "\">");
                out.println(rs.getString("kom_sammel_abnr") + "</A></TD><TD>");
                out.print(rs.getString("kom_art_nr").substring(3, 5) + ".");
                out.println(rs.getString("kom_art_nr").substring(5, 8) + "</TD><TD ALIGN=\"CENTER\" COLSPAN=\"3\">");
                out.println(rs.getString("art_bez") + "</TD><TD ALIGN=\"CENTER\" >");
                out.println(rs.getString("kom_zs_sys") + "</TD><TD ALIGN=\"CENTER\" >");
                out.println(rs.getString("kom_status") + "</TD><TD ALIGN=\"CENTER\" >");
                out.println(rs.getString("kom_gebucht_kz") + "</TD><TD ALIGN=\"CENTER\" >");
                out.println(rs.getString("kom_ab_gedruckt") + "</TD></TR>");
            }
//		out.println("</TABLE>");

            // Kommissions-Fertigungsstufen
            sql = "SELECT ";
            sql += " kfs_artnr,kfs_ordnr,kfs_fs,kfs_tr,kfs_te,kfs_dezi,kfs_pnr,kfs_fs_status,att_bez ";
            sql += " FROM plrv11.zus_kom_fs INNER JOIN plrv11.plr_attrAttr ON att_attr=kfs_fs ";
            sql += " WHERE att_tabname='fs' ";
            sql += " AND kfs_abnr=" + abNr;
            sql += " ORDER BY kfs_abnr,kfs_ordnr";
//		out.println("<TABLE BORDER=1>");
            rs = stmt.executeQuery(sql);
            out.println("<TR BGCOLOR=\"ffdddd\"><TH ALIGN=\"CENTER\" COLSPAN=\"9\">Fertigungsstufen</TH></TR>");
            out.println("<TR BGCOLOR=\"ddddff\">");
            out.println("<TD ALIGN=\"CENTER\" >Bezugs-Nr</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Ord-Nr</TD>");
            out.println("<TD ALIGN=\"CENTER\" >TR</TD>");
            out.println("<TD ALIGN=\"CENTER\" >TE</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Dezi</TD>");
            out.println("<TD ALIGN=\"CENTER\" >P-Nr</TD>");
            out.println("<TD ALIGN=\"CENTER\" COLSPAN=\"2\">Fertigungsstufe</TD>");
            out.println("<TD ALIGN=\"CENTER\" >FS-Status</TD></TR>");
            while (rs.next()) {
                out.print("<TR><TD ALIGN=\"CENTER\" >" + rs.getString("kfs_artnr").substring(3, 5));
                out.println("." + rs.getString("kfs_artnr").substring(5, 8));
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString("kfs_ordnr"));
                out.println("</TD><TD ALIGN=\"RIGHT\" >" + df.format(rs.getFloat("kfs_tr") / 10));
                out.println("</TD><TD ALIGN=\"RIGHT\" >" + df.format(rs.getFloat("kfs_te") / 10));
                out.println("</TD><TD ALIGN=\"RIGHT\" >");
                out.println(df.format(rs.getFloat("kfs_dezi") / 10) + "</TD><TD>");
                if (rs.getString("kfs_pnr") != null) {
                    out.println(rs.getString("kfs_pnr") + "</TD>");
                } else {
                    out.println("&nbsp;</TD>");
                }
                out.println("<TD COLSPAN=\"2\">");
                out.println(rs.getString("att_bez") + "</TD><TD>");
                if (rs.getString("kfs_fs_status") != null) {
                    out.println(rs.getString("kfs_fs_status") + "</TD></TR>");
                } else {
                    out.println("&nbsp;</TD></TR>");
                }
            }
            out.println("</TABLE><TABLE CELLPADDING=\"4\"><TR><TD><TABLE>");
            out.println("<TR BGCOLOR=\"#ff0000\"><TD COLSPAN=\"4\" ALIGN=\"CENTER\">");
            out.println("<FORM ACTION=\"../ldzusplanung/auftrLoesch.jsp\" METHOD=\"POST\" NAME=\"loesch\">");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"abNr\" VALUE=\"" + abNr + "\">");
            out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"loeschen\" VALUE=\"Auftrag L&ouml;schen\">");
            out.println("</FORM></TD></TR></TABLE>");
            out.println("</TD>");
            if ((status == 0) && (werk == 10)) {
                out.println("<TD><TABLE> <TR BGCOLOR=\"#0000ff\"><TD COLSPAN=\"4\" ALIGN=\"CENTER\">");
                out.println("<FORM ACTION=\"../ldzusplanung/auftrBeschl.jsp\" METHOD=\"POST\" NAME=\"loesch\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"abNr\" VALUE=\"" + abNr + "\">");
                out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"beschl\" VALUE=\"Auftrag Beschleunigen\">");
                out.println("</FORM></TD></TR></TABLE></TD>");
            } else if (status != 0) {
                out.println("<TD>läuft bereits</TD>");
            } else if (werk != 10) {
                out.println("<TD>Keine Beschleunigung m&ouml;glich: Werk>10</TD>");
            }
            out.println("</TR></TABLK>");
        }
        catch (Exception e) {
            out.println("<CENTER><FONT COLOR=\"red\">Fehlerhafte Eingabe!<BR>" + e.getMessage());
            out.println("Änderung nicht durchgef&uuml;hrt!<BR>" + e.getMessage() + "</FONT></CENTER>");
        }
    }

    con.close();

%>
</body>
</html>

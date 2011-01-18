<!--JSP-Import-Files-->

<%@ page errorPage="myErrorPage.jsp" %>

<%@ page import="com.rolfbenz.bdeDb" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.text.DecimalFormat" %>

<html>
<head>
    <title>R&uuml;ckmeldung</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.rueckForm.komArtAbNr.focus()">
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
            out.println("<br>");

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
            out.println("</TABLE>");
            out.println("<br>");

            //
            // Auftragsinfo (Hinweise)
            //
            sql = "SELECT ai_id									" +
                    "     , ai_hinweistext								" +
                    "     , ai_von_kst								" +
                    "     , to_char(ai_erdat, 'DD.MM.YYYY') 					" +
                    "     , ai_eruserid								" +
                    "     , to_char(ai_aedat, 'DD.MM.YYYY') 					" +
                    "     , ai_aeuserid								" +
                    "  FROM plrv11.plr_auftr_info 							" +
                    " WHERE ai_abnr   = " + abNr +
                    "   AND ai_an_kst = '171'							" +
                    " ORDER BY ai_id								";

            rs = stmt.executeQuery(sql);

            out.println("<TABLE BORDER=1>");
            out.println("<TR BGCOLOR=\"ffdddd\"><TH ALIGN=\"CENTER\" COLSPAN=\"9\">Auftragsinformationen</TH></TR>");
            out.println("<TR BGCOLOR=\"ddddff\">");
            out.println("<TD ALIGN=\"CENTER\" >lfd. Nr</TD>");
            out.println("<TD ALIGN=\"LEFT\"   >Hinweistext</TD>");
            out.println("<TD ALIGN=\"CENTER\" >von KST</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Erstelldatum</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Ersteller</TD>");
            out.println("<TD ALIGN=\"CENTER\" >&Auml;nderungsdatum</TD>");
            out.println("<TD ALIGN=\"CENTER\" >Bearbeiter</TD></TR>");

            while (rs.next()) {
                out.println("<TR><TD  ALIGN=\"RIGHT\">" + rs.getString("ai_id"));
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString("ai_hinweistext"));
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString("ai_von_kst"));
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString(4));
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString("ai_eruserid"));
                if (rs.getString(6) == null) {
                    out.println("</TD><TD ALIGN=\"LEFT\" >-");
                } else {
                    out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString(6));
                }
                out.println("</TD><TD ALIGN=\"LEFT\" >" + rs.getString("ai_aeuserid"));
                out.println("</TD></TR>");
            }

            out.println("</TABLE>");

        }
        catch (Exception e) {

            throw new Exception("keine Auftragsnummer eingegeben!");

        }

    }

    con.close();

%>
</body>
</html>

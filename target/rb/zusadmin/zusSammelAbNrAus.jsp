<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>

<html>
<head>
    <title>Sammel-Auftrag anzeigen</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        Connection con = oraBde.getConnection();

        Statement stmt = con.createStatement();
        Statement stmtFs = con.createStatement();
        ResultSet rs;
        ResultSet rsFs;
        DecimalFormat df = new DecimalFormat("####0.0");


        String sql = new String();
        String sqlFs = new String();

        long sANr = 0;
        int druck = 0;
        int platzBelegt = 0;

        try {
            sANr = Long.parseLong(request.getParameter("sANr"));
        }
        catch (Exception e) {
            out.println(e);
        }
        try {
            druck = Integer.parseInt(request.getParameter("druck"));
            out.println("Papiere f&uuml;r Sammelauftrag ausgedruckt<BR>");

            // ***************** Auftragspapiere drucken ****************************
            druckDatei apd = new druckDatei(zcd.getAbpDruckPfad(), "auftragsPapierDatei", zcd.getAbpEndung());
            apd.setNameTimestamp();
            apd.oeffnen();
            apd.arbeitsBegleitpapiere(sANr, con);
            apd.schliessen();
            apd.aktiviereDatei();
            apd.drucken(zcd.getManZusDrucker());
        }
        catch (Exception e) {
        }
        try {
            if (sANr != 0) {
                out.println("<TABLE BORDER=1>");
                out.println("<TR><TD COLSPAN=\"5\" BGCOLOR=\"#FFDDDD\" ALIGN=\"CENTER\" >Sammel-AB-Nr</TD></TR>");
                out.println("<TR><TD COLSPAN=\"5\"  ALIGN=\"CENTER\" >" + sANr + "</TD></TR>");

                sql = " SELECT ";
                sql += " sak_platz,sak_pnr ";
                sql += " FROM plrv11.zus_sammel_kopf ";
                sql += " WHERE sak_sanr=" + sANr;
                sql += " AND sak_platz is not null";
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                    out.println("<TR><TD ALIGN=\"CENTER\" COLSPAN=\"4\">Pufferplatz: ");
                    if ((rs.getString("sak_platz") != null) && (rs.getString("sak_platz").length() > 8)) {
                        out.println(rs.getString("sak_platz").substring(8));
                        platzBelegt = 1;
                    } else {
                        out.println("&nbsp;");
                    }
                    out.println("<TD ALIGN=\"CENTER\" >Personal-Nr.: " + rs.getString("sak_pnr") + "</TD>");
                    out.println("</TR>");
                }
                // Kommissionen
                sql = " SELECT ";
                sql += " kom_abnr,kom_art_nr,kom_prog,kom_gebucht_kz ";
                sql += " FROM plrv11.zus_kommission";
                sql += " WHERE kom_sammel_abnr=" + sANr;
                sql += " ORDER BY kom_abnr";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                out.println("<TR BGCOLOR=\"#FFDDDD\">");
                out.println("<TD ALIGN=\"CENTER\">AB-Nr</TD>");
                out.println("<TD ALIGN=\"CENTER\">Art-Nr</TD>");
                out.println("<TD ALIGN=\"RIGHT\">Prog</TD>");
                out.println("<TD ALIGN=\"RIGHT\">Gebucht</TD>");
                out.println("<TD ALIGN=\"CENTER\">FS</TD></TR>");
                while (rs.next()) {
                    out.println("<TR><TD><A HREF=\"../zusbemeldung/auftrInfo.jsp?abNr=");
                    out.println(rs.getString("kom_abnr") + "\">");
                    out.println(rs.getString("kom_abnr") + "</A></TD><TD>");
                    out.println(rs.getString("kom_art_nr").substring(3, 5) + ".");
                    out.println(rs.getString("kom_art_nr").substring(5, 8) + "</TD><TD ALIGN=\"RIGHT\">");
                    out.println(rs.getString("kom_prog") + "</TD><TD ALIGN=\"CENTER\">");
                    out.println(rs.getString("kom_gebucht_kz") + "</TD><TD>");

                    // Kommissionsfertigungsstufen
                    sqlFs = "SELECT ";
                    sqlFs += " kfs_ordnr,kfs_fs,att_bez,kfs_fs_text,kfs_fs_status,kfs_pnr,kfs_dezi ";
                    sqlFs += " FROM plrv11.zus_kom_fs ";
                    sqlFs += " INNER JOIN plrv11.plr_attrAttr ON att_attr=kfs_fs ";
                    sqlFs += " WHERE kfs_abnr   =" + rs.getString("kom_abnr");
                    sqlFs += " AND   kfs_artnr  =" + rs.getString("kom_art_nr");
                    sqlFs += " AND   att_tabname='fs' ";
                    sqlFs += " AND   kfs_fs     ='10244100000' ";
                    sqlFs += " ORDER BY kfs_ordnr";
                    stmtFs.executeQuery(sqlFs);
                    rsFs = stmtFs.getResultSet();
                    out.println("<TABLE BORDER=1>");
                    out.println("<TR BGCOLOR=\"#DDDDFF\">");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\" 50\">Ord-Nr</TD>");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\"200\">FS</TD>");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\" 50\">Dezi</TD>");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\" 50\">FS-Text</TD>");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\" 50\">FS-Status</TD>");
                    out.println("<TD ALIGN=\"CENTER\" WIDTH=\" 50\">PNr</TD></TR>");
                    while (rsFs.next()) {
                        out.println("<TR><TD ALIGN=\"RIGHT\">");
                        out.println(rsFs.getString("kfs_ordnr") + "</TD><TD>");
                        out.println(rsFs.getString("att_bez") + "</TD><TD ALIGN=\"right\">");
                        out.println(df.format(rsFs.getFloat("kfs_Dezi") / 10) + "</TD><TD>");
                        if (rsFs.getString("kfs_fs_text") != null) {
                            out.println(rsFs.getString("kfs_fs_text"));
                        } else {
                            out.println("&nbsp;");
                        }
                        out.println("</TD><TD ALIGN=\"right\">");
                        if (rsFs.getString("kfs_fs_status") != null) {
                            out.println(rsFs.getString("kfs_fs_status"));
                        } else {
                            out.println("&nbsp;");
                        }
                        out.println("</TD><TD ALIGN=\"right\">");
                        if (rsFs.getString("kfs_fs_status") != null) {
                            out.println(rsFs.getString("kfs_pnr"));
                        } else {
                            out.println("&nbsp;");
                        }
                        out.println("</TD></TR>");
                    }
                    out.println("</TABLE></TD></TR>");
                }
                out.println("<TR><TD>");
                out.println("<FORM ACTION=\"zusSammelAbNrAus.jsp\" METHOD=\"POST\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"sANr\"  VALUE=\"" + sANr + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"druck\" VALUE=\"1\">");
                out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Drucken\">");
                out.println("</FORM>");
                out.println("</TD>");
                if (platzBelegt == 1) {
                    out.println("<TD COLSPAN=\"3\">");
                    out.println("<FORM ACTION=\"liefChargeEin.jsp\" METHOD=\"POST\">");
                    out.println("<INPUT TYPE=\"hidden\" NAME=\"sANr\"  VALUE=\"" + sANr + "\">");
                    out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"Lieferant/Charge &auml;ndern\">");
                    out.println("</FORM></TD>");
                }
                out.println("</TR></TABLE>");
            }
        }
        catch (Exception e) {
            out.println(e);
        }
    %>
</CENTER>
</BODY>
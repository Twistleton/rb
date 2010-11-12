<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Arrays" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Teilesperre Gestellabruf</title>
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
        String bezeichn = new String();
        String teilenr = new String();
        String sperrgr = new String();

        Statement stmt = con.createStatement();
        Statement stmt2 = con.createStatement();
        ResultSet rs, rs2, rs3;

        boolean gesperrt;

        try { // Auswahl einer Teilenummer zum Sperren/Entsperren ...
            if (request.getParameter("teil") != null) { // Teilenummer sperren/entsperren
                //out.println("Teilenummer wurde ausgew&auml;hlt<br>");
                gesperrt = false;
                if (request.getParameter("aktion").compareTo("1") == 0 || request.getParameter("aktion").compareTo("3") == 0) {
                    //out.println("Aktion 1 sperren oder 3 entsperren wurde ausgew&auml;hlt<br>");
                    sql = "select distinct mt_bezeichn from plrv11.plr_mat_dat where ";
                    sql += "mt_teilenr='" + request.getParameter("teil") + "'";
                    stmt.executeQuery(sql);
                    rs = stmt.getResultSet();
                    bezeichn = "nicht gefunden";
                    while (rs.next()) {
                        //out.println("Teilenummer wurde in plr_mat_dat gesichtet<br>");
                        bezeichn = rs.getString("mt_bezeichn");
                        sql = "select * from plrv11.plr_teile_sperren where tsp_tnr='" + request.getParameter("teil") + "'";
                        stmt.executeQuery(sql);
                        rs2 = stmt.getResultSet();
                        while (rs2.next()) { // wenn Teilenummer in plr_teile_sperren ...
                            gesperrt = true;
                            if (request.getParameter("aktion").compareTo("3") == 0) {// entsperren
                                out.println("<h2><font color=\"#007FFF\">Entsperrung durchf&uuml;hren ...</h2>");
                                out.println("<TABLE BORDER=1>");
                                out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Teilenummer</TH><TH>Bezeichnung</TH><TH>entsperrt</TH>");
                                zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs2.getString("tsp_tnr");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("tsp_bezeichnung");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + bdeZeit.getTimestamp("dd.MM.yyyy");
                                zeile += "</TD></TR>";
                                out.println(zeile);
                                out.println("</TABLE>"); // besteht aus 1 Teilenummer
                                sql = "delete plrv11.plr_teile_sperren where tsp_tnr='" + request.getParameter("teil") + "'";
                                stmt.executeQuery(sql);
                                sql = "update plrv11.plr_ga_dat set ga_sperr_kz='N' where ga_abnr in ";
                                sql += "(select distinct mt_abnr from plrv11.plr_mat_dat where ";
                                sql += "mt_teilenr='" + request.getParameter("teil") + "')";
                                stmt.executeQuery(sql);
                                sql = "select tsp_tnr from plrv11.plr_teile_sperren";
                                stmt.executeQuery(sql);
                                rs3 = stmt.getResultSet();
                                while (rs3.next()) { // alle ABNR sperren, die in plr_teile_sperren ...
                                    sql = "update plrv11.plr_ga_dat set ga_sperr_kz='J' where ga_abnr in ";
                                    sql += "(select distinct mt_abnr from plrv11.plr_mat_dat where ";
                                    sql += "mt_teilenr='" + rs3.getString("tsp_tnr") + "')";
                                    stmt.executeQuery(sql);
                                }
                            }
                        }
                    }
                    if (request.getParameter("aktion").compareTo("3") == 0 && bezeichn == "nicht gefunden") {// entsperren ...
                        sql = "delete plrv11.plr_teile_sperren where tsp_tnr='" + request.getParameter("teil") + "'";
                        stmt.executeQuery(sql);
                    }
                    if (request.getParameter("aktion").compareTo("1") == 0 && gesperrt == false) {// sperren einer Teilenummer ...
                        out.println("<h2><font color=\"#007FFF\">Sperrung durchf&uuml;hren ...</h2>");
                        //out.println(request.getParameter("sperrgr"));
                        sql = "insert into plrv11.plr_teile_sperren values ('" + request.getParameter("teil") + "','" + bezeichn;
                        sql += "','" + request.getParameter("sperrgr") + "','" + bdeZeit.getTimestamp("dd.MM.yyyy") + "')";
                        //out.println(sql);
                        stmt.executeQuery(sql);
                        sql = "update plrv11.plr_ga_dat set ga_sperr_kz='J' where ga_status<40 and ga_abnr in ";
                        sql += "(select distinct mt_abnr from plrv11.plr_mat_dat where ";
                        sql += "mt_teilenr='" + request.getParameter("teil") + "')";
                        stmt.executeQuery(sql);
                        out.println("<TABLE BORDER=1>");
                        out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Teilenummer</TH><TH>Bezeichnung</TH><TH>gesperrt</TH>");
                        zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + request.getParameter("teil");
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + bezeichn;
                        zeile += "</TD><TD ALIGN=\"RIGHT\">" + bdeZeit.getTimestamp("dd.MM.yyyy");
                        zeile += "</TD></TR>";
                        out.println(zeile);
                        out.println("</TABLE>"); // besteht aus einer Zeile = Teilenummer
                    }
                } else {
                    if (request.getParameter("aktion").compareTo("4") == 0) {
                        if (request.getParameter("teil").compareTo("") != 0) {
                            sql = "select tsp_tnr, tsp_bezeichnung, tsp_flag from plrv11.plr_teile_sperren where ";
                            sql += "tsp_tnr='" + request.getParameter("teil") + "'";
                        } else   // alle ABNR ...
                            sql = "select tsp_tnr, tsp_bezeichnung, tsp_flag from plrv11.plr_teile_sperren";

                        stmt.executeQuery(sql);
                        rs = stmt.getResultSet();
                        while (rs.next()) { // eine oder alle Teilenummern
                            teilenr = rs.getString("tsp_tnr");
                            bezeichn = rs.getString("tsp_bezeichnung");
                            if (rs.getString("tsp_flag").compareTo("X") == 0)
                                sperrgr = "gesperrt";
                            else
                                sperrgr = "fehlt";
                            out.println("<h2><font color=\"#007FFF\">Liste gesperrter ABNR zu " + teilenr + "</font></h2>");
                            out.println("<TABLE BORDER=1>");
                            out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Auftrag</TH><TH>Teilenummer</TH><TH>Bezeichnung</TH>");
                            out.println("<TH>GA_SOLL</TH><TH>PROG</TH><TH>SE</TH><TH>GA_STATUS</TH><TH>GRUND</TH>");
                            sql = "select distinct mt_abnr, mt_bezeichn, ga_abrtag_soll, ga_prog, ga_se, ga_status from plrv11.plr_mat_dat, plrv11.plr_ga_dat where mt_teilenr='" + teilenr + "' and ga_abnr=mt_abnr and ga_status<40 and ga_sperr_kz='J' order by ga_abrtag_soll";
                            stmt2.executeQuery(sql);
                            rs2 = stmt2.getResultSet();
                            while (rs2.next()) {
                                zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs2.getInt("mt_abnr");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + teilenr;
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getString("mt_bezeichn");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getInt("ga_abrtag_soll");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getInt("ga_prog");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getInt("ga_se");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs2.getInt("ga_status");
                                zeile += "</TD><TD ALIGN=\"RIGHT\">" + sperrgr;
                                zeile += "</TD></TR>";
                                out.println(zeile);
                            }
                            rs2.close();
                            out.println("</TABLE>");
                        }
                    }
                }
            } // Liste wird in allen Modi angezeigt = aktion 2
            if (request.getParameter("aktion") != null) {
                out.println("<h2><font color=\"#007FFF\">Liste aktuell gesperrter Teile</font></h2>");
                out.println("<TABLE BORDER=1>");
                out.println("<TR BGCOLOR=\"#ffdddd\"><TH>Teilenummer</TH><TH>Bezeichnung</TH><TH>gesperrt seit</TH><TH>Grund</TH>");
                sql = "select * from plrv11.plr_teile_sperren order by tsp_timestamp desc";
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) { // Liste der gesperrten Teile
                    zeile = "<TR><TD ALIGN=\"RIGHT\" BGCOLOR=\"#FFDDDD\">" + rs.getString("tsp_tnr");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("tsp_bezeichnung");
                    zeile += "</TD><TD ALIGN=\"RIGHT\">" + rs.getString("tsp_timestamp");
                    if (rs.getString("tsp_flag").compareTo("X") == 0)
                        zeile += "</TD><TD ALIGN=\"RIGHT\">Sperre";
                    else
                        zeile += "</TD><TD ALIGN=\"RIGHT\">Fehlteil";
                    zeile += "</TD></TR>";
                    out.println(zeile);
                }
                out.println("</TABLE>");
                out.println("<form method=post>");
                out.println("<table border=1 bgcolor=\"#007fff\">");
                out.println("<td><input type=\"submit\" name=\"ende\" VALUE=\"beenden\"></td></table></form>");
            } else {
                //Kopflayout Rolf Benz
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr>");
                out.println("<td align=\"left\"><img src=\"/rb-logo.gif\"></td>");
                out.println("<td align=center bgcolor=\"#007FFF\">");
                out.println("<font FACE=\"ARIAL\" SIZE=\"5\"><b>Teilenummer zum Gestellabruf sperren/entsperren</b></font></td>");
                out.println("<td align=\"right\">" + bdeZeit.getTimestamp("dd.MM.yyyy") + "</td>");
                out.println("</tr>");
                out.println("</TABLE>");
                out.println("</p><hr><p>");
                // Eingabefelder
                out.println("<TABLE  width=100% align=\"center\">");
                out.println("<tr><td align=center>");
                out.println("<form method=post>TEILE-Nummer (10-stellig):");
                out.println("<input type=\"text\" name=\"teil\" tabindex=\"1\" size=\"10\" maxlength=\"10\">");
                out.println("Aktion : <select name=\"aktion\" size=\"1\">");
                out.println("<option value=\"1\">Sperren Teilenummer</option>");
                out.println("<option value=\"2\">Liste gesperrter Teile</option>");
                out.println("<option value=\"3\">Entsperren Teilenummer</option>");
                out.println("<option value=\"4\">Liste gesperrter ABNR</option></select>");
                out.println("Material : <select name=\"sperrgr\" size=\"1\">");
                out.println("<option value=\"X\">Sperre QM</option>");
                out.println("<option value=\"Y\">Fehlteile</option>");
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

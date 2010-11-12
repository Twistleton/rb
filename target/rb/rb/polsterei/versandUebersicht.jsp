<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>Versand &Uuml;bersicht</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</HEAD>
<BODY BGCOLOR="#CCCCCC">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        String sql2 = new String();
        String puffer = new String();
        Statement stmt = con.createStatement();
        Statement stmt2 = con.createStatement();
        ResultSet rs;
        ResultSet rs2;
        int zaehler = 0;
        sql = "SELECT " +
                "abf_abnr,abf_prog,abf_prio,abf_fabt_pps,abf_ordnr," +        // 1-5
                "abf_fs,abf_te,abf_dezi,abf_pnr,ma_ap,abf_fs_status," +        // 6-10
                "abf_pf_status,abf_spl_kz,ako_kunde,ako_fabt_vs," +    // 11-15
                "ako_uhr_zeit,ako_tournr,as_aend_ix, " +                // 16 - 18
                "abf_pf_platz " +
                "FROM plrv11.bde_ab_fs_ma " +
                "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix " +
                "INNER JOIN plrv11.plr_auftr_kopf ON ako_abnr=as_abnr AND ako_aend_ix=as_aend_ix " +
                "INNER JOIN plrv11.bde_madat ON abf_pnr = ma_pnr " +
                " WHERE as_status<>99 " +
                " AND abf_fs='10245100000' " +
                " AND abf_fs_status in (5,10,20,30) " +
                " AND ako_vpkz='K' " +
                " ORDER BY abf_prog,abf_pnr";
        try {
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            zaehler = 0;
            out.println("<TABLE BORDER='1'>");
            out.println("<TR><TH>AB-Nr</TH><TH>Prog.</TH><TH>Modelle</TH><TH>AP</TH><TH>PP</TH></TR>");
            while (rs.next()) {
                out.println("<TR><TD>");
                out.println(rs.getInt("abf_abnr"));
                out.println("</TD><TD>");
                out.println(rs.getInt("abf_prog"));
                out.println("</TD><TD>");
                sql2 = "SELECT ap_posnr,ap_menge,ap_bezeichn ";
                sql2 += "FROM plrv11.plr_art_pos ";
                sql2 += "INNER JOIN  plrv11.plr_auftr_status ON ap_abnr=as_abnr AND ap_aend_ix=as_aend_ix ";
                sql2 += " WHERE ap_abnr=" + rs.getString("abf_abnr");
                sql2 += " AND as_status<>99";
                sql2 += " ORDER BY ap_posnr";
                stmt2.executeQuery(sql2);
                rs2 = stmt2.getResultSet();
                out.println("<TABLE BORDER='1'>");
                java.text.DecimalFormat format = new java.text.DecimalFormat("#.00");

                while (rs2.next()) {
                    out.println("<TR><TD>");
                    out.println(rs2.getString("ap_posnr"));
                    out.println("</TD><TD>");
                    out.println(format.format(Float.parseFloat(rs2.getString("ap_menge")) / 100));
                    out.println("</TD><TD>");
                    out.println(rs2.getString("ap_bezeichn"));
                    out.println("</TD></TR>");
                }
                rs2.close();
                out.println("</TABLE></TD><TD>");
                out.println(rs.getString("ma_ap").substring(8));
                sql2 = "SELECT pf_bez,pp_pf_platz ";
                sql2 += " FROM plrv11.bde_pufpl";
                sql2 += " INNER JOIN plrv11.bde_pfdat ON pf_pfnr=pp_pfnr ";
                sql2 += " WHERE (pp_abnr=" + rs.getString("abf_abnr");
                sql2 += " OR pp_ab2=" + rs.getString("abf_abnr");
                sql2 += " OR pp_ab3=" + rs.getString("abf_abnr");
                sql2 += ") AND (pp_kz='J' OR pp_kz='B') ORDER BY pp_pf_platz";
                stmt2.executeQuery(sql2);
                rs2 = stmt2.getResultSet();
                puffer = "<TABLE BORDER='1'>";
                while (rs2.next()) {
                    puffer += "<TR ";
                    if (rs2.getString("pp_pf_platz").substring(5, 7).compareTo("30") == 0) {
                        puffer += " style=\"background-color:yellow\"";
                    }
                    puffer += "><TD>";
                    puffer += rs2.getString("pf_bez") + ":</TD><TD>";
                    puffer += rs2.getString("pp_pf_platz").substring(2, 5) + ".";
                    if (rs2.getString("pf_bez").compareTo("PKZ") != 0) {
                        // Anzeige für Zonen
                        puffer += rs2.getString("pp_pf_platz").substring(5, 7) + ".";
                        puffer += rs2.getString("pp_pf_platz").substring(7, 9) + ".";
                        puffer += rs2.getString("pp_pf_platz").substring(9) + "\n";
                    } else {
                        puffer += rs2.getString("pp_pf_platz").substring(5, 8) + ".";
                        puffer += rs2.getString("pp_pf_platz").substring(8) + "\n";
                    }
                    puffer += "</TD><TR>\n";
                }
                rs2.close();
                puffer += "</TABLE>";
                out.println("<TD>" + puffer + "</TD>");
                out.println("</TR>");
            }
            out.println("</TABLE>");
        }
        catch (Exception e) {
            out.println(sql + "<BR>" + sql2 + "<BR>" + e.getMessage());
        }

    %>
</CENTER>
</BODY>
</HTML>

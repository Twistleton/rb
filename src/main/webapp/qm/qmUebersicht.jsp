<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>QM &Uuml;bersicht</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</HEAD>
<BODY BGCOLOR="#CCCCCC" onLoad="document.form.fs.focus();">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);
        String sql = new String();
        Statement stmt = con.createStatement();
        ResultSet rs;
        int zaehler = 0;
        sql = "SELECT abf_abnr,abf_fs,abf_fs_status,abf_fabt_pps,abf_vorzug,abf_aend_ix,qme_freigabe,pp_pfzone ";
        sql += "FROM plrv11.bde_ab_fs_ma ";
        sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
        sql += "LEFT OUTER JOIN plrv11.qm_endkontr ON abf_abnr=qme_abnr ";
        sql += "LEFT OUTER JOIN plrv11.bde_pufpl ON (pp_abnr=abf_abnr OR pp_ab2=abf_abnr OR pp_ab3=abf_abnr) and pp_kz='J' and pp_fs='10245400000' ";
        sql += "WHERE as_status<>99 ";
        sql += "AND abf_fs        ='10245400000' ";
        sql += "AND abf_fs_status>=1 AND abf_fs_status<40 ";
        sql += "AND abf_pf_status>10 ";
// sql += " GROUP BY abf_abnr,abf_fs,abf_fs_status,abf_fabt_pps,abf_vorzug,abf_aend_ix,qme_freigabe ";
        sql += " ORDER BY abf_fs_status,abf_fabt_pps,qme_freigabe desc ";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        zaehler = 0;
        out.println("<TABLE BORDER='1'>");
        out.println("<TR><TH>Ab-Nr</TH><TH>FS-Status</TH><TH>Fabt-PPS</TH><TH>Freigabe</TH><TH>PF-Zone</TH></TR>");
        while (rs.next()) {
            if ((rs.getString("pp_pfzone") != null) || ((rs.getInt("abf_fs_status") > 1))) {
                out.println("<TR ");
                if (rs.getInt("abf_fs_status") < 10) {
                    out.println("bgcolor='#ffffff'");
                } else if ((rs.getInt("abf_fs_status") >= 10) && (rs.getInt("abf_fs_status") < 20)) {
                    out.println("bgcolor='#ddddff'");
                } else if (rs.getInt("abf_fs_status") == 20) {
                    out.println("bgcolor='#ffdddd'");
                } else {
                    out.println("bgcolor='#dddddd'");
                }
                out.println("><TD>");
                out.println(rs.getInt("abf_abnr"));
                out.println("</TD><TD>");
                out.println(rs.getInt("abf_fs_status"));
                out.println("</TD><TD>");
                out.println(rs.getInt("abf_fabt_pps"));
                out.println("</TD>");
                if (rs.getString("qme_freigabe") != null) {
                    if (rs.getString("qme_freigabe").compareTo("n") == 0) {
                        out.println("<TD BGCOLOR='#ffdddd' ALIGN='CENTER'>");
                    } else {
                        out.println("<TD BGCOLOR='#ddffdd' ALIGN='CENTER'>");
                    }
                    out.println(rs.getString("qme_freigabe"));
                } else {
                    out.println("<TD BGCOLOR='#ffdddd' ALIGN='CENTER'>");
                    out.println("n");
                }
                out.println("</TD><TD>");
                if (rs.getString("pp_pfzone") != null) {
                    out.println(rs.getInt("pp_pfzone"));
                } else {
                    out.println("-");
                }
                out.println("</TD></TR>");
            }
        }
        out.println("</TABLE>");
    %>
</CENTER>
</BODY>
</HTML>

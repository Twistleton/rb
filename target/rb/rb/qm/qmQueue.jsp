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
        sql = "SELECT abf_abnr,abf_prog,abf_fs,abf_fs_status,abf_fabt_pps,abf_vorzug,abf_aend_ix,pp_pf_platz,pp_pfzone ";
        sql += "FROM plrv11.bde_ab_fs_ma ";
        sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
        sql += "INNER JOIN plrv11.bde_pufpl ON pp_abnr=abf_abnr ";
        sql += "WHERE as_status<>99 ";
        sql += "AND pp_pfnr  =10245400 ";
        sql += "AND pp_kz    ='J' ";
        sql += "AND abf_fs   ='10245400000' ";
        sql += "AND abf_fs_status<=10 ";
        sql += "AND abf_pf_status>=30 ";
        sql += "ORDER BY abf_vorzug,abf_fabt_pps ";
        stmt.executeQuery(sql);
        rs = stmt.getResultSet();
        zaehler = 0;
        out.println("<TABLE BORDER='1'>");
        out.println("<TR><TH>Ab-Nr</TH><TH>FS-Status</TH><TH>Fabt-PPS</TH><TH>PF-Zone</TH></TR>");
        while (rs.next()) {
            out.println("<TR><TD> ");
            out.println(rs.getInt("abf_abnr"));
            out.println("</TD><TD>");
            out.println(rs.getInt("abf_fs_status"));
            out.println("</TD><TD>");
            out.println(rs.getInt("abf_fabt_pps"));
            out.println("</TD><TD>");
            out.println(rs.getInt("pp_pfzone"));
            out.println("</TD></TR>");
        }
        out.println("</TABLE>");
    %>
</CENTER>
</BODY>
</HTML>

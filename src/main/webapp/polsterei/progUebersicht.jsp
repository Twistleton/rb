<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>Progamm &Uuml;bersicht</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</HEAD>
<BODY BGCOLOR="#CCCCCC" onLoad="document.progForm.prog.focus();">
<CENTER>
    <FORM NAME="progForm" METHOD="GET">
        <TABLE BORDER="0">
            <TR>
                <TD>Programm-Nr eingeben (3-stellig)</TD>
                <TD><INPUT TYPE="text" SIZE="6" MAXLENGTH="3" NAME="prog"></TD>
                <TD><INPUT TYPE="submit" NAME="ok" VALUE="OK"></TD>
            </TR>
        </TABLE>
            <%
bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
zcd.verarbeiten();
Connection  con = oraBde.getConnection();
con.setAutoCommit(false);
String sql    = new String();
String sql2   = new String();
String puffer = new String();
Statement stmt = con.createStatement();
Statement stmt2 = con.createStatement();
ResultSet rs;
ResultSet rs2;
int zaehler=0;
sql = "SELECT "+
	"abf_abnr,abf_prog,abf_prio,abf_fabt_pps,abf_ordnr," +		// 1-5
	"abf_fs,abf_te,abf_dezi,abf_pnr,abf_fs_status,"+		// 6-10
	"abf_pf_status,abf_spl_kz,ma_ap,ako_kunde,ako_fabt_vs,"+	// 11-15
	"ako_uhr_zeit,ako_tournr,as_aend_ix, "+				// 16 - 18
	"abf_pf_platz "+
	"FROM "+
	"plrv11.bde_ab_fs_ma,plrv11.plr_auftr_status,plrv11.bde_madat,plrv11.plr_auftr_kopf "+
	" WHERE abf_pnr=ma_pnr(+) AND as_abnr=abf_abnr AND as_status<>99 "+
	" AND abf_aend_ix=as_aend_ix AND ako_abnr=abf_abnr AND ako_aend_ix=as_aend_ix "+
	" AND abf_fs='10245100000' "+
	" AND abf_fs_status in (5,10,20,30,40) ";
	if ( (request.getParameter("prog") != null) && 
	     (request.getParameter("prog").trim().compareTo("")!=0) ) {
		sql += " AND abf_prog="+ request.getParameter("prog");
	}
	sql += " ORDER BY abf_prog,abf_pnr,abf_fs_status";
if ( (request.getParameter("prog") != null) && 
	(request.getParameter("prog").trim().compareTo("")!=0) ) {
	try {
		stmt.executeQuery(sql);
		rs = stmt.getResultSet();
		zaehler=0;
		out.println("<TABLE BORDER='1'>");
		out.println("<TR><TH>AB-Nr</TH><TH>Prog.</TH><TH>Fabt-PPS</TH><TH>FS-Status</TH><TH>AP</TH><TH>PP</TH></TR>");
		while (rs.next()) {
			out.println("<TR><TD>");
			out.println(rs.getInt("abf_abnr"));
			out.println("</TD><TD>");
			out.println(rs.getInt("abf_prog"));
			out.println("</TD><TD>");
			out.println(rs.getInt("abf_fabt_pps"));
			out.println("</TD><TD>");
			out.println(rs.getInt("abf_fs_status"));
			out.println("</TD><TD>");
			out.println(rs.getString("ma_ap").substring(8));
	
			sql2  = "SELECT pf_bez,pp_pf_platz ";
			sql2 += " FROM plrv11.bde_pufpl";
			sql2 += " INNER JOIN plrv11.bde_pfdat ON pf_pfnr=pp_pfnr ";
			sql2 += " WHERE (pp_abnr="+rs.getString("abf_abnr");
			sql2 += " OR pp_ab2="+rs.getString("abf_abnr");
			sql2 += " OR pp_ab3="+rs.getString("abf_abnr");
			sql2 += ") AND (pp_kz='J' OR pp_kz='B') ORDER BY pp_pf_platz";
			stmt2.executeQuery(sql2);
			rs2 = stmt2.getResultSet();
			puffer ="<TABLE BORDER='0'>";
			while (rs2.next()) {
				puffer += "<TR ";
				if (rs2.getString("pp_pf_platz").substring(5,7).compareTo("30")==0) {
					puffer += " style=\"background-color:yellow\"";
				}
				puffer += "><TD>";
				puffer += rs2.getString("pf_bez")+":</TD><TD>";
				puffer += rs2.getString("pp_pf_platz").substring(2,5)+".";
				if (rs2.getString("pf_bez").compareTo("PKZ")!=0) {
					// Anzeige für Zonen
					puffer += rs2.getString("pp_pf_platz").substring(5,7)+".";
					puffer += rs2.getString("pp_pf_platz").substring(7,9)+".";
					puffer += rs2.getString("pp_pf_platz").substring(9)+"\n";
				} else {
					puffer += rs2.getString("pp_pf_platz").substring(5,8)+".";
					puffer += rs2.getString("pp_pf_platz").substring(8)+"\n";
				}
				puffer +="</TD><TR>\n";
			}
			puffer +="</TABLE>";
			
			out.println("<TD>"+puffer+"</TD>");
	
	
			out.println("</TR>");
		}
		out.println("</TABLE>");
	} 
	catch (Exception e) {
		out.println(sql+"<BR>"+e.getMessage());
	}
}
%>
</CENTER>
</BODY>
</HTML>

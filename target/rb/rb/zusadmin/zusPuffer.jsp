<!--JSP-Import-Files Stand: 09.07.2008 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>


<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Puffer Zuschnitt</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    String sql = new String();
    String sqlZs = new String();

    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();

    ResultSet rs;

    String team = new String("10");
    String maPNr = new String();
    String umplanAuswahl = new String();

    String puffer = new String();
    DecimalFormat df = new DecimalFormat("#######0.00");
    float sumQm = 0;

    String sort = new String(" sak_ztag");
    try {
        sort = request.getParameter("sort");
    }
    catch (Exception e) {
        sort = " sak_ztag";
    }
    if (sort == null) {
        sort = " sak_ztag";
    }

    out.println("<CENTER><H2>Pufferninhalt anzeigen</H2><HR>");
    out.println("<TABLE><TR>");
    out.println("<TD>Puffer</TD>");
    out.println("<TD><FORM ACTION=\"zusPuffer.jsp\" METHOD=\"POST\" NAME=\"puffer\">");

    try {
        if (request.getParameter("puffer") != null) {
            puffer = request.getParameter("puffer");
        } else {
            puffer = "10244100";
        }
    }
    catch (NullPointerException npe) {
        puffer = "10244100";
    }

    try {
        if (request.getParameter("team") != null) {
            team = request.getParameter("team");
        } else {
            team = "";
        }
    }
    catch (NullPointerException npe) {
        team = "";
    }

    sql = "SELECT";
    sql += " att_bez,att_attr";
    sql += " FROM plrv11.plr_attrAttr ";
    sql += " WHERE att_tabname='zusPuffer' ORDER BY att_attr";
    out.println(oraBde.getHtmlSelectAllgS("puffer", sql, puffer));
    out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\">");
    out.print("</FORM></TD></TR></TABLE><HR>");

    sql = " SELECT ";
    sql += " sak_sanr,sak_artnr,sak_platz,sak_zs_sys,sak_charg_nr,sak_ztag,sum(kom_qm_brutto),";
    sql += " sak_zugew,sak_status,sak_pnr,kom_zs_sys,kom_werk_zuschn ";
    sql += " FROM plrv11.zus_sammel_kopf";
    sql += " INNER JOIN plrv11.zus_kommission ON sak_sanr=kom_sammel_abnr ";
    sql += " WHERE sak_platz like '" + puffer + "%' ";
    sql += " AND sak_zugew='N' ";
    sql += " AND kom_ab_gedruckt='N' ";
    sql += " GROUP BY sak_sanr,sak_artnr,sak_platz,sak_zs_sys,sak_charg_nr,sak_ztag,sak_zugew,sak_status,sak_pnr,kom_zs_sys,kom_werk_zuschn ";
    sql += " ORDER BY " + sort;

    stmt.executeQuery(sql);
    rs = stmt.getResultSet();
    out.println("<TABLE BORDER=1>");
    out.println("<TR BGCOLOR=\"#ddddff\">");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"zusPuffer.jsp?sort=sak_sanr&puffer=" + puffer + "\">S-AB-Nr</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"zusPuffer.jsp?sort=sak_ztag&puffer=" + puffer + "\">Zuschnitt-Tag</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"zusPuffer.jsp?sort=sum(kom_qm_brutto)&puffer=" + puffer + "\">Brutto-Menge</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"zusPuffer.jsp?sort=sak_status&puffer=" + puffer + "\">Status</A></TD>");
    out.println("<TD ALIGN=\"CENTER\"><A HREF=\"zusPuffer.jsp?sort=sak_platz&puffer=" + puffer + "\">Platz</A></TD>");

    out.println("<TD ALIGN=\"CENTER\">Umplanung ZS-Sys</TD>");
    out.println("<TD ALIGN=\"CENTER\">Man. Zuweisung</TD></TR>");
    while (rs.next()) {
        sumQm += rs.getFloat(7);
        out.println("<TR><TD>");
        out.println("<A HREF=\"zusSammelAbNrAus.jsp?sANr=" + rs.getString("sak_sanr") + "\">");
        out.println(rs.getString("sak_sanr") + "</A></TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_ztag") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(df.format(rs.getFloat(7)) + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_status") + "</TD><TD ALIGN=\"RIGHT\">");
        out.println(rs.getString("sak_platz").substring(8) + "</TD>");
        if (rs.getInt("kom_werk_zuschn") == 10) {
            out.println("<FORM ACTION=\"umplanung.jsp\" METHOD=\"POST\"><TD>");
            out.println("<INPUT TYPE=\"hidden\" NAME=\"sANr\" VALUE=\"" + rs.getString("sak_sanr") + "\">von");
            out.println(rs.getString("kom_zs_sys") + " nach ");
            // out.println(sqlZs);
            sqlZs = "SELECT kom_zs_sys,kom_zs_sys FROM plrv11.zus_kommission ";
            sqlZs += "WHERE kom_zs_sys<>" + rs.getString("kom_zs_sys") + " AND kom_zs_sys<>20 GROUP BY kom_zs_sys";
            out.println(oraBde.getHtmlSelectAllgS("zsSys", sqlZs, ""));
            out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\"></TD></FORM>");
        } else {
            out.println("<TD>Nicht m&ouml;glich</TD>");
            out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"puffer\" VALUE=\"" + puffer + "\">");
        }
        if (rs.getInt("kom_werk_zuschn") == 10) {
            out.println("<FORM ACTION=\"zuweisung.jsp\" METHOD=\"POST\"><TD>");
            if (puffer.equals("10244200")) {
                team = rs.getString("sak_pnr");
                // Personal-Nummer (Team) = null dann für die Ausgabe auf "1" (kein Team) setzen
                if (team == null) {
                    team = "1";
                }
                sql = "SELECT ma_nname,ma_pnr FROM plrv11.bde_madat WHERE ma_team_kz='J' ORDER BY ma_nname";
                out.println(oraBde.getHtmlSelectAllgS("team", sql, String.valueOf(team)));
                out.println("<INPUT TYPE=\"hidden\" NAME=\"sANr\" VALUE=\"" + rs.getString("sak_sanr") + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"team\"  VALUE=\"" + team + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"verfahren\" VALUE=\"CUTTER\">");
                out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\"></TD></FORM>");
            } else {
                out.println("<INPUT TYPE=\"hidden\" NAME=\"sANr\" VALUE=\"" + rs.getString("sak_sanr") + "\">");
                out.println("<INPUT TYPE=\"text\"   NAME=\"pNr\"  MAXLENGTH=\"4\" SIZE=\"6\"");
                if (rs.getString("sak_pnr") == null) {
                    out.println("VALUE=\"\">");
                } else {
                    out.println("VALUE=\"" + rs.getInt("sak_pnr") + "\">");

                }
                out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"OK\"></TD></FORM>");
            }
        } else {
            out.println("<TD>Nicht m&ouml;glich<BR></TD>");
        }
        out.println("</TR>");
    }
    con.close();
    out.println("<TR BGCOLOR=\"AAAAFF\"><TD></TD><TD></TD><TD ALIGN=\"right\">" + sumQm + "</TD><TD></TD><TD></TD><TD></TD><TD></TD></TR>");
    out.println("</TABLE>");
    out.println("<INPUT TYPE=\"HIDDEN\" NAME=\"puffer\" VALUE=\"" + puffer + "\">");
%>
</body>
</html>

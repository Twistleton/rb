<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftragszuweisung Cutter</title>
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
        ResultSet rs;
        String sql = new String();
        int allgEinarb = 0;
        int team = 0;
        String allgEinarbListe = new String();

        try {
            team = Integer.parseInt(request.getParameter("team"));
        }
        catch (Exception ex) {
            team = 1;
        }
//Einarbeit des Mitarbeiters
        sql = "SELECT map_prog FROM plrv11.bde_ma_prog WHERE map_fs='10244100000' AND map_pnr=" + team;
        try {
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            allgEinarbListe = "<TR>";
            while (rs.next()) {
                allgEinarbListe += "<TD>" + rs.getString(1) + "</TD>";
                allgEinarb++;
                if (allgEinarb % 20 == 0) {
                    allgEinarbListe += "</TR><TR>";
                }
            }
            allgEinarbListe += "<TR>";
        }
        catch (SQLException sqlex) {
            out.println(sqlex.getMessage() + "<BR>" + sql + "<BR>");
        }

        out.println("<B>Auftragszuweisung Cutter</B><BR>");

        out.println("<FORM ACTION=\"cutSelbstZuwEnde.jsp\" METHOD=\"POST\">");
// Selektieren der Zuweisungsfaehigen Auftraege
        sql = " SELECT sak_pnr,sak_sanr,sak_artnr,sak_ztag,kom_werk_zuschn,sum(kom_qm_brutto) ";
        sql += " FROM plrv11.zus_sammel_kopf ";
        sql += " INNER JOIN plrv11.zus_kommission ON kom_sammel_abnr=sak_sanr ";
        if (allgEinarb > 0) {
            sql += "INNER JOIN plrv11.bde_ma_prog ON " + team + "=map_pnr AND map_fs='10244100000' AND map_prog=kom_prog ";
            out.println("<BR>Eingeschränkte Einarbeit auf die Programme:<BR><TABLE >" + allgEinarbListe + "</TABLE><BR><BR>");
        } else {
            out.println("<BR>Das Team ist voll eingearbeitet. Keine Einschränkunden auf bestimmte Programme<BR>");
        }
        sql += " WHERE sak_zs_sys=10 ";
        sql += " AND kom_werk_zuschn=10 ";
        sql += " AND (sak_pnr is null OR sak_pnr=" + request.getParameter("team") + ") ";
        sql += " AND sak_artnr=" + request.getParameter("sAArtNr");
        sql += " AND sak_zugew='N' ";
        sql += " AND sak_lief_kkz='" + request.getParameter("liefKkz") + "'";
        sql += " AND sak_charg_nr=" + request.getParameter("chargNr");
        sql += " GROUP BY sak_pnr,sak_sanr,sak_artnr,sak_ztag,kom_werk_zuschn ";
        sql += " ORDER BY sak_pnr DESC,sak_ztag,sak_artnr,sak_sanr";

        stmt.executeQuery(sql);

        rs = stmt.getResultSet();
        out.println("<TABLE BORDER=1><TR BGCOLOR=\"#DDDDFF\"><TD ALIGN=CENTER>");
        out.println("Zuschnitt-Tag</TD><TD>Brutto-Menge</TD><TD>Auswahl</TD></TR>");
        while (rs.next()) {
            out.println("<TR><TD ALIGN=\"right\">");
            // out.print(rs.getString("sak_artnr").substring(3,5)+".");
            // out.println(rs.getString("sak_artnr").substring(5,8)+"</TD><TD ALIGN=right>");
            out.println(rs.getString("sak_ztag") + "</TD><TD ALIGN=\"right\">");
            out.println(rs.getString(6));
            out.println("</TD><TD ALIGN=\"CENTER\">");
            out.println("<INPUT TYPE=\"CHECKBOX\" NAME=\"sANr\" VALUE=\"" + rs.getString("sak_sanr") + "\"");
            if (rs.getLong("sak_sanr") == Long.parseLong(request.getParameter("sANr"))) {
                out.println(" CHECKED ");
            }
            out.println(">");
            out.println("</TD></TR>");
        }
        out.println("</TABLE>");

        out.println("<INPUT TYPE=\"submit\" NAME=\"ok\" VALUE=\"Zuweisen\">");
        out.println("<INPUT TYPE=\"hidden\" NAME=\"team\" VALUE=\"" + request.getParameter("team") + "\"></FORM>");

        con.close();
    %>
</CENTER>
</body>
</html>

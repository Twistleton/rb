<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="zuschnitt.css">
    <title>Haken Historie</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <H2>Haken-Historie
        <%
            if ((request.getParameter("id") != null) && (request.getParameter("id") != "")) {
                out.println(request.getParameter("id"));
            }
            if (request.getParameter("lfdNr") != null) {
                out.println(" Lfd. Nr." + request.getParameter("lfdNr"));
            }
        %>
    </H2>
    <HR>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");

        Connection con = oraBde.getConnection();
        con.setAutoCommit(false);

        Statement stmt = con.createStatement();
        String sql = new String();
        ResultSet rs;
        sql = "SELECT hkh_id,hkh_mat_kz,hkh_lfd_nr,hkh_pnr,TO_CHAR(hkh_sendtime,'DD.MM.YYYY HH24:MI:SS'),";
        sql += "ma_vname,ma_nname,hkh_vg ";
        sql += "FROM plrv11.zus_hk_historie ";
        sql += "LEFT OUTER JOIN plrv11.bde_madat ON ma_pnr=hkh_pnr ";
        sql += " WHERE hkh_mat_kz  = 'L' ";
        if ((request.getParameter("id") != null) && (request.getParameter("id") != "")) {
            sql += " AND hkh_id  = " + request.getParameter("id");
        }
        if ((request.getParameter("lfdNr") != null) && (request.getParameter("lfdNr") != "")) {
            sql += " AND  hkh_lfd_nr   = " + request.getParameter("lfdNr");
        }
        if ((request.getParameter("id") != null) && (request.getParameter("id") != "")) {
            sql += " ORDER BY hkh_sendtime DESC";
        } else {
            sql += " ORDER BY hkh_id,hkh_lfd_nr,hkh_sendtime DESC";
        }
// out.println(sql+"<BR>");
        out.println("<TABLE>");
        try {
            rs = stmt.executeQuery(sql);
            out.println("<TR BGCOLOR=\"#FFFFFF\"><TD ALIGN=\"center\">Vorgang</TD>");
            if (request.getParameter("id") == null) {
                out.println("<TD ALIGN=\"center\">Haken-Nr</TD>");

            }
            if (request.getParameter("lfdNr") == null) {
                out.println("<TD ALIGN=\"center\">Lfd-Nr.</TD>");
            }

            out.println("<TD ALIGN=\"center\">Datum/Uhrzeit</TD><TD ALIGN=\"center\">Name</TD></TR>");
            while (rs.next()) {

                if (rs.getString("hkh_vg").compareTo("A") == 0) {
                    out.println("<TR BGCOLOR=\"#DDDDFF\"><TD BGCOLOR=\"#DDDDDD\">Ausgeliehen</TD>");
                } else if (rs.getString("hkh_vg").compareTo("Z") == 0) {
                    out.println("<TR BGCOLOR=\"#DDFFDD\"><TD BGCOLOR=\"#DDDDDD\">Zurückgegeben</TD>");
                } else {
                    out.println("<TR BGCOLOR=\"#DDFFFF\"><TD BGCOLOR=\"#DDDDDD\">Weitergegeben an</TD>");
                }

                if (request.getParameter("id") == null) {
                    out.println("<TD><A HREF=\"hakenHistorie.jsp?id=" + rs.getString("hkh_id") + "&lfdNr=" + rs.getString("hkh_lfd_nr") + "\">" + rs.getString("hkh_id") + "</A></TD>");
                }

                if (request.getParameter("lfdNr") == null) {
                    out.println("<TD>" + rs.getString("hkh_lfd_nr") + "</TD>");
                }

                out.println("<TD>" + rs.getString(5) + "</TD>");
                if ((rs.getString("ma_nname") == null) || (rs.getString("ma_nname") == null)) {
                    out.print("<TD>unbekannt</TD>");
                } else {
                    out.print("<TD>" + rs.getString("ma_nname"));
                    out.println(", " + rs.getString("ma_vname") + "</TD>");
                }
                out.println("</TR>\n");

            }
        }
        catch (Exception ex) {
            out.println("Bitte geben Sie eine Haken-ID ein!!<BR>");
        }

        out.println("</TABLE>");
        con.close();
    %>
</CENTER>
</body>
</html>

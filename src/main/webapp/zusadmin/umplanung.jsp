<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Dezi-Melden</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.deziForm.komNrFs.focus()">
<CENTER>
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
        zcd.verarbeiten();
        Connection con = oraBde.getConnection();

        con.setAutoCommit(false);

        Statement stmt = con.createStatement();
        ResultSet rs;

        String sql = new String();
        String komNrFs = new String();
        String zblKz = new String();
        long zblTNr = 0;

        long sANr = 0;
        int zsSys = 0;
        int anzDs = 0;

// Anmeldung überprüfen, wenn fehlerhaft angemeldet, dann Zurück zu Eingabemaske
        try {
            sANr = Long.parseLong(request.getParameter("sANr"));
            zsSys = Integer.parseInt(request.getParameter("zsSys"));
        }
        catch (Exception e) {
            sANr = 0;
            zsSys = 0;
            out.println(e);
        }

        if ((sANr != 0) && (zsSys != 0)) {
            try {
                sql = "SELECT zbl_tnr,zbl_lief_kkz,zbl_charg_nr ";
                sql += "FROM plrv11.zus_zbl ";
                sql += "INNER JOIN plrv11.zus_sammel_kopf ";
                sql += "ON sak_artnr=zbl_tnr AND sak_lief_kkz=zbl_lief_kkz AND sak_charg_nr=zbl_charg_nr ";
                sql += " WHERE sak_sanr =" + sANr;
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    zblTNr = rs.getLong("zbl_tnr");
                }
                rs.close();
                if (zblTNr != 0) {
                    zblKz = "J";
                    out.println("J<BR>");
                } else {
                    zblKz = "N";
                    out.println("N<BR>");
                }

                // Handelt es sich um ein zu bezuschussendes Leder?
                sql = "UPDATE plrv11.zus_sammel_kopf SET sak_zs_sys=" + zsSys;
                sql += ",sak_zbl='" + zblKz + "' ";
                sql += " WHERE sak_sanr=" + sANr;
                sql += " AND sak_pnr IS NULL";
                anzDs = stmt.executeUpdate(sql);
                con.commit();
                if (anzDs > 0) {
                    sql = "UPDATE plrv11.zus_kommission SET kom_zs_sys=" + zsSys;
                    sql += " WHERE kom_sammel_abnr=" + sANr;
                    anzDs = stmt.executeUpdate(sql);
                    // Dezi immer neu setzen. Egal ob ZBL oder nicht
                    out.println("<B>Dezi neu berechnen</B><BR>");
                    sammelAuftrag.zblDeziSetzen(con, sANr);
                    if (anzDs != 0) {
                        out.println("<B>Umplanung erfolgreich</B><BR>");
                        con.commit();
                    } else {
                        out.println("<FONT COLOR=\"red\">Fehlgeschlagen</B></FONT><BR>");
                        con.rollback();
                    }
                }
            }
            catch (Exception e) {
                out.println(e);
                con.rollback();
            }
        }
    %>
</CENTER>
</BODY>
</HTML>
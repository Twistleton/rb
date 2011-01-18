<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <title>QM Selbstzuweisung</title>
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
        Statement stmt = con.createStatement();
        ResultSet rs;
        ResultSet rs2;
        long fs = 0;
        long pfPlatz = 0;
        int pfZone = 0;
        int abNr = 0;
        int fsStatus = 0;
        int zaehler = 0;
        int neuzuweis = 0;
        int aendIx = 0;
        int prog = 0;
        String freigabe = new String("n");
        String sql = new String();
        String ausgabe = new String();

        try {
            if (request.getParameter("fs").compareTo("") != 0) {
                abNr = Integer.parseInt(request.getParameter("fs"));
            }
        }
        catch (Exception ex) {
            abNr = 0;
        }
        if (abNr != 0) {
            sql = "SELECT abf_abnr,abf_fs,abf_fs_status,abf_fabt_pps,abf_vorzug,abf_aend_ix,qme_freigabe ";
            sql += "FROM plrv11.bde_ab_fs_ma ";
            sql += "INNER JOIN plrv11.plr_auftr_status ON abf_abnr=as_abnr AND abf_aend_ix=as_aend_ix ";
            sql += "LEFT OUTER JOIN plrv11.qm_endkontr ON abf_abnr=qme_abnr ";
            sql += "WHERE as_status<>99 ";
            sql += "AND abf_fs   ='10245400000' ";
            sql += "AND abf_abnr = " + abNr + " ";
            sql += "AND abf_fs_status>=10 AND abf_fs_status<40 ";

            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            zaehler = 0;
            while ((rs.next() && (zaehler < 1))) {
                zaehler++;
                abNr = rs.getInt("abf_abnr");
                aendIx = rs.getInt("abf_aend_ix");
                freigabe = rs.getString("qme_freigabe");
            }
            if (zaehler == 1) {
                if (freigabe != null) {
                    if (freigabe.compareTo("j") == 0) {
                        // Auftrag fertigmelden
                        sql = "UPDATE plrv11.bde_ab_fs_ma ";
                        sql += "SET abf_fs_status=40 ";
                        sql += "WHERE abf_abnr=" + abNr;
                        sql += " AND abf_fs='10245400000' ";
                        stmt.executeUpdate(sql);
                        ausgabe += "<H3>Auftrag " + abNr + " fertig</H3>";
                        con.commit();
                    } else {
                        ausgabe += "<H3><FONT COLOR=\"red\">Dieser Auftrag wird noch untersucht, ist aber noch nicht freigegeben</FONT></H3>";
                    }
                } else {
                    ausgabe += "<H3><FONT COLOR=\"red\">Dieser Auftrag wird noch untersucht, ist aber noch nicht freigegeben</FONT></H3>";
                }
            } else {
                ausgabe += "<H3>Auftrag " + abNr + " wurde nicht gefunden</H3>";
            }
        }
        try {
            if (request.getParameter("neuzuweis").compareTo("j") == 0) {
                // Liste der im Puffer befindlichen Aufträge selektieren, nach Dringlichkeit sortiert.
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
                while ((rs.next() && (zaehler < 1))) {
                    zaehler++;
                    abNr = rs.getInt("abf_abnr");
                    prog = rs.getInt("abf_prog");
                    aendIx = rs.getInt("abf_aend_ix");
                    pfPlatz = rs.getLong("pp_pf_platz");
                    pfZone = rs.getInt("pp_pfzone");
                }
                if (zaehler > 0) {
                    ausgabe += "<TABLE>";
                    ausgabe += "<TR><TD>Ihr neuer Auftrag :</TD><TD>" + abNr + "</TD></TR>";
                    ausgabe += "<TR><TD>Programm :         </TD><TD>" + prog + "</TD></TR>";
                    ausgabe += "<TR><TD>Pufferzone :      </TD><TD>" + pfZone + "</TD></TR>";
                    ausgabe += "</TABLE>";
                    // Dringlichsten Auftrag als gestartet markieren und Papier ausdrucken
                    sql = "UPDATE plrv11.bde_ab_fs_ma ";
                    sql += "SET abf_fs_status=10 ";
                    sql += "WHERE abf_abnr=" + abNr;
                    sql += " AND abf_fs='10245400000' ";
                    sql += " AND abf_fs_status<10";
                    sql += " AND abf_aend_ix=" + aendIx;
                    // ausgabe += "<BR>"+sql+"<BR>";
                    stmt.executeUpdate(sql);

                    // Kolliaufkleber Versand (seit 04.01.2010)
                    /*
                    sql = "SELECT ako_vpkz                  " +
                          "  FROM plrv11.plr_auftr_kopf     " +
                          " WHERE ako_abnr = " + abNr;

                    stmt.executeQuery(sql);
                    rs2 = stmt.getResultSet();

                    while (rs2.next()) {
                        if (rs2.getString("ako_vpkz") == "K") {
                            vsDatei vsd = new vsDatei(zcd.getVSPfad(), "vsDatei", zcd.getVSEndung());
                            vsd.setNameTimestamp();
                            vsd.oeffnen();
                            vsd.vsPapiere(abNr, con);
                            vsd.schliessen();
                            vsd.drucken(zcd.getVSDrucker());
                        }
                    }
                    */
                    // Papier ausdrucken
                    qmDatei qmd = new qmDatei(zcd.getQMPfad(), "qmDatei", zcd.getQMEndung());
                    qmd.setNameTimestamp();
                    qmd.oeffnen();
                    qmd.qmPapiere(abNr, con);
                    qmd.schliessen();
                    qmd.aktiviereDatei();
                    qmd.drucken(zcd.getQMDrucker());
                    // Pufferplatz freigeben
                    sql = "UPDATE plrv11.bde_pufpl ";
                    sql += "SET pp_abnr=0,pp_ab2=0,pp_ab3=0,pp_kz='N' ";
                    sql += "WHERE pp_pf_platz='" + pfPlatz + "'";
                    // ausgabe += "<BR>"+sql+"<BR>";
                    stmt.executeUpdate(sql);

                } else {
                    ausgabe += "Es konnte kein Auftrag gefunden werden<BR>";
                }
                con.commit();
            }
        }
        catch (Exception ex) {
            // ausgabe +=ex.getMessage();
            con.rollback();
        }
        ausgabe += "<FORM NAME='form' METHOD='POST'>";
        ausgabe += "<TABLE BORDER='0'>";
        ausgabe += "<TR><TD>Ab-Nr</TD>";
        ausgabe += "<TD><INPUT TYPE='text' NAME='fs' SIZE='8' MAXLENGTH='6'></TD></TR>";
        ausgabe += "<TR><TD>Neuzuweisung</TD>";
        ausgabe += "<TD><INPUT TYPE='checkbox' NAME='neuzuweis' VALUE='j' CHECKED></TD></TR>";
        ausgabe += "<TR><TD><INPUT TYPE='submit' NAME='ok' VALUE='OK'>";
        ausgabe += "</FORM>";
        ausgabe += "</TABLE>";

        out.println(ausgabe);

    %>
</CENTER>
</BODY>
</HTML>

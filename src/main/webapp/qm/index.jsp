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
        textDatei errorDatei = new textDatei("/tmp", "zuweis.log");

        try {
            if (request.getParameter("abNr").compareTo("") != 0) {
                abNr = Integer.parseInt(request.getParameter("abNr"));
            }
        }
        catch (Exception ex) {
            abNr = 0;
        }

        try {
            if (request.getParameter("neuzuweis").compareTo("Neuzuweisung") == 0) {
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
                if (abNr != 0) {
                    sql += "AND abf_abnr=" + abNr;
                }
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
                    ausgabe += "<TR><TD>Pufferzone :       </TD><TD>" + pfZone + "</TD></TR>";
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
                    // Papier ausdrucken
                    qmDatei qmd = new qmDatei(zcd.getQMPfad(), "qmDatei", zcd.getQMEndung());
                    qmd.setNameTimestamp();
                    qmd.oeffnen();
                    qmd.qmPapiere(abNr, con);
                    qmd.schliessen();
                    qmd.aktiviereDatei();
                    qmd.drucken(zcd.getQMDrucker());

                    // bqs-Datei für MMKS-Meldung erstellen
                    qmDatei bqs = new qmDatei(zcd.getBqsPfad(), "bqsDatei", zcd.getBqsEndung());
                    bqs.setNameTimestamp();
                    bqs.oeffnen();
                    bqs.bqsDatei(abNr, 10, con); // Status auf "Start" setzen: fs_status = 10
                    bqs.schliessen();
                    bqs.aktiviereDatei();
                    // Pufferplatz freigeben
                    sql = "UPDATE plrv11.bde_pufpl ";
                    sql += "SET pp_abnr=0,pp_ab2=0,pp_ab3=0,pp_kz='N' ";
                    sql += "WHERE pp_pf_platz='" + pfPlatz + "'";
                    // ausgabe += "<BR>"+sql+"<BR>";
                    errorDatei.write(bdeZeit.getTimestamp("ddMMyyyyHHmmss") + " : AB:" + abNr + "-->Puffer-Freigabe: " + sql + "\n");
                    stmt.executeUpdate(sql);
                } else {
                    ausgabe += "Es konnte kein Auftrag gefunden werden<BR>";
                }
                con.commit();
            }
        }
        catch (Exception ex) {
            ausgabe += ex.getMessage();
            ex.printStackTrace();
            con.rollback();
        }
        ausgabe += "<FORM NAME='form' METHOD='POST'>";
        ausgabe += "<TABLE BORDER='0'>";
        ausgabe += "<TR><TD>Dringender Auftrag :</TD>";
        ausgabe += "<TD><INPUT TYPE='text' NAME='abNr' SIZE='8' MAXLENGTH='6'></TD></TR>";
        ausgabe += "<TR><TD><INPUT TYPE='submit' NAME='neuzuweis' VALUE='Neuzuweisung'>";
        ausgabe += "</FORM>";
        ausgabe += "</TABLE>";
        out.println(ausgabe);

    %>
</CENTER>
</BODY>
</HTML>

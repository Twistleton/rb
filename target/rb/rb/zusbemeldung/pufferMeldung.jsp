<%--  <!--JSP-Import-Files-->  --%>
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Puffermeldung Zuschnitt</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.pufMeld.sammelAbNr.focus()">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
    zcd.verarbeiten();

    String sql = new String();
    String sqlUpdate = new String();
    String lkk = new String();
    String zblKz = new String();

    java.util.Date datum = new java.util.Date();

    int puffer = 0;
    long sammelAbNr = 0;
    long artNr = 0;
    int pufPl = 0;
    int werkZus = 0;
    int zsSys = 0;
    long charge = 0;
    long zblTNr = 0;
    String kzMF = new String();
    int minFabtZuschn = 0;
    float wertFl = 0;


    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();
    ResultSet rs;

    String drucken = new String();

    if ((request.getParameter("sammelAbNr") != null) &&
            (request.getParameter("pufPl") != null) &&
            (request.getParameter("charge") != null) &&
            (request.getParameter("lkk") != null)) {
        try {
            sammelAbNr = Long.parseLong(request.getParameter("sammelAbNr").trim());
            pufPl = Integer.parseInt(request.getParameter("pufPl").trim());
            charge = Long.parseLong(request.getParameter("charge").trim());
            lkk = request.getParameter("lkk").toUpperCase();
            sql = "SELECT kom_art_nr,kom_zs_sys,min(kom_fabt_zuschn),kom_werk_zuschn,kom_kz_mf ";
            sql += " FROM plrv11.zus_kommission ";
            sql += " WHERE kom_sammel_abnr=" + sammelAbNr;
            // sql += " AND kom_kz_mf<>'M' AND kom_kz_mf<>'F' ";
            sql += " GROUP BY kom_art_nr,kom_zs_sys,kom_werk_zuschn,kom_kz_mf";
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                artNr = rs.getLong("kom_art_nr");
                zsSys = rs.getInt("kom_zs_sys");
                minFabtZuschn = rs.getInt(3);
                werkZus = rs.getInt("kom_werk_zuschn");
                kzMF = rs.getString("kom_kz_mf");
            }
            puffer = 0;

            if (werkZus > 40) {
                puffer = Integer.parseInt(String.valueOf(werkZus) + "244100");
            }
            if (werkZus == 10) {
                if (zsSys == 10) {
                    puffer = 10244200;
                }
                if (zsSys == 11) {
                    puffer = 10244211;
                }
                if (zsSys == 30) {
                    puffer = 10244100;
                }
                if (zsSys == 31) {
                    puffer = 10244210;
                }
            }

            if (werkZus == 30) {
                if (zsSys == 10) {
                    puffer = 10244200;
                }
                if (zsSys == 11) {
                    puffer = 10244211;
                }
                if (zsSys == 30) {
                    puffer = 10244100;
                }
                if (zsSys == 31) {
                    puffer = 10244210;
                }
            }

            if ((kzMF.compareTo("M") == 0) || (kzMF.compareTo("F") == 0)) {
                puffer = 90244000;
            }

            // Wenn es sich um ein ZBL (zu bezuschussendes Leder) handelt==>Kennzeichen in Sammelauftragskopf auf 'J' setzen
            sql = "SELECT zbl_tnr,zbl_lief_kkz,zbl_charg_nr ";
            sql += "FROM plrv11.zus_zbl ";
            sql += " WHERE zbl_tnr     =" + artNr;
            sql += "  AND  zbl_lief_kkz='" + lkk;
            sql += "' AND  zbl_charg_nr=" + charge;
            stmt.executeQuery(sql);
            rs = stmt.getResultSet();
            while (rs.next()) {
                zblTNr = rs.getLong("zbl_tnr");
            }
            if (zblTNr != 0) {
                zblKz = "J";
            } else {
                zblKz = "N";
            }

            // Sammelauftrags-Kopf anlegen
            sqlUpdate = "INSERT INTO plrv11.zus_sammel_kopf ";
            sqlUpdate += "(sak_sanr,sak_artnr,sak_platz,sak_zs_sys,sak_charg_nr,";  //  1- 5
            sqlUpdate += "sak_lief_kkz,sak_ztag,sak_status,sak_a_dat,sak_zugew,"; //  6-10
            sqlUpdate += "sak_korr_kz,sak_zbl) VALUES (";    // 11-12
            sqlUpdate += sammelAbNr + "," + artNr + ",'" + puffer + rbTextFormat.format('0', 3, pufPl) + "',";
            sqlUpdate += zsSys + "," + charge + ",'" + lkk + "'," + minFabtZuschn + ",10,";
            sqlUpdate += "TO_DATE(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD'),'N','N','" + zblKz + "')";
            try {
                stmt.executeUpdate(sqlUpdate);
            }
            catch (SQLException sqlex) {
                out.println("<CENTER><TABLE BGCOLOR=red><TR><TD>Fehler beim Anlegen des Sammelauftrag-Kopf-Datensatzes<BR>");
                out.println("Fehler:" + sqlex.getMessage() + "</TD></TR></TABLE></CENTER>");
            }
            if (zblTNr != 0) {
                sammelAuftrag.zblDeziSetzen(con, sammelAbNr);
            }
            // Sammelauftrags-Haken anlegen
            sqlUpdate = "INSERT INTO plrv11.zus_sammel_hk (shk_sanr,shk_artnr,shk_hkk_id,shk_hkk_mat) ";
            sqlUpdate += "SELECT kom_sammel_abnr,kom_art_nr,khk_hkk_id,khk_hkk_mat ";
            sqlUpdate += "FROM ";
            sqlUpdate += "plrv11.zus_kommission,";
            sqlUpdate += "plrv11.zus_kom_hk ";
            sqlUpdate += "WHERE ";
            sqlUpdate += "khk_abnr=kom_abnr AND ";
            sqlUpdate += "kom_sammel_abnr='" + sammelAbNr;
            sqlUpdate += "' GROUP BY ";
            sqlUpdate += "kom_sammel_abnr,kom_art_nr,khk_hkk_id,khk_hkk_mat";
            try {
                stmt.executeUpdate(sqlUpdate);
            }
            catch (SQLException sqlex) {
                out.println("<CENTER><TABLE BGCOLOR=red><TR><TD>Fehler beim Anlegen der Sammelauftrags-Haken<BR>");
                out.println("Fehler:" + sqlex.getMessage() + "</TD></TR>");
                out.println("<TR><TD>" + sqlUpdate + "</TD></TR></TABLE></CENTER>");
            }

            try {
                String kzGedruckt = new String();
                sql = "SELECT kom_ab_gedruckt FROM plrv11.zus_kommission WHERE kom_sammel_abnr=" + sammelAbNr;
                stmt.executeQuery(sql);
                rs = stmt.getResultSet();
                while (rs.next()) {
                    kzGedruckt = rs.getString("kom_ab_gedruckt");
                }
                try {
                    if (request.getParameter("druckAp") == null) {
                        drucken = "0";
                    } else {
                        drucken = request.getParameter("druckAp");
                    }
                }
                catch (Exception npe) {
                    drucken = "0";
                }
                if (((drucken.compareTo("1") == 0) || (werkZus > 40) || (kzMF.compareTo("M") == 0) || (kzMF.compareTo("F") == 0)) &&
                        (kzGedruckt.compareTo("N") == 0)) {
                    druckDatei apd = new druckDatei(zcd.getAbpDruckPfad(), "auftragsPapierDatei", zcd.getAbpEndung());
                    apd.setNameTimestamp();
                    apd.oeffnen();
                    apd.arbeitsBegleitpapiere(sammelAbNr, con);
                    apd.schliessen();
                    apd.aktiviereDatei();
                    apd.drucken(zcd.getPufZusDrucker());
                    out.println("<CENTER>AB Gedruckt</CENTER>");
                    sqlUpdate = "UPDATE plrv11.zus_kommission SET ";
                    sqlUpdate += "kom_ab_gedruckt='J' WHERE kom_sammel_abnr=" + sammelAbNr;
                    try {
                        stmt.executeUpdate(sqlUpdate);
                    }
                    catch (SQLException sqlex) {
                    }
                } else {
                    out.println("<CENTER>Keine AB Gedruckt</CENTER>");
                }
            }
            catch (Exception ex) {

            }
            // Status der Kommissionen des Sammelauftrags erhöhen
            sqlUpdate = "UPDATE plrv11.zus_kommission SET kom_status=50 WHERE kom_sammel_abnr=" + sammelAbNr;
            try {
                stmt.executeUpdate(sqlUpdate);
            }
            catch (SQLException sqlex) {
                out.println("<CENTER><TABLE BGCOLOR=red><TR><TD>Fehler beim Erhoehen der Kommissions-Stati<BR>");
                out.println("Fehler:" + sqlex.getMessage() + "</TD></TR></TABLE></CENTER>");
            }

            if ((werkZus > 40) || (kzMF.compareTo("M") == 0) || (kzMF.compareTo("F") == 0)) {
                // Datei an Host
                bvwDatei bvw = new bvwDatei(zcd.getRueckMeldPfad(), zcd.getStartEndeEndung());
                bvw.druck(sammelAbNr, 0, con);
                out.println("<CENTER>Datei für Host bereitgestellt");
                out.println("<FORM ACTION=\"../buchung/buchung.jsp\" \"POST\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"auftr_bez_nr\" VALUE=\"" + sammelAbNr + "\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"key\" VALUE=\"nixkey\">");
                out.println("<INPUT TYPE=\"hidden\" NAME=\"mod\" VALUE=\"imez_sammel\">");
                out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\"  VALUE=\"Buchung\">");
                out.println("</FORM></CENTER>");
            }
        }
        catch (Exception e) {
            out.println("<CENTER><B><FONT COLOR=\"red\">Fehlerhafte Eingabe ist nicht vollstaendig</FONT></B></CENTER><BR>");
            out.println(e.getMessage());
        }
    }

    sql = "SELECT att_bez,att_attr FROM plrv11.plr_attrAttr WHERE att_tabname='zusPuffer' ORDER BY att_attr";
    out.println("<CENTER><B>Puffermeldung</B><BR>");
    out.println("<TABLE BORDER=1>");
    out.println("<FORM ACTION=\"pufferMeldung.jsp\" NAME=\"pufMeld\" METHOD=\"POST\">");
    out.println("<TR><TD>Sammel-Auftrag  </TD><TD ALIGN=\"right\">");
    out.println("<INPUT TYPE=\"text\" NAME=\"sammelAbNr\" SIZE=14  MAXLENGTH=14></TD></TR>");
    out.println("<TR><TD>Pufferplatz     </TD><TD ALIGN=\"right\">");
    out.println("<INPUT TYPE=\"text\" NAME=\"pufPl\"  SIZE=3   MAXLENGTH=3 ></TD></TR>");
    out.println("<TR><TD>Lieferant       </TD><TD ALIGN=\"right\">");
    out.println("<INPUT TYPE=\"text\" NAME=\"lkk\"    SIZE=4   MAXLENGTH=4 ></TD></TR>");
    out.println("<TR><TD>Charge          </TD><TD ALIGN=\"right\">");
    out.println("<INPUT TYPE=\"text\" NAME=\"charge\" SIZE=10  MAXLENGTH=10></TD></TR>");
/*
out.println("<TR><TD>Arbeitsbegleitpapiere<BR>drucken</TD><TD ALIGN=\"right\">");
out.println("<INPUT TYPE=\"checkbox\" NAME=\"druckAp\" VALUE=\"1\" ></TD></TR>");
*/
    out.println("<TR><TD>&nbsp;        </TD><TD ALIGN=\"right\">");
    out.println("<INPUT TYPE=\"SUBMIT\" NAME=\"ok\" VALUE=\"OK\"></TD></TR>");
    out.println("</FORM></TABLE></CENTER>");
    con.close();
%>
</body>
</html>

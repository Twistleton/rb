<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head></head>
<body bgcolor="#eeeeee">
<div align="center">
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    Statement stmt1;
    Statement stmt2;
    String sql;

    //String artnr1     = request.getParameter("ART_NR_1");
    //String artnr3     = request.getParameter("ART_NR_3");
    String artnr1 = "";
    String artnr3 = "";
    String artnr2 = request.getParameter("ART_NR_2");
    artnr3 = "00";
    int zahl = Integer.valueOf(artnr2).intValue();

    if (zahl >= 30000) {
        //out.println("Leder:"+zahl);
        artnr1 = "442";
    } else {
        //out.println("Stoff:"+zahl);
        artnr1 = "432";
    }

    String artnr = artnr1 + artnr2 + artnr3;
    //out.println(artnr);

    String artbez = request.getParameter("ART_BEZ");
    String insertArtBez = artbez.toUpperCase();
    String artsperr = request.getParameter("ART_SPERR_KZ");
    String artliefkz = request.getParameter("ART_LIEF_KKZ");
    String artcutman = request.getParameter("ART_CUT_FHG");

    String cutterparameter = request.getParameter("ART_CUT_PARM");
    String digitparameter = request.getParameter("ART_DIG_PARM");

    String artmanzs = "N";
    String artcut = "J";
    String sent = request.getParameter("sent");

    String matBez1 = request.getParameter("matBez1");
    String matBez2 = request.getParameter("matBez2");
    String matBez3 = request.getParameter("matBez3");
    String matBez4 = request.getParameter("matBez4");
    String matBez5 = request.getParameter("matBez5");

    int matProz1 = new Integer(request.getParameter("matProz1")).intValue();
    int matProz2 = new Integer(request.getParameter("matProz2")).intValue();
    int matProz3 = new Integer(request.getParameter("matProz3")).intValue();
    int matProz4 = new Integer(request.getParameter("matProz4")).intValue();
    int matProz5 = new Integer(request.getParameter("matProz5")).intValue();

    int matTyp1 = new Integer(request.getParameter("matTyp1")).intValue();
    int matTyp2 = new Integer(request.getParameter("matTyp2")).intValue();
    int matTyp3 = new Integer(request.getParameter("matTyp3")).intValue();
    int matTyp4 = new Integer(request.getParameter("matTyp4")).intValue();
    int matTyp5 = new Integer(request.getParameter("matTyp5")).intValue();

    //#####---Arrays werden benoetigt,um die Eingabesummen zu pruefen---#####
    int[] material = new int[6];
    int[] prozente = new int[6];

    int typ1gesProz = 0;
    int typ2gesProz = 0;
    int error = 0;

    material[1] = matTyp1;
    material[2] = matTyp2;
    material[3] = matTyp3;
    material[4] = matTyp4;
    material[5] = matTyp5;

    prozente[1] = matProz1;
    prozente[2] = matProz2;
    prozente[3] = matProz3;
    prozente[4] = matProz4;
    prozente[5] = matProz5;

    //#####---Pruefen, ob Artikelkopfdaten korrekt eingegeben wurden---#####
    if (artbez.equals("") || artnr2.equals("")) {
        out.println("Eingabefehler bei den Artikelkopfdaten!!<br>");
        error = 1;
    }

//#####---Stouurz!! Hier wird geprueft,ob nicht mehr oder weniger als 100% pro Material oder gar kein Material eingegeben wurde---#####
    if (matProz1 != 0) {
        for (int i = 1; i < 6; i++) {
            if (material[i] == 1) {
                if (prozente[i] == 0) {
                    break;
                }
                typ1gesProz += prozente[i];
                //out.println("MaterialTyp1,Eintrag"+i+":"+prozente[i]+",Gesamt:"+typ1gesProz+"<br>");
            } else {
                if (prozente[i] == 0) {
                    break;
                }
                typ2gesProz += prozente[i];
                //out.println("MaterialTyp2,Eintrag"+i+":"+prozente[i]+",Gesamt:"+typ2gesProz+"<br>");
            }
        }
    } else {
        out.println("Kein Material angegeben!!<br>");
    }

//#####---Stouuurz!! Wenn alle Eingaben korrekt-->Datenbankeintrag---#####
    if ((typ1gesProz == 100 || typ1gesProz == 0) && (typ2gesProz == 100 || typ2gesProz == 0) && typ1gesProz + typ2gesProz != 0 && error != 1) {
        out.println("Materialeingabe in Ordnung-Datenbankverbindung wird ge&ouml;ffnet...<br>");

        //#####---Zuerst die Kopfdaten---#####
        sql = "INSERT INTO PLRV11.PLR_ART_KOPF (ART_NR,ART_BEZ,ART_SPERR_KZ,ART_LIEF_KKZ,"
                + "ART_CUT_FHG,ART_MAN_ZS,ART_ZS_SYS,ART_CUT_PARM,ART_DIG_PARM) "
                + " VALUES("
                + artnr
                + ",'" + insertArtBez + "'"
                + ",'" + artsperr + "'"
                + ",'" + artliefkz + "'"
                + ",'" + artcut + "'"
                + ",'" + artmanzs + "'"
                + "," + artcutman
                + ",'" + cutterparameter + "'"
                + ",'" + digitparameter + "'"
                + ")";
        try {
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
        } catch (SQLException e) {
            out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
            error = 1;
        }

        //#####---Wenn SQL-Exception bei PLR_ART_KOPF werden auch in PLR_ART ZUSAM keine Daten eingetragen---#####
        if (error != 1) {
            sql = "INSERT INTO PLRV11.PLR_ART_ZUSAM (AZS_ART_NR,AZS_BEZ_TYP,AZS_BEZ_MAT,AZS_PROZ_ANTT) "
                    + " VALUES("
                    + "'" + artnr + "'"
                    + ",'" + matTyp1 + "'"
                    + ",'" + matBez1 + "'"
                    + "," + matProz1 + ")";
            try {
                //out.println(sql);
                stmt1 = con.createStatement();
                stmt1.executeQuery(sql);
                out.println("Datensatz angelegt!");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
            }

            //#####---Ab jetzt Eintrag der Materialdaten, vorausgesetzt es wurde etwas angegeben---#####
            if (matProz2 != 0) {

                sql = "INSERT INTO PLRV11.PLR_ART_ZUSAM (AZS_ART_NR,AZS_BEZ_TYP,AZS_BEZ_MAT,AZS_PROZ_ANTT) "
                        + " VALUES("
                        + "'" + artnr + "'"
                        + ",'" + matTyp2 + "'"
                        + ",'" + matBez2 + "'"
                        + "," + matProz2 + ")";

                try {
                    //out.println(sql);
                    stmt2 = con.createStatement();
                    stmt2.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
                }
            }
            if (matProz3 != 0) {

                sql = "INSERT INTO PLRV11.PLR_ART_ZUSAM (AZS_ART_NR,AZS_BEZ_TYP,AZS_BEZ_MAT,AZS_PROZ_ANTT) "
                        + " VALUES("
                        + "'" + artnr + "'"
                        + ",'" + matTyp3 + "'"
                        + ",'" + matBez3 + "'"
                        + "," + matProz3 + ")";

                try {
                    //out.println(sql);
                    stmt2 = con.createStatement();
                    stmt2.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
                }
            }
            if (matProz4 != 0) {
                //out.println("MatProz4="+matProz4);
                sql = "INSERT INTO PLRV11.PLR_ART_ZUSAM (AZS_ART_NR,AZS_BEZ_TYP,AZS_BEZ_MAT,AZS_PROZ_ANTT) "
                        + " VALUES("
                        + "'" + artnr + "'"
                        + ",'" + matTyp4 + "'"
                        + ",'" + matBez4 + "'"
                        + "," + matProz4 + ")";

                try {
                    //out.println(sql);
                    stmt2 = con.createStatement();
                    stmt2.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
                }
            }
            if (matProz5 != 0) {
                //out.println("MatProz5="+matProz5);
                sql = "INSERT INTO PLRV11.PLR_ART_ZUSAM (AZS_ART_NR,AZS_BEZ_TYP,AZS_BEZ_MAT,AZS_PROZ_ANTT) "
                        + " VALUES("
                        + "'" + artnr + "'"
                        + ",'" + matTyp5 + "'"
                        + ",'" + matBez5 + "'"
                        + "," + matProz5 + ")";

                try {
                    //out.println(sql);
                    stmt2 = con.createStatement();
                    stmt2.executeQuery(sql);
                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
                }
            } else {
                //out.println("Break!");
            }

            out.println("<br><br>");
            con.close();
        }
    }

//#####---Bei Fehleingabe(<>100%) Fehlermeldung incl. Prozentangaben und history.back-Button---#####
    else {
        out.println("<font color=\"#ff0000\"><b>Fehler bei der Materialeingabe:</b></font><br>");
        out.println("Materialtyp1-Prozent:" + typ1gesProz + "<br>");
        out.println("Materialtyp2-Prozent:" + typ2gesProz + "<br><br>");
        out.println("<input type=\"button\" name=\"Verweis\" value=\"zur&uuml;ck zur Eingabe\" onClick=\"history.back()\">");
    }

%>
<a href="./anzeigen.jsp?ART_NR=<%=artnr%>&sent=1&sel=j">weiter zum Artikel</a>
</div>
</body>
</html>
    
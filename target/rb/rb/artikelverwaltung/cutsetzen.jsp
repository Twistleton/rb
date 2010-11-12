<!--Artikelverwaltung - Stand 03.07.2008 --->

<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Hashtable" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">
<table border="0" align="center">
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>
<div align="center">
    <%
        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
        Connection con = oraBde.getConnection();
        Statement stmt;
        Statement stmt1;
        String sql;
        String sql1;
        ResultSet resultSet;

        String artnr = request.getParameter("artnr");
        String cutkennz = request.getParameter("cutkennz");

        // Hashtable für Zuschnittssystembezeichnungen anlegen
        Hashtable Zuschnittssystem = new Hashtable();

        Zuschnittssystem.put("10", "CUTTER-ZUSCHNITT");
        Zuschnittssystem.put("11", "LOHNZUSCHNITT");
        Zuschnittssystem.put("20", "CUTTER/MANUELL");
        Zuschnittssystem.put("30", "MANUELL");

        // gültige Zuschnittskennzeichen prüfen
        if (cutkennz.equals("10") ||          // Cutter-System
                cutkennz.equals("11") ||        // Lohnzuschnitt
                cutkennz.equals("20") ||        // Cutter-System/manuell
                cutkennz.equals("30")) {        // manuell

            sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_ZS_SYS = " + cutkennz + " WHERE ART_NR = " + artnr;
            try {
                stmt = con.createStatement();
                stmt.executeQuery(sql);
                out.println("Zuschnittsystem ge&auml;ndert!<br>");
                out.println("<font color=\"#ff0000\"><b>Artikel auf " + Zuschnittssystem.get(cutkennz)
                        + " gesetzt</b><br><br></font>");
            } catch (SQLException e) {
                out.println("Fehler beim Updaten des Datensatzes:&nbsp;" + e + "<p>");
            }
            sql1 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_ZS_SYS=" + cutkennz + "WHERE KOM_ART_NR=" + artnr + " AND KOM_STATUS <= 10";
            try {
                stmt1 = con.createStatement();
                stmt1.executeQuery(sql1);
                out.println("<b>Kommissionstabelle aktualisiert!!</b>");
            } catch (SQLException e) {
                out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");

            }
        } else {
            out.println("Fehler:Kein gu&uuml;ltiges Bearbeitungskennzeichen &uuml;bergeben!!");
        }


        /*
        //#####---Auf manuell setzen---#####
        if (cutkennz.equals("30")){

          sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_ZS_SYS=30 WHERE ART_NR="+artnr;
          try{
            stmt      = con.createStatement();
            stmt.executeQuery(sql);
            out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<font color=\"#ff0000\"><b>Artikel auf MANUELLEN ZUSCHNITT gesetzt</b><br><br></font>");
          } catch(SQLException e) {
                  out.println("Fehler beim Updaten des Datensatzes:&nbsp;"+e+"<p>");
            }


          sql1 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_ZS_SYS=30 WHERE KOM_ART_NR="+artnr+" AND KOM_STATUS <= 10";
          try{
            stmt1      = con.createStatement();
            stmt1.executeQuery(sql1);
            //out.println(sql1);
            //out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<b>Kommissionstabelle aktualisiert!!</b>");
          } catch(SQLException e) {
                  out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;"+e+"<p>");
                }
        }
        //#####---Auf cutterfaehig setzen---#####
        else if (cutkennz.equals("10")){
          sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_ZS_SYS=10 WHERE ART_NR="+artnr;
          try{
            stmt      = con.createStatement();
            stmt.executeQuery(sql);
            out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<font color=\"#ff0000\"><b>Artikel auf CUTTER-ZUSCHNITT gesetzt</b><br><br></font>");
          } catch(SQLException e) {
                  out.println("Fehler beim Updaten des Datensatzes:&nbsp;"+e+"<p>");
            }

          sql1 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_ZS_SYS=10 WHERE KOM_ART_NR="+artnr+" AND KOM_STATUS <= 10";
          try{
            stmt1      = con.createStatement();
            stmt1.executeQuery(sql1);
            //out.println(sql1);
            //out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<b>Kommissionstabelle aktualisiert!!</b>");
          } catch(SQLException e) {
                  out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;"+e+"<p>");
                }
        }
        //#####---Auf Cutter/Manuell setzen---#####
        else if (cutkennz.equals("20")){
          sql = "UPDATE PLRV11.PLR_ART_KOPF SET ART_ZS_SYS=20 WHERE ART_NR="+artnr;
          try{
            stmt      = con.createStatement();
            stmt.executeQuery(sql);
            out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<font color=\"#ff0000\"><b>Artikel auf CUTTER/MANUELL gesetzt</b><br><br></font>");
          } catch(SQLException e) {
                  out.println("Fehler beim Updaten des Datensatzes:&nbsp;"+e+"<p>");
            }

          sql1 = "UPDATE PLRV11.ZUS_KOMMISSION SET KOM_ZS_SYS=20 WHERE KOM_ART_NR="+artnr+" AND KOM_STATUS <= 10";
          try{
            stmt1      = con.createStatement();
            stmt1.executeQuery(sql1);
            //out.println(sql1);
            //out.println("Zuschnittsystem ge&auml;ndert!<br>");
            out.println("<b>Kommissionstabelle aktualisiert!!</b>");
          } catch(SQLException e) {
                  out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;"+e+"<p>");
                }
        }
        else{
          out.println("Fehler:Kein Bearbeitungskennzeichen &uuml;bergeben!!");
        }

      */

        out.println("<br><br>");
        con.close();
    %>

    <a href="./anzeigen.jsp?ART_NR=<%=artnr%>&sent=1&sel=j">zur&uuml;ck zum Artikel</a>
</div>
</body>
</html>

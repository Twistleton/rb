<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<%

    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    String charge = "";
    String liefkkz = "";
    long artnr = 0;
    String puffer = "10244400";
    String lagernr = "";
    String lagerort = "";
    long resABNR = 0;
    int progNR = 0;
    String cutFHG = "";
    String manZS = "";
    String artsperr = "";
    String fungizid = "";
    String comment = "";
    String menge = "";
    String clearmenge = "";
    float floatmenge = 0;
    int error = 0;
    int count = 0;
    int newresID = 0;
    int maxID = 0;
    int counter = 1;
    int resID = 0;
    int sqlerr = 0;

    try {
        artnr = new Long(request.getParameter("ART_NR")).longValue();
        //lagernr    = new Long(request.getParameter("lagernr")).longValue(); 
        lagernr = request.getParameter("lagernr");
        fungizid = request.getParameter("fungizid");
        cutFHG = request.getParameter("cutFHG");
        manZS = request.getParameter("manZS");
        resABNR = new Long(request.getParameter("resABNR")).longValue();
        progNR = new Integer(request.getParameter("progNR")).intValue();
        charge = request.getParameter("charge");
        liefkkz = request.getParameter("liefkkz");

        lagerort = puffer + lagernr;

        artsperr = request.getParameter("ART_SPERR_KZ");
        comment = request.getParameter("comment");

        menge = request.getParameter("menge");
        clearmenge = menge.replace(',', '.');
        //out.println("Menge:"+menge+"<br>Saubere Menge:"+clearmenge);
        floatmenge = Float.valueOf(clearmenge).floatValue();

    } catch (java.lang.NumberFormatException e) {
        out.println("<br>Fehler bei Eingabe der Bruttomenge!!");
        error = 1;
        out.println("<br><input type=\"button\" name=\"Verweis\" value=\"zur&uuml;ck zur Eingabe\" onClick=\"history.back()\">");
    }

    //#####---Groesste bereits vergebene ID bestimmen---#####
    sql = "SELECT MAX(RES_ID) AS maxID FROM  PLRV11.ZUS_REST_RESERV";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    try {
        resultSet.next();
        maxID = resultSet.getInt("maxID");
        //out.println("MAXID="+maxID);
    } catch (SQLException e) {
        out.println("<br>Fehler beim Auslesen der Identifizierungsnumer!!&nbsp;" + e + "<p>");
    }

    //#####---Anzahl der bereits vergebenen IDs bestimmen---#####
    sql = "SELECT count(RES_ID) as count FROM  PLRV11.ZUS_REST_RESERV";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    try {
        resultSet.next();
        count = resultSet.getInt("count");
        //out.println("ANZAHL:"+count);
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Identifizierungsnumer!!&nbsp;" + e + "<p>");
    }

    //#####---IDs abfragen, aufsteigend---#####
    sql = "SELECT RES_ID as ID FROM  PLRV11.ZUS_REST_RESERV order by RES_ID asc";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    try {
        //#####---Luecken in der ID-Vergabe finden und verwenden---#####
        while (counter < maxID) {
            resultSet.next();
            resID = resultSet.getInt("ID");
            //out.println ("<br>"+resID);
            if (counter == resID) {
                counter++;
            } else {
                //#####---Falls Luecke vorhanden, diese als neue ID verwenden---#####
                newresID = counter;
                break;
            }
        }
        if (newresID == 0) {
            //####---wenn keine Luecke vorhanden, setze neue ID= MAX-ID+1---#####
            newresID = maxID + 1;
        }
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen der Identifizierungsnumer!!&nbsp;" + e + "<p>");
    }
    //out.println ("<br><br>NEWID="+newresID);

    //#####---Wenn keine Fehleingaben bzw. fehlende Daten,dann ab in die DB---#####
    if (error != 1) {
        sql = "INSERT INTO PLRV11.ZUS_REST_RESERV (RES_ID,RES_ABNR,RES_ART_NR,RES_PROG_NR,RES_CHARG_NR,RES_FUNGIZID,RES_QM_BRUTTO,RES_RESERV_KZ,"
                + "RES_REST_KZ,RES_RES_LAGERORT,RES_BEMERK,RES_LAGER_KZ,RES_CUTTER_KZ,RES_MANUELL_KZ,RES_STATUS,RES_ANLAGE_DAT,RES_LIEF_KKZ)"
                + " VALUES("
                + newresID
                + ","
                + resABNR
                + ","
                + artnr
                + ","
                + progNR
                + ",'" + charge + "'"
                + ",'" + fungizid + "'"
                + "," + floatmenge
                + ",'J'"
                + ","
                + "'N',"
                + "'" + lagerort + "'"
                + ",'" + comment + "'"
                + ",'" + cutFHG + "'"
                + ",'" + manZS + "'"
                + ",'J'"
                + ",0"
                + ",sysdate"
                + ",'" + liefkkz + "'"
                + ")";

        //out.println(sql);

        try {
            //out.println(sql);
            stmt = con.createStatement();
            stmt.executeQuery(sql);
            out.println("<br>Reservierungs-Daten wurden erfolgreich angelegt!!<br>");
        } catch (SQLException e) {
            out.println("Fehler beim Einf&uuml;gen des Datensatzes:&nbsp;" + e + "<p>");
            sqlerr = 1;
        }

        //#####---Wenn Fehler beim ersten INSERT gibts auch kein Update des Pufferplatzes---#####
        /*if(sqlerr != 1){
           sql = "UPDATE PLRV11.BDE_PUFPL SET PP_KZ='J',PP_ABNR="+resABNR+" WHERE PP_PF_PLATZ="+lagerort;
           //out.println(sql);

           try
           {
              //out.println(sql);
              stmt = con.createStatement();
              stmt.executeQuery(sql);
              out.println("<br>Pufferplatz erfolgreich vergeben!<br>");
           } catch(SQLException e) {
               out.println("<br>Fehler bei der Pufferplatzvergabe:&nbsp;"+e+"<p>");
             }
        }*/
    }

    con.close();
%>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee">
<table border="0" align="center">
    <tr>
        <td align="center">&nbsp;</td>
    </tr>
</table>
</body>
</html>
      
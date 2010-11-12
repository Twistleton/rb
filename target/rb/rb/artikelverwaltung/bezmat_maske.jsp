<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt;
    String sql;
    ResultSet resultSet;

    int matnr = 0;
    int matnrvalue = 0;

    //#####---Die Nummer wird automatisch vergeben,wird auch nicht angezeigt und ist fuer den Benutzer irrelevant---#####
    sql = "SELECT MAX(AMB_MAT_NR) AS value FROM  PLRV11.ZUS_MATBEZ";
    //out.println(sql);
    stmt = con.createStatement();
    stmt.executeQuery(sql);
    resultSet = stmt.getResultSet();

    try {
        resultSet.next();
        matnr = resultSet.getInt("value");
        matnrvalue = matnr + 1;
        //out.println(matnrvalue);
    } catch (SQLException e) {
        out.println("Fehler beim Auslesen!!&nbsp;" + e + "<p>");
    }
    con.close();
%>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<form action="./bezmat_anlegen.jsp" method="post">
    <table border="0" align="center">
        <tr>
            <td>
                <b>Rohstoff-Neueintrag:</b>
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <tr>
            <td align="center">
                <input type="hidden" name="sent" value="1"></input>
                <input type="hidden" name="matnr" value="<%=matnrvalue%>"></input>
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <tr>
            <td align="center">
                Materialkurzkennzeichen
            </td>
            <td>
                <input type="text" name="matkkz" size="3" maxlength="3"></input>
                <!-- Textfeld MATKKZ-->
            </td>
        </tr>
        <tr>
            <td align="center">
                Materialbezeichnung
            </td>
            <td>
                <input type="text" name="matbez" size="32" maxlength="32"></input>
                <!-- Textfeld MATBEZ-->
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <tr>
            <td>
                <input type="submit" value="Hinzuf&uuml;gen"></input>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
      
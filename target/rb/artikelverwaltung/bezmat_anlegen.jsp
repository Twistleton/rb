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
        String sql;
        ResultSet resultSet;

        String matnr = request.getParameter("matnr");
        String matkkz = request.getParameter("matkkz");
        String matbez = request.getParameter("matbez");

        String sent = request.getParameter("sent");

        if (sent != null)
            if (sent.equals("1")) {
                //#####---Eintrag in DB:Tabelle ZUS_MATBEZ ---#####
                sql = "INSERT INTO PLRV11.ZUS_MATBEZ (amb_mat_nr,amb_mat_kzbez,amb_mat_bez)"
                        + " VALUES("
                        + "'" + matnr + "'"
                        + ",'" + matkkz + "'"
                        + ",'" + matbez + "'"
                        + ")";
                try {
                    //out.println(sql);
                    stmt = con.createStatement();
                    stmt.executeQuery(sql);
                    out.println("Material-Datensatz hinzugef&uuml;gt!");
                } catch (SQLException e) {
                    out.println("Fehler beim Einf&uuml;gen des Material-Datensatzes:&nbsp;" + e + "<p>");
                }
                out.println("<br><br>");
                con.close();
            }
        sent = null;
    %>
    <a href="./bezmat_anzeigen.jsp">weiter</a>
</div>
</body>
</html>
      
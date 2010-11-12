<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<BODY>
<%
    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
    Connection con = oraBde.getConnection();
    Statement stmt = con.createStatement();

    String sql = new String();
    sql = "UPDATE plrv11.zus_kommission SET kom_status=0,kom_tagesmenge_dat=NULL WHERE ";
    sql += "kom_status=10 AND to_char(kom_tagesmenge_dat,'YYYY-MM-DD')=TO_CHAR(SYSDATE,'YYYY-MM-DD') AND ";
    sql += "kom_kz_mf<>'F' AND kom_kz_mf<>'M' AND kom_kom_kz='N' AND kom_werk_zuschn=10 ";

    try {
        stmt.executeUpdate(sql);
        out.println("Tagesmenge wurde zurückgesetzt<BR>");
    }
    catch (Exception e) {
        out.println("Es ist ein Fehler aufgetreten<BR>");
        out.println(e.getMessage());
    }
    con.close();
%>
</body>
</html>

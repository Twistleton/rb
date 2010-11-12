<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head></head>
<body bgcolor="#eeeeee">
<%
    MyDBAccess myDBAccess = new MyDBAccess("bdev10", "dbbde", "ss33.rolf-benz.de", "1521", "ora2test");
    myDBAccess.openConnection();
    String sql;
    Statement stmt;
    Connection con;
    ResultSet resultSet;
    PreparedStatement prepStmt;

    con = myDBAccess.getConnection();

    String user = request.getRemoteUser();
    out.println("Remote-User=" + user);
%>

</body>
</html>
    

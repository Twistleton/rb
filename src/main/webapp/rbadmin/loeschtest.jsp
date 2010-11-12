<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>
<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Test zum löschen von Dateien</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<%
    File f = new File("/home/ss06/SS01/vom_host", "K_Anlage.log");
    out.println(f.delete());
    // *************************************************************
%>
</body>
</html>

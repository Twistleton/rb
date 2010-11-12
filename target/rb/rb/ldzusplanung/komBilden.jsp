<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Zuschnitt-Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#0000FF" alink="#0000FF" vlink="#0000FF">
<H2>Prüfung auf neue Kommissionen...</H2>
<%
    out.println(kommission.bilden("/etc/zusJsp.conf"));
%>
</CENTER>
</body>
</html>

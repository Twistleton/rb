<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftrags-Info</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <H2>Auftrags-Information</H2>
    <TABLE BORDER=1>
        <FORM ACTION="auftrInfo.jsp" NAME="formular" METHOD="POST">
            <TR>
                <TD>Auftr-Nr</TD>
                <TD ALIGN=right><INPUT TYPE="text" NAME="abNr" SIZE=7 MAXLENGTH=6></TD>
            </TR>
            <TR>
                <TD COLSPAN="2" ALIGN="CENTER"><INPUT TYPE="SUBMIT" VALUE="OK" name="ok"></TD>
            </TR>
        </FORM>
    </TABLE>
</CENTER>
</BODY>

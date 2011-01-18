<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Anmeldung Dezi-Login</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000"
      onLoad="document.formular.pNr.focus()">
<CENTER>
    <H2>Anmeldung Dezi-Meldung</H2>
    <TABLE BORDER=1>
        <FORM ACTION="zusDeziEin.jsp" NAME="formular" METHOD="POST">
            <TR>
                <TD>Personal-Nr.</TD>
                <TD ALIGN=right><INPUT TYPE="TEXT" NAME="pNr" SIZE=4 MAXLENGTH=4></TD>
            </TR>
            <TR>
                <TD>PIN</TD>
                <TD ALIGN=right><INPUT TYPE="password" NAME="pin" SIZE=4 MAXLENGTH=4></TD>
            </TR>
            <TR>
                <TD COLSPAN="2" ALIGN="CENTER"><INPUT TYPE="SUBMIT" VALUE="OK" name="ok"></TD>
            </TR>
        </FORM>
    </TABLE>
</CENTER>
</BODY>
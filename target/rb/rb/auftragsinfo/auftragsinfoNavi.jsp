<!--JSP-Import-Files-->

<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <title>Navigation</title>
</head>
<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<style type="text/css">
    p {
        margin-left: 35px;
        margin-top: 40px;
    }
</style>
<FORM ACTION="../auftragsinfo/auftragsinfo.jsp" METHOD="POST" TARGET="haupt">
    <p>
    <TABLE BORDER=1>
        <TR>
            <TH>Auftragsinfo</TH>
        </TR>
        <TR>
            <TD>
                <INPUT TYPE="text" NAME="abNr" SIZE="6" MAXLENGTH="6">
                <INPUT TYPE="submit" NAME="ok" VALUE="OK">
            </TD>
        </TR>
    </TABLE>
</FORM>
<p>
</body>
</html>

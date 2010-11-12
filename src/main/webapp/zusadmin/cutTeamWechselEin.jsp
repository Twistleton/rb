<!--JSP-Import-Files-->
<%@ page import="java.sql.*" %>
<%@ page import="com.rolfbenz.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>Auftragszuweisung Cutter</title>
    <link rel=stylesheet type="text/css" href="zuschnitt.css">
    <SCRIPT TYPE="text/javascript">
        function checkTeam(t) {
            if (t.value == "1") {
                alert("Wählen Sie bitte ein Team aus und drücken Sie ok");
                return false;
            } else {
                return true;
            }
        }
    </SCRIPT>
</head>

<body text="#000000" bgcolor="#c0c0c0" link="#FF0000" alink="#FF0000" vlink="#FF0000">
<CENTER>
    <B>Teamwechsel Cutter</B><BR>

    <FORM NAME="teamWechselForm" ACTION="cutTeamWechselAus.jsp" METHOD="POST" onSubmit="return checkTeam(team)">
        <TABLE BORDER=1>
            <TR BGCOLOR="#DDDDFF">
                <TD ALIGN="CENTER">Sammel-ABNr</TD>
                <TD ALIGN="CENTER">Team</TD>
                <TD>&nbsp;</TD>
            </TR>
            <TR BGCOLOR="#DDDDFF">
                <TD><INPUT TYPE="text" NAME="sANr" SIZE="14" MAXLENGTH="14"></TD>
                <TD>
                    <%
                        bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
                        zusConfigDatei zcd = new zusConfigDatei("/etc/zusJsp.conf");
                        zcd.verarbeiten();
                        String sql = new String();
                        sql = "SELECT ma_nname,ma_pnr FROM plrv11.bde_madat WHERE ma_team_kz='J' AND ma_pnr>1 ORDER BY ma_nname";
                        out.println(oraBde.getHtmlSelectAllgS("team", sql, ""));

                    %>
                </TD>
                <TD><INPUT TYPE="SUBMIT" NAME="ok" VALUE="OK"></TD>
            </TR>
    </FORM>
    </TABLE>
</CENTER>
</body>
</html>

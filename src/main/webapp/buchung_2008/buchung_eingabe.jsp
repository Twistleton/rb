<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<%
    String mod = request.getParameter("mod");
    String vorgang = "";
    String buchungsart = "";
    String size = "";
    String color = "";

    //### Ueberschriften generieren ###
    if (mod.equals("imez_kom")) {
        vorgang = "Buchung Einzelkommission";
        buchungsart = "IMEZ/H VG=21";
        size = "16";
        color = "#f0e68c";
    }
    if (mod.equals("imez_kom_korr")) {
        vorgang = "Korrekturbuchung Einzelkommission";
        buchungsart = "IMEZ/K VG=21";
        size = "16";
        color = "#ffaeb9";
    }
    if (mod.equals("lmez_kom")) {
        vorgang = "Mehrverbrauch Einzelkommission";
        buchungsart = "LMEZ/H VG=30,31";
        size = "16";
        color = "#9ac0cd";
    }
    if (mod.equals("imez_sammel")) {
        vorgang = "Buchung Sammelauftrag";
        buchungsart = "IMEZ/H VG=21";
        size = "14";
        color = "#f0e68c";
    }
    if (mod.equals("imez_sammel_korr")) {
        vorgang = "Korrekturbuchung Sammelauftrag";
        buchungsart = "IMEZ/K VG=21";
        size = "14";
        color = "#ffaeb9";
    }

%>
<html>
<head>
    <style type="text/css" media="screen">
        <!--
        body {
            font-size: 12px;
            font-family: "Arial", Arial, sans-serif;
            color: #000000;
        }

        -->
    </style>
    <title>
    </title>
</head>
<body OnLoad="document.form.auftr_bez_nr.focus();" bgcolor=<%=color%>>
<table border="0" align="center" cellspacing="1">
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <form name="form" action="./buchung.jsp?mod=<%=mod%>&key=nixkey" method="post" target="main">
            <td align="center">
                <font size="+2">
                    <b>
                        <%=vorgang%>
                    </b>
                </font>
            </td>
    </tr>
    <tr>
        <td align="center">
            <font color="#0000cd">
                <b>[<%=buchungsart%>]</b>
            </font>
        </td>
    </tr>
    <tr>
        <td align="center">
            &nbsp;
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="text" name="auftr_bez_nr" size=<%=size%> maxlength=<%=size%> ></input>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="submit" value="Feuer frei">
            </input>
        </td>
        </form>
    </tr>
</table>
</body>
</html>
      


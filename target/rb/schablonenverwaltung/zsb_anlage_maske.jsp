<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.*" %>

<%
    String zsb = request.getParameter("zsb");
    Date dt = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyy");
    String jahr = df.format(dt);
%>
<html>
<head>
    <title></title>
    <script type="text/javascript">

        function getKey() {
            document.neuanlage.cutterSb1.value = document.neuanlage.zsb.value;
        }
        function checkCutterSb() {
            if (document.neuanlage.cutterSb1.value.length < 6)
            { 
                alert("Eingabe für LD-Cutter-SB " + document.neuanlage.cutterSb1.value + " zu kurz!");
                document.neuanlage.cutterSb1.focus();
            }
        }
        
    </script>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FF0000" alink="#FF0000" vlink="#FF0000">

<form name="neuanlage" action="./anlegen.jsp?art=zsb" method="post">
    <table border="0" align="center">
        <tr>
            <td>
                <b>ZSB-Neueintrag:</b>
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <tr>
            <td align="center">Zuschnitt-SB</td>
            <td>
                <input type="text" name="zsb" size="6" maxlength="6" value=<%=zsb%> onchange="getKey()"></input>
            </td>
        </tr>
        <tr>
            <td align="center">Anlaufjahr</td>
            <td>
                <input type="text" name="anl_jahr" size="4" maxlength="4" value=<%=jahr%>></input>
            </td>
        </tr>
        <tr>
            <td align="center">Auslaufdatum</td>
            <td>
                <input type="text" name="ausl_dat_tag" size="2" maxlength="2" value="00"></input>.
                <input type="text" name="ausl_dat_monat" size="2" maxlength="2" value="00"></input>.
                <input type="text" name="ausl_dat_jahr" size="4" maxlength="4" value="0000"></input>&nbsp;[tt-mm-jjjj]
            </td>
        </tr>
        <tr>
            <td align="center">LD-Cutter-SB</td>
            <td>
                <input type="text" name="cutterSb1" size="6" maxlength="6" value="<%=zsb%>" onchange="checkCutterSb()"></input>
                <input type="text" name="cutterSb2" size="1" maxlength="1" value="8"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                Pfad
            </td>
            <td>
                <select size="1" name="pfad">
                    <option value="G:\models\freies_legen\" selected>
                        G:\models\freies_legen\
                    </option>
                    <option value="G:\models\Ausfallmuster\">
                        G:\models\Ausfallmuster\
                    </option>
                    <option value="G:\models\Auslauf\">
                        G:\models\Auslauf\
                    </option>
                    <option value="G:\models\Test\">
                        G:\models\Test\
                    </option>
                </select>
            </td>
        </tr>
        <tr>
            <td align="center">Regel</td>
            <td>
                <select size="1" name="regel">
                    <option value="frei_neu.ppc" selected>
                        frei_neu.ppc
                    </option>
                    <option value="default.ppc">
                        default.ppc
                    </option>
                    <option value="frei_neu1.ppc">
                        frei_neu1.ppc
                    </option>
                    <option value="frei_neu2.ppc">
                        frei_neu2.ppc
                    </option>
                    <option value="frei_neu3.ppc">
                        frei_neu3.ppc
                    </option>
                </select>
            </td>
        </tr>
        <tr>
            <td align="center">MDL</td>
            <td>
                <input type="text" name="mdl" size="20" maxlength="50"></input>
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <tr>
            <td>
                <input type="submit" value="Hinzuf&uuml;gen"></input>
            </td>
        </tr>
    </table>
</form>
</body>
</html>
      
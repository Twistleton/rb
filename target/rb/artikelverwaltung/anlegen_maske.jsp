<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#eeeeee" link="#FF0000" alink="#FF0000" vlink="#FF0000">

<form action="./anlegen.jsp" method="post">
    <table border="0" align="center">
        <tr>
            <td>
                <b>Artikel-Neueintrag:</b>
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <tr>
            <td align="center">Artikelnummer</td>
            <td>
                <!--<input type="text" name="ART_NR_1" size="3" maxlength="3"></input>.-->
                <!--<select size="1" name="ART_NR_1">
                <option value="432">432</option>
                <option value="442" selected>442</option>
              </select>-->
                <input type="text" name="ART_NR_2" size="5" maxlength="5"></input>
                <!--<input type="text" name="ART_NR_3" size="2" maxlength="2" value="00" readonly></input>-->
                <!-- Textfeld ARTNR-->
            </td>
        </tr>
        <tr>
            <td align="center">Artikelbezeichnung</td>
            <td><input type="text" name="ART_BEZ" size="24" maxlength="24"></input>
                <!-- Textfeld ARTBEZ-->
            </td>
        </tr>
        <tr>
            <td align="center">Sperrkennzeichen</td>
            <td><select size="1" name="ART_SPERR_KZ">
                <option value="J">J</option>
                <option value="N" selected>N</option>
            </select>
                <!--<input type="text" name="ART_SPERR_KZ" size="1" maxlength="1"></input>-->
                <!-- SELECT ARTSPERRKZ-->
            </td>
        </tr>
        <tr>
            <td align="center">Lieferanten-Kurzkennzeichen</td>
            <td><input type="text" name="ART_LIEF_KKZ" size="4" maxlength="4" value=" "></input>
                <!-- Textfeld ARTLIEFKKZ-->
            </td>
        </tr>
        <tr>
            <td align="center">Zuschnittsystem</td>
            <td><select size="1" name="ART_CUT_FHG">
                <option value="10">Cutter</option>
                <option value="30">Manuell</option>
                <option value="20" selected>Cutter/Manuell</option>

            </select>
                <!--<input type="text" name="ART_CUT_FHG" size="1" maxlength="1"></input>-->
                <!-- SELECT ARTCUTFHG-->
            </td>
        </tr>
        <tr>
            <td align="center">Cutterparameter</td>
            <td><input type="text" name="ART_CUT_PARM" size="20" maxlength="40"></input>
                <!-- Textfeld CUTTERPARAMETER-->
            </td>
        </tr>
        <tr>
            <td align="center">Digitparameter</td>
            <td><input type="text" name="ART_DIG_PARM" size="20" maxlength="40"></input>
                <!-- Textfeld DIGITPARAMETER-->
            </td>
        </tr>

        <!--<tr>
          <td align="center">Manueller Zuschnitt</td>
          <td><select size="1" name="ART_MAN_ZS">
              <option value="J">J</option>
              <option value="N" selected>N</option>
            </select>-->
        <!--<input type="text" name="ART_MAN_ZS" size="1" maxlength="1"></input>-->
        <!-- SELECT ARTMANZUS-->
    </table>
    <table border="0" align="center">
        <tr>
            <td>&nbsp;
            </td>
        </tr>
    </table>
    <table border="1" align="center">
        <colgroup>
            <col width="140">
            <col width="140">
            <col width="140">
        </colgroup>
        <tr>
            <td align="center">Materialtyp</td>
            <td align="center">Bezeichnung</td>
            <td align="center">Anteil&nbsp;[%]</td>
        </tr>
        <tr>
            <td align="center">
                <select size="1" name="matTyp1">
                    <option value="1" selected>Oberseite</option>
                    <option value="2">Unterseite</option>
                </select>
            </td>
            <td align="center">
                <%
                    bdeDb oraBde = new bdeDb("/etc/zusJsp.conf");
                    Connection con = oraBde.getConnection();
                    out.println(oraBde.getHtmlSelectAllg("matBez1", "SELECT AMB_MAT_BEZ,AMB_MAT_KZBEZ FROM PLRV11.ZUS_MATBEZ", " "));
                %>
            </td>
            <td align="center"><input type="text" name="matProz1" size="3" maxlength="3" value="0"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <select size="1" name="matTyp2">
                    <option value="1" selected>Oberseite</option>
                    <option value="2">Unterseite</option>
                </select>
            </td>
            <td align="center">
                <%
                    out.println(oraBde.getHtmlSelectAllg("matBez2", "SELECT AMB_MAT_BEZ,AMB_MAT_KZBEZ FROM PLRV11.ZUS_MATBEZ", " "));
                %>
            </td>
            <td align="center"><input type="text" name="matProz2" size="3" maxlength="3" value="0"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <select size="1" name="matTyp3">
                    <option value="1" selected>Oberseite</option>
                    <option value="2">Unterseite</option>
                </select>
            </td>
            <td align="center">

                <%
                    out.println(oraBde.getHtmlSelectAllg("matBez3", "SELECT AMB_MAT_BEZ,AMB_MAT_KZBEZ FROM PLRV11.ZUS_MATBEZ", " "));
                %>

            </td>
            <td align="center"><input type="text" name="matProz3" size="3" maxlength="3" value="0"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <select size="1" name="matTyp4">
                    <option value="1" selected>Oberseite</option>
                    <option value="2">Unterseite</option>
                </select>
            </td>
            <td align="center">

                <%
                    out.println(oraBde.getHtmlSelectAllg("matBez4", "SELECT AMB_MAT_BEZ,AMB_MAT_KZBEZ FROM PLRV11.ZUS_MATBEZ", " "));
                %>

            </td>
            <td align="center"><input type="text" name="matProz4" size="3" maxlength="3" value="0"></input>
            </td>
        </tr>
        <tr>
            <td align="center">
                <select size="1" name="matTyp5">
                    <option value="1" selected>Oberseite</option>
                    <option value="2">Unterseite</option>
                </select>
            </td>
            <td align="center">

                <%
                    out.println(oraBde.getHtmlSelectAllg("matBez5", "SELECT AMB_MAT_BEZ,AMB_MAT_KZBEZ FROM PLRV11.ZUS_MATBEZ", " "));
                    con.close();
                %>

            </td>
            <td align="center"><input type="text" name="matProz5" size="3" maxlength="3" value="0"></input>
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
      
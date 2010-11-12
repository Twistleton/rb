<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title>
    </title>
</head>
<body bgcolor="#ddddFF" link="#0000ff" alink="#0000ff" vlink="#0000ff">
<table border="0" align="center" cellspacing="10">
    <!--<tr>
           <td align="center">
         <b>
           Neu anlegen:
         </b>
           </td>
         </tr>
         <tr>
           <td align="center">
         <input type="button" name="Verweis" value="ZSB"
           onClick="parent.frames[2].location.href='./zsb_anlage_maske.jsp'">
           </td>
         </tr>-->
    <tr>
        <td align="center">
            <b>
                Anzeigen:
            </b>
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Hakenliste"
                   onClick="parent.frames[2].location.href='./hakenliste_eingabe.html'">
        </td>
    </tr>
    <tr>
        <td align="center">
            <input type="button" name="Verweis" value="Hakens&auml;tze"
                   onClick="parent.frames[2].location.href='./hakensaetze_eingabe.html'">
        </td>
    </tr>
    <tr>
        <td>
            &nbsp;
        </td>
    </tr>
</table>
<table border="0" align="center">
    <form action="./verleihnix_zurueck.jsp" method="post" target="main">
        <tr>
            <td align="center">
                <b>
                    Entliehene Haken:
                </b>
            </td>
        </tr>
</table>
<table border="0" align="center">
    <tr>
        <td align="center">
            <input type="text" name="pNr" size="4" maxlength="4"></input>
        </td>
        <td align="center">
            <input type="submit" value="zur&uuml;ckgeben"></input>
        </td>
    </tr>
    <!--<tr>
           <td align="center">
         <font size="-2" color="blue">
           Personalnr.
         </font>
           </td>
           <td>
         &nbsp;
           </td>
         </tr>-->
    </form>
</table>

<!--<tr>
          <td align="center">
        <input type="button" name="Verweis" value="zur&uuml;ckgeben"
		  onClick="parent.frames[2].location.href='./verleihnix_zurueck.jsp'">	
	      </td>
	    </tr>
	  <tr>
	  <td align="center">
	  <input type="button" name="Verweis" value="Reservierungen"
	  onClick="parent.frames[2].location.href='./reservierungsverw.jsp'">
	</td>
	</tr>-->
</table>
</body>
</html>
      
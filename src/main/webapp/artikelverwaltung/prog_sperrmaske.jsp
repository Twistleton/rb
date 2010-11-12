<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#ddddff">
<form action="./prog_sperren.jsp?art=sperren" method="post" target="main">
    <table border="0" align="center">
        <tr>
            <td align="center">
                &nbsp;
            </td>
        </tr>
        <tr>
            <td align="center">
                <b>
                    Programm sperren:
                </b>
            </td>
        </tr>
    </table>
    <table border="0" align="center">
        <td align="center">
            <input type="text" name="prognr" size="3" maxlength="3"></input>
        </td>
        <td align="center">
            <input type="submit" value="Sperren"></input>
        </td>
        </tr>
    </table>
</form>
<!--<form action="./prog_sperren.jsp?art=freigeben" method="post" target="main">
	    <table border="0" align="center"> 
	      <tr>
		<td align="center">
		  <b>
		    Programm freigeben:
		  </b>
		</td>
	      </tr>
	    </table>
	    <table border="0" align="center">  	
	      <tr>
		<td align="center"> 
<%
		  bdeDb oraBde   = new bdeDb("/etc/zusJsp.conf");
		  Connection con = oraBde.getConnection();
		  out.println(oraBde.getHtmlSelectAllg("prognr","SELECT PRG_PRG,PRG_PRG FROM PLRV11.PLR_PRG_SPERR"," "));
%>
		  
		</td>
		<td align="center">
		  <input type="submit" value="freigeben"></input>
		</td>
	      </tr>
	    </table>
	  </form>-->
</body>
</html>

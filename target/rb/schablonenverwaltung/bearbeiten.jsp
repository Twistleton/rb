<!--JSP-Import-Files-->
<%@ page import="com.sira.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>

<html>
<head>
    <title></title>
</head>
<body text="#000000" bgcolor="#ddddff">
<table border="0" align="center" cellspacing="5">

        <%
	  bdeDb oraBde   = new bdeDb("/etc/zusJsp_test.conf");
	  Connection con = oraBde.getConnection();
	  String sql           = "";
	  String modID         = "";
	  String zsbID         = "";
	  long sbID            = 0;
	  String anlJahr       = "";
	  String auslDat       = "";
	  String gueltKz       = "";
	  String cutterSb      = "";
	  String cutterSb1     = "";
	  String cutterSb2     = "";
	  String pfad          = "";
	  String regel         = "";
	  String mdl           = "";
	  String userID        = "";
	  String aendDat       = "";
	  String jahr          = "";
	  String monat         = "";
	  String tag           = "";
	  String uhrzeit       = "";
	  long hakenID         = 0;
	  String hkkid         = "";
	  String matKz         = "";
	  long hakenNr         = 0;
      String hakenBez      = "";
	  int hakenProg        = 0;
	  String kommentar     = "";
	  long standort        = 0;
	  long aktPlatz        = 0;
	  long reservAbnr      = 0;
          int lfdNr            = 0;
	  String aendDatString = "";
	  Statement stmt;
	  stmt  = con.createStatement();
	 
	  ResultSet resultSet;

          String art = request.getParameter("art");		 
	 
          //#####---ZSB---#####
	  if(art.equals("zsb")){ 
	     
	     zsbID     = request.getParameter("sbID");
	     sql       = "SELECT * FROM PLRV11.zus_schnittbild where SB_ID="+zsbID;
	     resultSet = stmt.executeQuery(sql);
	     
	     out.println("<form action=\"./updaten.jsp?art=zsb\" method=\"post\">");
	     out.println("<table border=\"0\" align=\"center\"><tr><td><b>ZSB-Eintrag bearbeiten:</b></td></tr></table>");
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#eeeeee\">");
	         
	     try
	     {
	       resultSet.next();
	    	    
	       anlJahr    = resultSet.getString("SB_ANL_JAHR");
	       auslDat    = resultSet.getString("SB_AUSL_DAT");
	       cutterSb   = resultSet.getString("SB_CUTTER_SB");
	       cutterSb1  = cutterSb.substring(0,6);
	       cutterSb2  = cutterSb.substring(6);

	       pfad       = resultSet.getString("SB_PFAD");
	       regel      = resultSet.getString("SB_REGEL");
	       mdl        = resultSet.getString("SB_MLD");
	       userID     = resultSet.getString("SB_USER_ID");
	       aendDat    = resultSet.getString("SB_AEND_DAT");

	       if(aendDat != null){
	           jahr    = aendDat.substring(0,4);
	           monat   = aendDat.substring(5,7);
	           tag     = aendDat.substring(8,10);
	           uhrzeit = aendDat.substring(11,16);
		   aendDatString = "am:&nbsp;&nbsp;"+tag+"."+monat+"."+jahr+"&nbsp;"+uhrzeit+"<br>von:&nbsp;"+userID;
	       }
	       else{
		   aendDatString = "am:<br>von:";
	       }
	       
	       out.println("<tr><td align=\"center\">Zuschnitt-SB</td><td>");
               out.println("<input type=\"text\" name=\"zsb\" size=\"6\" maxlength=\"6\" value="+zsbID+" readonly></input></td></tr>");
	       out.println("<tr><td align=\"center\">Anlaufjahr</td><td>");
               out.println("<input type=\"text\" name=\"anl_jahr\" size=\"4\" maxlength=\"4\" value="+anlJahr+" readonly></input>");
	       out.println("</td></tr>");
	       out.println("<tr><td align=\"center\">Auslaufdatum</td><td>");
	       out.println("<input type=\"text\" name=\"ausl_dat_tag\" size=\"2\" maxlength=\"2\" value=\"00\"></input>.");
	       out.println("<input type=\"text\" name=\"ausl_dat_monat\" size=\"2\" maxlength=\"2\" value=\"00\"></input>.");
	       out.println("<input type=\"text\" name=\"ausl_dat_jahr\" size=\"4\" maxlength=\"4\" value=\"0000\"></input></td></tr>");
	       out.println("<tr><td align=\"center\">LD-Cutter-SB</td><td>");
	       out.println("<input type=\"text\" name=\"cutterSb1\" size=\"6\" maxlength=\"6\" value="+cutterSb1+"></input>");
	       out.println("<input type=\"text\" name=\"cutterSb2\" size=\"1\" maxlength=\"1\" value="+cutterSb2+"></input></td></tr>");
	       
	       out.println("<tr><td align=\"center\">Pfad</td><td>");
	       out.println("<input type=\"text\" name=\"pfad\" size=\"50\" maxlength=\"100\" value="+pfad+"></input></td></tr>");
	       out.println("<tr><td align=\"center\">Regel</td><td>");
	       out.println("<input type=\"text\" name=\"regel\" size=\"20\" maxlength=\"50\" value="+regel+"></input></td></tr>");
	       out.println("<tr><td align=\"center\">MDL</td><td>");
	       out.println("<input type=\"text\" name=\"mdl\" size=\"20\" maxlength=\"50\" value="+mdl+"></input></td></tr>");
	       out.println("<tr><td>Letzte &Auml;nderung</td>");
	       out.println("<td><font size=\"-1\">"+aendDatString+"</font></td></tr></table>");
	       out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"&Uuml;bernehmen\"></input>");
	       out.println("</td></tr></table></form>");

	     } catch(SQLException e) {
	         out.println("ZSB-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	  
	    }
	  //#####---Haken---#####
	  else if(art.equals("haken")){
	     out.println("<form action=\"./updaten.jsp?art=haken\" method=\"post\">");
	     out.println("<tr><td align=\"center\"><h3>Haken bearbeiten:</h3></td></tr></table>");
	     
	     //sbID  = new Long(request.getParameter("sbID")).longValue();
	     hkkid = request.getParameter("hkkid"); 
	     matKz = request.getParameter("matKZ"); 
	      
	     sql = "SELECT * FROM PLRV11.zus_haken_kopf where HKK_ID="+hkkid+" AND HKK_MAT_KZ='"+matKz+"'";
	     resultSet = stmt.executeQuery(sql);
	     
             out.println("<table border=\"1\" align=\"center\" bgcolor=\"#eeeeee\">");
	   	      
	     try
	     {
	       resultSet.next();
	    
	       anlJahr   = resultSet.getString("HKK_ANL_JAHR");
	       matKz     = resultSet.getString("HKK_MAT_KZ");
	       hakenNr   = resultSet.getLong("HKK_ID");
	       hakenBez  = resultSet.getString("HKK_BEZ");
	       hakenProg = resultSet.getInt("HKK_PROG");
	       kommentar = resultSet.getString("HKK_KOMMENTAR");
	       userID    = resultSet.getString("HKK_USER_ID");
	       aendDat   = resultSet.getString("HKK_AEND_DAT");

	       if(aendDat != null){
	           jahr    = aendDat.substring(0,4);
	           monat   = aendDat.substring(5,7);
	           tag     = aendDat.substring(8,10);
	           uhrzeit = aendDat.substring(11,16);
		   aendDatString = "am:&nbsp;&nbsp;"+tag+"."+monat+"."+jahr+"&nbsp;"+uhrzeit+"<br>von:&nbsp;"+userID;
	       }
	       else{
		   aendDatString = "am:<br>von:";
	       }
	       
	       //out.println("<tr><td align=\"center\">Zuschnitt-SB</td><td>");
               //out.println("<input type=\"text\" name=\"zsb\" size=\"6\" maxlength=\"6\" value="+sbID+" readonly></input></td></tr>");
	       out.println("<tr><td align=\"center\">Haken-ID</td><td>");
               out.println("<input type=\"text\" name=\"hkk_id\" size=\"8\" maxlength=\"8\" value="+hakenNr+" readonly></input></td></tr>");
	       out.println("<tr><td align=\"center\">Material</td><td>"); 
	       out.println("<input type=\"text\" name=\"hkk_material\" size=\"1\"  value="+matKz+" readonly></input></td></tr>");
	       out.println("<tr><td align=\"center\">Anlaufjahr</td><td>");
	       out.println("<input type=\"text\" name=\"anl_jahr\" size=\"4\"maxlength=\"4\" value="+anlJahr+" readonly></input></td></tr>");
	       out.println("<tr><td align=\"center\">Bezeichnung</td><td>");
	       out.println("<input type=\"text\" name=\"hkk_bez\" size=\"30\" maxlength=\"50\" value=\""+hakenBez+"\"></input></td></tr>");
	       out.println("<tr><td align=\"center\">Programm</td><td>");
	       out.println("<input type=\"text\" name=\"hkk_prog\" size=\"3\" maxlength=\"3\" value="+hakenProg+"></input></td></tr>");
	       out.println("<tr><td align=\"center\">Kommentar</td><td>");
	       out.println("<input type=\"text\" name=\"hkk_kommentar\" size=\"30\" maxlength=\"100\" value=\""+kommentar+"\"></input>");
	       out.println("</td></tr>");
	     
	       out.println("<tr><td>Letzte &Auml;nderung</td>");
	       out.println("<td><font size=\"-1\">am:&nbsp;&nbsp;"+tag+"."+monat+"."+jahr+"&nbsp;"+uhrzeit+"<br>von:&nbsp;"+userID);
	       out.println("</font></td></tr></table>");
	       out.println("<table border=\"0\" align=\"center\"><tr><td><input type=\"submit\" value=\"&Uuml;bernehmen\"></input>");
	       out.println("</td></tr></table></form>");
             	  
	     } catch(SQLException e) {
	         out.println("Haken-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	  }
	  
	  con.close();
%>

</body>
</html>
      
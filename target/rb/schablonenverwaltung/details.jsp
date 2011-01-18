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
	  String sql1          = "";
	  String modID         = "";
	  String zsbID         = "";
	  String sbID          = "";
	  String anlJahr       = "";
	  String auslDat       = "";
	  String gueltKz       = "";
	  String cutterSb      = "";
	  String pfad          = "";
	  String regel         = "";
	  String mdl           = "";
	  String userID        = "";
	  String aendDat       = "";
	  String jahr          = "";
	  String monat         = "";
	  String tag           = "";
	  String uhrzeit       = "";
	  String hakenID       = "";
	  String new_hakenID   = "";
	  String hkkid         = "";
	  String matKz         = "";
	  String hakenNr       = "";
	  String new_hakenNr   = "";
          String hakenBez      = "";
	  String hakenProg     = "";
	  String kommentar     = "";
	  String new_hakenProg = "";
	  long standort        = 0;
	  long aktPlatz        = 0;
	  long reservAbnr      = 0;
          int lfdNr            = 0;
          String modBez        = "";
	  int modProg          = 0;
	  String progID        = "";
	  String new_progID    = "";;
	  //long modNr         = 0;
	  String modNr         = "";
	  String new_modNr     = "";
	  String new_modID     = "";
	  String new_sbID      = "";
	  String aendDatString = "";
	  int count            = 0;
	  String linkVar       = "";
          int count1           = 0;
	  String hakenreihe    = "";
	  
	  ResultSet resultSet;
          ResultSet resultSet1;
	  Statement stmt;
	  Statement stmt1;
	  stmt   = con.createStatement();
	  stmt1  = con.createStatement();
	  
	  String art = request.getParameter("art");
	
	  //######---Programm---#####
	  if(art.equals("prog"))
	  { 
	     progID = request.getParameter("prog_id");
	     count  = progID.length();

	     //#####---auf korrekte Laenge bringen---#####
	     if(count == 1){
	        new_progID = "00"+progID;
	     }
	     else if(count == 2){
	       new_progID = "0"+progID;
	     }
	     else{
	       new_progID = progID;
	     }
	     out.println("<tr><td align=\"center\"><h3>Programm&nbsp;"+new_progID+"</h3></td></tr></table>");
	     
	     sql = "SELECT MOD_NR,MOD_BEZ FROM PLRV11.PLR_MODELL WHERE MOD_PROG="+progID+" ORDER BY MOD_NR";
	     //out.println(sql);
	    
	     resultSet = stmt.executeQuery(sql);
	    
	     out.println("<table border=\"0\" align=\"center\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	     out.println("<tr><td>&nbsp;</td></tr></table>"); 
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	     out.println("<colgroup><col width=\"90\"><col width=\"280\"><col width=\"80\"><col width=\"80\"></colgroup>");
	     out.println("<tr><td><b>Modell</b></td>");
	     out.println("<td><b>Bezeichnung</b></td><td>&nbsp;</td><td>&nbsp;</td>");

	     try
	     {
	       while(resultSet.next()){
	         modNr  = resultSet.getString("MOD_NR");
	         modBez = resultSet.getString("MOD_BEZ");
	         count  = modNr.length();

	         //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
	         if(count == 6)
	         {
	            new_modNr = "0"+modNr;
	         }
	         else if(count == 5)
	         {
	            new_modNr = "00"+modNr;
	         }
	         else
	         {
	            new_modNr = modNr;
	         }

	         String zsb = new_modNr.substring(0,6);
	         out.println("<tr><td>"+new_modNr+"</td>");
		 out.println("<td>"+modBez+"</td><td align=\"center\">");
		 out.println("<a href=\"./details.jsp?art=mod&mod_id="+new_modNr+"\" target=\"main\">");
		 out.println("<img src=\"./img/details.jpg\" border=\"0\"></a>&nbsp;</TD>");
		 
		 //#####---Gibts schon ein ZSB??---#####
		 sql1 = "SELECT SB_ANL_JAHR FROM PLRV11.ZUS_SCHNITTBILD WHERE SB_ID="+zsb;
		 //out.println(sql1);
		     count1 = 0;
	             resultSet1 = stmt1.executeQuery(sql1);
                     try
	             {
	                while(resultSet1.next()){
	                  count1 ++;
		        }
	             }  catch(SQLException e) {
	                   out.println("Fehler!!&nbsp;"+e+"<p>");
                        }
		     if(count1 == 1){
		       out.println("<td align=\"center\">&nbsp;</td>");
		     }
		     else{
		       out.println("<td align=\"center\"><a href=\"./zsb_anlage_maske.jsp?zsb="+zsb+"\" target=\"main\">");
	               out.println("<img src=\"./img/zsb-anlegen.jpg\" border=\"0\"></a>&nbsp;</td>");
		     }

		 out.println("</tr>"); 
	       }     
	     } catch(SQLException e) {
	         out.println("Programmnummer nicht gefunden!<br>");
	         out.println(e);
	       }
	     out.println("</table>");
	  }
		
	  //######---Modell---#####
	  if(art.equals("mod"))
	  { 
	     out.println("<tr><td align=\"center\"><h3>Modell</h3></td></tr></table>");
	     modID = request.getParameter("mod_id");
	     count = modID.length();
	     
	     //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
	     if(count == 6)
	     {
	       new_modID = "0"+modID;
	     }
	     else if(count == 5)
	     {
	       new_modID = "00"+modID;
	     }
	     else
	     {
	        new_modID = modID;
	     }
	     
	     String mod_zsb = new_modID.substring(0,6);
	 
	     sql = "SELECT MOD_BEZ,MOD_PROG FROM PLRV11.PLR_MODELL WHERE MOD_NR="+modID;
	     //out.println(sql);
	     resultSet = stmt.executeQuery(sql);
	     
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");

	     try
	     {
	       resultSet.next();
	       
	       modBez  = resultSet.getString("MOD_BEZ");
	       modProg = resultSet.getInt("MOD_PROG");

	       out.println("<tr><td>Modell</td><td>"+modID+"</td></tr>");
	       out.println("<tr><td>Bezeichnung</td><td>"+modBez+"</td></tr>");
	       out.println("<tr><td>Modell-ZSB</td><td>"+mod_zsb+"</td></tr></table>");
	     
	     } catch(SQLException e) {
	         out.println("Modellnummer nicht gefunden!<br>");
	         out.println(e);
	       }
	  
	     out.println("<table border=\"0\" align=\"center\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	     out.println("<tr><td>&nbsp;</td></tr></table>"); 

	     sql1 = "SELECT SB_ID,SB_ANL_JAHR,SB_AUSL_DAT  FROM PLRV11.ZUS_SCHNITTBILD WHERE SB_ID="+mod_zsb;
	     //out.println(sql);
	     resultSet1 = stmt.executeQuery(sql1);

	     try
	     {
	       out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	       out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	       out.println("<tr><td><b>ZSB</b></td>");
	       out.println("<td>&nbsp;</td></tr>");
	       while(resultSet1.next()){
	           sbID = resultSet1.getString("SB_ID");
	           out.println("<tr><td>"+mod_zsb+"</td><td>");
		   out.println("<a href=\"./details.jsp?art=zsb&zsb_id="+sbID+"\" target=\"main\">");
		   out.println("<img src=\"./img/details.jpg\" border=\"0\"></a>&nbsp;");
		   out.println("<a href=\"./loeschen_confirm.jsp?sbID="+sbID+"&var=zsb\" target=\"main\">");
	           out.println("<img src=\"./img/loeschen.jpg\" border=\"0\"></a>&nbsp;");
		   //out.println("<a href=\"./zsb_anlage_maske.jsp?zsb="+sbID+"\" target=\"main\">");
	           //out.println("<img src=\"./img/neuer-haken.jpg\" border=\"0\"></a>&nbsp;");
		   out.println("</td></tr>"); 
	       }
	     } catch(SQLException e) {
	         out.println("SB-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	     out.println("<table>");
	     
	  }
	  //#####---ZSB---#####
	  else if(art.equals("zsb"))
          {
	     out.println("<tr><td align=\"center\"><h3>Zuschnitt-Schnittbild</h3></td></tr></table>");
	     zsbID = request.getParameter("zsb_id");

	     sql       = "SELECT * FROM PLRV11.zus_schnittbild where SB_ID="+zsbID;
	     resultSet = stmt.executeQuery(sql);
	   	 	     
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
    
	     try
	     {
	       while(resultSet.next()){
	    
	         sbID       = resultSet.getString("SB_ID");
		 count      = sbID.length();
				 
		 //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
		 if(count == 5)
		 {
		   new_sbID = "0"+sbID; 
	           hakenreihe = sbID.substring(0,2);
		 }
		 else if(count == 4)
		 {
		   new_sbID = "00"+sbID;
	           hakenreihe = sbID.substring(0,1);
		 }
		 else
		 {
	           new_sbID = sbID;
	           hakenreihe = sbID.substring(0,3);
		 }
	         //out.println(hakenreihe);
	         anlJahr    = resultSet.getString("SB_ANL_JAHR");
	         auslDat    = resultSet.getString("SB_AUSL_DAT");
		     cutterSb   = resultSet.getString("SB_CUTTER_SB");
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
	         out.println("<tr><td>ZSB-NR.</td><td>"+new_sbID+"</td></tr>");
	         out.println("<tr><td>Anlaufjahr</td><td>"+anlJahr+"</td></tr>");
	         
		 if(auslDat == null)
	         {
	            out.println("<tr><td>Auslaufdatum</td><td>-</td></tr>");
	         }
	         else
	         {
	            String newauslDat = auslDat.substring(0,10);
	            out.println("<tr><td>Auslaufdatum</td><td>"+newauslDat+"</td></tr>");
	         }
	         out.println("<tr><td>Cutter SB</td><td>"+cutterSb+"</td></tr>");
	         out.println("<tr><td>Pfad</td><td>"+pfad+"</td></tr>");
	         out.println("<tr><td>Regel</td><td>"+regel+"</td></tr>");
	         out.println("<tr><td>MDL</td><td>"+mdl+"</td></tr>");
	         out.println("<tr><td>Letzte &Auml;nderung</td>");
	         out.println("<td><font size=\"-1\">"+aendDatString+"</font></td></tr></table>");
  	      
	         out.println("<table border=\"0\" align=\"center\" width=\"500\" bgcolor=\"#ddddff\">");
	         out.println("<tr><td align=\"center\">");
	         out.println("<a href=\"./bearbeiten.jsp?art=zsb&sbID="+new_sbID+"\" target=\"main\">");
	         out.println("<img src=\"./img/bearbeiten.jpg\" border=\"0\"></a>&nbsp;");
	         out.println("<a href=\"./loeschen_confirm.jsp?sbID="+new_sbID+"&var=zsb\" target=\"main\">");
	         out.println("<img src=\"./img/loeschen.jpg\" border=\"0\"></a>&nbsp;");
                 out.println("<a href=\"./hkk_anlage_maske.jsp?zsb="+new_sbID+"&anlJahr="+anlJahr+"&prog="+hakenreihe+"\" target=\"main\">");
	         out.println("<img src=\"./img/neuer-haken.jpg\" border=\"0\"></a>&nbsp;");
	         out.println("</td></tr></table>");
	         out.println("<table border=\"0\" align=\"center\" bgcolor=\"#ddddff\">");
	         out.println("<tr><td align=\"center\">");
		 out.println(" <form action=\"./anlegen.jsp?art=haken_spezial\" method=\"post\">");
		 out.println("Haken:&nbsp;"+oraBde.getHtmlSelectSpezial("hkk_id","SELECT DISTINCT HKK_MAT_KZ,HKK_ID,HKK_ID FROM PLRV11.ZUS_HAKEN_KOPF WHERE HKK_PROG="+hakenreihe+""," "));
                 out.println("<input type=\"hidden\" name=\"zsb\" value="+sbID+">");
                 out.println("</td><td><input type=\"submit\" value=\"Hinzuf&uuml;gen\"></td></tr></table></form>");
		 out.println("<table border=\"0\" align=\"center\">");
	         out.println(" <form action=\"./anlegen.jsp?art=alle_haken_kopieren\" method=\"post\">");
	         out.println("<input type=\"hidden\" name=\"zsb\" value="+sbID+">");
	         out.println("<tr><td>Alle Haken des Materials&nbsp;");
		 out.println("<select size=\"1\" name=\"von_mat\">");
	         out.println("<option value=\"L\" selected>Leder</option>");
	         out.println("<option value=\"S\">Stoff</option>");
	         out.println("<option value=\"Z\">Leinen-Zuschnitt</option>");
	         out.println("</select>");
	         out.println("&nbsp;kopieren nach&nbsp;"); 
                 out.println("<select size=\"1\" name=\"nach_mat\">");
	         out.println("<option value=\"L\">Leder</option>");
	         out.println("<option value=\"S\" selected>Stoff</option>");
	         out.println("<option value=\"Z\">Leinen-Zuschnitt</option>");
	         out.println("</select>");
                 out.println("&nbsp;<input type=\"submit\" value=\"OK\"></input></td></tr></form>");
	         out.println("<tr><td>&nbsp;</td></tr>");
		 out.println("<tr><td align=\"center\">");
		 out.println("<input type=\"button\" name=\"Verweis\" value=\"Haken ausleihen\" onClick=\"self.location.href='./verleihnix.jsp?zsb="+new_sbID+"'\">");	
		 out.println("</td></tr></table>");
	       } 
	     } catch(Exception e) {
	         out.println("Artikelnummer nicht gefunden!<br>");
	         out.println(e);
		 out.println(e.getMessage());
	       }
	  
	     out.println("<table border=\"0\" align=\"center\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	     out.println("<tr><td>&nbsp;</td></tr></table>"); 

	     sql  = "SELECT VKN_SB_ID,VKN_HKK_ID,VKN_HKK_MAT_KZ FROM PLRV11.zus_vkn_hkk_zsb WHERE vkn_SB_ID="+zsbID;
	     sql += " ORDER BY VKN_HKK_MAT_KZ,VKN_HKK_ID";
	     //out.println(sql);
	     
	     resultSet = stmt.executeQuery(sql);

	     try
	     {
	       out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	       out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	       out.println("<tr><td><b>Haken</b></td>");
	       out.println("<td>&nbsp;</td>");
	       while(resultSet.next()){
	         sbID    = resultSet.getString("vkn_SB_ID");
	         hakenID = resultSet.getString("VKN_HKK_ID");
	         matKz   =  resultSet.getString("VKN_HKK_MAT_KZ");

	          //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
                  count      = hakenID.length();
	          if(count == 7)
	          {
	            new_hakenID = "0"+hakenID;
	          }
	          else if(count == 6)
	          {
	            new_hakenID = "00"+hakenID;
	          }
	          else
	          {
	            new_hakenID = hakenID;
	          }

	         out.println("<tr><td>"+matKz+"-"+new_hakenID+"</td><td>");
		 out.println("<a href=\"./details.jsp?art=haken&hkkid="+hakenID+"&sbID="+sbID+"&matKz="+matKz+"\" target=\"main\">");
		 out.println("<img src=\"./img/details.jpg\" border=\"0\"></a>&nbsp;");
		 //out.println("<a href=\"./loeschen_confirm.jsp?sbID="+sbID+"&var=vkn&hkkID="+hakenID+"&matKZ="+matKz+"&anlJahr="+anlJahr+"\"\" target=\"main\">");
		 out.println("<a href=\"./loeschen_confirm.jsp?sbID="+sbID+"&var=vkn&hkkID="+hakenID+"&matKZ="+matKz+"\" target=\"main\">");
	         out.println("<img src=\"./img/loeschen.jpg\" border=\"0\"></a>&nbsp;[nur die Verkn&uuml;pfung!]&nbsp;");
		 out.println("</td></tr>"); 
	       }
	     } catch(SQLException e) {
	         out.println("ZSB-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	      out.println("</table>");

	    }

	  //#####---Haken---#####
	  else if(art.equals("haken"))
	  {
	     out.println("<tr><td align=\"center\"><h3>Haken Details</h3></td></tr></table>");
	     //sbID  = request.getParameter("sbID"); 
	     hkkid = request.getParameter("hkkid"); 
	     matKz = request.getParameter("matKz");  
	      
	     sql = "SELECT * FROM PLRV11.zus_haken_kopf where HKK_ID="+hkkid+" AND HKK_MAT_KZ='"+matKz+"'";
	  // AND HKK_SB_ID="+sbID;
	     resultSet = stmt.executeQuery(sql);
	     
             //out.println(sql);
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>"); 
	      
	     try
	     {
	       resultSet.next();
	    
	       anlJahr   = resultSet.getString("HKK_ANL_JAHR");
	       matKz     = resultSet.getString("HKK_MAT_KZ");
	       hakenNr   = resultSet.getString("HKK_ID");
	       hakenBez  = resultSet.getString("HKK_BEZ");
	       hakenProg = resultSet.getString("HKK_PROG");
	       kommentar = resultSet.getString("HKK_KOMMENTAR");
	       userID    = resultSet.getString("HKK_USER_ID");
	       aendDat   = resultSet.getString("HKK_AEND_DAT");

	       //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
               count      = hakenNr.length();
	       if(count == 7)
	       {
	         new_hakenNr = "0"+hakenNr;
	       }
	       else if(count == 6)
	       {
	         new_hakenNr = "00"+hakenNr;
	       }
	       else
	       {
	         new_hakenNr = hakenNr;
	       }


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
	       
	       count = hakenProg.length();
	       if(count == 1){
	          new_hakenProg = "00"+hakenProg;
	       }
	       else if(count == 2){
	          new_hakenProg = "0"+hakenProg;
	       }
	       else{
	          new_hakenProg = hakenProg;
	       }
	       out.println("<tr><td>Haken-NR.</td><td>"+matKz+"-"+new_hakenNr+"</td></tr>");
	       out.println("<tr><td>Anlaufjahr</td><td>"+anlJahr+"</td></tr>");
	       out.println("<tr><td>Bezeichnung</td><td>"+hakenBez+"</td></tr>");
	       out.println("<tr><td>Programm</td><td>"+new_hakenProg+"</td></tr>");
	       out.println("<tr><td>Kommentar</td><td>"+kommentar+"</td></tr>");
	       out.println("<tr><td>Letzte &Auml;nderung</td>");
	       out.println("<td><font size=\"-1\">"+aendDatString+"</font></td></tr></table>");
	       out.println("<table border=\"0\" align=\"center\" width=\"500\" bgcolor=\"#ddddff\">");
	       out.println("<tr><td align=\"center\">");
	       out.println("<a href=\"./bearbeiten.jsp?art=haken&hkkid="+hkkid+"&matKZ="+matKz+"\" target=\"main\">");
	       out.println("<img src=\"./img/bearbeiten.jpg\" border=\"0\"></a>&nbsp;");
	       out.println("<a href=\"./loeschen_confirm.jsp?var=haken&hkkID="+hkkid+"&matKZ="+matKz+"&anlJahr="+anlJahr+"\"\" target=\"main\">");
	       out.println("<img src=\"./img/loeschen.jpg\" border=\"0\"></a>&nbsp;");
	       out.println("<a href=\"./anlegen.jsp?art=haken_neu&anlJahr="+anlJahr+"&hkkid="+hakenNr+"&hakenMat="+matKz+"&hakenBez="+hakenBez+"&hakenProg="+hakenProg+"\" target=\"main\">");
	       out.println("<img src=\"./img/neuer-haken.jpg\" border=\"0\"></a>&nbsp;");
	       out.println("</td></tr>");

	       /*out.println(" <form action=\"./anlegen.jsp?art=haken\" method=\"post\">");
	       out.println("<input type=\"hidden\" name=\"zsb\" value="+sbID+"></input>");
	       out.println("<input type=\"hidden\" name=\"hkk_id\" value="+hkkid+"></input>");
               out.println("<input type=\"hidden\" name=\"anl_jahr\" value="+anlJahr+"></input>");
	       out.println("<input type=\"hidden\" name=\"hkk_bez\" value="+hakenBez+"></input>");
	       out.println("<input type=\"hidden\" name=\"hkk_prog\" value="+hakenProg+"></input>");
	       out.println("<input type=\"hidden\" name=\"hkk_bez\" value="+sbID+"></input>");
	       out.println("<tr><td align=\"center\">Haken kopieren nach:&nbsp;");
	       out.println("<select size=\"1\" name=\"hkk_material\">");
	       out.println("<option value=\"L\" selected>Leder</option>");
	       out.println("<option value=\"S\">Stoff</option>");
	       out.println("<option value=\"Z\">Leinen-Zuschnitt</option>");
	       out.println("</select>");
               out.println("&nbsp;<input type=\"submit\" value=\"Kopieren\"></input></form>");*/

	       out.println("</td></tr></table>"); 
	  
	     } catch(SQLException e) {
	         out.println("Hakennummer nicht gefunden!<br>");
	         out.println(e);
	       }
	     
	     out.println("<table border=\"0\" align=\"center\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>");
	     out.println("<tr><td>&nbsp;</td></tr></table>"); 

	     sql = "SELECT * FROM PLRV11.zus_haken_detail WHERE HKD_ID="+hakenNr+" AND HKD_MAT_KZ='"+matKz+"'";
	     //out.println(sql);
	     resultSet = stmt.executeQuery(sql);

	     try
	     {
	       out.println("<table border=\"1\" align=\"center\" bgcolor=\"#c0c0c0\">");
	       out.println("<colgroup><col width=\"40\"><col width=\"210\"><col width=\"210\">");
	       out.println("<col width=\"30\"></colgroup>");
	       out.println("<tr>");
	       out.println("<td><b>Nr.</b></td><td><b>Lagerort</b></td>");
	       out.println("<td><b>Akt. Platz</b></td><td>&nbsp;</td></tr></table>");
	    
	       while(resultSet.next()){
	         hakenID    = resultSet.getString("HKD_ID");
		 lfdNr      = resultSet.getInt("HKD_LFD_NR");
		 standort   = resultSet.getLong("HKD_STANDORT");
		 reservAbnr = resultSet.getLong("HKD_RESERV_ABNR");
		 aktPlatz   = resultSet.getLong("HKD_AKT_PLATZ");
	         anlJahr    = resultSet.getString("HKD_ANL_JAHR"); 
	         matKz      = resultSet.getString("HKD_MAT_KZ"); 

	         out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
		 out.println("<colgroup><col width=\"40\"><col width=\"210\">");
		 out.println("<col width=\"210\"><col width=\"30\"></colgroup>");
	         out.println("<tr>");
		 out.println("<td>"+lfdNr+"</td>");
		 out.println("<td><a href=\"./zuweisen.jsp?art=standort&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+standort+"</a></td>");
	         out.println("<td>"+aktPlatz+"</td>");
		 //out.println("<td><a href=\"./zuweisen.jsp?art=platz&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+aktPlatz+"</a></td>");
		 //out.println("<td>"+reservAbnr+"</td>");
	         //out.println("<td><a href=\"./zuweisen.jsp?art=reserv&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+reservAbnr+"</a></td>");
	         out.println("<td><a href=\"./loeschen_confirm.jsp?var=haken_detail&hkkID="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKZ="+matKz+"\" target=\"main\">");
	         out.println("<img src=\"./img/recycle.gif\" border=\"0\"></a></td>");
		 out.println("</tr>");
	       }
	     } catch(SQLException e) {
	         out.println("Haken-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	      out.println("</table>");
	}

          //#####---Haken-Einzelanzeige aus Eingabefeld---#####
	  else if(art.equals("haken_solo"))
	  {
	     hakenNr = request.getParameter("hkk_id"); 
	     matKz   = request.getParameter("mat"); 

	     out.println("<tr><td align=\"center\"><h3>Haken Details</h3></td></tr></table>");
	   
	     sql  = "SELECT HKK_ANL_JAHR,HKK_BEZ,HKK_PROG,HKK_USER_ID,HKK_AEND_DAT FROM PLRV11.zus_haken_kopf where HKK_ID="+hakenNr+" AND";
	     sql += " HKK_MAT_KZ='"+matKz+"'";
	     resultSet = stmt.executeQuery(sql);
	     
             //out.println(sql);
	     out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
	     out.println("<colgroup><col width=\"190\"><col width=\"300\"></colgroup>"); 
	      
	     try
	     {
	       resultSet.next();
	    
	       anlJahr   = resultSet.getString("HKK_ANL_JAHR");
	       hakenBez  = resultSet.getString("HKK_BEZ");
	       hakenProg = resultSet.getString("HKK_PROG");
	       userID    = resultSet.getString("HKK_USER_ID");
	       aendDat   = resultSet.getString("HKK_AEND_DAT");

	       //#####---Probleme wegen fuehrender Nullen aus dem Weg gehen---#####
               count = hakenNr.length();
	       if(count == 7)
	       {
	         new_hakenNr = "0"+hakenNr;
	       }
	       else if(count == 6)
	       {
	         new_hakenNr = "00"+hakenNr;
	       }
	       else
	       {
	         new_hakenNr = hakenNr;
	       }

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
	       
	       count = hakenProg.length();
	       if(count == 1){
	          new_hakenProg = "00"+hakenProg;
	       }
	       else if(count == 2){
	          new_hakenProg = "0"+hakenProg;
	       }
	       else{
	          new_hakenProg = hakenProg;
	       }

	       out.println("<tr><td>Haken-NR.</td><td>"+matKz+"-"+new_hakenNr+"</td></tr>");
	       out.println("<tr><td>Anlaufjahr</td><td>"+anlJahr+"</td></tr>");
	       out.println("<tr><td>Bezeichnung</td><td>"+hakenBez+"</td></tr>");
	       out.println("<tr><td>Programm</td><td>"+new_hakenProg+"</td></tr>");
	       out.println("<tr><td>Letzte &Auml;nderung</td>");
	       out.println("<td><font size=\"-1\">"+aendDatString+"</font></td></tr></table>");
 
	     } catch(SQLException e) {
	         out.println("Haken-ID nicht gefunden!<br>");
	         out.println(e);
	       }

	     out.println("</table>");
	     out.println("<table border=\"0\" align=\"center\">");
	     out.println("<tr><td>");
	     out.println("<a href=\"./loeschen_confirm.jsp?var=haken&hkkID="+hakenNr+"&matKZ="+matKz+"&anlJahr="+anlJahr+"\"\" target=\"main\">");
	     out.println("<img src=\"./img/loeschen.jpg\" border=\"0\"></a>&nbsp;");
	     out.println("</td></tr></table>");
	     sql = "SELECT * FROM PLRV11.zus_haken_detail WHERE HKD_ID="+hakenNr+" AND HKD_MAT_KZ='"+matKz+"'";
	     //out.println(sql);
	     resultSet1 = stmt.executeQuery(sql);

	     try
	     {
	       out.println("<table border=\"1\" align=\"center\" bgcolor=\"#c0c0c0\">");
	       out.println("<colgroup><col width=\"40\"><col width=\"210\"><col width=\"210\">");
	       out.println("<col width=\"30\"></colgroup>");
	       out.println("<tr>");
	       out.println("<td><b>Nr.</b></td><td><b>Lagerort</b></td>");
	       out.println("<td><b>Akt. Platz</b></td><td>&nbsp;</td></tr></table>");
	    
	       while(resultSet1.next()){
	         hakenID    = resultSet1.getString("HKD_ID");
		 lfdNr      = resultSet1.getInt("HKD_LFD_NR");
		 standort   = resultSet1.getLong("HKD_STANDORT");
		 reservAbnr = resultSet1.getLong("HKD_RESERV_ABNR");
		 aktPlatz   = resultSet1.getLong("HKD_AKT_PLATZ");
	         anlJahr    = resultSet1.getString("HKD_ANL_JAHR"); 
	         matKz      = resultSet1.getString("HKD_MAT_KZ"); 

	         out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
		 out.println("<colgroup><col width=\"40\"><col width=\"210\"><col width=\"210\">");
		 out.println("<col width=\"30\"></colgroup>");
	         out.println("<tr>");
		 out.println("<td>"+lfdNr+"</td>");
		 out.println("<td><a href=\"./zuweisen.jsp?art=standort&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+standort+"</a></td>");
		 out.println("<td>"+aktPlatz+"</td>");
	         //out.println("<td><a href=\"./zuweisen.jsp?art=platz&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+aktPlatz+"</a></td>");
		 //out.println("<td>"+reservAbnr+"</td>");
	         //out.println("<td><a href=\"./zuweisen.jsp?art=reserv&hkkid="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKz="+matKz+"\" target=\"main\">"+reservAbnr+"</a></td>");
	         out.println("<td><a href=\"./loeschen_confirm.jsp?var=haken_detail&hkkID="+hakenID+"&anlJahr="+anlJahr+"&lfdNr="+lfdNr+"&matKZ="+matKz+"\" target=\"main\">");
	         out.println("<img src=\"./img/recycle.gif\" border=\"0\"></a></td>");
		 out.println("</tr>");	         


	         /*out.println("<table border=\"1\" align=\"center\" bgcolor=\"#ffffff\">");
		 out.println("<colgroup><col width=\"40\"><col width=\"140\"><col width=\"140\">");
		 out.println("<col width=\"140\"></colgroup>");
	         out.println("<tr>");
		 out.println("<td>"+lfdNr+"</td>");
		 out.println("<td><font color=\"blue\">"+standort+"</font></td>");
		 out.println("<td><font color=\"blue\">"+aktPlatz+"</font></td>");
		 out.println("<td><font color=\"blue\">"+reservAbnr+"</font></td>");
	         out.println("</tr>");*/
	       }
	     } catch(SQLException e) {
	         out.println("Haken-ID nicht gefunden!<br>");
	         out.println(e);
	       }
	      out.println("</table>");
	    
}

    con.close();
%>
</body>
</html>
      
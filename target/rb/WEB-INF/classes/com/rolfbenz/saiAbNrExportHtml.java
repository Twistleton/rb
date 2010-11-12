package com.rolfbenz;

import java.sql.*;
import java.util.*;
import java.text.*;
import java.net.*;

public class saiAbNrExportHtml {
    public static void main(String args []){
        System.out.println(export("/etc/zusJsp.conf"));
    }
    public static String export (String confDatei) {
        String rueck = new String();
        zusConfigDatei zcd = new zusConfigDatei(confDatei);
        zcd.verarbeiten();
        int zaehler=0;
        try {
                bdeDb oraBde = new bdeDb(confDatei);
                Connection con = oraBde.getConnection();
                con.setAutoCommit(false);
                Statement stmt = con.createStatement();
                ResultSet rs;
                ResultSetMetaData  rsmd;
                String sql       = new String();

                basisDatei saiExport = new basisDatei("/tmp","saiAbNrExport","html");
                saiExport.oeffnen();

                sql  = "SELECT * ";
                sql += "FROM plrv11.sai_table1 ";
                sql += "ORDER BY sai_time,sai_name,sai_auftrag";
		saiExport.ausgabe.write("<HTML><BODY><TABLE BORDER=1>");
                try {
                        stmt.executeQuery(sql);
                        rs = stmt.getResultSet();
                        rsmd = rs.getMetaData();
                        while (rs.next()) {
				saiExport.ausgabe.write("<TR><TD>");
                                if (zaehler==0) {
                                        for (int i=1;i<=rsmd.getColumnCount();i++) {
                                                if (rs.getString(i)!=null) {
                                                        saiExport.ausgabe.write(rsmd.getColumnName(i));
                                                }
                                                saiExport.ausgabe.write("</TD><TD>");
                                        }
					saiExport.ausgabe.write("</TD></TR><TR><TD>");
                                }

                                for (int i=1;i<=rsmd.getColumnCount();i++) {
                                        if (rs.getString(i)!=null) {
                                                saiExport.ausgabe.write(rs.getString(i));
                                        }
                                        saiExport.ausgabe.write("</TD><TD>");
                                }
                                saiExport.ausgabe.write("\n");
                                zaehler++;
				saiExport.ausgabe.write("</TD></TR>\n");
                        }
                }
                catch (SQLException sqlex) {
                        System.out.println(sqlex.getMessage());
                }
		saiExport.ausgabe.write("</TABLE></BODY></HTML>");
                saiExport.schliessen();
                saiExport.aktiviereDatei();
                stmt.close();
                con.close();
        }
        catch (Exception e) {
                e.printStackTrace();
                System.out.println(e.getMessage());
        }
        return rueck;
    }
}

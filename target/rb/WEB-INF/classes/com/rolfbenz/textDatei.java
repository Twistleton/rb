package com.rolfbenz;

import java.io.*;
import java.util.*;
import java.text.*;
import java.lang.*;

public class textDatei {
    private String pfad;
    private String dateiname;
    private FileOutputStream ausgabeStrom;
    private PrintWriter      ausgabe;
    private boolean append;

    public textDatei() {
        
    }    
    public textDatei(String iPfad,String iDateiName) {
        pfad      = new String (iPfad);
        dateiname = new String (iDateiName);                    
	append    = true;
    }

    public textDatei(File iPfad) {
        pfad      = new String (iPfad.getPath().substring(0,iPfad.getPath().lastIndexOf("/")));
        dateiname = new String (iPfad.getPath().substring(iPfad.getPath().lastIndexOf("/")+1));
	append    = true;
    }
    public void setNameTimestamp(String iPfad, String iEndung) {              
        dateiname = bdeZeit.getTimestamp("yyMMddHHmmss") + iEndung;
        pfad      = iPfad;
	append    = true;
    }    
    public String getPfad() {
        return pfad;
    }
    public String getDateiname() {
        return dateiname;
    }
    public void setNameTimestamp(String iPfad, String iAnfang,String iEndung) {
        dateiname = iAnfang + bdeZeit.getTimestamp("yyMMddHHmmss") + iEndung;
        pfad      = iPfad;
    }    
    public void nichtAnhaengen() {
	append=false;
    }
    public void anhaengen() {
	append=true;
    }
    public void writeln(String text) {
        try {
            ausgabeStrom = new FileOutputStream(pfad + "/" + dateiname,append);
            ausgabe      = new PrintWriter(ausgabeStrom);
            ausgabe.println(text);
            ausgabe.flush();           
            ausgabe.close();
            ausgabeStrom.close();
        }
        catch(IOException ioe) {
            ioe.printStackTrace();
        }
    }
    public void write(String text) {
        try {
            ausgabeStrom = new FileOutputStream(pfad + "/" + dateiname,append);
            ausgabe      = new PrintWriter(ausgabeStrom);
            ausgabe.print(text);
            ausgabe.flush();           
            ausgabe.close();
            ausgabeStrom.close();
        }
        catch(IOException ioe) {
            ioe.printStackTrace();

        }
    }
    public static String format(char iPaddChar,int iLength,String iString) {
        String retString = new String();
        int i=0;
        if (iString==null) iString="";         

        while( i < iLength) {
            if (i < (iLength-iString.length()) ) {              
                retString += iPaddChar;
            } else {               
                retString += iString.charAt(i-(iLength-iString.length()));
            }
        
        i++;                                                                            
        }
        return (retString);
    }

}

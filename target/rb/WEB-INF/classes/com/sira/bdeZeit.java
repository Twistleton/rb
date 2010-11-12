package com.sira;

import java.util.*;
import java.text.*;

public class bdeZeit {
    public bdeZeit() {	 
    }    
    public static String  getTimestamp(String iFormat) {
       	Date datum = new Date();
	String     timestamp = new String();	
	timestamp = new  SimpleDateFormat(iFormat).format(datum);      
	return timestamp;
    }
}

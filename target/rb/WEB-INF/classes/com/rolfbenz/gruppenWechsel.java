package com.rolfbenz;

public class gruppenWechsel {
	private int neu;
	private String wert = new String();
	
	public void gruppenWechsel(){
		neu=1;
	}
	public int veraendert(String iWert) {
		if ((iWert.compareTo(wert)!=0) || (neu==1)) {
			neu=0;			
			wert=iWert;
			return 1;
		} else {			
			return 0;
		}
	}
}
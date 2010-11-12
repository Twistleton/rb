/* Ergänzung Lohnzuschnitt - Stand: 08.07.2008 */

package com.rolfbenz;

import java.util.*;

public class zusConfigDatei extends configDatei {
	private String abpDrucker                = new String();
	private String abpEndung                 = new String();
	private String abpDruckPfad              = new String();
	private String zusDrucker                = new String();
	private String manZusDrucker             = new String();
	private String cutZusDrucker             = new String();
	private String pufZusDrucker             = new String();
	private String zusBereitstellListeEndung = new String();
	private String zusLogPfad                = new String();
	private String komBildSperrDatei         = new String();
	private String zusDruckPfad              = new String();
	private String rueckMeldPfad             = new String();
	private String rueckMeldEndung           = new String();
	private String startEndeEndung           = new String();
	private String cutPfad                   = new String();
	private String cutEndung                 = new String();
	private String cutHilfPfad               = new String();
	private String cutHilfEndung             = new String();
	private String cutHilfDrucker		 = new String();
	private String qmPfad 			 = new String();
	private String qmEndung			 = new String();
	private String qmRWPEndung		 = new String();
	private String qmDrucker		 = new String();
	private String bqsPfad        		 = new String();
	private String bqsEndung		 = new String();
	private String errorDir                  = new String();
	private String lsEndung			 = new String();
	private String lsDrucker                 = new String();
	private String lsDruckPfad               = new String();
	

	public zusConfigDatei() {
	}
	public zusConfigDatei(String dname) {
		super(dname);
	}
	public String getZusDrucker() {
		return zusDrucker;
	}
	public String getManZusDrucker() {
		return manZusDrucker;
	}
	public String getCutZusDrucker() {
		return cutZusDrucker;
	}
	public String getPufZusDrucker() {
		return pufZusDrucker;
	}	
	public String getZusBereitstellListeDrucker() {
		return zusBereitstellListeEndung;
	}
	public String getZusLogPfad() {
		return zusLogPfad;
	}
	public String getKomBildSperrDatei() {
		return komBildSperrDatei;
	}
	public String getZusDruckPfad() {
		return zusDruckPfad;
	}
	public String getAbpDrucker() {
		return abpDrucker;
	}
	public String getAbpDruckPfad() {
		return abpDruckPfad;
	}
	public String getAbpEndung() {
		return abpEndung;
	}
	public String getRueckMeldPfad() {
		return rueckMeldPfad;
	}
	public String getRueckMeldEndung() {
		return rueckMeldEndung;
	}
	public String getStartEndeEndung() {
		return startEndeEndung;
	}
	public String getCutPfad() {
		return cutPfad;
	}
	public String getCutEndung() {
		return cutEndung;
	}
	public String getCutHilfPfad() {
		return cutHilfPfad;
	}
	public String getCutHilfEndung() {
		return cutHilfEndung;
	}
	public String getCutHilfDrucker() {
		return cutHilfDrucker;
	}
	public String getQMPfad() {
		return qmPfad;
	}
	public String getQMEndung() {
		return qmEndung;
	}
	public String getQMRWPEndung() {
		return qmRWPEndung;
	}
	public String getQMDrucker() {
		return qmDrucker;
	}
	public String getBqsPfad() {
		return bqsPfad;
	}
	public String getBqsEndung() {
		return bqsEndung;
	}
	public String getErrorDir() {
		return errorDir;
	}
	public String getlsDrucker() {
		return lsDrucker;
	}
	public String getlsDruckPfad() {
		return lsDruckPfad;
	}
	public String getlsEndung() {
		return lsEndung;
	}
	
	public String verarbeiten() {
		super.einlesen();
		String retString = new String();
		// Auswerten der Config-Datei
		StringTokenizer st = new StringTokenizer(inhalt,"\n");
		String aktToken = new String();
		while (st.hasMoreTokens()) {
			aktToken=st.nextToken();
			if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("zusDrucker")==0) {
				zusDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("zusBereitstellListeEndung")==0) {
				zusBereitstellListeEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("zusLogPfad")==0) {
                                zusLogPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("zusDruckPfad")==0) {
				zusDruckPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("abpDrucker")==0) {
				abpDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("abpEndung")==0) {
				abpEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("abpDruckPfad")==0) {
				abpDruckPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("rueckMeldPfad")==0) {
				rueckMeldPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("rueckMeldEndung")==0) {
				rueckMeldEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutPfad")==0) {
				cutPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutEndung")==0) {
				cutEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutZusDrucker")==0) {
				cutZusDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("manZusDrucker")==0) {
				manZusDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("pufZusDrucker")==0) {
				pufZusDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("startEndeEndung")==0) {
				startEndeEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutHilfPfad")==0) {
				cutHilfPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutHilfEndung")==0) {
				cutHilfEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("cutHilfDrucker")==0) {
				cutHilfDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("qmPfad")==0) {
				qmPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("qmEndung")==0) {
				qmEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("qmRWPEndung")==0) {
				qmRWPEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("qmDrucker")==0) {
				qmDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("bqsPfad")==0) {
				bqsPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("bqsEndung")==0) {
				bqsEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("errorDir")==0) {
				errorDir = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("komBildSperrDatei")==0) {
				komBildSperrDatei = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("lsEndung")==0) {
				lsEndung = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("lsDrucker")==0) {
				lsDrucker = aktToken.substring(aktToken.indexOf(":")+1);
			} else if (aktToken.substring(0,aktToken.indexOf(":")).compareTo("lsDruckPfad")==0) {
				lsDruckPfad = aktToken.substring(aktToken.indexOf(":")+1);
			} 
		}
		return retString;
	}
}
	

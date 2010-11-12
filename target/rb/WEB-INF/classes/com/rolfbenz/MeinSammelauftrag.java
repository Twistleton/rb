package com.rolfbenz;

// 
// Objekt Sammelauftrag
//
public class MeinSammelauftrag {

	private long sammelauftragsnummer;
	private long artikelnummer;
	private long chargennummer;
	private String lieferantenkurzkennzeichen;
	private int  zs_system;
	
	private static int anzahlObjekte = 0;

	public  MeinSammelauftrag(long sammelauftragsnummer, long artikelnummer,
				  long chargennummer, String lieferantenkurzkennzeichen,
				  int  zs_system					) {

		this.sammelauftragsnummer = sammelauftragsnummer;
		this.artikelnummer	  = artikelnummer;
		this.chargennummer	  = chargennummer;
		this.lieferantenkurzkennzeichen = lieferantenkurzkennzeichen;
		this.zs_system		        = zs_system;
		++anzahlObjekte;
	}

	public  long getSammelauftragsnummer() {

		return this.sammelauftragsnummer;
	}

	public  long getArtikelnummer()        {

		return this.artikelnummer;
	}

	public  int getZuschnittssystem()      {
	
		return this.zs_system;

	}

	public static int getAnzahl()          {

		return anzahlObjekte;

	}
}

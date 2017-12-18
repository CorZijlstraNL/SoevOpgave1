module Volume_v2

 import IO;
 import List;
 import Map;
 import Relation;
 import Set;
 import analysis::graphs::Graph;
 import util::Resources;
 import lang::java::jdt::m3::Core;
 import util::Resources;
 import String;

 import AlgemeneFuncties_v2;
 

// Volume bepalen van een set met locaties
public lrel[loc,int] bepaalVolume(set[loc] bestanden){

 	map[loc locatie, int aantal] aantalRegels = ( a:regelsCode(a)|loc a <- bestanden);
 
	// zet het aantalRegels om naar een lijst: aantalRegelsList	
 	aantalRegelsList = toList(aantalRegels);
 	
 	aantalRegelsList = sort(aantalRegelsList);
	return aantalRegelsList;
 }
 
 
 // bepaalt op basis van een tabel de score voor LOC voor volume van een heel project
 public str bepaalLOCklasse(int totaalAantalRegels){
 	
 	str klasse="";
 	
 	if(totaalAantalRegels <= 66000){klasse="++";}
 	else if (totaalAantalRegels <= 246000){klasse="+";}
 	else if (totaalAantalRegels <= 665000){klasse="o";}
  	else if (totaalAantalRegels <= 1310000){klasse="-";}
 	else {klasse="--";}
 	
 	return klasse;
 
 }
 
 // Methode voor het rapporteren van Volume van een project.
 public str rapporteerVolume(str projectNaam, lrel[loc,int] aantalRegelsList, loc bestandMetOutput){
 
 	int totaalAantalRegels=0;
 
  	for(bestand <- aantalRegelsList){totaalAantalRegels=totaalAantalRegels+bestand[1];}

 	appendToFile(bestandMetOutput, "\r\nHet totaal aantal code regels voor project <projectNaam> is: <totaalAantalRegels>");
 	appendToFile(bestandMetOutput, "\r\nHiermee scoort het project een <bepaalLOCklasse(totaalAantalRegels)> voor LOC");
 	
 	// return is gebruikt om score door te geven voor algemene scoreberekening 
	return bepaalLOCklasse(totaalAantalRegels);
 }
module Volume

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

 import AlgemeneFuncties;

public lrel[loc,int] bepaalVolume(set[loc] bestanden){

	int totaalAantalRegels=0;
	
 	map[loc locatie, int aantal] aantalRegels = ( a:regelsCode(a)|loc a <- bestanden);
 
 
 	aantalRegelsList = toList(aantalRegels);
 	
 
 return aantalRegelsList;
 }
 
 public str bepaalLOCklasse(int totaalAantalRegels){
 	
// 	str LocKlasse ="";
 	
 	klasse="";
 	
 	if(totaalAantalRegels <= 66000){klasse="++";}
 	else if (totaalAantalRegels <= 246000){klasse="+";}
 	else if (totaalAantalRegels <= 665000){klasse="0";}
  	else if (totaalAantalRegels <= 1310000){klasse="-";}
 	else {klasse="--";}
 	
 	return klasse;
 
 }
 
 
 public void rapporteerVolume(str projectNaam, lrel[loc,int] aantalRegelsList){
 
 	int totaalAantalRegels=0;
 
  	for(bestand <- aantalRegelsList){totaalAantalRegels=totaalAantalRegels+bestand[1];}

 	println("Het totaal aantal regels voor project <projectNaam> is: <totaalAantalRegels>");
 	println("Hiermee scoort het project een <bepaalLOCklasse(totaalAantalRegels)> voor LOC");
 
 
 return;
 }
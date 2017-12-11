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
 
 
 public void rapporteerVolume(lrel[loc,int] aantalRegelsList){
 
 	int totaalAantalRegels=0;
 
  	for(bestand <- aantalRegelsList){totaalAantalRegels=totaalAantalRegels+bestand[1];}
 	println(totaalAantalRegels);
 
 
 return;
 }
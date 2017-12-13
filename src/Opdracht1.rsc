// uitwerking oefenopgaven Rascal
// naam: C. Zijlstra
// studenten nummer: 851948642
// naam: R. Pöttgens
// studenten nummer: 851941098
//
// uitvoeren dmv
// import Opdracht1;
// analyseerProject(projectNaam)  - projectNaam is de naam van het project tussen "" dat geanalyseerd moet worden.


module Opdracht1

 import IO;
 import List;
 import Map;
 import Relation;
 import Set;
 import analysis::graphs::Graph;
 import util::Resources;
 import lang::java::m3::core;
 import lang::java::jdt::m3::Core;
 import lang::java::jdt::m3::AST;
 import util::Resources;
 
 import AlgemeneFuncties;
 import Volume;
 import Duplicatie;
 import UnitMetrieken;


 

 //invoer projectNaam - naam van het project wat geanalyseerd moet worden.
 public void analyseerProject(str projectNaam){
 

 // lees het project in 
  set[loc] alleJavaBestanden=javaBestanden(|project://<projectNaam>/|);
  
  // bepaal Volume
  lrel[loc,int] projectVolume = bepaalVolume(alleJavaBestanden);
  
 // bepaal Duplicatie
 
 lrel[loc,int,int] dupLocaties = calculateDuplication(alleJavaBestanden);
 
 // bepaal Unit Metrieken
 
 lrel[loc,int,int] unitMetrieken = berekenUnitMetrieken(alleJavaBestanden);
 
 // rapporteer
 rapporteerVolume(projectNaam, projectVolume);
 printUnitResultaten();
 printDuplicatieResultaten();
 
 printDetails(unitMetrieken, dupLocaties);
 
 }
 
 private void printDetails(lrel[loc,int,int] unitMetrieken, lrel[loc,int,int] dupLocaties){
 	println();
 	for(unit <- unitMetrieken){
 		println("unit op locatie <unit[0]> heeft <unit[1]> regels code met complexiteit <unit[2]>");
 	}
 	println();
 	for(dup <- dupLocaties){
 		println("Duplicatie op locatie <dup[0]> op regel <dup[1] + 1> heeft <dup[2]> regels");
 	}
 }
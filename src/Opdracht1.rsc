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
  M3 model = createM3FromEclipseProject(|project://<projectNaam>/|);
  set[loc] methoden = methods(model);
  // bepaal Volume
  lrel[loc,int] projectVolume = bepaalVolume(alleJavaBestanden);
  
 // bepaal Duplicatie
 
 calculateDuplication(alleJavaBestanden);
 
 // bepaal Unit Metrieken
 
 lrel[loc,int,int] unitMetrieken = berekenUnitMetrieken(alleJavaBestanden);
 
 // rapporteer
 rapporteerVolume(projectNaam, projectVolume);
 printUnitResultaten();
 printDuplicatieResultaten();
 
 }
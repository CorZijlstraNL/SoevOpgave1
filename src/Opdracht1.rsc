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
 import lang::java::jdt::m3::Core;
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
 
 // calculateDuplication(alleJavaBestanden, 45);
 
 // bepaal Unit Metrieken
 
 // rapporteer
 rapporteerVolume(projectNaam, projectVolume);
 
 }
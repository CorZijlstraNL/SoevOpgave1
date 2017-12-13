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
 import util::Benchmark;
  
 import AlgemeneFuncties;
 import Volume;
 import Duplicatie;
 import UnitMetrieken;


 

 //invoer projectNaam - naam van het project wat geanalyseerd moet worden.
 public void analyseerProject(str projectNaam){
 
 // Start tijdmeting
 measuredTime = cpuTime();
	

 // lees het project in 
  set[loc] alleJavaBestanden=javaBestanden(|project://<projectNaam>/|);
  
  // bepaal Volume
  lrel[loc,int] projectVolume = bepaalVolume(alleJavaBestanden);
  
 // bepaal Duplicatie
 
 lrel[loc,int,int] dupLocaties = calculateDuplication(alleJavaBestanden);
 
 // bepaal Unit Metrieken
 
 lrel[loc,int,int,str,str] unitMetrieken = berekenUnitMetrieken(alleJavaBestanden);
 
 // rapporteer en geef scores
 str volumescore = rapporteerVolume(projectNaam, projectVolume);
 tuple[str,str] unitscore = printUnitResultaten();
 str duplicatiescore = printDuplicatieResultaten();
 str testscore = "o"; // Voor nu o meegeven, nog niet geïmplementeerd
 
 // rapporteer algemene scores
 unitGrootteScore = unitscore[0];
 unitCCScore = unitscore[1];
 printAlgemeneScores(volumescore, unitGrootteScore, unitCCScore, duplicatiescore, testscore);
 
 // rapporteer details
 printDetails(projectVolume, unitMetrieken, dupLocaties);
 
 // Stop tijdmeting en rapporteer
 measuredTime = cpuTime() - measuredTime;
 measuredSeconds = (measuredTime + 500000000) / 1000000000;
 hours = measuredSeconds / 3600;
 minutes = (measuredSeconds - (hours * 3600)) / 60;
 seconds = measuredSeconds - (hours * 3600) - (minutes * 60);
 
 println();
 println("Alle metrieken gedaan in <hours> uren, <minutes> minuten en <seconds> seconden.");
 }
 
 private void printAlgemeneScores(str volumeScore, str unitGrootteScore, str unitCCScore, str duplicatieScore, str unitTestingScore){
 	int analyseerbaarheid = getScorefromStr(volumeScore) + getScorefromStr(duplicatieScore) + getScorefromStr(unitGrootteScore) + getScorefromStr(unitTestingScore);
 	int veranderbaarheid = getScorefromStr(unitCCScore) + getScorefromStr(duplicatieScore);
 	int stabiliteit = getScorefromStr(unitTestingScore);
 	int testbaarheid = getScorefromStr(unitCCScore) + getScorefromStr(unitGrootteScore) + getScorefromStr(unitTestingScore);
 	
 	str analyseerbaarheidScore = gewogenScore(analyseerbaarheid, 4.0);
 	str veranderbaarheidScore = gewogenScore(veranderbaarheid, 2.0);
 	str stabiliteitScore = gewogenScore(stabiliteit, 1.0);
 	str testbaarheidScore = gewogenScore(testbaarheid, 3.0);
 	
 	int totaal =  getScorefromStr(analyseerbaarheidScore) + getScorefromStr(veranderbaarheidScore) + getScorefromStr(stabiliteitScore) + getScorefromStr(testbaarheidScore);
 	
 	str totaalScore = gewogenScore(totaal, 4.0);
 	
 	println();
 	println("analyseerbaarheidScore: <analyseerbaarheidScore>");
 	println("veranderbaarheidScore: <veranderbaarheidScore>");
 	println("stabiliteitScore: <stabiliteitScore>");
 	println("testbaarheidScore: <testbaarheidScore>");
 	println();
 	println("totaalScore: <totaalScore>");
 } 
 
 private str gewogenScore(int waarde, real aantal){
 	str score = "o";
 	real gemiddelde = waarde / aantal;
 	if (gemiddelde > 1.2){
 	score = "++";
 	} else if (gemiddelde > 0.4){
 	score = "+";
 	} else if (gemiddelde < -1.2){
 	score = "--";
 	} else if (gemiddelde < -0.4){
 	score = "-";
 	}
 	return score;
 }
 private int getScorefromStr(str score){
 	int s = 0;
 	if(score == "++"){
 		s = 2;
 	}
 	if(score == "+"){
 		s = 1;
 	}
 	if(score == "-"){
 		s = -1;
 	}
 	if(score == "--"){
 		s = -2;
 	}
 	return s;
 }
 private void printDetails(lrel[loc,int] projectVolume, lrel[loc,int,int,str,str] unitMetrieken, lrel[loc,int,int] dupLocaties){
 	
 	println();
 	
 	for(volume <- projectVolume){
 		println("Bestand <volume[0]> bevat <volume[1]> regels code.");
 	}
 	println();
 	
 	str laag = UnitMetrieken::laagRisico;
	str normaal = UnitMetrieken::normaalRisico;
	str hoog = UnitMetrieken::hoogRisico;
	str zeerHoog = UnitMetrieken::zeerHoogRisico;
 	
 	printGrootteRisico(unitMetrieken, zeerHoog);
 	printGrootteRisico(unitMetrieken, hoog);
 	printGrootteRisico(unitMetrieken, normaal);
 	printGrootteRisico(unitMetrieken, laag);
 	
 	printCCRisico(unitMetrieken, zeerHoog);
 	printCCRisico(unitMetrieken, hoog);
 	printCCRisico(unitMetrieken, normaal);
 	printCCRisico(unitMetrieken, laag);
 	
 	println();
 	for(dup <- dupLocaties){
 		println("Duplicatie op locatie <dup[0]> op regel <dup[1] + 1> heeft <dup[2]> regels");
 	}
 }
 
private void printGrootteRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	println("De volgende units hebben het grootte risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[3] == risico){
 			println("Unit op locatie <unit[0]> heeft <unit[1]> regels code.");
 		}
 	}
 	println();
 }

private void printCCRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	println("De volgende units hebben het complexiteit risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[4] == risico){
 			println("Unit op locatie <unit[0]> heeft <unit[1]> regels code met cyclomatische complexiteit <unit[2]>.");
 		}
 	}
 	println();
 }
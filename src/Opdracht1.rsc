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
 import lang::java::m3::core;
 import lang::java::jdt::m3::Core;
 import lang::java::jdt::m3::AST;
 import util::Resources;
 import util::Benchmark;
 import util::Math;
 
  
 import AlgemeneFuncties;
 import Volume;
 import Duplicatie;
 import UnitMetrieken;

 loc detailOutput = |cwd:///Details.txt|;
 
 //invoer projectNaam - naam van het project wat geanalyseerd moet worden.
 public void analyseerProject(str projectNaam){
 
 // Start met leeg bestand
 writeFile(detailOutput,"");
 
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
 
 // rapporteer details
 printDetails(projectVolume, unitMetrieken, dupLocaties);
  
 // rapporteer en geef scores
 str volumescore = rapporteerVolume(projectNaam, projectVolume, detailOutput);
 tuple[str,str] unitscore = printUnitResultaten(detailOutput);
 str duplicatiescore = printDuplicatieResultaten(detailOutput);
 str testscore = "o"; // Voor nu o meegeven, nog niet geïmplementeerd
 
 // rapporteer algemene scores
 unitGrootteScore = unitscore[0];
 unitCCScore = unitscore[1];
 printAlgemeneScores(volumescore, unitGrootteScore, unitCCScore, duplicatiescore, testscore);
 
 
 // Stop tijdmeting en rapporteer
 measuredTime = cpuTime() - measuredTime;
 measuredSeconds = (measuredTime + 500000000) / 1000000000;
 hours = measuredSeconds / 3600;
 minutes = (measuredSeconds - (hours * 3600)) / 60;
 seconds = measuredSeconds - (hours * 3600) - (minutes * 60);
 
 appendToFile(detailOutput, "\r\n");
 appendToFile(detailOutput, "\r\nAlle metrieken gedaan in <hours> uren, <minutes> minuten en <seconds> seconden.");
 println(readFile(detailOutput));
 println("Details staan in <detailOutput>");
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
 	
 	appendToFile(detailOutput, "\r\n");
 	appendToFile(detailOutput, "\r\nanalyseerbaarheidScore: <analyseerbaarheidScore>");
 	appendToFile(detailOutput, "\r\nveranderbaarheidScore: <veranderbaarheidScore>");
 	appendToFile(detailOutput, "\r\nstabiliteitScore: <stabiliteitScore>");
 	appendToFile(detailOutput, "\r\ntestbaarheidScore: <testbaarheidScore>");
 	appendToFile(detailOutput, "\r\n");
 	appendToFile(detailOutput, "\r\ntotaalScore: <totaalScore>");
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
 	
 	
 	for(volume <- projectVolume){
 		appendToFile(detailOutput, "\r\nBestand <volume[0]> bevat <volume[1]> regels code.");
 	}
 	appendToFile(detailOutput, "\r\n");
 	
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
 	
 	appendToFile(detailOutput, "\r\n");
	int dupNummer  = 0;
	int dupRegelsOpDezeLocatie = 0;
	for(dup <- dupLocaties){
		bool meerDupsOpDezeLocatie = false;
		dupRegelsOpDezeLocatie += dup[2];
		dupNummer += 1;
 		if (dupNummer < size(dupLocaties)){
			tuple[loc,int, int] volgendeDup = dupLocaties[dupNummer];
			if (dup[0] == volgendeDup[0]){ // Dezelfde locatie
				Meerdups = true;
			}
		}
		if (!meerDupsOpDezeLocatie) {
			loc locatie = dup[0];
			int bestandsGrootte = size(readFileLines(locatie));
			int percentage = percent(dupRegelsOpDezeLocatie, bestandsGrootte);
			appendToFile(detailOutput, "\r\nOp locatie <locatie> zijn <dupRegelsOpDezeLocatie> duplicatie regels aanwezig in <bestandsGrootte> regels in totaal, dit komt neer op <percentage> %.");
			dupRegelsOpDezeLocatie = 0;
		}
 	}
	appendToFile(detailOutput, "\r\n");
 	for(dup <- dupLocaties){
 		appendToFile(detailOutput, "\r\nOp locatie <dup[0]> op regel <dup[1] + 1> begint een reeks van <dup[2]> regels die ook elders voorkomen.");
 	}
 	
 }
 
private void printGrootteRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	appendToFile(detailOutput, "\r\nDe volgende units hebben het grootte risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[3] == risico){
 			appendToFile(detailOutput, "\r\nUnit op locatie <unit[0]> heeft <unit[1]> regels code.");
 		}
 	}
 	appendToFile(detailOutput, "\r\n");
 }

private void printCCRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	appendToFile(detailOutput, "\r\nDe volgende units hebben het complexiteit risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[4] == risico){
 			appendToFile(detailOutput, "\r\nUnit op locatie <unit[0]> heeft <unit[1]> regels code met cyclomatische complexiteit <unit[2]>.");
 		}
 	}
 	appendToFile(detailOutput, "\r\n");
 }
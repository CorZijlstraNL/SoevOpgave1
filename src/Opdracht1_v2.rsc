// uitwerking opdracht 1: Metrieken
// naam: C. Zijlstra
// studenten nummer: 851948642
// naam: R. Pöttgens
// studenten nummer: 851941098
//
// uitvoeren dmv
// import Opdracht1_v2;
// analyseerProject(projectNaam)  - projectNaam is de naam van het project tussen "" dat geanalyseerd moet worden.
// terughalen bestanden: import IO, dan readFile(|cwd:///<projectNaam>_alles.txt|) of een ander bestand.

module Opdracht1_v2

 import IO;
 import ValueIO;
 import List;
 import Map;
 import Relation;
 import Set;
 import String;
 import analysis::graphs::Graph;
 //import lang::java::m3::core;
 import lang::java::jdt::m3::Core;
 import lang::java::jdt::m3::AST;
 import util::Resources;
 import util::Benchmark;
 import util::Math;
 
  
 import AlgemeneFuncties_v2;
 import Volume_v2;
 import Duplicatie_v3;
 import UnitMetrieken_v2;

 M3 model;
 str projectNaam = "";
 loc allesOutput = |cwd:///alles.txt|;
 loc detailOutput = |cwd:///details.txt|;
 loc samenvattingOutput = |cwd:///samenvatting.txt|;
 loc detailVolumeOutput = |cwd:///details_volume.txt|;
 loc detailUnitSizeOutput = |cwd:///details_unit_size.txt|;
 loc detailUnitCCOutput = |cwd:///details_unit_cc.txt|;
 loc detailUnitTestOutput = |cwd:///details_unit_test.txt|;
 loc detailDuplicatieOutput = |cwd:///details_duplicatie.txt|;
 
 str bestandsPrefix = "uitvoer/leesbaar/";
 str bestandsPrefixVar = "uitvoer/variabelen/";
 
 
 
 //invoer projectNaam - naam van het project wat geanalyseerd moet worden.
 public void analyseerProject(str opgegevenProjectNaam){
 projectNaam = opgegevenProjectNaam;
 //printMethods(|project://<projectNaam>/|);
 
 // Start tijdmeting
 measuredTime = cpuTime();
 
 
 bestandsPrefix = "uitvoer/<projectNaam>/leesbaar/";
 bestandsPrefixVar = "uitvoer/<projectNaam>/variabelen/";
 
 allesOutput = |cwd:///<bestandsPrefix>alles.txt|;
 detailOutput = |cwd:///<bestandsPrefix>details.txt|;
 samenvattingOutput = |cwd:///<bestandsPrefix>samenvatting.txt|;
 detailVolumeOutput = |cwd:///<bestandsPrefix>details_volume.txt|;
 detailUnitSizeOutput = |cwd:///<bestandsPrefix>details_unit_size.txt|;
 detailUnitCCOutput = |cwd:///<bestandsPrefix>details_unit_cc.txt|;
 detailUnitTestOutput = |cwd:///<bestandsPrefix>details_unit_test.txt|;
 detailDuplicatieOutput = |cwd:///<bestandsPrefix>details_duplicatie.txt|;
  
 // Start met lege bestanden
 writeFile(allesOutput,"");
 writeFile(detailOutput,"");
 writeFile(samenvattingOutput,"");
 writeFile(detailVolumeOutput,"");
 writeFile(detailUnitSizeOutput,"");
 writeFile(detailUnitCCOutput,"");
 writeFile(detailUnitTestOutput,"");
 writeFile(detailDuplicatieOutput,"");
 
 	

 // lees het project in 
 iprintln("Loading Project <projectNaam>");
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/projectNaam.txt|, projectNaam);
 loc projectOmTeMeten = |project://<projectNaam>/|;
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/projectOmTeMeten.txt|, projectOmTeMeten);
 iprintln("Getting files of Project <projectNaam>");
 set[loc] alleJavaBestanden=javaBestanden(projectOmTeMeten);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/alleJavaBestanden.txt|, alleJavaBestanden);
 iprintln("Creating M3 of Project <projectNaam>");
 model = createM3FromEclipseProject(projectOmTeMeten);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/model.txt|, model);
 
 // bepaal Volume
 iprintln("Calculating Volume metrics of Project <projectNaam>");
 lrel[loc,int] projectVolume = bepaalVolume(alleJavaBestanden);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/projectVolume.txt|, projectVolume);
  
 // bepaal Unit Metrieken
 iprintln("Calculating Unit metrics of Project <projectNaam>");
 lrel[loc,int,int,str,str] unitMetrieken = berekenUnitMetrieken(alleJavaBestanden);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/unitMetrieken.txt|, unitMetrieken);
 
 // bepaal Duplicatie
 iprintln("Calculating Duplication metrics of Project <projectNaam>");
 lrel[loc,int,int] dupLocaties = calculateDuplication(alleJavaBestanden);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/dupLocaties.txt|, dupLocaties);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/allPossibleLineBlocks.txt|, Duplicatie_v3::allPossibleLineBlocks);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/allFiles.txt|, Duplicatie_v3::allFiles);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/detectedStrings.txt|, Duplicatie_v3::detectedStrings);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/allBlocks.txt|, Duplicatie_v3::allBlocks);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/alleRegels.txt|, Duplicatie_v3::alleRegels);
  
 // rapporteer details
 iprintln("Saving metrics of Project <projectNaam>");
 printDetails(projectVolume, unitMetrieken, dupLocaties);
 appendToFile(allesOutput, "\r\n<readFile(detailOutput)>");
  
 // rapporteer en geef scores
 appendToFile(allesOutput, "\r\n\r\nNu de samenvatting:");
 
 str volumescore = rapporteerVolume(projectNaam, projectVolume, samenvattingOutput);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/volumescore.txt|, volumescore);
 
 tuple[str,str] unitscore = printUnitResultaten(samenvattingOutput);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/unitscore.txt|, unitscore);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/laagRisicoUnitGrootte.txt|, UnitMetrieken_v2::laagRisicoUnitGrootte);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/normaalRisicoUnitGrootte.txt|, UnitMetrieken_v2::normaalRisicoUnitGrootte);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/hoogRisicoUnitGrootte.txt|, UnitMetrieken_v2::hoogRisicoUnitGrootte);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitGrootte.txt|, UnitMetrieken_v2::zeerHoogRisicoUnitGrootte);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/totaleUnitGrootte.txt|, UnitMetrieken_v2::totaleUnitGrootte);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/laagRisicoUnitGroottePercentage.txt|, UnitMetrieken_v2::laagRisicoUnitGroottePercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/normaalRisicoUnitGroottePercentage.txt|, UnitMetrieken_v2::normaalRisicoUnitGroottePercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/hoogRisicoUnitGroottePercentage.txt|, UnitMetrieken_v2::hoogRisicoUnitGroottePercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitGroottePercentage.txt|, UnitMetrieken_v2::zeerHoogRisicoUnitGroottePercentage);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/laagRisicoUnitCC.txt|, UnitMetrieken_v2::laagRisicoUnitCC);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/normaalRisicoUnitCC.txt|, UnitMetrieken_v2::normaalRisicoUnitCC);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/hoogRisicoUnitCC.txt|, UnitMetrieken_v2::hoogRisicoUnitCC);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitCC.txt|, UnitMetrieken_v2::zeerHoogRisicoUnitCC);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/totaleUnitCC.txt|, UnitMetrieken_v2::totaleUnitCC);
 
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/laagRisicoUnitCCPercentage.txt|, UnitMetrieken_v2::laagRisicoUnitCCPercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/normaalRisicoUnitCCPercentage.txt|, UnitMetrieken_v2::normaalRisicoUnitCCPercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/hoogRisicoUnitCCPercentage.txt|, UnitMetrieken_v2::hoogRisicoUnitCCPercentage);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitCCPercentage.txt|, UnitMetrieken_v2::zeerHoogRisicoUnitCCPercentage);
  
 
 str duplicatiescore = printDuplicatieResultaten(samenvattingOutput);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/duplicatiescore.txt|, duplicatiescore);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/totalDupLines.txt|, Duplicatie_v3::totalDupLines);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/projectSize.txt|, Duplicatie_v3::projectSize);
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/dupPercent.txt|, Duplicatie_v3::dupPercent);
 
 
 str testscore = "o"; // Voor nu o meegeven, nog niet geïmplementeerd
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/testscore.txt|, testscore);
 
 // rapporteer algemene scores
 unitGrootteScore = unitscore[0];
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/unitGrootteScore.txt|, unitGrootteScore);
 unitCCScore = unitscore[1];
 writeTextValueFile(|cwd:///<bestandsPrefixVar>/unitCCScore.txt|, unitCCScore);
 printAlgemeneScores(volumescore, unitGrootteScore, unitCCScore, duplicatiescore, testscore);
 
 
 // Stop tijdmeting en rapporteer
 measuredTime = cpuTime() - measuredTime;
 measuredSeconds = (measuredTime + 500000000) / 1000000000;
 hours = measuredSeconds / 3600;
 minutes = (measuredSeconds - (hours * 3600)) / 60;
 seconds = measuredSeconds - (hours * 3600) - (minutes * 60);
 
 appendToFile(samenvattingOutput, "\r\n");
 appendToFile(samenvattingOutput, "\r\nAlle metrieken gedaan in <hours> uren, <minutes> minuten en <seconds> seconden.");
 appendToFile(samenvattingOutput, "\r\nHet complete overzicht staat in <allesOutput>");
 appendToFile(samenvattingOutput, "\r\nDe samenvatting staat in <samenvattingOutput>");
 appendToFile(samenvattingOutput, "\r\nDe details staan in <detailOutput>");
 appendToFile(samenvattingOutput, "\r\nDe details van de volumemeting staan in <detailVolumeOutput>");
 appendToFile(samenvattingOutput, "\r\nDe details van de metingen van de unitsizes staan in <detailUnitSizeOutput>");
 appendToFile(samenvattingOutput, "\r\nDe details van de metingen van de unit complexiteiten staan in <detailUnitCCOutput>");
 appendToFile(samenvattingOutput, "\r\nDe details van de metingen betreffende de duplicaten staan in staan in <detailDuplicatieOutput>");
 // Deze is nog niet geïmplementeerd.
 //appendToFile(samenvattingOutput, "\r\nDe details van de metingen van de unit tests staan in <detailUnitTestOutput>");
 appendToFile(allesOutput, "\r\n<readFile(samenvattingOutput)>");
 println(readFile(allesOutput));
 
 }
 
 private void printAlgemeneScores(str volumeScore, str unitGrootteScore, str unitCCScore, str duplicatieScore, str unitTestingScore){
 	int analyseerbaarheid = getScorefromStr(volumeScore) + getScorefromStr(duplicatieScore) + getScorefromStr(unitGrootteScore) + getScorefromStr(unitTestingScore);
 	int veranderbaarheid = getScorefromStr(unitCCScore) + getScorefromStr(duplicatieScore);
 	int stabiliteit = getScorefromStr(unitTestingScore);
 	int testbaarheid = getScorefromStr(unitCCScore) + getScorefromStr(unitGrootteScore) + getScorefromStr(unitTestingScore);
 	
 	str analyseerbaarheidScore = gewogenScore(analyseerbaarheid, 4.0);
 	writeTextValueFile(|cwd:///<bestandsPrefixVar>/analyseerbaarheidScore.txt|, analyseerbaarheidScore);
 	str veranderbaarheidScore = gewogenScore(veranderbaarheid, 2.0);
 	writeTextValueFile(|cwd:///<bestandsPrefixVar>/veranderbaarheidScore.txt|, veranderbaarheidScore);
 	str stabiliteitScore = gewogenScore(stabiliteit, 1.0);
 	writeTextValueFile(|cwd:///<bestandsPrefixVar>/stabiliteitScore.txt|, stabiliteitScore);
 	str testbaarheidScore = gewogenScore(testbaarheid, 3.0);
 	writeTextValueFile(|cwd:///<bestandsPrefixVar>/testbaarheidScore.txt|, testbaarheidScore);
 	
 	int totaal =  getScorefromStr(analyseerbaarheidScore) + getScorefromStr(veranderbaarheidScore) + getScorefromStr(stabiliteitScore) + getScorefromStr(testbaarheidScore);
 	
 	str totaalScore = gewogenScore(totaal, 4.0);
 	writeTextValueFile(|cwd:///<bestandsPrefixVar>/totaalScore.txt|, totaalScore);
 	
 	appendToFile(samenvattingOutput, "\r\n");
 	appendToFile(samenvattingOutput, "\r\nanalyseerbaarheidScore: <analyseerbaarheidScore>");
 	appendToFile(samenvattingOutput, "\r\nveranderbaarheidScore: <veranderbaarheidScore>");
 	appendToFile(samenvattingOutput, "\r\nstabiliteitScore: <stabiliteitScore>");
 	appendToFile(samenvattingOutput, "\r\ntestbaarheidScore: <testbaarheidScore>");
 	appendToFile(samenvattingOutput, "\r\n");
 	appendToFile(samenvattingOutput, "\r\ntotaalScore: <totaalScore>");
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
 	
 	rel[loc,loc] declaraties = invert(model.declarations);
 	lrel[loc,int,int,str,str] unitMetriekenMetPrintbareLocaties = [];
	
 	appendToFile(detailVolumeOutput, "Hier volgen de details van de volume metingen.");
 	for(volume <- projectVolume){
 		appendToFile(detailVolumeOutput, "\r\nBestand <volume[0]> bevat <volume[1]> regels code.");
 	}
 	appendToFile(detailOutput, "\r\n<readFile(detailVolumeOutput)>");
 	
 	str laag = UnitMetrieken_v2::laagRisico;
	str normaal = UnitMetrieken_v2::normaalRisico;
	str hoog = UnitMetrieken_v2::hoogRisico;
	str zeerHoog = UnitMetrieken_v2::zeerHoogRisico;
 	
 	for (eenheid <- unitMetrieken) {
 		loc locatie = eenheid[0];
		loc printbareLocatie = eenheid[0];
		list[loc] declaratie = toList(declaraties[locatie]);
		//iprintln(declaratie);
		if (declaratie != []){
			printbareLocatie = declaratie[0];
		}
		unitMetriekenMetPrintbareLocaties += <printbareLocatie, eenheid[1], eenheid[2], eenheid[3], eenheid[4]>;
 	}
 	
 	unitMetriekenMetPrintbareLocaties = sort(unitMetriekenMetPrintbareLocaties);
 	
 	printGrootteRisico(unitMetriekenMetPrintbareLocaties, zeerHoog);
 	printGrootteRisico(unitMetriekenMetPrintbareLocaties, hoog);
 	printGrootteRisico(unitMetriekenMetPrintbareLocaties, normaal);
 	printGrootteRisico(unitMetriekenMetPrintbareLocaties, laag);
 	
 	printCCRisico(unitMetriekenMetPrintbareLocaties, zeerHoog);
 	printCCRisico(unitMetriekenMetPrintbareLocaties, hoog);
 	printCCRisico(unitMetriekenMetPrintbareLocaties, normaal);
 	printCCRisico(unitMetriekenMetPrintbareLocaties, laag);
 	
 	appendToFile(detailOutput, "<readFile(detailUnitSizeOutput)><readFile(detailUnitCCOutput)>");
 	
 	int dupNummer  = 0;
	int dupRegelsOpDezeLocatie = 0;
	
	if(Duplicatie_v3::alleRegels){
		for(dupl <- dupLocaties){
			bool meerDups = false;
			dupRegelsOpDezeLocatie += dupl[2];
			dupNummer += 1;
 			if (dupNummer < size(dupLocaties)){
				tuple[loc,int, int] volgendeDup = dupLocaties[dupNummer];
				if (dupl[0] == volgendeDup[0]){ // Dezelfde locatie
					meerDups = true;
				}
			}
			
			if (!meerDups) {
				loc locatie = dupl[0];
				int bestandsGrootte = Duplicatie_v3::allFiles[locatie][0][1];
				int percentage = percent(dupRegelsOpDezeLocatie, bestandsGrootte);
				appendToFile(detailDuplicatieOutput, "\r\nOp locatie <locatie> zijn <dupRegelsOpDezeLocatie> duplicatie regels aanwezig in <bestandsGrootte> regels in totaal, dit komt neer op <percentage> %.");
				dupRegelsOpDezeLocatie = 0;
			}
 		}
		appendToFile(detailDuplicatieOutput, "\r\n");
 		for(dupl <- dupLocaties){
 			appendToFile(detailDuplicatieOutput, "\r\nOp locatie <dupl[0]> op regel <dupl[1] + 1> begint een reeks van <dupl[2]> regels die ook elders voorkomen.");
 		}
 	} else {
 		for(dupl <- dupLocaties){
			bool meerDups = false;
			dupRegelsOpDezeLocatie += dupl[2];
			dupNummer += 1;
 			if (dupNummer < size(dupLocaties)){
				tuple[loc,int, int] volgendeDup = dupLocaties[dupNummer];
				if (dupl[0] == volgendeDup[0]){ // Dezelfde locatie
					meerDups = true;
				}
			}
			
			if (!meerDups) {
				loc locatie = dupl[0];
				int bestandsGrootte = Duplicatie_v3::allFiles[locatie][0][1];
				int percentage = percent(dupRegelsOpDezeLocatie, bestandsGrootte);
				appendToFile(detailDuplicatieOutput, "\r\nOp locatie <locatie> zijn <dupRegelsOpDezeLocatie> duplicatie code regels aanwezig in <bestandsGrootte> code regels in totaal, dit komt neer op <percentage> %.");
				dupRegelsOpDezeLocatie = 0;
			}
 		}
 	}
 	appendToFile(detailOutput, "\r\n<readFile(detailDuplicatieOutput)>");
 }
 
private void printGrootteRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	appendToFile(detailUnitSizeOutput, "\r\nDe volgende units hebben het grootte risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[3] == risico){
 			appendToFile(detailUnitSizeOutput, "\r\nUnit op locatie <unit[0]> heeft <unit[1]> regels code.");
 		}
 	}
 	appendToFile(detailUnitSizeOutput, "\r\n");
 }

private void printCCRisico(lrel[loc,int,int,str,str] unitMetrieken, str risico){
 	appendToFile(detailUnitCCOutput, "\r\nDe volgende units hebben het complexiteit risico <risico>:");
 	for (unit <- unitMetrieken){
 		if (unit[4] == risico){
 			appendToFile(detailUnitCCOutput, "\r\nUnit op locatie <unit[0]> heeft <unit[1]> regels code met cyclomatische complexiteit <unit[2]>.");
 		}
 	}
 	appendToFile(detailUnitCCOutput, "\r\n");
 }
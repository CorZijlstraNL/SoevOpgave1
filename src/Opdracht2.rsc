// uitwerking opdracht 2: Visualisatie
// naam: C. Zijlstra
// studenten nummer: 851948642
// naam: R. Pöttgens
// studenten nummer: 851941098
//
// uitvoeren dmv
// import Opdracht2;
// visualiseerProject("opgegevenProjectNaam");
module Opdracht2


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

 str laag = "laag";
 str normaal = "normaal";
 str hoog = "hoog";
 str zeerHoog = "zeerHoog";


 str bestandsPrefixVar = "uitvoer/JabberPoint/variabelen/";
 
 //alias BoomNode = tuple[loc locatie, list[BoomNode], int zcc, int hcc, int ncc, int lcc, int tcc, int zlo, int hlo, int mlo, int llo, in tlo];
 
 str projectNaam;
 loc projectOmTeMeten;
 set[loc] alleJavaBestanden = {};
 M3 model;
 lrel[loc,int] projectVolume = [];
 lrel[loc,int,int,str,str] unitMetrieken=[];
 
 lrel[loc locatie, loc leesBareLocatie, int cc, tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] waarden] unitWaarden = [];
 
// data KindWaarden = Waarden(int zcc, int hcc, int ncc, int lcc, int cc, int zlo, int hlo, int nlo, int llo, int tlo);
 
 rel[loc van, loc naar] ouderKind = {};
 rel[loc naar, loc van] kindOuder = {};
 rel[loc locatie, tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] waarden] nodeWaarden = {};
 
 //list[Fstruct] unitWaarden = [];
 lrel[loc,int,int] dupLocaties = [];
 lrel[str,loc,int] allPossibleLineBlocks = [];
 lrel[loc,list[str],int] allFiles = [];
 set[str] detectedStrings = {};
 lrel[loc,lrel[str,loc,int],int] allBlocks = [];
 bool alleRegels;
 str volumescore;
 tuple[str,str] unitscore;
 int laagRisicoUnitGrootte;
 int normaalRisicoUnitGrootte;
 int hoogRisicoUnitGrootte;
 int zeerHoogRisicoUnitGrootte;
 int totaleUnitGrootte;
 int laagRisicoUnitGroottePercentage;
 int normaalRisicoUnitGroottePercentage;
 int hoogRisicoUnitGroottePercentage;
 int zeerHoogRisicoUnitGroottePercentage;
 int laagRisicoUnitCC;
 int normaalRisicoUnitCC;
 int hoogRisicoUnitCC;
 int zeerHoogRisicoUnitCC;
 int totaleUnitCC;
 int laagRisicoUnitCCPercentage;
 int normaalRisicoUnitCCPercentage;
 int hoogRisicoUnitCCPercentage;
 int zeerHoogRisicoUnitCCPercentage;
 str duplicatiescore;
 int totalDupLines;
 int projectSize;
 int dupPercent;
 str testscore;
 str unitGrootteScore;
 str unitCCScore;
 str analyseerbaarheidScore;
 str veranderbaarheidScore;
 str stabiliteitScore;
 str testbaarheidScore;
 str totaalScore;

 rel[loc name, loc src] declarations = {};
 rel[loc src, loc name] declarationsInv = {};
 
 
 public void visualiseerProject(str opgegevenProjectNaam){
  leesProject(opgegevenProjectNaam);
 }
 
 private void leesProject(str opgegevenProjectNaam){


 alleJavaBestanden = {};
 projectVolume = [];
 unitMetrieken=[];
 
 unitWaarden = [];
 
// data KindWaarden = Waarden(int zcc, int hcc, int ncc, int lcc, int cc, int zlo, int hlo, int nlo, int llo, int tlo);
 
 ouderKind = {};
 kindOuder = {};
 nodeWaarden = {};
 
 dupLocaties = [];
 allPossibleLineBlocks = [];
 allFiles = [];
 detectedStrings = {};
 allBlocks = [];
 declarations = {};
 declarationsInv = {};
  
  
  iprintln("De bestanden worden gelezen.");
  bestandsPrefixVar = "uitvoer/<opgegevenProjectNaam>/variabelen/";
  
  projectNaam = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/projectNaam.txt|);
  projectOmTeMeten = readTextValueFile(#loc, |cwd:///<bestandsPrefixVar>/projectOmTeMeten.txt|);
  alleJavaBestanden = readTextValueFile(#set[loc], |cwd:///<bestandsPrefixVar>/alleJavaBestanden.txt|);
  model = readTextValueFile(#M3, |cwd:///<bestandsPrefixVar>/model.txt|);
  projectVolume = readTextValueFile(#lrel[loc,int], |cwd:///<bestandsPrefixVar>/projectVolume.txt|);
  unitMetrieken = readTextValueFile(#lrel[loc,int,int,str,str], |cwd:///<bestandsPrefixVar>/unitMetrieken.txt|);
  dupLocaties = readTextValueFile(#lrel[loc,int,int], |cwd:///<bestandsPrefixVar>/dupLocaties.txt|);
  allPossibleLineBlocks = readTextValueFile(#lrel[str,loc,int], |cwd:///<bestandsPrefixVar>/allPossibleLineBlocks.txt|);
  allFiles = readTextValueFile(#lrel[loc,list[str],int], |cwd:///<bestandsPrefixVar>/allFiles.txt|);
  detectedStrings = readTextValueFile(#set[str], |cwd:///<bestandsPrefixVar>/detectedStrings.txt|);
  allBlocks = readTextValueFile(#lrel[loc,lrel[str,loc,int],int], |cwd:///<bestandsPrefixVar>/allBlocks.txt|);
  alleRegels = readTextValueFile(#bool, |cwd:///<bestandsPrefixVar>/alleRegels.txt|);
  volumescore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/volumescore.txt|);
  unitscore = readTextValueFile(#tuple[str,str], |cwd:///<bestandsPrefixVar>/unitscore.txt|);
  laagRisicoUnitGrootte = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/laagRisicoUnitGrootte.txt|);
  normaalRisicoUnitGrootte = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/normaalRisicoUnitGrootte.txt|);
  hoogRisicoUnitGrootte = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/hoogRisicoUnitGrootte.txt|);
  zeerHoogRisicoUnitGrootte = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitGrootte.txt|);
  totaleUnitGrootte = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/totaleUnitGrootte.txt|);
  laagRisicoUnitGroottePercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/laagRisicoUnitGroottePercentage.txt|);
  normaalRisicoUnitGroottePercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/normaalRisicoUnitGroottePercentage.txt|);
  hoogRisicoUnitGroottePercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/hoogRisicoUnitGroottePercentage.txt|);
  zeerHoogRisicoUnitGroottePercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitGroottePercentage.txt|);
  laagRisicoUnitCC = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/laagRisicoUnitCC.txt|);
  normaalRisicoUnitCC = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/normaalRisicoUnitCC.txt|);
  hoogRisicoUnitCC = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/hoogRisicoUnitCC.txt|);
  zeerHoogRisicoUnitCC = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitCC.txt|);
  totaleUnitCC = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/totaleUnitCC.txt|);
  laagRisicoUnitCCPercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/laagRisicoUnitCCPercentage.txt|);
  normaalRisicoUnitCCPercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/normaalRisicoUnitCCPercentage.txt|);
  hoogRisicoUnitCCPercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/hoogRisicoUnitCCPercentage.txt|);
  zeerHoogRisicoUnitCCPercentage = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/zeerHoogRisicoUnitCCPercentage.txt|);
  duplicatiescore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/duplicatiescore.txt|);
  totalDupLines = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/totalDupLines.txt|);
  projectSize = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/projectSize.txt|);
  dupPercent = readTextValueFile(#int, |cwd:///<bestandsPrefixVar>/dupPercent.txt|);
  testscore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/testscore.txt|);
  unitGrootteScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/unitGrootteScore.txt|);
  unitCCScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/unitCCScore.txt|);
  analyseerbaarheidScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/analyseerbaarheidScore.txt|);
  veranderbaarheidScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/veranderbaarheidScore.txt|);
  stabiliteitScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/stabiliteitScore.txt|);
  testbaarheidScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/testbaarheidScore.txt|);
  totaalScore = readTextValueFile(#str, |cwd:///<bestandsPrefixVar>/totaalScore.txt|);
  iprintln("De bestanden zijn gelezen.");
  
  declarations = model.declarations;
  declarationsInv = invert(declarations);
  
  //lrel[loc locatie, loc leesBareLocatie, int cc, tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] waarden] unitWaarden = [];
 
  for (metriek <- unitMetrieken) {
  	locatie = metriek[0];
  	loc printbareLocatie = metriek[0];
	list[loc] declaratie = toList(declarationsInv[locatie]);
	//iprintln(declaratie);
	if (declaratie != []){
		printbareLocatie = declaratie[0];
	}
  	int zcc = 0;
  	int hcc = 0;
  	int ncc = 0;
  	int lcc = 0;
  	int zlo = 0;
  	int hlo = 0;
  	int nlo = 0;
  	int llo = 0;
  	linesOfCode = metriek[1];
  	cc = metriek[2];
  	linesOfCodeRisk = metriek[3];
  	ccRisk = metriek[4];
  	switch ( ccRisk ) {
  		case zeerHoog: zcc += linesOfCode;
  		case hoog: hcc += linesOfCode;
  		case normaal: ncc += linesOfCode;
  		case laag: lcc += linesOfCode;
  	}
  	switch ( linesOfCodeRisk ) {
  		case zeerHoog: zlo += linesOfCode;
  		case hoog: hlo += linesOfCode;
  		case normaal: nlo += linesOfCode;
  		case laag: llo += linesOfCode;
  	}
  	waarden = <locatie, printbareLocatie, cc, <zcc, hcc, ncc, lcc, zlo, hlo, nlo, llo, linesOfCode>>;
  	unitWaarden += waarden;
  }
  
  for (eenheid <- unitWaarden) {
  	loc locatie = eenheid.locatie;
  	loc ouder = projectOmTeMeten + locatie.path;
  	  ouderKind += <ouder, locatie>;
  	  kindOuder += <locatie, ouder>;
  }
  
  for (bestand <- alleJavaBestanden){
  	loc locatie = bestand;
  	while (locatie != projectOmTeMeten){
  	  loc ouder = locatie.parent;
  	  ouderKind += <ouder, locatie>;
  	  kindOuder += <locatie, ouder>;
  	  locatie = ouder;
  	}
  }
  geefWaarden(projectOmTeMeten);
}  

void geefWaarden(loc locatie) {
  tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] waarden = <0, 0, 0, 0, 0, 0, 0, 0, 0>;
  set[loc] kinderen = ouderKind[locatie];
  if (kinderen == {}) {
    lrel[loc leesBareLocatie, int cc, tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] waarden] WaardenLijst = unitWaarden[locatie];
    for (waardenElement <- WaardenLijst){
        waarden = addValueTuple(waarden, waardenElement.waarden);
    }
  } else {
    for (kind <- kinderen) {
      geefWaarden(kind);
      for (kindWaarden <- nodeWaarden[kind]){
        waarden = addValueTuple(waarden, kindWaarden);
      }
    }
  }
  nodeWaarden += <locatie, waarden>;
}


tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] addValueTuple(tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] a, tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] b){
  int zcc = a.zcc+b.zcc;
  int hcc = a.hcc+b.hcc;
  int ncc = a.ncc+b.ncc;
  int lcc = a.lcc+b.lcc;
  int zlo = a.zlo+b.zlo;
  int hlo = a.hlo+b.hlo;
  int nlo = a.nlo+b.nlo;
  int llo = a.llo+b.llo;
  int tlo = a.tlo+b.tlo;
  tuple[int zcc, int hcc, int ncc, int lcc, int zlo, int hlo, int nlo, int llo, int tlo] returnWaarden = <zcc, hcc, ncc, lcc, zlo, hlo, nlo, llo, tlo>;
  return returnWaarden;
}

module AlgemeneFuncties

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
 import util::Math;


// hulp functie. Invoer project. Uitvoer een set van alle bestanden met extentie java
public set[loc] javaBestanden(loc project) =
{ a | /file(a) <- getProject(project), a.extension == "java" };

public list[str] zoekNaarString (str tekst) =
[begin,stb,rest | /^<begin:[^"\/]*><stb:">{0,1}<stm:[^\\]*\\*"[^"]*"|"[^"]*">{0,1}<rest:.*>$/ := tekst];

public list[str] zoekNaarBeginStringOfCommentaar (str tekst) =
[begin,stb,comb,rest | /^<begin:[^"\/]*><stb:">{0,1}<comb:\/\*|\/\/>{0,1}<rest:.*>$/ := tekst];



public str vervangString(str tekst){
	bool eindString;

	str resultaatTekst="";
	str restTekst=tekst;
	str b="\\"; // hulpvariabele met \ als inhoud om te zoeken naar \ in tekst
	str q="\""; // hulpvariabele met " als inhoud om te zoeken naar " in tekst
	
	// herhaal totdat restTekst leeg is
	do {
		resultaatZoek=[begin,bs1,q1,rest | /^<begin:[^<b><q>]*><bs1:<b>>{0,1}<q1:<q>>{0,1}<rest:.*>$/ := restTekst];
		restTekst=resultaatZoek[3];
		resultaatTekst=resultaatTekst+resultaatZoek[0];
		eindString=false;
		// indien begin string (resultaatZoek[2] heeft een waarde) gevonden, ga dan op zoek naar het einde van de string\
		if(resultaatZoek[2]!=""){
			while(restTekst!="" && eindString==false)
				{
					resultaatZoek2=[begin,bs1,q1,rest | /^<begin:[^<b><q>]*><bs1:<b>>{0,1}<q1:<q>>{0,1}<rest:.*>$/ := restTekst];
					restTekst=resultaatZoek2[3];
					if(resultaatZoek2[1]=="" && resultaatZoek2[2]!=""){
						eindString=true;
						resultaatTekst=resultaatTekst+"string";
					}
					
				}	
		}
	
	} while (restTekst!="");
	
	return resultaatTekst;
	
}


// bepaalt of een (deel van een) regel een commentaar regel (dus begint met //) is.
public bool bepaalCommentaarRegel(str tekst){
	bool commentaarRegel;
//	str commentaarRegel;
	if(tekst[..2]=="//") commentaarRegel=true; else commentaarRegel=false;
	return commentaarRegel;
}



public map[str,str] testCommentaar(str tekst, map[str,str] commentaarZoekWaarden){

	str resultaat="";
	int codeGevonden = toInt(commentaarZoekWaarden["codeGevonden"]);
	str zoekString=commentaarZoekWaarden["zoekString"];

	restTekst=tekst;
	list[str] resultaatStap1;
	list[str] resultaatStap2;
	// kijk eerst of de regel met gezochte string (/* of */ afhankelijk van inhoud zoekString) begint
    resultaatStap1=[begin, rest | /^<begin:<zoekString>>{0,1}<rest:.*>$/ := restTekst];
    
 	restTekst=resultaatStap1[1];
 	
    // indien zoekstring gevonden, dan staat deze in resultaatStap1[0], 
    // past dan de zoekString aan, dit wordt gedaan door de tekens in de zoekString
    // om te keren
 	
 	if(resultaatStap1[0]!="")
    	{zoekString=zoekString[1]+zoekString[0];}
 	
 	
     	// bepaal of de rest van de regel commentaar is
    testRestCommentaarRegel=bepaalCommentaarRegel(restTekst);
    
    
    // indien rest van de regel commentaar is, stop dan met zoeken
    if(testRestCommentaarRegel==true && zoekString=="/*"){
    	// maak de restTekst leeg
    	restTekst="";
    	}

    
   
    // dit stuk alleen uitvoeren indien er nog tekst over was en bij de eerste stap niet op de eerste twee posities
    // de zoekString is gevonden. Indien er wel op de eerste twee posities de zoekString is gevonden moet stap1 eerst opnieuw 
    // worden uitgevoerd dus een recursieve aanroep van deze functie
    if (restTekst!="" && resultaatStap1[0]=="" )
    	{
    	
    	
    	// indien geen commentaar aan het begin van de string is gevonden, zoek dan verder, maar 
    	// sla het eerste teken daarbij over. (Anders zou dit problemen geven wanneer een commentaar
    	// blok eindigt met **/.
    	resultaatStap2=[begin, bcom, rest | /^.<begin:[^\/*]*><bcom:<zoekString>>{0,1}<rest:.*>$/ := restTekst];
    			
    	// indien op zoek naar zoekString /* (dus niet in een commentaar blok
    	// en het eerste deel van het resultaat uit stap 2 is niet leeg
    	// dan is er sprake van code. 
    	if(zoekString=="/*" && resultaatStap2[0]!=""){
    		codeGevonden +=1;
    	}
    				
    	// indien de zoekstring is gevonden staat deze in resultaatStap2[1]. In dat geval de zoek string omdraaien
    	if(resultaatStap2[1]!="")
    		{zoekString=zoekString[1]+zoekString[0];}
    	restTekst=resultaatStap2[2];
    }
    	
    // indien restTekst niet leeg is, dan moet de functie opnieuw worden uitgevoerd
    commentaarZoekWaarden["zoekString"] = zoekString;
    commentaarZoekWaarden["codeGevonden"]=toString(codeGevonden);
  
    
    if(restTekst!=""){    	
    	commentaarZoekWaarden = testCommentaar(restTekst, commentaarZoekWaarden);
    }
    return commentaarZoekWaarden;
}

	public int regelsCode(loc programmaCode){
	
	int codeRegelTeller = 0;
	bool inCommentaarBlok = false;
	str zoekString="/*";  // hulpvariabele met de string waarna bij vinden van commentaar blokken wordt gezocht
	map[str,str] commentaarZoekWaarden = ();
	
	commentaarZoekWaarden["zoekString"]="/*";
	
	// ga een voor een de getrimde regels uit het stukje code door
	for(codeRegel <- readFileLines(programmaCode)){
		if(trim(codeRegel)!=""){
			//alleen wanneer de codeRegel tekens bevat
				if(inCommentaarBlok==false){
				// indien we niet in een blok met commentaar zitten
	
					tekstzonderString=vervangString(trim(codeRegel));
		
					// de tekst bevat geen strings meer
					
					// eerst de indicator of in een regel code zit op leeg zetten.
					commentaarZoekWaarden["codeGevonden"]="0";
	 				commentaarZoekWaarden=testCommentaar(tekstzonderString,commentaarZoekWaarden);
					// hierna staat in commentaarZoekWaarden de huidige zoekString die aangeeft of we wel of niet in een commentaarblok
					// zitten en in codeGevonden staat of er code in de laatste regel is gevonden.  
					
					if(toInt(commentaarZoekWaarden["codeGevonden"])>0){
						codeRegelTeller += 1;
					}
				}
			}
		}
	return codeRegelTeller;
	}







public int regelsCodeReserve(loc programmaCode){

int regelTeller = 0;
bool inCommentaarBlok = false;


// ga een voor een de getrimde regels uit het stukje code door
for(codeRegel <- readFileLines(programmaCode)){
	
	if(inCommentaarBlok==false){

		// we zitten niet al in een commentaar blok
		resultaat = zoekNaarBeginStringOfCommentaar(trim(codeRegel));
		if (resultaat[1] != ""){
			// Begin van een string gevonden. 
			println("begin van een string gevonden");
		} else if (resultaat[2] == "/*") {
			// begin van commentaar blok gevonden.
			println("begin van commentaar blok gevonden");
			} else if (resultaat[2] == "//") {
				// begin van commentaar regel gevonden (//) 
				// indien er code voor staat dan is het een code regel, anders niet
				println("begin van regel commentaar gevonden");
				if (resultaat[0] != ""){
						regelTeller += 1;
					}
				}
	} else {
		// we zitten in een commentaar blok 
		println("we zitten in een commentaar blok");
		}
	}
return regelTeller;
}
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



public str vervangString(str tekst){
	bool eindString;

	str resultaatTekst="";
	str restTekst=tekst;
	str b="\\"; // hulpvariabele met \ als inhoud om te zoeken naar \ in tekst
	str q="\""; // hulpvariabele met " als inhoud om te zoeken naar " in tekst
	
	// herhaal totdat restTekst leeg is
	do {
		// zoek naar of een \ of een " of beide in de tekst. 
		// indien alleen een " wordt gevonden dan is er sprake van het begin van een string, dan wordt de tweede lus uitgevoerd
		//   waarin naar het eind van de string wordt gezocht.
		// indien er\ of \" wordt gevonden, dan overslaan en de restTekst onderzoeken of daar nog een sting in staat.
		resultaatZoek=[begin,bs1,q1,rest | /^<begin:[^<b><q>]*><bs1:<b>>{0,1}<q1:<q>>{0,1}<rest:.*>$/ := restTekst];
		restTekst=resultaatZoek[3];
		resultaatTekst=resultaatTekst+resultaatZoek[0];
		eindString=false;
		// indien begin string (resultaatZoek[2] heeft een waarde) gevonden, ga dan op zoek naar het einde van de string.
		if(resultaatZoek[2]!=""){
			while(restTekst!="" && eindString==false){
				// opnieuw zoeken naar " of \ of beide.
				// indien " zonder \ dan is het eind van de string gevonden. In dat geval komt in plaats van de string de tekst 	
			    //   "string te staan". (zodat indien er alleen een string op een regel staat, dit toch als code wordt gezien.)
			    // indien \" of \ wordt gevonden, dan verder gaan met het restant en daarin kijken of het eind van de string wordt 
			    //    gevonden.
			    // indien de string in een stuk commentaar staat dan wordt ook die vervangen door de tekst "string" maar dat heeft
			    //    geen gevolgen. 
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

public map[str,str] doorzoekCode(str restTekst, map[str,str] commentaarZoekWaarden){

	
	int codeGevonden = toInt(commentaarZoekWaarden["codeGevonden"]);
	str zoekString=commentaarZoekWaarden["zoekString"];


	list[str] resultaatStap1;
	list[str] resultaatStap2;
	restTekst=vervangString(restTekst);


	// kijk eerst of de regel met gezochte string (/* of */ afhankelijk van inhoud zoekString) begint
    resultaatStap1=[begin, rest | /^<begin:<zoekString>>{0,1}<rest:.*>$/ := restTekst];
    
 	restTekst=resultaatStap1[1];
 	
    // indien zoekstring gevonden, dan staat deze in resultaatStap1[0], 
    // past dan de zoekString aan, dit wordt gedaan door de tekens in de zoekString
    // om te keren
 	
 	if(resultaatStap1[0]!="")
    	{zoekString=zoekString[1]+zoekString[0];}
 	
 	// indien we niet in een commentaarblok zitten, kijk dan of de restTekst met // begint.
 	// 		Zo ja, maak dan restTekst leeg (de rest van de regel hoeft dan niet te worden onderzocht.)
 	if(zoekString=="/*" && restTekst[..2]=="//"){
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
    	commentaarZoekWaarden = doorzoekCode(restTekst, commentaarZoekWaarden);
    }
    return commentaarZoekWaarden;
}








public tuple[str zoekString,int codeGevonden] doorzoekCode2(str restTekst, tuple[str zoekString,int codeGevonden] zoekVariabelen){

	str zoekString=zoekVariabelen.zoekString; // bevat /* of */ en wordt gebruikt om te bepalen of we wel of niet in een 
											  //   blok commentaar zitten.
	int codeGevonden = zoekVariabelen.codeGevonden; // een teller die alleen wordt opgehoogd wanneer ergens code is gevonden. 
													// dus indien codeGevonden > 0, dan is er code. 

	list[str] resultaatStap1;
	list[str] resultaatStap2;

	// eerst gaan we alle strings in de regel vervangen door het woord "string", zodat we bij het bepalen van of iets 
	// commentaar is
	restTekst=vervangString(restTekst);


	// kijk eerst of de regel met gezochte string (/* of */ afhankelijk van inhoud zoekString) begint
    resultaatStap1=[begin, rest | /^<begin:<zoekString>>{0,1}<rest:.*>$/ := restTekst];
    
 	restTekst=resultaatStap1[1];
 	
    // indien zoekstring gevonden, dan staat deze in resultaatStap1[0], 
    // past dan de zoekString aan, dit wordt gedaan door de tekens in de zoekString
    // om te keren
 	
 	if(resultaatStap1[0]!="")
    	{zoekString=zoekString[1]+zoekString[0];}
 	
 	// indien we niet in een commentaarblok zitten, kijk dan of de restTekst met // begint.
 	// 		Zo ja, maak dan restTekst leeg (de rest van de regel hoeft dan niet te worden onderzocht.)
 	if(zoekString=="/*" && restTekst[..2]=="//"){
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
    	
    zoekVariabelen = <zoekString,codeGevonden>;

  
    // indien restTekst niet leeg is, dan moet de functie opnieuw worden uitgevoerd    
    if(restTekst!=""){    	
    	zoekVariabelen = doorzoekCode2(restTekst, zoekVariabelen);
    }
    return zoekVariabelen;
}









// Bepaalt het aantal regels code in een aangeboden (deel van een) bestand.
public int regelsCode(loc programmaCode){
	
	int codeRegelTeller = 0;
	map[str,str] commentaarZoekWaarden = ();
	
	commentaarZoekWaarden["zoekString"]="/*";
	
	tuple[str zoekWaarde, int codeGevonden] zoekVariabelen=<"/*",0>;
	
	// ga een voor een de regels uit het stukje code door
	for(codeRegel <- readFileLines(programmaCode)){
		// alleen indien de regel niet leeg is, wordt bepaald of deze code bevat.
		if(trim(codeRegel)!=""){
				
			// eerst de indicator of in een regel code zit op leeg zetten.
			commentaarZoekWaarden["codeGevonden"]="0";
			commentaarZoekWaarden=doorzoekCode(trim(codeRegel),commentaarZoekWaarden);
			
			zoekVariabelen.codeGevonden=0;
			zoekVariabelen=doorzoekCode2(trim(codeRegel),zoekVariabelen);

			// hierna staat in commentaarZoekWaarden de huidige zoekString die aangeeft of we wel of niet in een commentaarblok
			// zitten en in codeGevonden staat of er code in de laatste regel is gevonden.  
					
			if(toInt(commentaarZoekWaarden["codeGevonden"])>0){
				codeRegelTeller += 1;
			}

		}
	}
	return codeRegelTeller;
}

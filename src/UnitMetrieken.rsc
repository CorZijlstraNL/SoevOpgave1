module UnitMetrieken

import AlgemeneFuncties;

import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
//import Tuple;
import String;
import Relation;
import util::Math;
import demo::common::Crawl;

public str unitGrootteScore = "";
public str unitCCScore = "";

public int laagRisicoUnitGrootte = 0;
public int normaalRisicoUnitGrootte = 0;
public int hoogRisicoUnitGrootte = 0;
public int zeerHoogRisicoUnitGrootte = 0;

public int totaleUnitGrootte = 0;

public int laagRisicoUnitGroottePercentage = 0;
public int normaalRisicoUnitGroottePercentage = 0;
public int hoogRisicoUnitGroottePercentage = 0;
public int zeerHoogRisicoUnitGroottePercentage = 0;

public int laagRisicoUnitCC = 0;
public int normaalRisicoUnitCC = 0;
public int hoogRisicoUnitCC = 0;
public int zeerHoogRisicoUnitCC = 0;

public int totaleUnitCC = 0;

public int laagRisicoUnitCCPercentage = 0;
public int normaalRisicoUnitCCPercentage = 0;
public int hoogRisicoUnitCCPercentage = 0;
public int zeerHoogRisicoUnitCCPercentage = 0;

public str laagRisico = "laag";
public str normaalRisico = "normaal";
public str hoogRisico = "hoog";
public str zeerHoogRisico = "zeerHoog";

private lrel[loc,int,int] unitMetriekenLijst = [];
private lrel[loc,int,int,str,str] unitMetriekenLijstMetWaardering = [];

public lrel[loc,int,int,str,str] berekenUnitMetrieken(set[loc] bestanden) {
	unitMetriekenLijst = [];
	unitMetriekenLijstMetWaardering = [];
	set[Declaration] decls = createAstsFromFiles(bestanden, false);
	
	//iprintln(decls);
	
	rel[loc, Statement] alleMethoden = {};
	visit(decls){
		case m: \method(_,_,_,_, Statement s):
			alleMethoden += <m.src, s>;
		case c: \constructor(_,_,_, Statement s):
			alleMethoden += <c.src, s>;
	}
	
	for (methode <- alleMethoden) {
		loc locatie = methode[0];
		int aantalRegels = regelsCode(locatie);
		int cc = 1;
		//iprintln(methode);
		
		//println(readFile(locatie));
		Statement statement = methode[1];
		
		visit (statement) {
			case \if(Expression condition, Statement thenBranch): {
				cc += countInFix(condition);
			}
			case \if(Expression condition, Statement thenBranch, Statement elseBranch): {
				cc += countInFix(condition);
			}
			case \case(Expression expression): {
				cc += 1;
			}
			case \while(Expression condition, Statement body): {
				cc += countInFix(condition);
			}
			case \foreach(Declaration parameter, Expression collection, Statement body): {
				cc += 1;
			}
			case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): {
				cc += countInFix(condition);
			}
			case \for(list[Expression] initializers, list[Expression] updaters, Statement body): {
				cc += 1;
			}
			case \catch(Declaration exception, Statement body): {
				cc += 1;
			}
			case \continue(): {
				cc += 1;
			}
			case \continue(str label): {
				cc += 1;
			}
		};
		
		unitMetriekenLijst += <locatie, aantalRegels, cc>;
	}
	unitMetriekenLijst = sort(unitMetriekenLijst);
	
	
	laagRisicoUnitGrootte = 0;
	normaalRisicoUnitGrootte = 0;
	hoogRisicoUnitGrootte = 0;
	zeerHoogRisicoUnitGrootte = 0;
	totaleUnitGrootte = 0;
	
	laagRisicoUnitCC = 0;
	normaalRisicoUnitCC = 0;
	hoogRisicoUnitCC = 0;
	zeerHoogRisicoUnitCC = 0;
	totaleUnitCC = 0;
	
	
	for (unit <- unitMetriekenLijst) {
		loc curentLocation = unit[0];
		int currentLoc = unit[1];
		int currentCC = unit[2];
		str grootteRisico = "";
		str complexiteitRisico = "";
		
		if (currentLoc >= 1 && currentLoc <= 20) {
			laagRisicoUnitGrootte += currentLoc;
			grootteRisico = laagRisico;
		} else if (currentLoc >= 21 && currentLoc <= 50) {
			normaalRisicoUnitGrootte += currentLoc;
			grootteRisico = normaalRisico;
		} else if (currentLoc >= 51 && currentLoc <= 100) {
			hoogRisicoUnitGrootte += currentLoc;
			grootteRisico = hoogRisico;
		} else if (currentLoc > 100) {
			zeerHoogRisicoUnitGrootte += currentLoc;
			grootteRisico = zeerHoogRisico;
		}
		
		totaleUnitGrootte += currentLoc;
	
		if (currentCC >= 1 && currentCC <= 10) {
			laagRisicoUnitCC += currentLoc;
			complexiteitRisico = laagRisico;
		} else if (currentCC >= 11 && currentCC <= 20) {
			normaalRisicoUnitCC += currentLoc;
			complexiteitRisico = normaalRisico;
		} else if (currentCC >= 21 && currentCC <= 50) {
			hoogRisicoUnitCC += currentLoc;
			complexiteitRisico = hoogRisico;
		} else if (currentCC > 50) {
			zeerHoogRisicoUnitCC += currentLoc;
			complexiteitRisico = zeerHoogRisico;
		}
		
		totaleUnitCC += currentLoc;
		
		unitMetriekenLijstMetWaardering += <curentLocation, currentLoc, currentCC, grootteRisico, complexiteitRisico>;
	}
	
	laagRisicoUnitGroottePercentage = percent(laagRisicoUnitGrootte, totaleUnitGrootte);
	normaalRisicoUnitGroottePercentage = percent(normaalRisicoUnitGrootte, totaleUnitGrootte);
	hoogRisicoUnitGroottePercentage = percent(hoogRisicoUnitGrootte, totaleUnitGrootte);
	zeerHoogRisicoUnitGroottePercentage = percent(zeerHoogRisicoUnitGrootte, totaleUnitGrootte);
		
	if (normaalRisicoUnitGroottePercentage <= 25 && hoogRisicoUnitGroottePercentage == 0 && zeerHoogRisicoUnitGroottePercentage == 0) {
		unitGrootteScore = "++";
	} else if (normaalRisicoUnitGroottePercentage <= 30 && hoogRisicoUnitGroottePercentage <= 5 && zeerHoogRisicoUnitGroottePercentage == 0) {
		unitGrootteScore = "+";
	} else if (normaalRisicoUnitGroottePercentage <= 40 && hoogRisicoUnitGroottePercentage <= 10 && zeerHoogRisicoUnitGroottePercentage == 0) {
		unitGrootteScore = "o";
	} else if (normaalRisicoUnitGroottePercentage <= 50 && hoogRisicoUnitGroottePercentage <= 15 && zeerHoogRisicoUnitGroottePercentage <= 5) {
		unitGrootteScore = "-";
	} else {
		unitGrootteScore = "--";
	}
	
	laagRisicoUnitCCPercentage = percent(laagRisicoUnitCC, totaleUnitCC);
	normaalRisicoUnitCCPercentage = percent(normaalRisicoUnitCC, totaleUnitCC);
	hoogRisicoUnitCCPercentage = percent(hoogRisicoUnitCC, totaleUnitCC);
	zeerHoogRisicoUnitCCPercentage = percent(zeerHoogRisicoUnitCC, totaleUnitCC);
		
	if (normaalRisicoUnitCCPercentage <= 25 && hoogRisicoUnitCCPercentage == 0 && zeerHoogRisicoUnitCCPercentage == 0) {
		unitCCScore = "++";
	} else if (normaalRisicoUnitCCPercentage <= 30 && hoogRisicoUnitCCPercentage <= 5 && zeerHoogRisicoUnitCCPercentage == 0) {
		unitCCScore = "+";
	} else if (normaalRisicoUnitCCPercentage <= 40 && hoogRisicoUnitCCPercentage <= 10 && zeerHoogRisicoUnitCCPercentage == 0) {
		unitCCScore = "o";
	} else if (normaalRisicoUnitCCPercentage <= 50 && hoogRisicoUnitCCPercentage <= 15 && zeerHoogRisicoUnitCCPercentage <= 5) {
		unitCCScore = "-";
	} else {
		unitCCScore = "--";
	}
	
	return unitMetriekenLijstMetWaardering;
}

public int countInFix(Expression expression) {
	int cc = 1;
	visit (expression) {
		case \infix(Expression lhs, str operator, Expression rhs): {
			if (operator == "&&" || operator == "||") { 
				cc += 1;
			}
		}
	};
	return cc; 
}

public tuple[str,str] printUnitResultaten() {
	println("Unit Grootte");
	println();
	
	println("laagRisico: <laagRisicoUnitGroottePercentage>%");
	println("normaalRisico: <normaalRisicoUnitGroottePercentage>%");
	println("hoogRisico: <hoogRisicoUnitGroottePercentage>%");
	println("zeerHoogRisico: <zeerHoogRisicoUnitGroottePercentage>%");	
	println();	
	println("Unit Grootte Rating: <unitGrootteScore>");
	
	println();
	
	println("unit complexiteit");
	println();
	
	println("laagRisico: <laagRisicoUnitCCPercentage>%");
	println("normaalRisico: <normaalRisicoUnitCCPercentage>%");
	println("hoogRisico: <hoogRisicoUnitCCPercentage>%");
	println("zeerHoogRisico: <zeerHoogRisicoUnitCCPercentage>%");	
	
	println();
	
	println("Unit Complexiteit Rating: <unitCCScore>");  
	return <unitGrootteScore,unitCCScore>;
}
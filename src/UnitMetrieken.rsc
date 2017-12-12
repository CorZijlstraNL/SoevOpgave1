module UnitMetrieken

import AlgemeneFuncties;

import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Tuple;
import String;
import Relation;
import util::Math;
import demo::common::Crawl;

public str unitSizeScore;
public str unitCCScore;

public int lowRiskUnitSize;
public int mediumRiskUnitSize;
public int highRiskUnitSize;
public int veryHighRiskUnitSize;

public int lowRiskUnitCC;
public int mediumRiskUnitCC;
public int highRiskUnitCC;
public int veryHighRiskUnitCC;

public lrel[loc,int,int] unitMetriekenLijst = [];

public lrel[loc,int,int] berekenUnitMetrieken(set[loc] bestanden) {
	unitMetriekenLijst = [];
	set[Declaration] decls = createAstsFromFiles(bestanden, false);
	
	//iprintln(decls);
	
	rel[loc, Statement] allMethods = {};
	visit(decls){
		case m: \method(_,_,_,_, Statement s):
			allMethods += <m.src, s>;
		case c: \constructor(_,_,_, Statement s):
			allMethods += <c.src, s>;
	}
	
	for (method <- allMethods) {
		loc locatie = method[0];
		int aantalRegels = regelsCode(locatie);
		int cc = 1;
		iprintln(method);
		
		unitMetriekenLijst += <locatie, aantalRegels, cc>;
	}
	
	return unitMetriekenLijst;
}
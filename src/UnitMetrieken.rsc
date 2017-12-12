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
		
		Statement statement = method[1];
		
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
	
	return unitMetriekenLijst;
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

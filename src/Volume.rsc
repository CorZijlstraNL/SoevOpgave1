module Volume

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

 import AlgemeneFuncties;

public int bepaalVolume(set[loc] bestanden){

//LOC is iedere regel 

 	map[loc, int] aantalRegels = ( a:regelsCode(a)|loc a <- bestanden);
 
 println(aantalRegels); 
 return 1;
 }
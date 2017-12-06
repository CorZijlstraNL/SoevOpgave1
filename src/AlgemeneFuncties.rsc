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


// hulp functie. Invoer project. Uitvoer een set van alle bestanden met extentie java
public set[loc] javaBestanden(loc project) =
{ a | /file(a) <- getProject(project), a.extension == "java" };
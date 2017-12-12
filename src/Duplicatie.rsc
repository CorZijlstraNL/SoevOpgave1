module Duplicatie

import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Tuple;
import String;
import Relation;
import Prelude;
import util::Benchmark;
import util::Math;
import demo::common::Crawl;

lrel[loc,list[str]] allFiles = [];

lrel[loc,list[str]] allBlocks = [];

int totalDupLines = 0;
int projectSize = 0;
int dupPercent = 0;
str dupRank = "";

int measuredTime = 0;
int measuredSeconds = 0;
int hours = 0;
int minutes = 0;
int seconds = 0;

rel[loc,int] duprel = {};


private list[str] getSixLines(list[str] lines, int lineNumber){
	return for (int n <- [lineNumber .. lineNumber + 6]) append lines[n];
}


private void detectClone(int fileNumberToStart, int blockNumberToStart){
	tuple[loc,list[str]] fileToStart = allBlocks[fileNumberToStart];
	bool starting = true;
	list[str] startBlocks = fileToStart[1];
	int startSize = size(startBlocks);
	 
	bool detected = false;
	
	str blockToSearch = startBlocks[blockNumberToStart];
	int fileN = fileNumberToStart;
	int blockN = blockNumberToStart;
	
	for (int f <- [fileN .. size(allBlocks)]){
		tuple[loc,list[str]] file = allBlocks[f];
		list[str] blocks = file[1];
		fileSize = size(blocks);

		for (int b <- [blockN .. fileSize]){
			str found = blocks[b];
			if (starting) { // using this for detecting FIRST run, lists are the same because of the SAME information is used
				starting = false;
				continue; //continue loop
			}
			if (found == blockToSearch){
				detected = true;
				//iprintln("Detected dups");
				duprel += <fileToStart[0], blockNumberToStart>;
				duprel += <file[0], b>;
				break; // inner loop
			}
		}
		blockN = 0;
		if (detected){
			break; // outer loop
		}
	}
	fileN = 0;
}


//public void calculateDuplication(set[loc] allLocations, int projectTotalSize) {
public void calculateDuplication(set[loc] allLocations) {

	measuredTime = cpuTime();
	
	projectSize = 0;
	// Start with fresh lists
	allFileLines = [];
	allFiles = [];
	allBlocks = [];
	duplications = {};
	
//	iprintln("reading files");
	
	for (currentLocation <- allLocations) {
		list[str] fileLines = [];
		for (line <- readFileLines(currentLocation)) {
			line = trim(line);
			fileLines += line;
			projectSize += 1;
		}
		allFiles += [<currentLocation, fileLines>];
	}
	
//	iprintln("Creating Strings from code blocks");
	
	for (file <- allFiles){
		int fileLength = size(file[1]);
		if (fileLength < 6){
			continue; // file is too short for  getting blocks
		}
		list[str] blocks = [];
		int fileSizeMinus6 = fileLength - 6;
		for (int l <- [0 .. fileSizeMinus6]){
			str element = toString(getSixLines(file[1], l));
			blocks += element;
		}
		allBlocks += <file[0],blocks>;
	}	
	
	
//	iprintln("Getting set of dups");
	int lineBlock = 0;
	int fileNumber = 0;
	for (file <- allBlocks) {
//		iprintln("Analyzing file <fileNumber + 1> of <size(allBlocks)>");
		int blockNumber = 0;
		list[str] blocks = file[1];
		for (line <- blocks) {
			detectClone(fileNumber, blockNumber);
			blockNumber += 1; 
		}
		fileNumber += 1;
	}
	
//	iprintln("Converting to list of dups");
	
	lrel[loc, int] dups = toList(duprel);
//	iprintln("Sorting dups");
	dups = sort(dups);
	
	totalDupLines = 0;
	dupLines = 6;
	
//	iprintln("Counting duplines");
	
	int dupNumber = 0;
	for (singleDup <- dups) {
		bool foundLonger = false;
		dupNumber += 1;
		int diff = 0;
		if (dupNumber < size(dups)){
			tuple[loc,int] nextDup = dups[dupNumber];
			if (singleDup[0] == nextDup[0]){ // same location
				diff = nextDup[1] - singelDup[1];
				if (diff < 6){
					foundLonger = true;
				}
			}
		}
		if (foundLonger) {
			dupLines += diff;
		} else {
			loc dupLoc = singleDup[0];
			//iprintln("DUP in <dupLoc> DUPLINES <dupLines> from line <singleDup[1] + 6 - dupLines>");
			totalDupLines += dupLines;
			dupLines = 6;
		}
	}
	
	measuredTime = cpuTime() - measuredTime;
	measuredSeconds = (measuredTime + 500000000) / 1000000000;
	hours = measuredSeconds / 3600;
	minutes = (measuredSeconds - (hours * 3600)) / 60;
	seconds = measuredSeconds - (hours * 3600) - (minutes * 60);
	
	dupPercent = percent(totalDupLines, projectSize);
	
	dupRank = "";
	
	if (dupPercent > 0 && dupPercent <= 3) {
		dupRank = "++";
	} else if (dupPercent > 3 && dupPercent <= 5) {
		dupRank = "+";
	} else if (dupPercent > 5 && dupPercent <= 10) {
		dupRank = "o";
	} else if (dupPercent > 10 && dupPercent <= 20) {
		dupRank = "-";
	} else if (dupPercent > 20 && dupPercent <= 100) {
		dupRank = "--";
	}
	
}

public void printDuplicationResults() {
	println("Duplication");
	println();
	println("Duplication: <totalDupLines> duplication lines in <projectSize> lines found in <hours> hours, <minutes> minutes and <seconds> seconds.");
	println();
	println("Duplication: <dupPercent>%"); 
   	println();	
	println("Duplication rank: <dupRank>");
	println();
}
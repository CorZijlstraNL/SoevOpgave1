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

lrel[list[str],loc] allFiles = [];

lrel[list[str],loc] allBlocks = [];

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
	tuple[list[str],loc] fileToStart = allBlocks[fileNumberToStart];
	bool starting = true;
	list[str] startBlocks = fileToStart[0];
	int startSize = size(startBlocks);
	 
	bool detected = false;
	
	str blockToSearch = startBlocks[blockNumberToStart];
	int fileN = fileNumberToStart;
	int blockN = blockNumberToStart;
	
	for (int f <- [fileN .. size(allBlocks)]){
		tuple[list[str],loc] file = allBlocks[f];
		list[str] blocks = file[0];
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
				duprel += <fileToStart[1], blockNumberToStart + 1>;
				duprel += <file[1], b + 1>;
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


public void calculateDuplication(set[loc] allLocations, int projectTotalSize) {

	measuredTime = cpuTime();
	
	projectSize = projectTotalSize;
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
		}
		allFiles += [<fileLines, currentLocation>];
	}
	
//	iprintln("Creating Strings from code blocks");
	
	for (file <- allFiles){
		int fileLength = size(file[0]);
		if (fileLength < 6){
			continue; // file is too short for  getting blocks
		}
		list[str] blocks = [];
		int fileSizeMinus6 = fileLength - 6;
		for (int l <- [0 .. fileSizeMinus6]){
			str element = toString(getSixLines(file[0], l));
			blocks += element;
		}
		allBlocks += <blocks,file[1]>;
	}	
	
	
	iprintln("Getting set of dups");
	int lineBlock = 0;
	int fileNumber = 0;
	for (file <- allBlocks) {
//		iprintln("Analyzing file <fileNumber + 1> of <size(allBlocks)>");
		int blockNumber = 0;
		list[str] blocks = file[0];
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
		
		if (dupNumber < size(dups)){
			tuple[loc,int] nextDup = <singleDup[0],singleDup[1]+1>;
			if (dups[dupNumber] == nextDup){
				foundLonger = true;
			}
		}
		if (foundLonger) {
			dupLines += 1;
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

public void printResults() {
	println("Duplication");
	println();
	println("Duplication: <totalDupLines> duplication lines in <projectSize> lines found in <hours> hours, <minutes> minutes and <seconds> seconds.");
	println();
	println("Duplication: <dupPercent>%"); 
   	println();	
	println("Duplication rank: <dupRank>");
	println();
}
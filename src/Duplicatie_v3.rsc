module Duplicatie_v3

import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
//import Tuple;
import String;
import Relation;
import Prelude;
import util::Benchmark;
import util::Math;
import demo::common::Crawl;

import AlgemeneFuncties_v2;

lrel[loc,list[str],int] allFiles = [];
int allFilesCount = 0;

set[str] detectedStrings = {};

lrel[loc,lrel[str,loc,int],int] allBlocks = [];
int allBlocksCount = 0;

lrel[str,loc,int] allPossibleLineBlocks = [];
int allPossibleLineBlocksCount = 0;

public bool alleRegels = false;

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

lrel[loc, int, int] dupLocations = [];

private list[str] getSixLines(list[str] lines, int lineNumber){
	return for (int n <- [lineNumber .. lineNumber + 6]) append lines[n];
}

//public void calculateDuplication(set[loc] allLocations, int projectTotalSize) {
public lrel[loc,int,int] calculateDuplication(set[loc] allLocations) {

	measuredTime = cpuTime();
	
	// Start with fresh lists
	allFiles = [];
	allFilesCount = 0;
	allBlocks = [];
	allBlocksCount = 0;
	
	detectedStrings = {};
	
	allPossibleLineBlocks = [];
	allPossibleLineBlocksCount = 0;
	
	totalDupLines = 0;
	projectSize = 0;
	dupPercent = 0;
	dupRank = "";
	duprel = {};
	dupLocations = [];

	iprintln("reading files");
	
	for (currentLocation <- allLocations) {
		list[str] fileLines = [];
		int fileLinesCount = 0;
		list[str] lines = [];
		if (alleRegels) {
			lines = readFileLines(currentLocation);
		} else {
			 lines = codeRegels(currentLocation);
		}
		for (line <- lines) {
			line = trim(line);
			fileLines += line;
			fileLinesCount += 1;
			projectSize += 1;
		}
		allFiles += [<currentLocation, fileLines, fileLinesCount>];
		allFilesCount += 1;
	}
	
	iprintln("Sorting the list allFiles");
	allFiles = sort(allFiles);
	//allFilesCount = size(allFiles);
	
	iprintln("Creating Strings from code blocks");
	
	int fileNumber = 0;
	while (fileNumber < allFilesCount) {
		tuple[loc,list[str],int] file = allFiles[fileNumber];
		loc fileLocation = file[0];
		list [str] fileLines = file[1];
		int fileLinesCount = file[2];
		fileNumber += 1;
		iprintln("   Creating strings from file <fileNumber> of <allFilesCount>");
		if (fileLinesCount >= 6){
			int fileLinesCountMinus6 = fileLinesCount - 6;
			int lineNumber = 0;
			lrel[str,loc,int] blocks = [];
			while (lineNumber < fileLinesCountMinus6) {
				str sixLines = toString(getSixLines(fileLines, lineNumber));
				blocks += <sixLines, fileLocation, lineNumber>;
				lineNumber += 1;
			}
			allBlocks += <fileLocation, blocks, fileLinesCountMinus6>;
			allBlocksCount += 1;
			allPossibleLineBlocks += blocks;
			allPossibleLineBlocksCount += fileLinesCountMinus6;
		}
	}
	
	iprintln("Sorting lineBlocks");
	allPossibleLineBlocks = sort(allPossibleLineBlocks);
	
	iprintln("Searching for duplications");
	int blockNumber = 0;
	while (blockNumber < allPossibleLineBlocksCount){
		str thisStr = allPossibleLineBlocks[blockNumber][0];
		loc thisLoc = allPossibleLineBlocks[blockNumber][1];
		int thisInt = allPossibleLineBlocks[blockNumber][2];
		blockNumber += 1;
		if (blockNumber < allPossibleLineBlocksCount){
			str nextStr = allPossibleLineBlocks[blockNumber][0];
			loc nextLoc = allPossibleLineBlocks[blockNumber][1];
			int nextInt = allPossibleLineBlocks[blockNumber][2];
			if (thisStr == nextStr){ // dup found
				duprel += <thisLoc,thisInt>;
				duprel += <nextLoc,nextInt>;
			}
		}
	}
	
	iprintln("Converting duprelation to list");
	lrel[loc, int] dups = toList(duprel);
	iprintln("Sorting dups");
	dups = sort(dups);
	
	totalDupLines = 0;
	dupLines = 6;
	
	iprintln("Counting duplines");
	
	int dupNumber = 0;
	for (singleDup <- dups) {
		bool foundLonger = false;
		dupNumber += 1;
		int diff = 0;
		if (dupNumber < size(dups)){
			tuple[loc,int] nextDup = dups[dupNumber];
			if (singleDup[0] == nextDup[0]){ // same location
				diff = nextDup[1] - singleDup[1];
				if (diff < 7){
					foundLonger = true;
				}
			}
		}
		if (foundLonger) {
			dupLines += diff;
		} else {
			loc dupLoc = singleDup[0];
			int dupPos = singleDup[1] + 6 - dupLines;
			//iprintln("DUP in <dupLoc> DUPLINES <dupLines> from line <dupPos>");
			dupLocations += <dupLoc, dupPos, dupLines>;
			totalDupLines += dupLines;
			dupLines = 6;
		}
	}
	
	measuredTime = cpuTime() - measuredTime;
	measuredSeconds = (measuredTime + 500000000) / 1000000000;
	hours = measuredSeconds / 3600;
	minutes = (measuredSeconds - (hours * 3600)) / 60;
	seconds = measuredSeconds - (hours * 3600) - (minutes * 60);
	iprintln ("<totalDupLines> duplines found");
	dupPercent = percent(totalDupLines, projectSize);
	
	dupRank = "";
	
	if (dupPercent >= 0 && dupPercent <= 3) {
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
	
	return dupLocations;
}

public str printDuplicatieResultaten(loc bestandMetOutput) {
	appendToFile(bestandMetOutput, "\r\nDuplicatie:");
	appendToFile(bestandMetOutput, "\r\n");
	appendToFile(bestandMetOutput, "\r\n<totalDupLines> duplicatie regels gevonden in <projectSize> regels in <hours> uren, <minutes> minuten en <seconds> seconden.");
	appendToFile(bestandMetOutput, "\r\n");
	appendToFile(bestandMetOutput, "\r\n<dupPercent>%"); 
   	appendToFile(bestandMetOutput, "\r\n");	
	appendToFile(bestandMetOutput, "\r\nScore: <dupRank>");
	appendToFile(bestandMetOutput, "\r\n");
	
	// return is gebruikt om score door te geven voor algemene scoreberekening 
	return dupRank;
}
//////////////////////////////////////////////////////////////////////////////////////////
//macro "BatchRegister" {
//macro "BatchSplitWells" {
//macro "PlateRegions" {
//macro "BatchAnalyzeFolders" {
//macro "AnalyzeFolder" {
//macro "ProcessWell2" {
//macro "MontageVideo" {
//
//

macro "BatchRegister" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “BatchRegister.ijm”
// This macro registers video files in a folder.
//
//
// Dirk Albrecht
//
//
// A single-well video file should already be loaded. This function is intended to be
// called by other functions.
//

pathname = getDirectory("Choose a Directory to register videos");
print("Selected directory: "+pathname);

///////////////////////////////////
// Main loop
//
  fileList = getFileList(pathname);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
  	if (endsWith(fileName,"avi")) {
  		j++;
  		print(TimeStamp()+": Currently processing video "+ j +": "+ fileName);

  		fullfile = pathname + File.separator() + fileName;
  		registeredFileName = pathname + File.separator() +
  							 substring(fileName,0,lastIndexOf(fileName,".")) + "_reg.avi";
  				
		if ((indexOf(fileName,"reg") < 0) & !File.exists(registeredFileName)) {

			if (nImages()>0) close("*");
			
  			open(fullfile);
  			run("8-bit");
  			
			print(TimeStamp()+": Registration started");

  			
			run("StackReg", "transformation=[Rigid Body]");
			
			print(TimeStamp()+": Registration complete! Saving "+registeredFileName);
			run("AVI... ", "compression=JPEG frame=7 save=[" + registeredFileName + "]");
  			
		} else {
			print("Already registered.");
		}
  	}
  }
//////////////////////////////////////////////////////////////////////////
// pulled out TimeStamp
} ///// end BatchRegister.ijm








macro "BatchSplitWells" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “BatchSplitWells.ijm”
// This macro creates individual well files for each plate.
//
//
// Dirk Albrecht
//
//
// 
//

pathname = getDirectory("Choose a Directory to Batch extract wells from AVI plate videos");
print("Selected directory: "+pathname);

///////////////////////////////////
// Main loop
//
  fileList = getFileList(pathname);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
  	if (endsWith(fileName,"avi")) {
  		j++;
  		print(TimeStamp()+": Currently processing video "+ j +": "+ fileName);

		fileNameNoReg = replace(fileName,"_reg","");
		wellFolder = pathname+substring(fileNameNoReg,0,lastIndexOf(fileNameNoReg,".avi"))+"_WellVideos";
		
		if (File.exists(wellFolder)) {
			
			print(wellFolder+" already exists. Skipping.");
			
		} else {

			//print(TimeStamp()+": Saving data to: " + wellFolder);
			print(TimeStamp()+": Opening video file: " + pathname+fileName);

			open(pathname+fileName); 
				
			print(TimeStamp()+": File Loaded. Begin well segmentation");

			//title = "Start well separation";
  			//msg = "Run the PlateRegio.ijm script, \n then click \"OK\".";
  			//waitForUser(title, msg);

			runMacro("PlateRegions");
		}
			
	//print(TimeStamp()+": all done.");
  	}
	
}
//////////////////////////////////////////////////////////////////////////
// pulled out TimeStamp
} ///// end BatchSplitWells.ijm









macro "PlateRegions" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin "PlateRegions"
// This macro creates regions for each well of a multiwell plate.
//
//
// Dirk Albrecht
//
// INSTALLATION:
// ImageJ is a high-quality public domain software very useful for image processing.
// Download the software from the imagej.nih.gov site. 
// You should have ImageJ installed in your machine in the first place.
// This plugin is a script written in ImageJ macro language (.ijm file).
// After opening ImageJ, install this plugin by doing Plugins > Install… and choosing 
// PlateRegions from the appropriate directory.
// The plugin PlateRegions should now appear listed under the Plugins menu, and is ready to 
// be launched by clicking Plugins > PlateRegions. 
//
//////////////////////////////////////////////////////////////////////////////////////////
//
// Example image: 
//
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// Clearing table with results and removing overlay

run("Clear Results");
run("Remove Overlay");

//////////////////////////////////////////////////////////////////////////////////////////

leftButton = 16;
message =

"STEP-BY-STEP INSTRUCTIONS FOR USE:						\n"
+"														\n"
+"	PlateRegions 0.1 (April 2019)						\n"
+"	Dirk Albrecht, PhD									\n"
+"														\n"						
+"	An AVI file should already be loaded, then click through the options.	\n"						
showMessage ("Readplate", message);

//////////////////////////////////////////////////////////////////////////////////////////
// Opening a video file
//

if (nImages() == 0) {
	exit ("Load an AVI video file as grayscale");
}

//////////////////////////////////////////////////////////////////////////////////////////
// Setting default grid parameter values

nc=12; nr=8; xo=516; yo=786; xf=4134; yf=3054; csize=440;
startWell="A1";

//////////////////////////////////////////////////////////////////////////////////////////
// Refining grid parameter values

do {

run("Remove Overlay");
roiManager("reset");

//////////////////////////////////////////////////////////////////////////////////////////
// Get coordinates

showMessage ("Coordinates", "Click first on upper left well and then on lower right well");

clicked = false;
while (!clicked) {
	getCursorLoc(xo, yo, z, modifiers);
	clicked = (modifiers&leftButton!=0);
	wait(10);
}
wait(200);
clicked = false;
while (!clicked) {
	getCursorLoc(xf, yf, z, modifiers);
	clicked = (modifiers&leftButton!=0);
	wait(10);
}

//////////////////////////////////////////////////////////////////////////////////////////
// Entering grid parameter values

Dialog.create("Grid Parameters");
Dialog.addNumber("Number of Columns (max 12):", nc);
Dialog.addNumber("Number of Rows (max 8):", nr);
Dialog.addNumber("Center of well A1: X origin (in pixels, left equals zero):", xo);
Dialog.addNumber("Center of well A1: Y origin (in pixels, up equals zero):", yo);
Dialog.addNumber("Center of well H12: X end (in pixels):", xf);
Dialog.addNumber("Center of well H12: Y end (in pixels):", yf);
Dialog.addNumber("Circle Size (Diameter in pixels):", csize);

Dialog.show();

//////////////////////////////////////////////////////////////////////////////////////////
// Checking grid parameter values

nc=Dialog.getNumber();
if (nc > 12)
	exit ("The number of columns should be less than or equal to 12");
if (nc < 1)
	exit ("The number of columns should be at least 1");

nr=Dialog.getNumber();
if (nr > 8)
	exit ("The number of rows should be less than or equal to 8");
if (nr < 1)
	exit ("The number of rows should be at least 1");

xo=Dialog.getNumber();
if (xo < 0)
	exit ("The X origin cannot be negative");

yo=Dialog.getNumber();
if (yo < 0)
	exit ("The Y origin cannot be negative");

xf=Dialog.getNumber();
if (xf < xo)
	exit ("The X end cannot be lower than the X origin");

yf=Dialog.getNumber();
if (yf < yo)
	exit ("The Y end cannot be lower than the Y origin");

csize=Dialog.getNumber();
if (csize < 1)
	exit ("The Diameter should be at least one pixel");

csepx=(xf - xo)/(nc-1); 
csepy=(yf - yo)/(nr-1);

//////////////////////////////////////////////////////////////////////////////////////////
// Building the grid

roiManager("reset")

x=xo-csize/2;
y=yo-csize/2;
//csmallsize=csize/sqrt(3);

for (i=0; i<nr; i++) {
 
	for (j=0; j<nc; j++) {

		makeOval(x+j*csepx, y+i*csepy, csize, csize);
		//run("Measure");
		roiManager("add");

	} 
 }  
roiManager("Show All");

run("Clear Results");

//////////////////////////////////////////////////////////////////////////////////////////
// Checking the grid

grid=newArray("Yes", "No");

Dialog.create("Grid check-up");
Dialog.addChoice("Does the grid fit the position of each well?", grid);
Dialog.show();
grid = Dialog.getChoice();

} while (grid== "No");

//////////////////////////////////////////////////////////////////////////////////////////
// Entering video parameter values
//
do {
	
pathname = getInfo("image.directory");

filename = getTitle();
filename = substring(filename,0,lastIndexOf(filename,"."));
filename = replace(filename,"_reg","");
foldername = filename+"_WellVideos";

Dialog.create("Save Well Videos");
Dialog.addString("Save to path:",pathname,60);
Dialog.addString("Save to folder:",foldername,60);
Dialog.addString("First well (upper left):",startWell);
Dialog.addChoice("Register Video first:", newArray("None", "Translation", "Rigid Body"));
Dialog.show();

pathname = Dialog.getString();
foldername = Dialog.getString();
startWell = Dialog.getString();
transformation = Dialog.getChoice();

reg = "";
if (!matches(transformation,"None")) {
	registeredFileName = pathname + File.separator() + filename + "_reg.avi";

	// Confirm registration -- this may take a while...

	reg=newArray("Yes", "No");
	Dialog.create("Registration check-up");
		
	if (File.exists(registeredFileName))
		Dialog.addMessage("Registered video file: " + registeredFileName + " already exists.");
	else if (indexOf(filename,"registered") > 0)
		Dialog.addMessage("Looks like the video is already registered. /n");
	else
		Dialog.addMessage("Registered video file: " + registeredFileName + " will be created.");
		
	Dialog.addChoice("Are you sure?", reg);
	Dialog.show();
	reg = Dialog.getChoice();
}
	
} while (reg == "No");

Dialog.create("Save Well Videos");
fullfolder = pathname + File.separator + foldername;
Dialog.addMessage("Selected folder is: "+fullfolder);
if (!File.exists(fullfolder)) {
	Dialog.addMessage("\t This folder does not exist and will be created.")
} else {
	Dialog.addMessage("\t This folder already exists. Contents will be overwritten.")
}
Dialog.show();

if (!File.exists(fullfolder)) {
	File.makeDirectory(fullfolder);
	print(fullfolder + " folder created");
}


rowOffset = charCodeAt(startWell,0) - charCodeAt("A",0);
colOffset = parseInt(substring(startWell,1)) - 1;


//////////////////////////////////////////////////////////////////////////////////////////
//  Video Registration (if selected)
//
if (!matches(transformation,"None")) {
	print("Running " + transformation + " registration! This may take several minutes.");
	run("StackReg", "transformation=[" + transformation + "]");

	run("AVI... ", "compression=JPEG frame=7 save=[" + registeredFileName + "]");
}


//////////////////////////////////////////////////////////////////////////////////////////
// Doing measurements on the chosen grid

for (i=0; i<nr; i++) { //nr

	row=substring("ABCDEFGH",i+rowOffset,i+1+rowOffset);
	
	for (j=0; j<nc; j++) { //nc

		col = j+1+colOffset;

		wellFileName = fullfolder + File.separator + filename + "_" + row + col + ".avi";
		//print(wellFileName);
		
		makeOval(x+j*csepx, y+i*csepy, csize, csize);
		getStatistics (area, mean);

		run("Measure");
	
 		setResult("Row", nResults-1, row);
 		setResult("Column", nResults-1, j+1);
 		setResult("MeanIntensity", nResults-1, mean);
 	
 		updateResults();

 		run("Duplicate...", "title=["+filename+"-"+row+col+"] duplicate");

 		// Save well video
 		//getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
 		//timeStamp = year+"-"+month+"-"+dayOfMonth+" "+hour+":"+minute+":"+second;
 		print("Saving video: "+wellFileName);
 		run("AVI... ", "compression=JPEG frame=7 save=["+wellFileName+"]");

		run("Close");
 	} 
  }  

  saveAs("Results", fullfolder + File.separator +"WellData.xls");
//////////////////////////////////////////////////////////////////////////////////////////
} // end "PlateRegions"







macro "BatchAnalyzeFolders" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “BatchAnalyzeFolders”
//
// This macro reads in an experiment foldername and loops through each well-plate folder
// of single-well videos. “BatchSplitWells” should be run first.
//
//
// Dirk Albrecht
//
//
//
///////////////////////////////////
// Get directory of Well videos
//  
dir = getArgument(); 
if (dir=="") {
	dir = getDirectory("Select a Directory");
	dialogs = true;
} else {
	dialogs = false;
}
print("Selected Data directory: "+dir);

///////////////////////////////////
// Main loop
//
  fileList = getFileList(dir);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
//  	print(fileName);
  	if (endsWith(fileName,"WellVideos/")) {
  		j++;
  		print(TimeStamp()+": Currently processing folder "+ j +": "+ dir+fileName);

  		if (File.exists(replace(dir+fileName,"WellVideos","DATA"))) {
  			print("Already done");
  		} else {
  			runMacro("AnalyzeFolder",dir+fileName);
  		}
 		close("*");
  	}
  }
//////////////////////////////////////////////////////////////////////////
} // end "BatchAnalyzeFolders"
  		






macro "AnalyzeFolder" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “AnalyzeFolder.ijm”
//
// This macro analyzes a folder of single well videos, saving the data and summary images
// in a folder _DATA.  It then calls another script to make montage whole-plate videos
// and images.
//
//
// Dirk Albrecht
//
//
// 
//


///////////////////////////////////
// Get directory of Well videos
//  
dir = getArgument(); 
if (dir=="") {
	dir = getDirectory("Select a Directory");
	dialogs = true;
} else {
	dialogs = false;
}
print("Selected video directory: "+dir);

// Check for Data folder
fullfolder = substring(dir,0,lastIndexOf(dir,"_"))+"_DATA";

if (dialogs) {
	
	Dialog.create("Save Data to:");
	Dialog.addMessage("Selected video folder is: "+dir);
	Dialog.addMessage(numFilesOfType(dir,"avi") + " avi video files found.");
	Dialog.addString("Save data to folder:",fullfolder,60);
//	Dialog.addCheckbox("Batch mode:",false);
	Dialog.show();

	fullfolder = Dialog.getString();
	//batch = Dialog.getCheckbox();

	Dialog.create("Save Data to:");
	Dialog.addMessage("Selected data folder is: "+fullfolder);
	if (!File.exists(fullfolder)) {
		Dialog.addMessage("\t Folder does not exist and will be created.");
	} else {
		Dialog.addMessage("\t Folder already exists. Contents will be overwritten.");
	}
	if(nImages() > 0) {
		Dialog.addMessage("Some image windows are open. These will be closed.");
	}

	Dialog.show();
}

if (!File.exists(fullfolder)) {
	File.makeDirectory(fullfolder);
	print(fullfolder + " folder created");
}

// List.set("directory",fullfolder);
close("*");

//if (batch == true) setBatchMode(true);

///////////////////////////////////
// Main loop
//
  fileList = getFileList(dir);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
  	if (endsWith(fileName,"avi")) {
  		j++;
  		print(TimeStamp()+": Currently processing well "+ j +": "+ fileName);

		open(dir+fileName);
		
  		runMacro("ProcessWell2");

  		selectWindow("montage");
  		montageFileName = fullfolder + File.separator() + fileName;
  		print(TimeStamp()+": Saving video: "+montageFileName);
 		run("AVI... ", "compression=JPEG frame=30 save=["+montageFileName+"]");

		dataFileName = replace(montageFileName,".avi",".xls");
		print("\\Update:"+ TimeStamp()+": Video. Saving data: "+dataFileName);
 		saveAs("Results", dataFileName);

		if (isOpen("QC")) {
			imageFileName = replace(montageFileName,".avi",".jpg");
			print("\\Update:"+ TimeStamp()+": Video. Data. Saving QC image: "+imageFileName);
			selectWindow("QC");
			saveAs("jpeg",imageFileName);
		}

		if (isOpen("output")) {
			binFileName = replace(montageFileName,".avi","_bin.avi");
			print("\\Update:"+ TimeStamp()+": Video. Data. QC. Saving binary stack: "+binFileName);
			selectWindow("output");
			run("AVI... ", "compression=JPEG frame=30 save=["+binFileName+"]");
		}

 		close("*");
  	}
  }

//if (batch == true) setBatchMode(false);

print("\\Update:"+ TimeStamp()+": starting Montage using: "+fullfolder);
runMacro("MontageVideo",fullfolder);
  		
//////////////////////////////////////////////////////////////////////////
} // end "AnalyzeFolder"





macro "ProcessWell2" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “ProcessWell2.ijm”
//
// Dirk Albrecht
//
// A single-well video file should already be loaded. This function is intended to be
// called by other functions.
//

setBatchMode(true)

name = getTitle();

// copy well stack & make B/W
run("Duplicate...", "title=raw_bw duplicate");
run("8-bit");

// get some information
getDimensions(width, height, channels, slices, frames)

// Correct for translation 
run("Duplicate...", "title=registered duplicate");
//run("StackReg", "transformation=Translation");
run("Enhance Contrast", "saturated=0.35");

// Get background and subtract
run("Z Project...", "projection=Median");
selectWindow("registered");
run("Z Project...", "projection=[Max Intensity]");
imageCalculator("Average create", "MED_registered","MAX_registered");
rename("background");
imageCalculator("Subtract create 32-bit stack", "registered","background");
setMinAndMax(-125, 25);
run("8-bit");
rename("bg_subtract");
run("Duplicate...", "title=QC duplicate");
setBatchMode("show");
run("Duplicate...", "title=threshold duplicate");

// Threshold for binary image
//run("Make Binary", "method=Otsu background=Light calculate");
run("Make Binary", "method=Default background=Light calculate");
run("Invert", "stack");
run("Invert LUT");
run("Despeckle", "stack");
run("Duplicate...", "title=binary duplicate");

// determine frame-to-frame difference
selectWindow("threshold");
run("Duplicate...", "title=before duplicate range=1-"+(nSlices-1));
selectWindow("threshold");
run("Duplicate...", "title=after duplicate range=2-"+nSlices);
imageCalculator("Subtract create 32-bit stack", "after","before");
rename("difference");

// determine movement
run("Duplicate...", "title=moved duplicate");
setMinAndMax(0, 255);
run("8-bit");
run("Duplicate...", "title=move2 duplicate");

//selectWindow("difference");
//run("Duplicate...", "title=moved2 duplicate");
//run("Abs", "stack");
//run("8-bit");

selectWindow("difference");
run("8-bit");
run("Enhance Contrast", "saturated=0.35");

// Clean up windows
close("after");
close("before");
//selectWindow("MED_registered");
//close();

// Prepare for quantification
if (isOpen("ROI Manager")) {
   selectWindow("ROI Manager");
   run("Close");
}
selectWindow("binary"); 
run("Invert", "stack");
// create blank border
border = 20;
makeRectangle(border, border, width-border*2, height-border*2);
run("Clear Outside", "stack");
run("Select All");
setAutoThreshold("Default dark");
roiManager("add");
selectWindow("move2"); 
makeRectangle(border, border, width-border*2, height-border*2);
run("Clear Outside", "stack");
run("Select All");
setAutoThreshold("Default dark");

setSlice(nSlices);
run("Add Slice");
imageCalculator("Add create 32-bit stack", "binary","move2");
run("8-bit");
rename("binary2");

// Filter out particles
minsize = 100; // adjust this value up if too many particles still present, or down if desired particles are lost 
setThreshold(64,255);
run("Analyze Particles...", "size="+minsize+"-Infinity show=Masks stack");
rename("binary2mask");
imageCalculator("Min create stack", "binary2","binary2mask");
rename("output");
resetThreshold();
setBatchMode("show");

run("Duplicate...", "title=output2 duplicate");


// Quantify
  if (isOpen("Results")) {
     selectWindow("Results");
     run("Close");
  }
run("Set Measurements...", "area mean centroid shape stack limit redirect=None decimal=3");

selectWindow("output2"); 
setThreshold(64,255);
roiManager("Select", 0);
roiManager("Multi Measure");

/*
selectWindow("move2"); 
roiManager("Multi Measure");
*/

updateResults();

/*
// Clean up windows
selectWindow("background"); run("Close");
selectWindow("MED_registered"); run("Close"); 
selectWindow("MAX_registered"); run("Close");
selectWindow("binary"); run("Close");
//selectWindow("binary2"); run("Close");
selectWindow("move2"); run("Close");
*/

// Make montage
	run("Combine...", "stack1=raw_bw stack2=bg_subtract");
	run("Combine...", "stack1=[Combined Stacks] stack2=threshold");
	rename("montage_top");
	
	run("Combine...", "stack1=difference stack2=moved");
	run("Combine...", "stack1=[Combined Stacks] stack2=output2");
	rename("montage_bottom");
	
	run("Combine...", "stack1=montage_top stack2=montage_bottom combine");
	rename("montage");	

	// label
	setColor(0,0,0);
	setFont("SanSerif",20);
	drawString(name,10,30);

setBatchMode(false);
////////////////////////////////////////////////////////////////////////////////////////////
} // end "ProcessWell2"






macro "MontageVideo" {
//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “MontageVideo.ijm”
// This macro creates video montage and color time-lapse summary
//
//
// Dirk Albrecht
//
//
// MontageVideo(foldername) 
//
// 	foldername is a folder containing videos after processing with the extension 
//			*_bin.avi
//

pathname = getArgument(); 
if (pathname=="") {
	pathname = getDirectory("Choose a Directory to montage _bin.avi videos");
}
if (!endsWith(pathname,"\\")) pathname = pathname+"\\";
print("Selected directory: "+pathname);
//cd(pathname);
print("...");

///////////////////////////////////
// Main loop
//
  fileList = getFileList(pathname);
  nFiles = lengthOf(fileList);

  sortedIdx = newArray(96); 
  maxRows = 0; maxCols = 0;
  
  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
  	if (endsWith(fileName,"_bin.avi")) {
  		j++;
		
		wellID = substring(fileName,0,lastIndexOf(fileName,"_bin.avi"));
		wellID = substring(wellID,lastIndexOf(wellID,"_")+1);
		wellRow = charCodeAt(wellID,0) - charCodeAt("A",0) + 1;
		wellCol = parseInt(substring(wellID,1));

		numRows = maxOf(numRows,wellRow);
		numCols = maxOf(numCols,wellCol);
		sortedIdx[(wellRow - 1)*numCols + wellCol - 1] = i;
  		
  		//print(TimeStamp()+": Currently processing video #"+ j +"("+sortedIdx[j]+"): "+wellID+", row: "+wellRow+", col: "+wellCol + "  " +   fileName);
  	}
  }

if (j == 0) exit("No _bin.avi files found. Did you select a _DATA folder?");

/*  for (i=0; i<lengthOf(sortedIdx); i++) { // nFiles
  	fileName = fileList[sortedIdx[i]];
  	//print(TimeStamp()+": Currently processing video #"+ (i+1) +": "+   fileName);
  	open(fileName);
  }
*/
close("*");
   
for (row=1; row <= numRows; row++) {
//row =1;
     
	for (col=1; col <= numCols; col++) {
		idx = (row-1)*numCols + col;
		fileName = fileList[sortedIdx[idx - 1]];
		print("\\Update:" + TimeStamp()+": Currently processing video #"+ idx +": "+pathname+fileName);
		open(pathname+File.separator()+fileName);
		//open(fileName); 
		run("8-bit");
		rename("next");
		if (col>1) {
			run("Combine...","stack1=row stack2=next");
		}
		rename("row");
	}
	
	if (row>1) {
		run("Combine...","stack1=montage stack2=row combine");
	}
	rename("montage");

}

baseName = substring(pathname,0,lastIndexOf(pathname,"_DATA"));
baseName = substring(baseName,lastIndexOf(baseName,"\\")+1);

print(TimeStamp()+": Saving video "+pathname+baseName+"_montage.avi");
run("AVI... ", "compression=JPEG frame=30 save=["+pathname+baseName+"_montage.avi]");

print(TimeStamp()+": Saving 50% scaled video "+pathname+baseName+"_montage2.avi");
run("Scale...", "x=.5 y=.5 interpolation=Bilinear average process create title=montage-2");
run("AVI... ", "compression=JPEG frame=30 save=["+pathname+baseName+"_montage2.avi]");

run("Temporal-Color Code", "lut=[Rainbow RGB]");
saveAs("jpeg",pathname+baseName+"_color2.jpg");

close("montage");

selectWindow("montage-2");
print(TimeStamp()+": Saving 25% scaled video "+pathname+baseName+"_montage4.avi");
run("Scale...", "x=.5 y=.5 interpolation=Bilinear average process create title=montage-4");
run("AVI... ", "compression=JPEG frame=30 save="+pathname+baseName+"_montage4.avi");

run("Temporal-Color Code", "lut=[Rainbow RGB]");
saveAs("jpeg",pathname+baseName+"_color4.jpg");

//////////////////////////////////////////////////////////////////////////
} // end "MontageVideo"












macro "MoveFilesForTransfer" {
///////////////////////////////////
// Get directory of Well videos
//  
dir = getArgument(); 
if (dir=="") {
	dir = getDirectory("Select an Experiment Directory (containing many plates)");
	dialogs = true;
} else {
	dialogs = false;
}
print("Selected Data directory: "+dir);

summaryFolder = dir+"Summary\\";
if (!File.exists(summaryFolder)) {
	File.makeDirectory(summaryFolder);
	print(summaryFolder + " folder created");
}
///////////////////////////////////
// Main loop
//
  fileList = getFileList(dir);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) { // nFiles
  	fileName = fileList[i];
//  	print(fileName);
  	if (endsWith(fileName,"_DATA/")) {
  		j++;
  		print(TimeStamp()+": Currently processing folder "+ j +": "+ dir+fileName);

  		if (!File.exists(summaryFolder+fileName)) {
			File.makeDirectory(summaryFolder+fileName);
			print(summaryFolder + " folder created");
		}

		fileList2 = getFileList(dir+fileName);
  		nFiles2 = lengthOf(fileList2);

  		for (k=0; k<nFiles2; k++) { // nFiles
  			fileName2 = fileList2[k];

  			if (endsWith(fileName2,".xls")) {
  					File.copy(dir+fileName+fileName2, summaryFolder+fileName+fileName2);
  			}

  			if ((indexOf(fileName2,"color2") > -1) || 
  				(indexOf(fileName2,"montage4") > -1)) {
					File.copy(dir+fileName+fileName2, summaryFolder+fileName2);
  			}
  		}
  	}
  }
/////////////////////////////////////////////////////////////////////////
} // end "MoveFilesForTransfer"







//////////////////////////////////////////////////////////////////////////
//
//  Common functions
//
//////////////////////////////////////////////////////////////////////////
function TimeStamp() {
     MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     month++;
     TimeString = ""+year;
     if (month<10) {TimeString = TimeString+"0";}
	 TimeString = TimeString+month;
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"_";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+":";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute+":";
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     return TimeString;
  }

//////////////////////////////////////////////////////////////////////////

function numFilesOfType(dir,ext) {
  fileList = getFileList(dir);
  nFiles = lengthOf(fileList);

  j = 0;
  for (i=0; i<nFiles; i++) {
  	fileName = fileList[i];
  	if (endsWith(fileName,ext)) {
  		j++;
  	}
  }
  return j;
}



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
// Choice of color for intensity measurements
/*
color=newArray("Green", "Blue", "Red", "Gray");

Dialog.create("Measurements");
Dialog.addChoice("Channel:", color);
Dialog.show();
color = Dialog.getChoice();

if (color== "Red") 
	setRGBWeights(1, 0, 0);
  else if (color== "Green") 
    setRGBWeights(0, 1, 0);
  else if (color== "Blue")
    setRGBWeights(0, 0, 1);
  else setRGBWeights(1/3, 1/3, 1/3);
*/

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
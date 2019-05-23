//////////////////////////////////////////////////////////////////////////////////////////
// Plugin “ProcessWell2.ijm”
// This macro creates regions for each well of a multiwell plate.
//
//
// Dirk Albrecht
//
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
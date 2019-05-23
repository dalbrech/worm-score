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
		
  		runMacro("D:\\Aroian\\ProcessWell2.ijm");

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
runMacro("D:\\Aroian\\MontageVideo.ijm",fullfolder);
  		
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
  
  
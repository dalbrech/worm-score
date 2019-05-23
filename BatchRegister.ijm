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
/*
filename = getTitle();
filename = substring(filename,0,lastIndexOf(filename,"."));
foldername = filename+"_WellVideos";

Dialog.create("Save Well Videos");
Dialog.addString("Save to path:",pathname,60);
Dialog.addString("Save to folder:",foldername,60);
Dialog.addString("First well (upper left):",startWell);
Dialog.addChoice("Register Video first:", newArray("Rigid Body", "Translation", "None"));
Dialog.show();

pathname = Dialog.getString();
foldername = Dialog.getString();
startWell = Dialog.getString();
transformation = Dialog.getChoice();

if (!matches(transformation,"None")) {
	registeredFileName = pathname + File.separator() + filename + "_registered.avi";

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
*/

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
  

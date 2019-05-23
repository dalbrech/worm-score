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

			runMacro("D:\\Aroian\\PlateRegions.ijm");

		}
			
	//print(TimeStamp()+": all done.");
  	}
	
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
  

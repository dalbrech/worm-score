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
  			runMacro("D:\\Aroian\\AnalyzeFolder.ijm",dir+fileName);
  		}
 		close("*");
  	}
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
  
  
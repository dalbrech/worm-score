///////////////////////////////////
// Get directory of Well videos
//  
dir = getArgument(); 
if (dir=="") {
	dir = getDirectory("Select an Experiment Directory (containing many plates)“);
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
  
  
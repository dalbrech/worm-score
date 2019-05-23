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
run("AVI... ", "compression=JPEG frame=30 save="+pathname+baseName+"_montage.avi");

print(TimeStamp()+": Saving 50% scaled video "+pathname+baseName+"_montage2.avi");
run("Scale...", "x=.5 y=.5 interpolation=Bilinear average process create title=montage-2");
run("AVI... ", "compression=JPEG frame=30 save="+pathname+baseName+"_montage2.avi");

run("Temporal-Color Code", "lut=[Rainbow RGB]");
saveAs("jpeg",pathname+baseName+"_color2.jpg");

close("montage");

selectWindow("montage-2");
print(TimeStamp()+": Saving 25% scaled video "+pathname+baseName+"_montage4.avi");
run("Scale...", "x=.5 y=.5 interpolation=Bilinear average process create title=montage-4");
run("AVI... ", "compression=JPEG frame=30 save="+pathname+baseName+"_montage4.avi");

run("Temporal-Color Code", "lut=[Rainbow RGB]");
saveAs("jpeg",pathname+baseName+"_color4.jpg");

//run("Images to Stack", "name=Stack title=[] use");
//run("Make Montage...", "columns="+numCols+"rows="+numRows+" scale=0.5");


/*		fileNameNoReg = replace(fileName,"_reg","");
		wellFolder = pathname+substring(fileNameNoReg,0,lastIndexOf(fileNameNoReg,".avi"))+"_WellVideos";
		
		if (File.exists(wellFolder)) {
			
			print(wellFolder+" already exists. Skipping.");
			
		} else {

			//print(TimeStamp()+": Saving data to: " + wellFolder);
			print(TimeStamp()+": Opening video file: " + pathname+fileName);

			open(pathname+fileName); 
				
			print(TimeStamp()+": File Loaded. Begin well segmentation");

			title = "Start well separation";
  			msg = "Run the PlateRegio.ijm script, \n then click \"OK\".";
  			waitForUser(title, msg);

		}
			*/
	//print(TimeStamp()+": all done.");



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
  

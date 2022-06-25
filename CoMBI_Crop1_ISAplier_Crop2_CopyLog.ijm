//ImageJ macro CoMBI_Crop1_ISApplier_Crop2.ijm (c)Yuki Tajika, 2022.6.23 CC-BY-NC
//
//The macro runs Crop1, IS Applier, Crop2 again, and Save
// For small image series which was used for IS.

// 1. Crop by a rectangle drawn manually.
// 2. Save crop values (x, y, Height, Width) in a work log, to reuse later for processing larger image series.
// 3. Images to be saved: [default]
//
// Radiobuttons:
//		openRadioButton = Dialog.getRadioButton();			// 1x2 [Virtual], Load to RAM
//
//		crop1RadioButton = Dialog.getRadioButton();			// 1x3	[Rectandle], Values, Skip
//		crop1saveRadioButton = Dialog.getRadioButton(); 	// 1x2	Save, [No need]
//		ISRadioButton = Dialog.getRadioButton();			// 1x2	Stabilize, [No need]
//		ISsaveRadioButton = Dialog.getRadioButton();		// 1x2	Save, [No need]
//		crop2RadioButton = Dialog.getRadioButton();			// 1x3 [Rectandle], Values, Skip
//		crop2saveRadioButton = Dialog.getRadioButton();		// 1x2 [Save], No need
//		graysaveRadioButton = Dialog.getRadioButton();		// 1x2 [Save], No need
//
// Numbers:
//		pixelsize = Dialog.getNumber();
//
//		crop1X = Dialog.getNumber();
//		crop1Y = Dialog.getNumber();
//		crop1W = Dialog.getNumber();
//		crop1H = Dialog.getNumber();
//		crop2X = Dialog.getNumber();
//		crop2Y = Dialog.getNumber();
//		crop2W = Dialog.getNumber();
//		crop2H = Dialog.getNumber();

// For FIJI on Intel Mac 2022.6. To import Log file, open it by other text editor app and Copy. Values will be pasted on Clipboard.
// Not for M1 Mac ImageJ1.53s 2022.6
// There are 2 place to be replace, indicating with /* and */.

//Update
// 2022.6.24 Upload to GitHub.
// 2022.6.24 Add function to save Grayscale images.
// 2022.6.25 Bug fix. 'Skip Crop1' stopped macro at IS. Virtual stack is loaded into RAM, by Cropping full-size.


//// Begin work log. 作業記録を開始   /////////////////////////////////////////////////////////////

	print("===================");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("[Crop1 > IS Applier > Crop2 > Grayscale]   ImageJ macro: CoMBI_Crop1_ISApplier_Crop2.ijm");
	print("Date: ",year,".",month+1,".",dayOfMonth, ", Time: ",hour,":", minute,",", second);
	nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
	
	
//// Select a folder containing serial images, 連続画像のフォルダを選択   ////////////////////////////

	pixelsize  = ""

Dialog.create("Select serial image");

		Dialog.addNumber("  1) Input pixel size of serial images (um/pixel) ", pixelsize);
		itemsOpen = newArray("Virtual","Load to RAM");
		Dialog.addRadioButtonGroup("2) Open:",itemsOpen,1,2,"Virtual");
		Dialog.addMessage("3) Click OK, then select a foloder containing serial images.");
	Dialog.show();

	pixelsize = Dialog.getNumber();
	openRadioButton = Dialog.getRadioButton();			// 1x2 [Virtual], Load to RAM

openDir = getDirectory("Choose a Directory"); 	//Open folder. 連続画像のフォルダを開く。注意、フォルダ内にテキストファイルなどが混入していないこと。
	list = getFileList(openDir);			//Get list. 配列listを取得、連続画像のファイル名一覧と、ゼロから始まる通し番号
				//Array.show(list); //Show list. ファイルリストを表としてしめす。Array.print(X);なら、Logウィンドウにテキストとしてしめされる。不要にした。
				
				
//Open virtual or load to RAM　
	if (openRadioButton == "Virtual"){
	File.openSequence(openDir, "virtual");
	}else{
	File.openSequence(openDir);
	}
	
	serialimgID = getImageID(); //Doesn't work for serial image
	
	//open(openDir+list[0]);		//Open first image. 一枚目を開いて、フォルダ名とアドレス、画像サイズを求める
	namePath = getInfo("image.directory");	//Get address. アドレス情報を取得し、
	nameDir = File.getParent(namePath);	//Get address without folder. アドレス、格納フォルダを除く。
	nameFolder = File.getName(namePath);	//Get only folder name. 格納フォルダのみ
	widthSerial=getWidth();		//Get Width. 連続画像のサイズ
	heightSerial=getHeight();		//Get Height. 連続画像のサイズ
	//close();

	//Show image info on Log window. Logに情報を表示する
	print("===================");
	print("Serial images");
	print("   Directory : ", nameDir);
	print("   Folder : ", "/", nameFolder);
	print("   Number of images : ", list.length);
	print("   Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
	print("   Pixel size :", pixelsize, " um/pixel");



//// Select Validated Log file, and open, 修正Logファイルを選択   ////////////////////////////////////
	/*
	//Select Log version
	showMessage("Open Validated Log File","Select validated log text file");
	TEXTpath = File.openDialog("Select a Log File");
	open(TEXTpath); // open the file
	TEXTdir = File.getParent(TEXTpath);
	TEXTname = File.getName(TEXTpath);
	print("----------------------");
	print("Log file for IS_Log_Applier");  
	print("  Name:", TEXTname);
	print("  Directory:", TEXTdir);
	*/
	
	//Copy Log version
	showMessage("Import Validated Log File","1: Open validated log text file with TextEdit.app (Mac), notepad.exe (Win).\n \n2: Select all, and Copy all values\n \n3: Then, come back to FIJI/ImageJ and click OK in this window."); 
	run("System Clipboard");

	print("Log file for IS_Log_Applier");  
	print("   Name: (memorize manually)");
	print("   Directory: (memorize manually)");


////  Settings for Crop and Save 設定用ダイアログ   //////////////////////////////////////////////////

	//Set Values
	crop1X = "";
	crop1Y = "";
	crop1W = "";
	crop1H = "";
	crop2X = "";
	crop2Y = "";
	crop2W = "";
	crop2H = "";

Dialog.create("Settings");
	
	//Crop1
	itemsCrop1 = newArray("Rectangle","Values","Skip");
	Dialog.addRadioButtonGroup("=== Crop1 ============",itemsCrop1,1,3,"Rectangle");
	Dialog.addMessage("   In case of previous values");
  		Dialog.addNumber("         X :",crop1X);
  		Dialog.addNumber("         Y :",crop1Y);
  		Dialog.addNumber("         H :",crop1W);
 		Dialog.addNumber("         W :",crop1H);
 	//Crop1 save
	itemsCrop1save = newArray("Yes","No need");
	Dialog.addRadioButtonGroup("     Save after Crop1",itemsCrop1save,1,2,"No need");

	//IS
	itemsIS = newArray("Stabilize","Skip");
	Dialog.addRadioButtonGroup("=== Image Stabilizer Log Applier ===",itemsIS,1,2,"Stabilize");
	// IS save
	itemsISsave = newArray("Yes","No need");
	Dialog.addRadioButtonGroup("     Save after Image Stabilizer: ",itemsISsave,1,2,"No need");

	//Crop2
	itemsCrop2 = newArray("Rectangle","Values","Skip");
	Dialog.addRadioButtonGroup("=== Crop2 ============",itemsCrop2,1,3,"Rectangle");
	Dialog.addMessage("In case of previous values");
  		Dialog.addNumber("         X :",crop2X);
  		Dialog.addNumber("         Y :",crop2Y);
  		Dialog.addNumber("         H :",crop2W);
 		Dialog.addNumber("         W :",crop2H);
 	//Crop2 save
	itemsCrop2save = newArray("Yes","No need");
	Dialog.addRadioButtonGroup("     Save after Crop2",itemsCrop2save,1,2,"Yes");
	
	//Grayscale
	itemsGray = newArray("Yes","No need");
	Dialog.addRadioButtonGroup("=== Grayscale =========",itemsGray,1,2,"Yes");
	
Dialog.show();

//Get Valiables

	crop1RadioButton = Dialog.getRadioButton();			// 1x3	[Rectandle], Values, Skip
	crop1X = Dialog.getNumber();
	crop1Y = Dialog.getNumber();
	crop1W = Dialog.getNumber();
	crop1H = Dialog.getNumber();
	crop1saveRadioButton = Dialog.getRadioButton(); 	// 1x2	Save, [No need]
	ISRadioButton = Dialog.getRadioButton();			// 1x2	Stabilize, [No need]
	ISsaveRadioButton = Dialog.getRadioButton();		// 1x2	Save, [No need]
	crop2RadioButton = Dialog.getRadioButton();			// 1x3 [Rectandle], Values, Skip
	crop2X = Dialog.getNumber();
	crop2Y = Dialog.getNumber();
	crop2W = Dialog.getNumber();
	crop2H = Dialog.getNumber();
	crop2saveRadioButton = Dialog.getRadioButton();		// 1x2 [Save], No need
	graysaveRadioButton = Dialog.getRadioButton();		// 1x2 [Save], No need
	
	
////  Set Dir valiables  ///////////////////////////////////////////////////////
	
////  saveDir variable after Crop1, 1 pattern

	saveDir_Crop1 = nameDir+"/"+nameFolder+"_Crop1";
	
////  saveDir variable after IS, 2 pattern

	if(crop1RadioButton == "Skip"){ 
	saveDir_IS = nameDir+"/"+nameFolder+"_IS";
	}
	
	if(crop1RadioButton != "Skip"){ 
	saveDir_IS = nameDir+"/"+nameFolder+"_Crop1_IS";
	}

////   saveDir variable after Crop2, 4 pattern

	if(crop1RadioButton == "Skip"){ 
		if(ISRadioButton == "Skip"){
		saveDir_Crop2 = nameDir+"/"+nameFolder+"_Crop2";
		}
	}
	
	if(crop1RadioButton == "Skip"){
		if(ISRadioButton != "Skip"){
		saveDir_Crop2 = nameDir+"/"+nameFolder+"_IS_Crop2";
		}
	}
	
	if(crop1RadioButton != "Skip"){
		if(ISRadioButton == "Skip"){
		saveDir_Crop2 = nameDir+"/"+nameFolder+"_Crop1_Crop2";
		}
	}

	if(crop1RadioButton != "Skip"){
		if(ISRadioButton != "Skip"){
		saveDir_Crop2 = nameDir+"/"+nameFolder+"_Crop1_IS_Crop2";
		}
	}

////   saveDir variable after Grayscale, 8 pattern

	if(crop1RadioButton == "Skip"){ 
		if(ISRadioButton == "Skip"){
			if(crop2RadioButton == "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Gray";
			}
		}
	}
	
	if(crop1RadioButton == "Skip"){ 
		if(ISRadioButton == "Skip"){
			if(crop2RadioButton != "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Crop2_Gray";
			}
		}
	}
	
	
	if(crop1RadioButton == "Skip"){ 
		if(ISRadioButton != "Skip"){
			if(crop2RadioButton == "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_IS_Gray";
			}
		}
	}
	
	if(crop1RadioButton != "Skip"){ 
		if(ISRadioButton == "Skip"){
			if(crop2RadioButton == "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Crop1_Gray";
			}
		}
	}
	
	if(crop1RadioButton == "Skip"){ 
		if(ISRadioButton != "Skip"){
			if(crop2RadioButton != "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_IS_Crop2_Gray";
			}
		}
	}
	
	if(crop1RadioButton != "Skip"){ 
		if(ISRadioButton != "Skip"){
			if(crop2RadioButton == "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Crop1_IS_Gray";
			}
		}
	}
	
	if(crop1RadioButton != "Skip"){ 
		if(ISRadioButton == "Skip"){
			if(crop2RadioButton != "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Crop1_Crop2_Gray";
			}
		}
	}
	
	if(crop1RadioButton != "Skip"){ 
		if(ISRadioButton != "Skip"){
			if(crop2RadioButton != "Skip"){
				saveDir_Gray = nameDir+"/"+nameFolder+"_Crop1_IS_Crop2_Gray";
			}
		}
	}

//// saved folder names, for print function

	namesaveFolder_Crop1 = File.getName(saveDir_Crop1);
	namesaveFolder_IS = File.getName(saveDir_IS);
	namesaveFolder_Crop2 = File.getName(saveDir_Crop2);
	namesaveFolder_Gray = File.getName(saveDir_Gray);


////  Crop1   //////////////////////////////////////////////////
// Variables to be used: 
//		crop1RadioButton		// 1x3	[Rectandle], Values, Skip
//		crop1X
//		crop1Y
//		crop1W
//		crop1H
//		crop1saveRadioButton  // 1x2	Yes, [No need]

print("--- Crop1 ---");
	
if(crop1RadioButton == "Rectangle"){

	//Dialog, wait for drawing rectancle 描くのをまつダイアログ。
		setTool("rectangle");
		title = "=== Crop1 ===";
		msg = "1. Draw a rectangle larger than the sample.\n  2. Browse serial image, and adjust the rectangle size.\n  3. Then, Click \"OK\" to run 'Crop'.";
		waitForUser(title, msg);
	//Get info and Crop 情報を得てからクロップ
		getSelectionBounds(crop1X, crop1Y, crop1W, crop1H);
		run("Crop");
	//Print info　情報を記載
		print("   Mode: Draw a Rectangle");
		print("   X :", crop1X);
		print("   Y :", crop1Y);
		print("   W :", crop1W);
		print("   H :", crop1H);
	
	if(crop1saveRadioButton == "Yes"){
	
		File.makeDirectory(saveDir_Crop1);
		run("Image Sequence... ", "dir=&saveDir_Crop1 format=JPEG use");
		print("   Save :");
		print("      ",namesaveFolder_Crop1);
	
	}
	
}

if(crop1RadioButton == "Values"){
	
	// Draw Rectangle from input values.
		makeRectangle(crop1X, crop1Y, crop1W, crop1H);
		run("Crop");
	//Print info　情報を記載
		print("   Mode: Use input values");
		print("   X :", crop1X);
		print("   Y :", crop1Y);
		print("   W :", crop1W);
		print("   H :", crop1H);	
	
	if(crop1saveRadioButton == "Yes"){
	
		File.makeDirectory(saveDir_Crop1);
		run("Image Sequence... ", "dir=&saveDir_Crop1 format=JPEG use");
		print("   Save :");
		print("      ",namesaveFolder_Crop1);
	}
}

if(crop1RadioButton == "Skip"){ 
	print("   Skip.");
	print("   No need to save.");
	
	if(openRadioButton == "Virtual"){     //Virtual stack should be loaded into RAM before ImgStab 
		
		makeRectangle(0, 0, widthSerial, heightSerial);
		run("Crop");	
		
	}
}

////  Image Stabilizer Log Applier   /////////////////////////////////////////////
// Variables to be used: 
//	Main
//		ISRadioButton 			// 1x2	[Stabilize], No need
//		ISsaveRadioButton 		// 1x2	Yes, [No need]
//	Sub
//		crop1saveRadioButton 	// 1x2	Yes, [No need]

print("--- Image Stabilizer Log Applier ---");

if(ISRadioButton == "Stabilize"){

	//IS Applier Start 開始時刻を記載
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print("  Start : ",hour,":", minute,",", second);
		run("Image Stabilizer Log Applier", " ");
	//IS Applier End  終了時刻を記載
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print("  End : ",hour,":", minute,",", second);
	
	if(ISsaveRadioButton == "Yes"){
		
		File.makeDirectory(saveDir_IS);
		run("Image Sequence... ", "dir=&saveDir_IS format=JPEG use");
		print("   Save :");
		print("      ",namesaveFolder_IS);
		
	}else{
		print("   No need to save.");
	}
	
}

if(ISRadioButton == "Skip"){
	
	print("   Skip");
	print("   No need to save.");
	
}


////  Crop2   //////////////////////////////////////////////////
// Variables to be used: 
//	Main
//		crop2RadioButton		// 1x3	[Rectandle], Values, Skip
//		crop2X
//		crop2Y
//		crop2W
//		crop2H
//		crop2saveRadioButton  // 1x2	Save, [No need]
//	Sub
//		crop1RadioButton 
//		ISRadioButton

print("--- Crop2 ---");	

//Rectangle by drawing
if(crop2RadioButton == "Rectangle"){

	//Dialog, wait for drawing rectancle 描くのをまつダイアログ。
		setTool("rectangle");
		title = "=== Crop2 ===";
		msg = "1. Draw a rectangle fitting the sample.\n  2. Browse serial image, and adjust the rectangle size.\n  3. Then, Click \"OK\" to run 'Crop'.";
		waitForUser(title, msg);
	//Get info and Crop 情報を得てからクロップ
		getSelectionBounds(crop2X, crop2Y, crop2W, crop2H);
		run("Crop");
	//Print info　情報を記載
		print("   Mode: Draw a Rectangle");
		print("   X :", crop2X);
		print("   Y :", crop2Y);
		print("   W :", crop2W);
		print("   H :", crop2H);
	
	if(crop2saveRadioButton == "Yes"){
	
		File.makeDirectory(saveDir_Crop2);
		run("Image Sequence... ", "dir=&saveDir_Crop2 format=JPEG use");
		print("   Save :");
		print("      ",namesaveFolder_Crop2);
	
	}else{
		print("   No need to save.");
	}
}

//Rectangle by values
if(crop2RadioButton == "Values"){

	// Draw Rectangle from input values.
		makeRectangle(crop2X, crop2Y, crop2W, crop2H);
		run("Crop");
	//Print info　情報を記載
		print("   Mode: Use input values");
		print("   X :", crop2X);
		print("   Y :", crop2Y);
		print("   W :", crop2W);
		print("   H :", crop2H);	
	
	if(crop2saveRadioButton == "Yes"){
	
		File.makeDirectory(saveDir_Crop2);
		run("Image Sequence... ", "dir=&saveDir_Crop2 format=JPEG use");
		print("   Save :");
		print("      ",namesaveFolder_Crop2);
	
	}else{
		print("   No need to save.");
	}
} 

//Skip crop2
if(crop2RadioButton == "Skip"){
	
	print("   Skip.");
	print("   No need to save.");
	
}

////  Grayscale   //////////////////////////////////////////////////
// Variables to be used:
//	Main
//		graysaveRadioButton
//	Sub
//		crop2RadioButton		// 1x3	[Rectandle], Values, Skip
//		crop1RadioButton 
//		ISRadioButton

print("--- Grayscale ---");	
	
if(graysaveRadioButton == "Yes"){
	
	run("8-bit");
	run("Invert", "stack");
	
	File.makeDirectory(saveDir_Gray);
	run("Image Sequence... ", "dir=&saveDir_Gray format=JPEG use");
	print("   Save :");
	print("      ",namesaveFolder_Gray);

}else{
		print("   No need to save.");
}



////  Close windows   //////////////////////////////////////////////////

selectWindow(nameFolder);
close();

/*
//Select Log version
selectWindow(TEXTname);
*/

//Copy Log version
selectWindow("Clipboard");

run("Close");


////  Save log as text. 作業ログを保存   /////////////////////////////////

print("===================");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("End at");
print("Date: ",year,".",month+1,".",dayOfMonth, ", Time: ",hour,":", minute,",", second);
nameEndTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("===================");
print("Examples to reuse rectangle values: ");
print("-----");
print(pixelsize, " um/pixel (Used for this process)");
print("Crop1 : ");
	print("   X :", crop1X);
	print("   Y :", crop1Y);
	print("   W :", crop1W);
	print("   H :", crop1H);
print("Crop2 : ");
	print("   X :", crop2X);
	print("   Y :", crop2Y);
	print("   W :", crop2W);
	print("   H :", crop2H);
	
print("-----");
print(pixelsize/2, " um/pixel (2x)");
print("Crop1 : ");
	print("   X :", crop1X*2);
	print("   Y :", crop1Y*2);
	print("   W :", crop1W*2);
	print("   H :", crop1H*2);
print("Crop2 : ");
	print("   X :", crop2X*2);
	print("   Y :", crop2Y*2);
	print("   W :", crop2W*2);
	print("   H :", crop2H*2);
	
print("-----");
print(pixelsize/4, " um/pixel (4x)");
print("Crop1 : ");
	print("   X :", crop1X*4);
	print("   Y :", crop1Y*4);
	print("   W :", crop1W*4);
	print("   H :", crop1H*4);
print("Crop2 : ");
	print("   X :", crop2X*4);
	print("   Y :", crop2Y*4);
	print("   W :", crop2W*4);
	print("   H :", crop2H*4);
print("===================");

selectWindow("Log");
saveAs("Text", nameDir+"/"+nameFolder+"_CropISCrop_"+nameEndTime+".txt");
wait(1000);
print("\\Clear");

beep();
wait(100);
beep();


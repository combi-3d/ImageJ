//ImageJ macro CoMBI_Crop1_ISApplier_Crop2.ijm (c)Yuki Tajika, 2022.6.23 CC-BY-NC
//
//The macro runs Crop1, IS Applier, Crop2 again, and Save
// For small image series which was used for IS.

// 1. Crop by a rectangle drawn manually.
// 2. Save crop values (x, y, Height, Width) in a work log, to reuse later for processing larger image series.
// 3. Images to be saved: [default]
//     _Crop1          [false]
//     _Crop1_IS       [false]
//     _Crop1_IS_Crop2 [true]
//
// For FIJI on Intel Mac 2022.6. To import Log file, open it by other text editor app and Copy. Values will be pasted on Clipboard.
// Not for M1 Mac ImageJ1.53s 2022.6


//// Begin work log. 作業記録を開始
	print("===================");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("[Crop1 > IS Applier > Crop2 > Save]   ImageJ macro: CoMBI_Crop1_ISApplier_Crop2.ijm");
	print("Date: ",year,".",month+1,".",dayOfMonth, ", Time: ",hour,":", minute,",", second);
	nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);

//// Select a folder containing serial images, 連続画像のフォルダを選択   ////////////////////////////////////

Dialog.create("Select serial image");

	pixelsize  = ""

	Dialog.addMessage("1) Input pixel size of serial images");
	Dialog.addNumber("         (µm/pixel) ", pixelsize);
	Dialog.addMessage("2) Click OK to select a foloder containing serial images.");
	Dialog.show();

	pixelsize = Dialog.getNumber();

openDir = getDirectory("Choose a Directory"); 	//Open folder. 連続画像のフォルダを開く。注意、フォルダ内にテキストファイルなどが混入していないこと。
	list = getFileList(openDir);			//Get list. 配列listを取得、連続画像のファイル名一覧と、ゼロから始まる通し番号
				//Array.show(list); //Show list. ファイルリストを表としてしめす。Array.print(X);なら、Logウィンドウにテキストとしてしめされる。不要にした。


	open(openDir+list[0]);		//Open first image. 一枚目を開いて、フォルダ名とアドレス、画像サイズを求める
	namePath = getInfo("image.directory");	//Get address. アドレス情報を取得し、
	nameDir = File.getParent(namePath);	//Get address without folder. アドレス、格納フォルダを除く。
	nameFolder = File.getName(namePath);	//Get only folder name. 格納フォルダのみ
	widthSerial=getWidth();		//Get Width. 連続画像のサイズ
	heightSerial=getHeight();		//Get Height. 連続画像のサイズ
	close();
	wait(200)

	//Show image info on Log window. Logに情報を表示する
	print("---------------");
	print("Serial images");
	print("   Directory : ", nameDir);
	print("   Folder : ", "/", nameFolder);
	print("   Number of images : ", list.length);
	print("   Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
	print("   Pixel size :", pixelsize, " µm/pixel")
	
	//Open 開く とりあえずvirtualでいいか。
	File.openSequence(openDir, "virtual");
	IDOriginal = getImageID();
	
	
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
	showMessage("Import Validated Log File","1: Open validated log text file with TextEdit.app (Mac), notepad.exe (Win), etc.\n \n2: Select all, and Copy all values\n \n3: Then, come back to FIJI/ImageJ and click OK in this window."); 
	run("System Clipboard");
	print("----------------------");
	print("Log file for IS_Log_Applier");  
	print("  Name: (memorize manually, pls)");
	print("  Directory: (memorize manually, pls)");


////  Settings for Crop and Save ダイアログで設定する   //////////////////////////////////////////////////

	//Set Values
	crop1X = "";
	crop1Y = "";
	crop1W =  "";
	crop1H = "";
	crop2X =  "";
	crop2Y = "";
	crop2W = "";
	crop2H = "";

Dialog.create("Settings");
	//Crop1
	Dialog.addMessage("==== Crop1 ==============");
	itemsCrop1 = newArray("Draw a Rectangle","Use Previous Values", "Skip Crop1");
	Dialog.addRadioButtonGroup("",itemsCrop1,3,1,"Draw a Rectangle");
	Dialog.addMessage("In case of previous values");
  		Dialog.addNumber("         X :",crop1X);
  		Dialog.addNumber("         Y :",crop1Y);
  		Dialog.addNumber("         H :",crop1W);
 		Dialog.addNumber("         W :",crop1H);
 	//Crop1 save
	itemsCrop1Save = newArray("No need to save","Save as '_Crop1'");
	Dialog.addRadioButtonGroup("",itemsCrop1Save,1,2,"No need to save");

	//IS save
	Dialog.addMessage("=== Image Stabilizer Log Applier ===");
	Dialog.addMessage("Runs automatically.");
	itemsISSave = newArray("No need to save","Save as '_Crop1_ISvalid'");
	Dialog.addRadioButtonGroup("",itemsISSave,1,2,"No need to save");

	//Crop2
	Dialog.addMessage("==== Crop2 ==============");
	itemsCrop2 = newArray("Draw a Rectangle","Use Previous Values", "Skip Crop2");
	Dialog.addRadioButtonGroup("",itemsCrop2,3,1,"Draw a Rectangle");
	Dialog.addMessage("In case of previous values");
		  Dialog.addNumber("         X :", crop2X);
		  Dialog.addNumber("         Y :",crop2Y);
		  Dialog.addNumber("         H :", crop2W);
		  Dialog.addNumber("         W :",crop2H);
	Dialog.addMessage("Save as '_Crop1_ISvalid_Crop2', automatically ");
Dialog.show();

//Get Valuables
	//Crop1
	crop1RadioButton = Dialog.getRadioButton();
	crop1X = Dialog.getNumber();
	crop1Y = Dialog.getNumber();
	crop1W = Dialog.getNumber();
	crop1H = Dialog.getNumber();
	crop1SaveRadioButton = Dialog.getRadioButton();
	//Values IS
	ISSaveRadioButton = Dialog.getRadioButton();
	//Values Crop2
	crop2RadioButton = Dialog.getRadioButton();
	crop2X = Dialog.getNumber();
	crop2Y = Dialog.getNumber();
	crop2W = Dialog.getNumber();
	crop2H = Dialog.getNumber();
	
	

////   Crop1   ///////////////////////////////////////////////////////////////////////

//IF Draw a Rectangle   Rectangleを描いてから、Logに記録
if(crop1RadioButton == "Draw a Rectangle"){
	
	//描くのをまつダイアログ。
		setTool("rectangle");
		title = "Waiting for...";
		msg = "=== Draw a Rectangle for Crop1. ===\n  1. Do not draw it a perfect fit. Only to reduce data size.\n  2. Browse serial image.\n  3. Adjust rectangle to cover the specimen.\n  4. Click \"OK\" to run 'Crop'.";
		waitForUser(title, msg);
	//Crop情報を得から、Crop実行
		getSelectionBounds(crop1X, crop1Y, crop1W, crop1H);
		run("Crop");
	//LogにRectangle情報を記録
		print("----------------------");
	   	print("Crop1");
		print("   Mode: Draw a Rectangle");
		print("   X :", crop1X);
		print("   Y :", crop1Y);
		print("   W :", crop1W);
		print("   H :", crop1H);


	// もし、保存するにチェックがあれば、フォルダをつくって保存する。閉じはしない。（デフォルトでは保存しない）
	if(crop1SaveRadioButton == "Save as '_Crop1'"){
		crop1Dir=nameDir+"/"+nameFolder+"_Crop1";
		File.makeDirectory(crop1Dir);
		run("Image Sequence... ", "dir=&crop1Dir format=JPEG use");
		//Logに保存情報を記録
		print("----------------------");
		print("Save Crop1 as");		
		print("   Folder : ",nameFolder,"_Crop1");
	}
}

//IF Use previous values   値を入力した場合
if(crop1RadioButton == "Use Previous Values"){
	//入力値を記録する
	print("----------------------");
	print("Crop1");
	print("   Mode: Use Previous values");
	print("   X :", crop1X);
	print("   Y :", crop1Y);
	print("   W :", crop1W);
	print("   H :", crop1H);

    //Rectangleを値で描き、Crop実行
    drawRect(crop1X, crop1Y, crop1W, crop1H);
    run("Crop");
    
	// もし、保存するにチェックがあれば、フォルダをつくって保存する。閉じはしない。（デフォルトでは保存しない）
	if(crop1SaveRadioButton == "Save as '_Crop1'"){
		crop1Dir=nameDir+"/"+nameFolder+"_Crop1";
		File.makeDirectory(crop1Dir);
		run("Image Sequence... ", "dir=&cropDir format=JPEG use");
		//Logに保存情報を記録
		print("----------------------");
		print("Save Crop1 as");
		print("   Folder : ",nameFolder,"_Crop1");
	}
}

////   Image Stabilize Log Applier   //////////////////////////////////////////////////////////////////

//IS Applier Start 開始時刻を記載
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("----------------------");
	print("IS_Log_Applier");
	print("  Start : ",hour,":", minute,",", second);

	run("Image Stabilizer Log Applier", " ");

//IS Applier End  終了時刻を記載
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("  End : ",hour,":", minute,",", second);
	print("----------------------");
	print("Stabilized Serial Images");
	print("  Folder : ",nameFolder,"_ISvalid");
	print("  Directory : ", nameDir);

//Close Log file ログファイルをかたづける
/*
	selectWindow(TEXTname); //Select Log Version
*/
	selectWindow("Clipboard"); //Copy Log Version
	run("Close");

//Save serial images afrer IS_Applier. ズレ補正した連続画像を保存して閉じる
	selectWindow(nameFolder); //Make sure
	if (ISSaveRadioButton == "Save as '_Crop1_ISvalid'"){ //保存するなら、_Crop1_ISvalid　または　_ISvalid
		if (crop1RadioButton == "Skip Crop1"){
		nameDirIS = nameDir+"/"+nameFolder+"_ISvalid";
		File.makeDirectory(nameDirIS);
		run("Image Sequence... ", "dir=&nameDirIS format=JPEG use");
		}else{
		nameDirIS = nameDir+"/"+nameFolder+"_Crop1_ISvalid";
		File.makeDirectory(nameDirIS);
		run("Image Sequence... ", "dir=&nameDirIS format=JPEG use");
		}
	}


////   Crop2   ///////////////////////////////////////////////////////////////////////

if(crop2RadioButton == "Draw a Rectangle"){
	
	//描くのをまつダイアログ。
		setTool("rectangle");
		title = "Waiting for...";
		msg = "=== Draw a Rectangle for Crop2 ===\n  1. Draw it a perfect fit. Reduce data size as possible.\n  2. Browse serial image.\n  3. Adjust rectangle to cover the specimen.\n  4. Click \"OK\" to run 'Crop'.";
		waitForUser(title, msg);
	//Crop情報を得から、Crop実行
		getSelectionBounds(crop2X, crop2Y, crop2W, crop2H);
		run("Crop");
	//LogにRectangle情報を記録
		print("----------------------");
	   	print("Crop2");
		print("   Mode: Draw a Rectangle");
		print("   X :", crop2X);
		print("   Y :", crop2Y);
		print("   W :", crop2W);
		print("   H :", crop2H);
}

//IF Use previous values   値を入力した場合
if(crop1RadioButton == "Use Previous Values"){
	//入力値を記録する
	print("----------------------");
	print("Crop1");
	print("   Mode: Use Previous values");
	print("   X :", crop1X);
	print("   Y :", crop1Y);
	print("   W :", crop1W);
	print("   H :", crop1H);

    //Rectangleを値で描き、Crop実行
    drawRect(crop1X, crop1Y, crop1W, crop1H);
    run("Crop");
}

// 保存する。Crop2のあとは、保存。Crop1の有無で2通り、_Crop1_ISvalid_Crop2　または　_ISvalid_Crop2
if (crop1RadioButton == "Skip Crop1"){
	crop2Dir=nameDir+"/"+nameFolder+"_ISvalid_Crop2";
	File.makeDirectory(crop2Dir);
	run("Image Sequence... ", "dir=&cropDir format=JPEG use");
	//Logに保存情報を記録
	print("----------------------");
	print("Save Crop2 as");		
	print("   Folder : ",nameFolder,"_ISvalid_Crop2");
}else{
	crop2Dir=nameDir+"/"+nameFolder+"_Crop1_ISvalid_Crop2";
	File.makeDirectory(crop2Dir);
	run("Image Sequence... ", "dir=&crop2Dir format=JPEG use");
	//Logに保存情報を記録
	print("----------------------");
	print("Save Crop2 as");		
	print("   Folder : ",nameFolder,"_Crop1_ISvalid_Crop2");
}

selectWindow(nameFolder); //Make sure
close();

print("===================");

//Save log as text. 作業ログを保存

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("End at");
print("Date: ",year,".",month+1,".",dayOfMonth, ", Time: ",hour,":", minute,",", second);
nameEndTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("===================");
print("Examples to reuse rectangle values: ");
print("-----");
print(pixelsize, " µm/pixel (This processing)");
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
print(pixelsize/2, " µm/pixel (2x)");
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
print(pixelsize/4, " µm/pixel (4x)");
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
wait(1500);
print("\\Clear");

beep();
wait(100);
beep();


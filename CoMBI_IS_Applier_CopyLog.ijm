//==============================================
// ”CoMBI_IS_Applier_CopyLog.ijm" (c) Yuki Tajika 2022.6.22 CC-BY-NC
// Velidfied on iMac2017 intel, FIJI 2.3.0/ImageJ 1.53q for intel mac, 2022
//==============================================
//Prepararion
// Open validated log text file with TextEdit.app (Mac).
// Select all (Command+a), Copy (Command+c) to keep value system clipboard.
//------------
// Then, Run automatically
	// File>New>System clipboard. to reveal values in FIJI/ImageJ
	// Open sequence images on system memory. NOT virtual stack as IS supports virtual stack "partially".
	// Run plugin: Image_Stabilizer_Log_Applier
	// Save as Image Sequence in new folder with _IS_Validated
	// Close images and log.
//==============================================

//Begin work log. 作業記録を開始
print("===================");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Image Stabilizer Log Applier, ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);
nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("----------------------");

//Open log file, 補正Logの値をひらく

//Copy Log version
  showMessage("Import Validated Log File","1: Open validated log text file with TextEdit.app (Mac), notepad.exe (Win), etc.\n \n2: Select all, and Copy all values\n \n3: Then, come back to FIJI/ImageJ and click OK in this window."); 
  run("System Clipboard");

  print("Log file for IS_Log_Applier");  
  print("  Name: (memorize manually, pls)");
  print("  Directory: (memorize manually, pls)");
  print("----------------------");

//Open serial image 連続画像をひらく
//フォルダを選んで情報をえる
showMessage("Select serial images","1) Make sure that validated values are ready in the 'Clipboard' window. \n \n2) Click 'OK' to select a folder containing serial images.\n \nThen, followings will run automatically.\n \n   *Image Stabilier Log Applier with validated values\n   *Save in a new folder '_IS_Validated'\n   *Close"); 
openDir = getDirectory("Choose a Directory"); 	//Open folder. 連続画像のフォルダを開く。注意、フォルダ内にテキストファイルなどが混入していないこと。
list = getFileList(openDir);			//Get list. 配列listを取得、連続画像のファイル名一覧と、ゼロから始まる通し番号
//連続画像をひらいて、情報を得る
File.openSequence(openDir);
	//This command requires 1.53p or newer. Does NOT work on ImageJ for mac 1.53k (latest in 2022.6). 

IDOriginal = getImageID();
namePath = getInfo("image.directory");	//Get address. アドレス情報を取得し、
nameDir = File.getParent(namePath);	//Get address without folder. アドレス、格納フォルダを除く。
nameFolder = File.getName(namePath);	//Get only folder name. 格納フォルダのみ
widthSerial=getWidth();		//Get Width. 連続画像のサイズ
heightSerial=getHeight();		//Get Height. 連続画像のサイズ

//Show image info on Log window. Logに情報を表示する
print("Serial Images");
print("  Folder : ", "/", nameFolder);
print("  Directory : ", nameDir);
print("  Number of images : ", list.length);
print("  Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
print("----------------------");

//IS Applierの開始時刻を記載
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("IS_Log_Applier");
print("  Start : ",hour,":", minute,",", second);

run("Image Stabilizer Log Applier", " ");

//IS Applierの終了。時刻を記載
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("  End : ",hour,":", minute,",", second);
print("----------------------");
print("Stabilized Serial Images");
print("  Folder : ",nameFolder,"_IS_Validated");
print("  Directory : ", nameDir);

//Save serial images afrer IS_Applier. ズレ補正した連続画像を保存して閉じる
selectWindow(nameFolder); //Make sure
nameDirISF = nameDir+"/"+nameFolder+"_IS_Validated";
File.makeDirectory(nameDirISF);
run("Image Sequence... ", "dir=&nameDirISF format=JPEG use");
close();

selectWindow("Clipboard");
run("Close");

print("===================");

//Save log as text. 作業ログを保存
selectWindow("Log");
saveAs("Text", nameDir+"/"+nameFolder+"_ImageStabilizer_Log_"+nameAddTime+".txt");
wait(1500);
print("\\Clear");

beep();
wait(100);
beep();


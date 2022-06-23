/* CoMBI_ImageStabilizer_2x.ijm, (c) Yuki Tajika, 2022.6.11, CC BY-NC

An ImageJ macro for registration of serial images acquired by CoMBI.
Version 1x1 (One by One) runs registration step by step; register forward, check success and failure, register backward and check success and failure.
Version 2x (Both 2 directions) runs registration forward then backward automatically.
The macro created and verified using ImageJ 1.53s for macOS/ARM on macOS12.4, FIJI/ImageJ2.3.0/1.53q on macOS12.4.

Setting up :  (2022.6)
   Use ImageJ 1.53p or newer. 
   For Apple silicon mac, use latest ImageJ_ARM (1.53s) or latest FIJI/mac (2.3.0/1.53q)
   For Intel mac, use only latest FIJI/mac (2.3.0/1.53q). Do not use ImageJ/Intel mac, bacause it is still 1.53k.
   Place this ijm file in ImageJ/plugins folder (Not macros folder), and a shortcut will be found in Menubar>plugins. 

Data Preparation:
   "a folder containing serial image".

Run Macro "CoMBI_ImageStabilizer_2x.ijm"
   1. Select items to be saved.
   2. Select a folder containing serial image.
      a. Run plugin; Image Registration. From first to last image (Forward).
      b. Save log (essential), and images (optional)
      c. Run plugin; Image Registration. From last to first image (Backward).
      d. Save log (essential), and images (optional)
 
*/

//Begin work log. 作業記録を開始
print("===================");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Image Stabilizer, ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);
nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("----------------------");

//Select and Open serial image 連続画像

Dialog.create("Image Stabilizer 2x");
	Dialog.addMessage("1) Select items to be saved : ");
	items = newArray("Log Files Only","Log Files and Stabilized Serial Images");
	Dialog.addRadioButtonGroup("",items,2,1,"Log Files Only");
	Dialog.addMessage("2) Click 'OK' to run followings : ");
	Dialog.addMessage("   a) Select a folder containing serial images to be registrated.");
	Dialog.addMessage("   b) Then, automatically run 'Image Registration' both forward and backward.");
	Dialog.addMessage("      *Translation only\n      *Log transformation coefficients\n      *Output to a new stack");
	Dialog.addMessage("   c) Save log files(transformation coefficients)");
	Dialog.addMessage("   d) Save stabilized serial Images (option)");
Dialog.show();
selectRadioButton = Dialog.getRadioButton();

//Select folder フォルダを選んでリスト情報を得る
	openDir = getDirectory("Choose a Directory"); 	//Open folder. 連続画像のフォルダを開く。注意、フォルダ内にテキストファイルなどが混入していないこと。
	list = getFileList(openDir);			//Get list. 配列listを取得、連続画像のファイル名一覧と、ゼロから始まる通し番号
//Open and get info 連続画像をひらいて、情報を得る
	File.openSequence(openDir);
	//This command requires 1.53p or newer. Does NOT work on ImageJ for mac 1.53k (latest in 2022.6). 
	IDOriginal = getImageID();
	namePath = getInfo("image.directory");	//Get address. アドレス情報を取得し、
	nameDir = File.getParent(namePath);	//Get address without folder. アドレス、格納フォルダを除く。
	nameFolder = File.getName(namePath);	//Get only folder name. 格納フォルダのみ
	widthSerial=getWidth();		//Get Width. 連続画像のサイズ
	heightSerial=getHeight();		//Get Height. 連続画像のサイズ

//Show image info on Log window. Logに情報を表示する
	print("Directory : ", nameDir);
	print("Folder : ", "/", nameFolder);
	print("Number of images : ", list.length);
	print("Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
	print("----------------------");

//Run Plugin_Image Stablizer (Forward) ズレ補正を前から実行
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("IS_Forward");
	print("Start : ",hour,":", minute,",", second);

	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients output_to_a_new_stack");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("End : ",hour,":", minute,",", second);
	beep();

//Save IS_Forward_log as text
selectWindow(nameFolder+".log");
	saveAs("Text", nameDir+"/"+nameFolder+"_IS_Forward.log");
	run("Close");
	print("Log file : ",nameFolder,"_IS_Log_Forward.txt");

//Sace serial images afrer IS_Forward. 前からズレ補正した連続画像を保存して閉じる
selectWindow("Stablized "+nameFolder); //Make sure
	if (selectRadioButton == "Log Files and Stabilized Serial Images"){
		nameDirISF = nameDir+"/"+nameFolder+"_IS_Forward";
		File.makeDirectory(nameDirISF);
		run("Image Sequence... ", "dir=&nameDirISF format=JPEG use");
		print("Registered images : ",nameFolder,"_IS_Forward");
	}else{
		print("Registered images were discarded.");
	}
	close();


//Run Plugin_Image Stablizer (Backward) ズレ補正を後から実行
selectWindow(nameFolder); //Make sure
	setSlice(list.length);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(" ");
	print("IS_Backward");
	print("Start : ",hour,":", minute,",", second);

	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients output_to_a_new_stack");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("End : ",hour,":", minute,",", second);
	beep();

//Save IS_Backward_log as text
selectWindow(nameFolder+".log");
	saveAs("Text", nameDir+"/"+nameFolder+"_IS_Backward.log");
	run("Close");
	print("Log file : ",nameFolder,"_IS_Log_Backward.txt");

//Sace serial images afrer IS_Backward. 後ろからズレ補正した連続画像を保存して閉じる
selectWindow("Stablized "+nameFolder); //Make sure
if (selectRadioButton == "Log Files and Stabilized Serial Images"){
	nameDirISB = nameDir+"/"+nameFolder+"_IS_Backward";
	File.makeDirectory(nameDirISB);
	run("Image Sequence... ", "dir=&nameDirISB format=JPEG use");
	print("Registered images : ",nameFolder,"_IS_Backward");
	}else{
	print("Registered images were discarded.");
	}
	close();


//Close original serial images 元画像も閉じる
run("Close All");

//Save log as text. 作業ログを保存
selectWindow("Log");
print("===================");
saveAs("Text", nameDir+"/"+nameFolder+"_ImageStabilizer2x_"+nameAddTime+".txt");
wait(1000);
print("\\Clear");

//Make sound when process ends. 終了の合図。
beep();
wait(100);
beep();
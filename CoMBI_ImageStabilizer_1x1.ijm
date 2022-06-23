/* CoMBI_ImageStabilizer1x1.ijm, (c) Yuki Tajika, 2022.6.11, CC BY-NC

An ImageJ macro for registration of serial images acquired by CoMBI.
Version 1x1 (One by One) runs registration step by step; register forward, check success and failure, register backward and check success and failure.
Version 2x (Both 2 directions) runs registration forward then backward automatically.
The macro created and verified using ImageJ 1.53s for macOS/ARM on macOS12.4, FIJI/ImageJ2.3.0/1.53q on macOS12.4.

Setting up :  (2022.6)
   Use ImageJ 1.53p or newer. 
   For Apple silicon mac, use latest ImageJ_ARM (1.53s) or latest FIJI/mac (2.3.0/1.53q)
   For Intel mac, use only latest FIJI/mac (2.3.0/1.53q). Do not use ImageJ/Intel mac, bacause it is still 1.53k.
   Place this ijm file in ImageJ/plugins folder (Not macros folder), and a shortcut will be found in Menubar>plugins. 

Preparation: 
   "a folder containing serial image"

Macro runs: 
   1. Select a folder containing serial image.
   2. Run plugin; Image Registration. From first to last image (Forward).
   3. [Success Forward] Save images and log, and end macro.
   4. [False Froward] Try again from last to first image (Backward).
   5. [Success Backward] Save images and log, and end macro.
   6. [False Backward] Save log only.
   7. Save work log.

*/

//Begin work log. 作業記録を開始
print("===================");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Image Stabilizer, ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);
nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("----------------------");

//Open serial image 連続ファイルをひらく
//フォルダを選んで情報をえる
showMessage("Select and Register","Select a folder containing serial images to be registrated. \n \nThen, automatically start 'Image Registration' form first to last (Forward).\n \n  *Translation only\n  *Log transformation coefficients\n  *Output to a new stack"); 
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
print("Directory : ", nameDir);
print("Folder : ", "/", nameFolder);
print("Number of images : ", list.length);
print("Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
print("----------------------");

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("IS_Forward");
print("Start : ",hour,":", minute,",", second);

//Plugin-Image Stablizer　ズレ補正を実行
run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients output_to_a_new_stack");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("End : ",hour,":", minute,",", second);
beep();
wait(100);
beep();

//Save log file as text
selectWindow(nameFolder+".log");
saveAs("Text", nameDir+"/"+nameFolder+"_IS_Forward.log");
run("Close");
print("Log file : ",nameFolder,"_IS_Log_Forward.txt");
selectWindow("Stablized "+nameFolder); //Make sure

//Review time
waitForUser("Review result", "Review stablized (registered) images. \n'Cursor key' can review faster than 'Play button' at the left bottom. \nIf misaligned images were found, note the serial number of the image, not the file name.")
selectWindow("Stablized "+nameFolder);  //Make sure

//保存、連続画像

Dialog.create ("Save or discard");
	Dialog.addMessage("Successfull registration > Save Image Sequence!\nMisaligned > Discard and try again from last to first (Backward).");
	Dialog.addChoice("Save or Discard",newArray("Save","Discard"));
Dialog.show();

want2save = Dialog.getChoice();
selectWindow("Stablized "+nameFolder); //Make sure

if(want2save == "Save"){
nameDirIS = nameDir+"/"+nameFolder+"_IS";
File.makeDirectory(nameDirIS);
run("Image Sequence... ", "dir=&nameDirIS format=JPEG use");
print("Registered images : ",nameFolder,"_IS");
print("[Success]");

}else{
	print("[Misaligned]");
	close();
	selectWindow(nameFolder); //Make sure
	setSlice(list.length);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(" ");
	print("IS_Backward");
	print("Start : ",hour,":", minute,",", second);

	//Plugin-Image Stabilizer　ズレ補正を実行
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients output_to_a_new_stack");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("End : ",hour,":", minute,",", second);
	beep();
	wait(100);
	beep();

	//Save log file as text
	selectWindow(nameFolder+".log");
	saveAs("Text", nameDir+"/"+nameFolder+"_IS_Backward.log");
	run("Close");
	print("Log file : ",nameFolder,"_IS_Log_Backward.txt");
	selectWindow("Stablized "+nameFolder); //Make sure
	
	//Review time
	waitForUser("Review result", "Review stabilized (registered) images. \n'Cursor key' can review faster than 'Play button' at the left bottom. \nIf misaligned images were found, note the serial number of the image, not the file name.");
	selectWindow("Stablized "+nameFolder); //Make sure
	
	//保存、連続画像
	Dialog.create ("Save or discard");
		Dialog.addMessage("Successfull registration > Save Image Sequence (^_^)\nMisaligned > Discard and modify 2 log files, manually...(;_;)");
		Dialog.addChoice("Save or Discard",newArray("Save","Discard"));
	Dialog.show();
	
	want2saveB = Dialog.getChoice();
	selectWindow("Stablized "+nameFolder); //Make sure
	
	if(want2saveB == "Save"){
	nameDirIS = nameDir+"/"+nameFolder+"_IS";
	File.makeDirectory(nameDirIS);
	run("Image Sequence... ", "dir=&nameDirIS format=JPEG use");
	print("Registered images : ",nameFolder,"_IS");
	print("[Success]");

	}else{
	close();
	print("[Misaligned]");
	}

}
//original imagesを閉じる
run("Close All");

//Save log as text. ログを保存
selectWindow("Log");
print("===================");
saveAs("Text", nameDir+"/"+nameFolder+"_ImageStabilizer1x1_"+nameAddTime+".txt");

//Make sound when process ends. 終了の合図。
beep();
wait(2000);
beep();
wait(100);
beep();
print("\\Clear");

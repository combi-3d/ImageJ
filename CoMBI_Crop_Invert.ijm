//Crop and Invert
// Simple macro for 'crop' and/or '8-bit invert'
// NOT include 'Image Stabilizer'

//Begin work log. 作業記録を開始
print("===================");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Crop and Invert, ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);
nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("----------------------");


Dialog.create("Crop/Invert plan");

items = newArray("Crop","Crop and Invert","Invert");
Dialog.addRadioButtonGroup("Select menu : ",items,3,1,"Crop and Invert");

Dialog.addMessage("Crop: Draw rectangle and Crop. Save as '_Crop'");
Dialog.addMessage("Crop and Invet: Draw rectangle and Crop. Save as '_Crop',");
Dialog.addMessage("                THEN, 8-bit and Invert. Save as '_Crop_Gray'.");
Dialog.addMessage("Invert: 8-bit and invert. Save as '_Gray'");
Dialog.addMessage("");
Dialog.addMessage("Click OK to Select and Open Serial Image as 'Virtual Stack'.");

Dialog.show();

selectRadioButton = Dialog.getRadioButton();

/// Open /////////////////////////////////////

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

//print("===================");	//Show image info on Log window. Logに情報を表示する
print("Directory : ", nameDir);
print("Folder : ", "/", nameFolder);
print("Number of images : ", list.length);
print("Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
print("----------------------");

File.openSequence(openDir, "virtual");



/// Crop /////////////////////////////////////

//Make folders for saving croped images at the same directory. Add some info at the end of folder name. 
//連続画像フォルダとおなじ場所でフォルダ名まで指定し、あとでフォルダ名に追記する

if(selectRadioButton == "Crop"){
	setTool("rectangle");
	title = "Wait for ...";
	msg = "Draw a rectangle to be croped.\nBrowse serial image. Adjust rectangle to cover the specimen.\nClick \"OK\" to run 'Crop'.";
	waitForUser(title, msg);

	getSelectionBounds(rectX, rectY, rectW, rectH);
	print("Rectangle  X: ",rectX, " Y: ",rectY," Height: ",rectH, " Width: ",rectW); //use , to add
	run("Crop");

	cropDir=nameDir+"/"+nameFolder+"_Crop";
	File.makeDirectory(cropDir);

	run("Image Sequence... ", "dir=&cropDir format=JPEG use");
	print("Croped images : ",nameFolder,"_Crop");
}



/// Crop and Invert /////////////////////////////////////

if(selectRadioButton == "Crop and Invert"){
	
	// Crop
	setTool("rectangle");
	title = "Wait for ...";
	msg = "Draw a rectangle to be croped.\nBrowse serial image. Adjust rectangle to cover the specimen.\nClick \"OK\" to run 'Crop'.";
	waitForUser(title, msg);

	getSelectionBounds(rectX, rectY, rectW, rectH);
	print("Rectangle  X: ",rectX, " Y: ",rectY," Height: ",rectH, " Width: ",rectW); //use , to add
	run("Crop");

	cropDir=nameDir+"/"+nameFolder+"_Crop";
	File.makeDirectory(cropDir);

	run("Image Sequence... ", "dir=&cropDir format=JPEG use");
	print("Croped images : ",nameFolder,"_Crop");
	
	// Invert
	run("8-bit");
	run("Invert", "stack");
	
	cropinvDir=nameDir+"/"+nameFolder+"_Gray";
	File.makeDirectory(cropinvDir);
	
	run("Image Sequence... ", "dir=&cropinvDir format=JPEG use");
	print("Croped images : ",nameFolder,"_Crop_Gray");
}


/// Invert /////////////////////////////////////
if(selectRadioButton == "Invert"){

	run("8-bit");
	run("Invert", "stack");
	
	invDir=nameDir+"/"+nameFolder+"_Gray";
	File.makeDirectory(invDir);
	
	run("Image Sequence... ", "dir=&invDir format=JPEG use");
	print("Croped images : ",nameFolder,"_Gray");
}

close();

print("----------------------");

print("Saved log at ", nameDir,"/",nameFolder,"_Crop_Invert_",nameAddTime,".txt");
print("===================");

//Save log as text. ログを保存
selectWindow("Log");

saveAs("Text", nameDir+"/"+nameFolder+"_Crop_Invert_"+nameAddTime+".txt");
 //open(nameDir+"/"+nameFolder+"_Resize_Log_"+nameAddTime+".txt");
print("\\Clear");

//Make sound when process ends. 終了の合図。
beep();
wait(200);
beep();
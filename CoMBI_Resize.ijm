/* CoMBI Resize.ijm, (c) Yuki Tajika, 2022.6.10, CC BY-NC
An ImageJ macro for processing serial images acquired by CoMBI. 
Place this ijm file in ImageJ/plugins folder (Not macros folder), and a shortcut will be found in Menubar>plugins. 
(Verified using ImageJ 1.53s for macOS/ARM on macOS12.4, FIJI/ImageJ2.3.0/1.53q on macOS12.4)
Prepare "a folder containing serial image" and "a scale image (reference image)", then run the macro.

Macro runs: 
1. Select a folder containing serial image.
2. Calculate the pixel size of the scale image (reference image) or Use the pixel size of the previous experiment..
3. Plan the resizing process. By default, RGB series of 5μm/pixel, 10μm/pixel, and 20μm/pixel are created. 
    Custom pixel sizes can also be selected. Grayscale series (8-bit, inverted) can be created optionally in addition to RGB series.
4. Create folders to store the resized images.
5. Resize the serial images as selected above.
6. All information (log window) will be saved as a text file, hoping that it will help the researcher to handle the dataset and reproduce the experiment.
*/

//Select a folder containing serial images, 連続画像のフォルダを選択

showMessage("Select a folder containing serial images"); 
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
wait(400)


print("===================");	//Show image info on Log window. Logに情報を表示する
print("Directory : ", nameDir);
print("Folder : ", "/", nameFolder);
print("Number of images : ", list.length);
print("Size of Serial Image :", widthSerial, " x ", heightSerial, "pixels");
print("----------------------");


//Dialog to select calc mode. Refer scale image or input previous values. ダイアログ　スケールをどうやって計算するるか、選択する。画像参照か、過去の数値を入力か。
lineLength = 0;
lineTick = 0;

Dialog.create("Scale");

items = newArray("Select a scale image","Use previous values");
Dialog.addRadioButtonGroup("Caliculate a scale from : ",items,2,1,"Use previous values");
Dialog.addMessage("Input previous values");
  Dialog.addNumber("Line length (pixels) : ", lineLength);
  Dialog.addNumber("Tick used (mm) :",lineTick);
Dialog.show();

scaleRadioButton = Dialog.getRadioButton();
lineLength = Dialog.getNumber();
lineTick = Dialog.getNumber();


//Refer Scale Image. Open a scale image and draw line. スケール画像を利用する場合、画像を開いて線を引く。
if(scaleRadioButton == "Select a scale image"){

	print("Calc.mode :", scaleRadioButton);
	
	run("Open...");
	ID = getImageID();
	setTool("line");
	
	title = "Wait for making a line";
	msg = "Draw a line of multiple tick lengths.\nMemorize the number of tick marks used. \nClick \"OK\" to continue";
	waitForUser(title, msg);
  
	selectImage(ID);  //make sure we still have the same image

	widthScaleImage=getWidth();
	heightScaleImage=getHeight();
	print("Size of Scale Image :", widthScaleImage, " x ",heightScaleImage, "pixels");//use , to add

	if (selectionType!=5)
		exit("Straight line selection required");
	getLine(x1, y1, x2, y2, lineWidth);
	getPixelSize(unit, width, height, depth);
	x1*=width; y1*=height; x2*=width; y2*=height; 
	lineLength = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));

	print("Scale line length :", lineLength, " pixels");

	Dialog.create("Input tick");
	Dialog.addMessage("Line length : "+ lineLength +" pixels");//use + to add
	Dialog.addNumber("Tick used (mm) :",lineTick);
	Dialog.show();
	
	lineTick = Dialog.getNumber();

	pixelsize = 1000*lineTick/lineLength;

	print("Tick used :", lineTick, " mm");
	print("Pixel size :", pixelsize, " µm/pixel");
	print("----------------------");
	close();

}

//Input previous values の場合。以前のスケール情報を手入力。
if(scaleRadioButton == "Use previous values"){
	
	pixelsize = 1000*lineTick/lineLength;
	print("Calc.mode :", scaleRadioButton);
	print("Scale line length :", lineLength, " pixels");
	print("Tick used :", lineTick, " mm");
	print("Pixel size :", pixelsize, " µm/pixel");
    print("----------------------");
}

//Dialog for planning resizing. つぎは、Dialogで縮小プランをたてる。まずは変数を計算しておく。

width5um = parseInt(d2s(widthSerial*lineTick*1000/5/lineLength,0)); //d2s, data to stringで四捨五入すると整数文字列になる。perseInt, string to dataで文字を数値へ。
height5um =  parseInt(d2s(heightSerial*lineTick*1000/5/lineLength,0));
width10um = parseInt(d2s(widthSerial*lineTick*1000/10/lineLength,0));
height10um =  parseInt(d2s(heightSerial*lineTick*1000/10/lineLength,0));
width20um = parseInt(d2s(widthSerial*lineTick*1000/20/lineLength,0));
height20um =  parseInt(d2s(heightSerial*lineTick*1000/20/lineLength,0));

Dialog.create("Resize plan");
	Dialog.addMessage("==STEP1==");
Dialog.addCheckbox("5 µm/pixel", true);
	Dialog.addMessage("Image size :"+width5um+" x "+height5um+" pixels");
	Dialog.addMessage("RGB data size :"+width5um*height5um*list.length*3/1000000000+" GB");
	Dialog.addMessage("-----");
Dialog.addCheckbox("10 µm/pixel", true);
	Dialog.addMessage("Image size :"+width10um+" x "+height10um+" pixels");
	Dialog.addMessage("RGB data size :"+width10um*height10um*list.length*3/1000000000+" GB");
	Dialog.addMessage("-----");
Dialog.addCheckbox("20 µm/pixel", true);
	Dialog.addMessage("Image size :"+width20um+" x "+height20um+" pixels");
	Dialog.addMessage("RGB data size :"+width20um*height20um*list.length*3/1000000000+" GB");
	Dialog.addMessage("-----");
Dialog.addCheckbox("Custom (µm/pixel)", false);
	Dialog.addNumber("       ", 0);
	Dialog.addMessage("==STEP2==");
Dialog.addCheckbox("Create both RGB & grayscale series", false);
	Dialog.addMessage("==STEP3==");
Dialog.addMessage("Click OK to start resizing.");
Dialog.show();

check5um = Dialog.getCheckbox();
check10um = Dialog.getCheckbox();
check20um = Dialog.getCheckbox();
checkCustom = Dialog.getCheckbox();
pixelsizeCustom = Dialog.getNumber();
createGrayscale = Dialog.getCheckbox();

if(check5um == true){
	print("Image size :", width5um," x ",height5um," pixels");
	print("RGB data size :", width5um*height5um*list.length*3/1000000000, " GB");
	print("Directory : ", nameDir);
	print("Folder : /", nameFolder,"_5um");
	if(createGrayscale == true){
		print("Folder : /", nameFolder,"_5um_gray");
	}
	print(" ");
}

if(check10um == true){
	print("Image size :", width10um," x ",height10um," pixels");
	print("RGB data size :", width10um*height10um*list.length*3/1000000000, " GB");
	print("Directory : ", nameDir);
	print("Folder : /", nameFolder,"_10um");
	if(createGrayscale == true){
		print("Folder : /", nameFolder,"_10um_gray");
	}
	print(" ");
}

if(check20um == true){
	print("Image size :", width20um," x ",height20um," pixels");
	print("RGB data size :", width20um*height20um*list.length*3/1000000000, " GB");
	print("Directory : ", nameDir);
	print("Folder : /", nameFolder,"_20um");
	if(createGrayscale == true){
		print("Folder : /", nameFolder,"_20um_gray");
	}
	print(" ");
}

if(checkCustom == true){
	
	widthCustom = parseInt(d2s(widthSerial*lineTick*1000/pixelsizeCustom/lineLength,0));
	heightCustom =  parseInt(d2s(heightSerial*lineTick*1000/pixelsizeCustom/lineLength,0));
	
	print("Image size :", widthCustom," x ",heightCustom," pixels");
	print("RGB data size :", widthCustom*heightCustom*list.length*3/1000000000, " GB");
	print("Directory : ", nameDir);
	print("Folder : /", nameFolder,"_",pixelsizeCustom,"um");
	if(createGrayscale == true){
		print("Folder : /", nameFolder,"_",pixelsizeCustom,"um_gray");
	}
	print(" ");
}

print("----------------------");

//Resizing process, ここから縮小処理

/*
Memorize START time, 開始時刻を記録
Make folder. フォルダをつくる
Run resize. 縮小処理
Save images. 画像を保存
Memorize END time,終了時刻を記録
Save log as text. ログを保存
*/


//Memorize START time, 開始時刻を記録
print("Resizing process");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("START : ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);

//Make folder. Follow checkbox states in Dialog. フォルダをつくる、ダイヤログで条件わけ

resizeDir=nameDir+"/"+nameFolder;	//Make folders for saving resized images at the same directory. Add some info at the end of folder name. 連続画像フォルダとおなじ場所でフォルダ名まで指定し、あとでフォルダ名に追記する
if (check5um == true){
File.makeDirectory(resizeDir+"_5um");
	if(createGrayscale ==true){
	File.makeDirectory(resizeDir+"_5um_gray");
	}
}

if (check10um == true){
File.makeDirectory(resizeDir+"_10um");
	if(createGrayscale ==true){
	File.makeDirectory(resizeDir+"_10um_gray");
	}
}

if (check20um == true){
File.makeDirectory(resizeDir+"_20um");
	if(createGrayscale ==true){
	File.makeDirectory(resizeDir+"_20um_gray");
	}
}

if (checkCustom == true){
File.makeDirectory(resizeDir+"_"+pixelsizeCustom+"um");
	if(createGrayscale ==true){
	File.makeDirectory(resizeDir+"_"+pixelsizeCustom+"um_gray");
	}
}


//Run Resize 縮小処理

for (i=0; i<list.length; i++){
	
	open(openDir+list[i]);			//Open a image 指定した場所の画像を開く
	nameNoExtention = File.nameWithoutExtension;	//Get filename without ext.ファイル名を拡張子なしで獲得する
	IDoriginal = getImageID();
	
if(check5um == true){
	
	if(createGrayscale == true){
	run("Duplicate...", nameNoExtention+"_gray");
	IDcopy = getImageID();
	run("Size...", "width=&width5um depth=1 constrain average interpolation=None"); //resize width can be assigned using & and variable. 設定では、&で変数指定できる
	run("8-bit");
	run("Invert");
	saveAs("Jpeg", resizeDir+"_5um_gray/"+nameNoExtention);
	close();
	}
selectImage(IDoriginal);
run("Size...", "width=&width5um depth=1 constrain average interpolation=None");
saveAs("Jpeg", resizeDir+"_5um/"+nameNoExtention);
run("Undo");
}

if(check10um == true){
	
	if(createGrayscale == true){
	run("Duplicate...", nameNoExtention+"_gray");
	IDcopy = getImageID();
	run("Size...", "width=&width10um depth=1 constrain average interpolation=None");
	run("8-bit");
	run("Invert");
	saveAs("Jpeg", resizeDir+"_10um_gray/"+nameNoExtention);
	close();
	}
selectImage(IDoriginal);
run("Size...", "width=&width10um depth=1 constrain average interpolation=None");
saveAs("Jpeg", resizeDir+"_10um/"+nameNoExtention);
run("Undo");
}

if(check20um == true){
	
	if(createGrayscale == true){
	run("Duplicate...", nameNoExtention+"_gray");
	IDcopy = getImageID();
	run("Size...", "width=&width20um depth=1 constrain average interpolation=None");
	run("8-bit");
	run("Invert");
	saveAs("Jpeg", resizeDir+"_20um_gray/"+nameNoExtention);
	close();
	}
selectImage(IDoriginal);
run("Size...", "width=&width20um depth=1 constrain average interpolation=None");
saveAs("Jpeg", resizeDir+"_20um/"+nameNoExtention);
run("Undo");
}

if(checkCustom == true){
	
	if(createGrayscale == true){
	run("Duplicate...", nameNoExtention+"_gray");
	IDcopy = getImageID();
	run("Size...", "width=&width20um depth=1 constrain average interpolation=None");
	run("8-bit");
	run("Invert");
	saveAs("Jpeg", resizeDir+"_"+pixelsizeCustom+"um_gray/"+nameNoExtention);
	close();
	}
selectImage(IDoriginal);
run("Size...", "width=&widthCustom depth=1 constrain average interpolation=None");
saveAs("Jpeg", resizeDir+"_"+pixelsizeCustom+"um/"+nameNoExtention);
}

close();

}


//Memorize END time. 終了時刻を記録
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("END : ",year,".",month+1,".",dayOfMonth, ",",hour,":", minute,",", second);
nameAddTime = d2s(year,0)+d2s(month+1,0)+d2s(dayOfMonth,0)+d2s(hour,0)+d2s(minute,0)+d2s(second,0);
print("----------------------");
print("Saved log at ", nameDir,"/",nameFolder,"_Resize_Log_",nameAddTime,".txt");


//Save log as text. ログを保存
selectWindow("Log");
print("===================");
saveAs("Text", nameDir+"/"+nameFolder+"_Resize_Log_"+nameAddTime+".txt");
 //open(nameDir+"/"+nameFolder+"_Resize_Log_"+nameAddTime+".txt");
print("\\Clear");

//Make sound when process ends. 終了の合図。
beep();

SetWorkingDir %A_ScriptDir%
IfNotExist, %A_ScriptDir%\AllSites
	FileCreateDir, %A_ScriptDir%\AllSites
IfNotExist, %A_ScriptDir%\Temp
	FileCreateDir, %A_ScriptDir%\Temp
IfNotExist, %A_ScriptDir%\Perdate
	FileCreateDir, %A_ScriptDir%\Perdate
IfNotExist, %A_ScriptDir%\Exclude
	FileCreateDir, %A_ScriptDir%\Exclude
				
Global cat_global
Global exclude
Global excludeCheck
Global excludeMode
Global exclude_file
Global exclude_length

exclude_file = %A_ScriptDir%\Exclude\Exclude.txt
FileRead, ExcludeMode, %A_ScriptDir%\Exclude\ExcludeMode.txt
FileRead, exclude, %exclude_file%

~$f6::
 {
   count++
   settimer, actions, 500
 }
return

actions:
 {
   if (count = 2)
    {
		MakeGui()
		GetExludeLength()
		FileRead, exclude, %exclude_file%
		
    }
   else if (count = 3)
    {
		SaveUrls()
    }
   else if (count = 4)
    {
		
		SelectFile()
      
    }
	else if (count = 5)
    {
		
		SearchFile()
      
    }
	else if (count = 6)
    {
		DeleteLinkFromFile()
      
    }
   count := 0
 }
return

GetExludeLength(){
	
	Loop, Read, %exclude_file%
	{
	   exclude_length = %A_Index%
	}
	
}

MakeGui(){

	Gui, Add, Text,, Please select an option
	if(excludeMode){
		Gui, Add, Text,, The ExcludeMode is turned on
	}
	else
	{
		Gui, Add, Text,, The ExcludeMode is turned off
	}
	Gui, Add, Button, x10 y50 w100 h30, Save  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Add, Button, x110 y50 w100 h30, Open
	Gui, Add, Button, x210 y50 w100 h30, Search
	Gui, Add, Button, x310 y50 w100 h30, Delete
	Gui, Add, Button, x410 y50 w100 h30, Exclude
	IfExist, %A_ScriptDir%\Exclude\Exclude.txt
		if(not excludeMode){
			Gui, Add, Button, x510 y50 w100 h30, Include
		}
	
	Gui, Add, Button, x810 y50 w100 h30, ExcludeMode
	Gui, Show,, UrlSaver
	return  ; End of auto-execute section. The script is idle until the user does something.

	GuiClose:
	Gui Destroy
	return
	
	ButtonOpen:
	Gui Destroy
	SelectFile()
	return
	
	ButtonSearch:
	SearchFile()
	return
	
	ButtonExclude:
	Gui Destroy
	ExcludeFile()
	return
	
	ButtonInclude:
	Gui Destroy
	IncludeFile()
	return
	
	ButtonExcludeMode:
	ExcludeMode()
	Gui Destroy
	Sleep, 125
	MakeGui()
	return
	
	
	ButtonDelete:
	WinActivate, ahk_exe chrome.exe
	Sleep, 250
	DeleteLinkFromFile()
	Gui Destroy
	return
	
	ButtonSave:
	WinActivate, ahk_exe chrome.exe
	Sleep, 250
	Gui Destroy
	SaveUrls()
	return
	
}

ExcludeFile(){
	
	excludeCheck = 1
	setCategoryGUI()
	FileRead, content, %exclude_file%
	if(NOT InStr(content, cat_global))
		FileAppend, %cat_global%`n, %A_ScriptDir%\Exclude\Exclude.txt
	ExcludeMode()
	Sleep, 250
	ExcludeMode()
	Sleep, 250
	FileRead, exclude, %exclude_file%
	MakeGui()()
}

IncludeFile(){
	LineNum =
	excludeCheck = 2
	setCategoryGUI()
	FileRead, Var, %exclude_file%
	Loop, Parse, Var ,`n,`r
	{
		if(A_LoopField = cat_global)
			{
				LineNum := A_Index
			}
	}
	if(LineNum = "Not found"){
		MsgBox, This category has not been found
	}
	else{
		ActivateFile(LineNum)
		MsgBox, Folder activated
	}
	
	ExcludeMode()
	Sleep, 250
	ExcludeMode()
	Sleep, 250
	FileRead, exclude, %exclude_file%
	MakeGui()()
}

ActivateFile(index){
	Loop, read, %exclude_file%, %A_ScriptDir%\Exclude\out.txt
		{
			If (A_Index != index){
				FileAppend, %A_LoopReadLine%`n
			}
		}
		fullbakfilename = %A_ScriptDir%\Exclude\exclude.bak
		if not FileExist(fullbakfilename){
			FileMove, %exclude_file%, %fullbakfilename%
		}
		else{
			FileDelete, %fullbakfilename%
			Sleep, 50
			FileMove, %exclude_file%, %fullbakfilename%
		}
		
		FileMove, %A_ScriptDir%\Exclude\out.txt, %exclude_file%
		FileDelete, %A_ScriptDir%\Exclude\out.txt
		FileDelete, %fullbakfilename%
	
}

ExcludeMode(){
	if(excludeMode){
		
		Loop, %A_ScriptDir%\PerDate\Categorised\*, 2, 0
		{
			FileSetAttrib, -H, %A_LoopFileLongPath%
		}
		
		FileDelete, %A_ScriptDir%\Exclude\ExcludeMode.txt
		excludeMode = 
		FileAppend, %excludeMode%, %A_ScriptDir%\Exclude\ExcludeMode.txt
		
	}
	else{
		
		Loop, %A_ScriptDir%\PerDate\Categorised\*, 2, 0
		{
			directoryIndex := A_index

			Loop, Read, %exclude_file%
			{
				if (InStr(A_LoopFileLongPath, A_LoopReadLine))
				{
					FileSetAttrib, +H, %A_LoopFileLongPath%
				}
			}
		}
		
		FileDelete, %A_ScriptDir%\Exclude\ExcludeMode.txt
		excludeMode = Yes
		FileAppend, %excludeMode%, %A_ScriptDir%\Exclude\ExcludeMode.txt
		
	}
	
}


SelectFile(){

	FileSelectFile, SelectedFile, 3, %A_ScriptDir%\PerDate\, Open a file, Text Documents (*.txt; *.doc)
		if SelectedFile !=
			OpenUrls(SelectedFile)
}

DeleteLinkFromFile(){
	if WinActive("ahk_class MozillaWindowClass") 
	  or WinActive("ahk_class Chrome_WidgetWin_0")
	  or winactive("ahk_class Chrome_WidgetWin_1")
	  {  
		ClipSave := Clipboard
		Clipboard = ; empty clipboard
		url := ""
		Clipboard = ; empty clipboard
		Send,^l
		Sleep,200
		Send,^c
		ClipWait, 50
		url := Clipboard
		MainFileText := GetStringLocation(url)
		StringReplace , MainFileTrimmed, MainFileText, %A_Space%,,All
		FileAppend, %MainFileTrimmed%, %A_ScriptDir%\Temp\TempMainFile.txt
		file = getMainFile() 
		file_temp = %A_ScriptDir%\Temp\TempMainFile.txt
		LineNum := getLineNumber(url, file_temp)
		if(LineNum = "Not found"){
			MsgBox, This URL has not been found
			FileDelete, %A_ScriptDir%\Temp\TempMainFile.txt
		}
		else{
			RemoveFromFile(LineNum, file)
			FileDelete, %A_ScriptDir%\Temp\TempMainFile.txt
			MsgBox, Removed from file
		}
		
	}
	
	else{
		MsgBox, No browser active
	}
}

RemoveFromFile(index, file){
	
	tempfile = %A_ScriptDir%\Temp\TempMainFile.txt
	
	
	Loop, read, %tempfile%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			MainFile = %A_LoopField%
		}
	}
	
	SplitPath, MainFile, name, dir, ext, name_no_ext, drive
	FileRead, Var, %MainFile%
	if(name_no_ext != "watched"){	
		Loop, Parse, Var ,`n,`r
		{
			If (A_Index = index){
				Text.=A_LoopField "`n"
			}
		}
		FileAppend, %Text%, %dir%\watched.txt
	}
	
	if(name_no_ext != "watched"){	
		Loop, read, %MainFile%, %dir%\out.txt
		{
			If (A_Index != index){
				FileAppend, %A_LoopReadLine%`n
			}
		}
		fullbakfilename = %dir%\%name_no_ext%.bak
		if not FileExist(fullbakfilename){
			FileMove, %MainFile%, %dir%\%name_no_ext%.bak
		}
		else{
			FileDelete, %dir%\%name_no_ext%.bak
			Sleep, 50
			FileMove, %MainFile%, %dir%\%name_no_ext%.bak
		}
		
		FileMove, %dir%\out.txt, %MainFile%
		FileDelete, %dir%\out.txt
	}
	else{
		MsgBox, File already deleted
	}
}

getMainFile(){

	file = %A_ScriptDir%\Temp\TempMainFile.txt

	Loop, read, %file%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			return A_LoopField
		}
	}
}

getLineNumber(url, file){
	if not FileExist(file)
		MsgBox, The file does not exist.
	Loop, read, %file%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			MainFile = %A_LoopField%
		}
	}
	MsgBox, %MainFile%
	if not FileExist(file)
		MsgBox, The file does not exist.
		
	FileRead, Var, %MainFile%
	
	Loop, Parse, Var ,`n,`r
	{
		if(A_LoopField = url)
			{
				return A_Index
				
			}
	}
}

OpenUrls(x){

	Loop, Read, %x%
	{
	   total_lines = %A_Index%
	}
	areyousure = You are going to open %total_lines% websites: `n
	domainlist := []
	domaintext =
	Loop, read, %x%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			
			RegexMatch(A_LoopField, InStr(A_LoopField, "//www.") ? "\.(.+?)\/" : "\/\/(.+?)\/" , domain)
			if (HasVal(domainlist, domain1) < 1){
				domainlist.Push(domain1)
			}
		}
	}
	
	for index, element in domainlist ; Enumeration is the recommended approach in most cases.
	{
		domaintext .= "- "element "`n"
	}

	areyousure = %areyousure% `n %domaintext%
	MsgBox, 3, , %areyousure%, 30  ; 30-second timeout.
	IfMsgBox, Cancel
		Return  ; User pressed the "No" button.
	IfMsgBox, No
		SelectFile()
	IfMsgBox, Timeout
		Return ; i.e. Assume "No" if it timed out.
		; Otherwise, continue:
	IfMsgBox, Yes
		CheckTabs(x, 0, "",0)
	
	return
}

join( strArray )
{
  s := ""
  for i,v in strArray
    s .= ", " . v
  return substr(s, 3)
}

CheckTabs(x, number, isIncognito, count){
	notOpened := ""
	opened_url := []
	opened_url := GetUrlsList()
	TempFileNotOpen = %A_ScriptDir%\Temp\TempNotOpen.txt
	Loop, read, %x%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			if (HasVal(opened_url, A_LoopField) < 1){
				notOpened .= A_LoopField "`n"
			}
		}
	}
	FileAppend, %notOpened%, %TempFileNotOpen%
	if(notOpened = ""){
		number := 5
	}
	if(number < 1){
		MsgBox, 4, , Do you want to open the links in incognito mode? , 15
		IfMsgBox, No
			isIncognito := ""
		IfMsgBox, Timeout
			isIncognito := ""
		IfMsgBox, Yes
			isIncognito = Yes
	}
	number++
	Loop, read, %TempFileNotOpen%
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			OpenLinks(A_LoopField, isIncognito)
		}
	}
	
	if(count = 0){
		FileDelete, %TempFileNotOpen%
		count++
		CheckTabs(x, number, isIncognito, count)
	}
	count++
	if(notOpened = ""){
		FileDelete, %TempFileNotOpen%
		MsgBox, All sites are loaded
		return
	}
	else{
		FileDelete, %TempFileNotOpen%
		CheckTabs(x, number, isIncognito, count)
	}
}

OpenLinks(url, isIncognito){
	
	if(isIncognito != ""){
		Run "chrome.exe" -incognito "%url%" --new-tab
		chromePageWait()
	}
	else{
		Run "chrome.exe" "%url%" --new-tab
		chromePageWait()
	}

}


HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
	return 0
	for index, value in haystack
	if (value = needle)
	return index
	return 0
}

GetUrls(){
	if WinActive("ahk_class MozillaWindowClass") 
	  or WinActive("ahk_class Chrome_WidgetWin_0")
	  or winactive("ahk_class Chrome_WidgetWin_1")
	  {  
		MainFile = %A_ScriptDir%\AllSites\AllSites.txt
		ClipSave := Clipboard
		Clipboard = ; empty clipboard
		url_list := ""
		first_url := ""
		url := ""
		youtube = https://www.youtube.com/
		FileRead, filetext, %MainFile% ; get the file contents
		Loop
		{
		  Clipboard = ; empty clipboard
		  Send,^l
		  Sleep,250
		  Send,^c
		  ClipWait,0
		  url := Clipboard
		  if (url == first_url)
			  break
		   if A_Index = 1
			  first_url := url
			
			if(url != youtube)
			{
				IfNotInString, filetext, %url% ; self-explanatory
					url_list .= url "`n"
			}
			
		  
		  Send, ^{tab}
		}
		return %url_list%
	}
}

GetUrlsList(){
	
	if WinActive("ahk_class MozillaWindowClass") 
	  or WinActive("ahk_class Chrome_WidgetWin_0")
	  or winactive("ahk_class Chrome_WidgetWin_1")
	  {  
		MainFile = %A_ScriptDir%\AllSites\AllSites.txt
		ClipSave := Clipboard
		Clipboard = ; empty clipboard
		url_list := []
		first_url := ""
		url := ""
		youtube = https://www.youtube.com/
		FileRead, filetext, %MainFile% ; get the file contents
		Loop
		{
		  Clipboard = ; empty clipboard
		  Send,^l
		  Sleep,200
		  Send,^c
		  ClipWait, 50
		  url := Clipboard
		  if (url == first_url)
			  break
		   if A_Index = 1
			  first_url := url
			
			if(url != youtube)
			{
				url_list.Push(url)
			}
			
		  
		  Send, ^{tab}
		}
		return %url_list%
	}
}

chromePageWait()
{
	global
	Loop 50
		{
		while (A_Cursor = "AppStarting")
			continue
		Sleep, 100
		}
}
	
IsLineInMyFile(TestText, FilePath)
{
    Loop, Read, %FilePath%
    {
        if (A_LoopReadLine = TestText)
        {
          
            return 1
        }
    }
 
    return 0
}

SaveUrls(){
	url_list := GetUrls()
	FormatTime, CurrentDateTimeFile,, dd-MM-yyyy_HH_mm
	FormatTime, CurrentDateTime,, dd-MM-yyyy HH:mm:ss
	FormatTime, CurrentDateTimeFolder,, dd-MM-yyyy
	fw := ""
	cat = Categorised
	foldername_complete := ""
	filename = %CurrentDateTimeFile%.txt
	foldername = %CurrentDateTimeFolder%
	MainFile = %A_ScriptDir%\AllSites\AllSites.txt
	
		if(url_list){
			Clipboard := ClipSave
			MsgBox, 3, , Categorised?, 10  ; 30-second timeout.
			IfMsgBox, Cancel
				Return  ; User pressed the "No" button.
			IfMsgBox, No
				fw = Not_Categorised\
				
			IfMsgBox, Timeout
				Return ; i.e. Assume "No" if it timed out.
				; Otherwise, continue:
			IfMsgBox, Yes
			{
				fw = Categorised
				excludeCheck = 0
				setCategoryGUI()
				category := cat_global
			}
			slash = \
			restdir = %A_ScriptDir%\Perdate\
			StringUpper, category, category, T
			category = %category%%slash%
			
			IfInString, cat, %fw%
			{
				foldername_complete = %restdir%%fw%%slash%%category%%foldername%
			}
			else
			{
				foldername_complete = %restdir%%fw%%slash%%foldername%
			}
			IfNotExist, %foldername_complete%
				FileCreateDir, %foldername_complete%
			FileAppend, `n ------------------- %CurrentDateTime% -----------------------`n, %MainFile%
			FileAppend, %url_list%, %MainFile%
			FileAppend, %url_list%, %foldername_complete%\%filename%
		}
		else{
			MsgBox, You either have an empty tab or your browser doesn't have any tabs opened. `n`nIf there are open tabs then they already exist in the textfile
			return
		}
	  }

	  
setCategoryGUI(){
	
	Gui, Add, Text,, Pick a file to launch from the list below.`nTo cancel, press ESCAPE or close this window.
	Global MyListBox
	if(excludeMode AND excludeCheck = 2)
	{
		Gui, Add, Text,, These files are excluded:
	}
	Gui, Add, ListBox, vMyListBox gMyListBox w640 r10
	Gui, Add, Button, Default, OK
	if(excludeCheck = 0){
		Gui, Add, Button, , Create
	}
	
	Loop, %A_ScriptDir%\PerDate\Categorised\*, 2, 0  ; Change this folder and wildcard pattern to suit your preferences.
	{
		if(excludeMode AND excludeCheck = 1){
			IfNotInString, exclude, %A_LoopFileName% ; self-explanatory
				GuiControl,, MyListBox, %A_LoopFileName%
		}
		else if(not excludeMode AND excludeCheck = 1){
			IfNotInString, exclude, %A_LoopFileName% ; self-explanatory
				GuiControl,, MyListBox, %A_LoopFileName%
		}
		else if(excludeMode AND excludeCheck = 2){
			IfInString, exclude, %A_LoopFileName% ; self-explanatory
				GuiControl,, MyListBox, %A_LoopFileName%
		}
		else if(not excludeMode AND excludeCheck = 2){
			IfInString, exclude, %A_LoopFileName% ; self-explanatory
				GuiControl,, MyListBox, %A_LoopFileName%
		}
		else if(not exclude_file AND excludeCheck = 2){
			IfNotInString, exclude, %A_LoopFileName%
				GuiControl,, MyListBox, Nothing is excluded
		}
		else{
			GuiControl,, MyListBox, %A_LoopFileName%
		}
	}
	
	Gui, Show,,UrlSaver1.0
	
	WinWaitClose, UrlSaver1.0
	
	MyListBox:
	if (A_GuiEvent <> "DoubleClick")
		return
	; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
	; So fall through to the next label.
	
	ButtonOK:
		GuiControlGet, MyListBox  ; Retrieve the ListBox's current selection.
		MsgBox, 4,, Would you like to select the category below?`n`n%MyListBox%
		IfMsgBox, No
			return
		IfMsgBox, Yes
			Gui, Submit 
			Gui Destroy
			cat_global := MyListBox
			return
	
	ButtonCreate:
		InputBox, category, Which category?
			Gui Destroy
			cat_global := category
			return
	
	if (ErrorLevel = "ERROR")
		MsgBox Could not launch the specified file. Perhaps it is not associated with anything.
	
	GuiEscape:
	Gui Destroy
	return
}
	  
	  
SearchFile(){
	File := "*.txt"             ;can include directory -- * is wildcard
	StringCheck := ""       	;replace with search string
	FileHit := ""               ;empty
	
	Directory = %A_ScriptDir%\PerDate
	FileGetSize, exclude_size, %exclude_file%
	If Directory
	{
		If(!InStr(FileExist(Directory), "D"))
		{
			msgbox Invalid directory
			Exit
		}
		StringRight, DirectoryEndingChar, Directory, 1
		If(DirectoryEndingChar != "\")
			Directory .= "\"
	}

	InputBox, StringCheck, Enter string to search, The search string is not case sensitive., , 300, 150

	if ErrorLevel
	{
		MsgBox, Query canceled.
		Exit
	}
	
	Loop, %Directory%%File%, , 1
	{
		directoryIndex := A_index
		if(excludeMode){
		
			IfNotExist, %exclude_file%
			{
				FileRead, FileCheck, %A_LoopFileLongPath%
				IfInString, FileCheck, %StringCheck%
					FileHit%A_Index% := A_LoopFileLongPath
			}
			
			Loop, Read, %exclude_file%
			{
				if(A_LoopReadLine= " "){
					FileRead, FileCheck, %A_LoopFileLongPath%
					IfInString, FileCheck, %StringCheck%
					  FileHit%A_Index% := A_LoopFileLongPath
				}
				
				if (InStr(A_LoopFileLongPath, A_LoopReadLine))
				{
					break
				}
				else
				{
					if(A_Index = exclude_length)
					{
						FileRead, FileCheck, %A_LoopFileLongPath%
						IfInString, FileCheck, %StringCheck%
						{
							FileHit%directoryIndex% := A_LoopFileLongPath
						}
					}
				}
			}
		}
		
		if(not excludeMode){
			FileRead, FileCheck, %A_LoopFileLongPath%
			IfInString, FileCheck, %StringCheck%
			  FileHit%A_Index% := A_LoopFileLongPath
		}
		
	}
	Loop, 100
	{
	   If (FileHit%A_Index% <> "")
		  FileHit .= FileHit%A_Index% . "`n"
	}

	If FileHit
		MsgBox, % FileHit
	Else
		MsgBox, No match found.
}

GetStringLocation(string){
	File := "*.txt"             ;can include directory -- * is wildcard
	FileHit := ""               ;empty
	
	Directory = %A_ScriptDir%\PerDate\

	Loop, %Directory%%File%, , 1
	{
	   FileRead, FileCheck, %A_LoopFileLongPath%
	   IfInString, FileCheck, %string%
		  FileHit%A_Index% := A_LoopFileLongPath
	}
	Loop, 100
	{
	   If (FileHit%A_Index% <> "")
		  FileHit .= FileHit%A_Index% . "`n"
	}

	If FileHit
		return %FileHit%
	Else
		MsgBox, No match found.
}


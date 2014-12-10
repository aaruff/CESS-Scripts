'----------------------------------------------------------------------------------
' Purpose:      The purpose of this script is to create a Z-Tree experimenter folder
'               containing output folders (data, treatment, payment, etc.) and all of
'               the lab supported versions of Z-Tree.
'
' Requirements: -- Windows XP or greater
'               -- Z-Leaf files must be located in 
'
' Author:   Anwar A. Ruff at the Center for Experimental Social Science
'
' License:  The Academic Free License 3.0
'----------------------------------------------------------------------------------
Option Explicit
On Error Resume Next

'-
' The location where this script will look for all supported version of Z-Tree.
' Note: The Z-Tree files must follow this naming convention (ztree-x.y.z.exe)
'       where x, y, and z are integers. For example ztree-3.2.1.exe
'-
Dim ZTreePath
set ZTreePath = "C:\CESS\Z-Tree"

'--
' Searches for a duplicated folder name in the ZTreePath. If found
' true is returned, otherwise false is returned.
'
' @param String folderName
' @param String folderPath
' 
' @return boolean
'--
Function duplicateFolderFound(folderName, folderPath)
	Dim FileSystem
	Set FileSystem = CreateObject("Scripting.FileSystemObject")

	Dim folder
	set folder = FileSystem.GetFolder(folderPath)
	
	Dim subFolders 
	set subFolders = folder.SubFolders
	
	Dim subFolder
	For Each subFolder In subFolders
		If subFolder.Name = folderName Then
			return true 
		End If
    Next 
	duplicateFolderFound = false
End Function

'--
' Prompts the experimenter for a folder name (preferably a last name) and
' the result is returned. If no value is entered the experimenter is prompted
' MAX_ATTEMPTS times and the last result is returned.
'
' @return String
'--
Function getFolderName()
    'Prompt experimenter for folder name
    Dim folderEntry : folderEntry = InputBox("Enter your last name:","Create Z-Tree Directory","")

    Dim MAX_ATTEMPTS : MAX_ATTEMPTS = 3 
    Dim numTries : numTries = 0
	Do While folderEntry = "" And numTries < MAX_ATTEMPTS
        ' Ask experimenter again
		folderEntry = InputBox("Please enter your last name:","Create Z-Tree Directory","")
		numTries = numTries + 1
	Loop
	
	getFolderName = folderEntry
End Function


'--
' Creates the Z-Tree folder specified by the experimenter and all output sub-folders.
' 
' @param String experimentFolderPath experimenter folder path
' @param String folderEntry experimenter folder name entry
'--
Function createExperimenterFolders(experimenterFolderPath, folderEntry)
    Dim FileSystem : Set FileSystem = CreateObject("Scripting.FileSystemObject")
    Dim experimenterPath : experimenterPath = experimenterFolderPath & "\" & folderEntry
	
	' Create Experimenter Z-Tree folder
	FileSystem.CreateFolder(ExperimenterPath)

    ' Z-Tree output folders
    Dim folderNames : folderNames = Array("Data","Garbage", "Payments", "Treatments", "Treatment-Backups")
    Dim garbageSubFolders : garbageSubFolders = Array("eec", "gsf", "tmp")
	
	'Create Experimenter folders
	Dim folderName
	For Each folderName In folderNames
		FileSystem.CreateFolder(experimenterPath & "\" & folderName)
	Next
	
	'Create Experimenter garbage sub folders
	Dim subFolder
	For Each subFolder In garbageSubFolders
		FileSystem.CreateFolder(experimenterPath & "\Garbage\" & subFolder)
	Next
End Function

'--
' Creates a Z-Tree link for each Z-Tree binary found in ZTreePath.
' 
' @param String experimenterFolderPath
' @parma String folderEntry
'--
Function createZTreeShortcuts(experimenterFolderPath, folderEntry)
    Dim FileSystem : Set FileSystem = CreateObject("Scripting.FileSystemObject")
	Dim ZTreePathConfig
	ZTreePathConfig = " /gsfdir ..\Experimenters\"   & folderEntry & "\Garbage\gsf " &_
			  "/tempdir ..\Experimenters\"  & folderEntry & "\Garbage\tmp " &_
			  "/leafdir ..\Experimenters\"  & folderEntry & "\Garbage\eec " &_
			  "/datadir ..\Experimenters\"  & folderEntry & "\Data " &_
			  "/paydir ..\Experimenters\"   & folderEntry & "\Payments " &_
			  "/language en"
	
    Dim zTreeFolder : Set zTreeFolder = FileSystem.GetFolder("C:\CESS\Z-Tree")
    Dim zTreeExecutable : Set zTreeExecutable = zTreeFolder.Files
	
	Dim zTreeShortcut
	Dim serverFile
    Dim linkName 
    
    Dim WSHShell : Set WSHShell = WScript.CreateObject("WScript.Shell")
	
    Dim regex : Set regex = New RegExp
	regex.Global = false
	regex.IgnoreCase = true
	regex.Pattern = "^ztree-[0-9]+\.[0-9]+(\.[0-9])*\.exe$"
	For Each serverFile In zTreeExecutable	
		If regex.Test(serverFile.Name) = true Then
			linkName = Replace(serverFile.Name,".exe",".lnk")
			Set zTreeShortcut = WSHShell.CreateShortcut(experimenterFolderPath & "\" & folderEntry & "\" & linkName)
			zTreeShortcut.TargetPath = zTreeFolder & "\" & serverFile.Name ' z-tree.exe absolute path
			zTreeShortcut.Arguments = ZTreePathConfig
			zTreeShortcut.WorkingDirectory = zTreeFolder		
			zTreeShortcut.WindowStyle = 4
			zTreeShortcut.IconLocation = zTreeFolder & "\" & serverFile.Name & ", 0"
			zTreeShortcut.Save
		End If
	Next
End Function

'--
' Prompts the experimenter for the Z-Tree folder name. Creates the folder
' and all of the required links and subfolders.
'--
Function init()
	Dim experimenterFolderPath
	experimenterFolderPath = ZTreePath

	Dim folderEntry
	folderEntry = getFolderName()

	'Error: No entry made
	If folderEntry = "" Then
		WScript.Echo "I can't create a folder for you if you don't name it."
		return false
	End If
	
	'Error: Duplicate folder found
	If duplicateFolderFound(folderEntry, experimenterFolderPath) Then
		WScript.Echo "A folder with this name already exists. Please enter a unique name"
		return false
	End If
	
	'TODO: validate folder creation
	call createExperimenterFolders(experimenterFolderPath, folderEntry)
	
	call createZTreeShortcuts(experimenterFolderPath, folderEntry)
End Function

call init()

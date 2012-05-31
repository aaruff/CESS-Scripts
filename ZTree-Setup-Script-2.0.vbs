' This script was created for use at the Center for Experimental Social Science.
' Author: Anwar A. Ruff
' Project: CESS Lab Tool Kit
Option Explicit
On Error Resume Next

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

Function getFolderName()
	Dim MAX_ATTEMPTS
	MAX_ATTEMPTS = 3
	
	Dim folderEntry
	folderEntry = InputBox("Enter your last name:","Create Z-Tree Directory","")

	Dim numTries
	numTries = 0
	Do While folderEntry = "" And numTries < MAX_ATTEMPTS
		folderEntry = InputBox("Please enter your last name:","Create Z-Tree Directory","")
		numTries = numTries + 1
	Loop
	
	getFolderName = folderEntry
End Function

Function createFolder(absolutePath)
End Function

Function createExperimenterFolders(experimenterFolderPath, folderEntry)
	Dim FileSystem
	Set FileSystem = CreateObject("Scripting.FileSystemObject")
	Dim experimenterPath
	experimenterPath = experimenterFolderPath & "\" & folderEntry
	
	' Experimenter folder
	FileSystem.CreateFolder(ExperimenterPath)
	
	Dim folderNames
	folderNames = Array("Data","Garbage", "Payments", "Treatments", "Treatment-Backups")
	Dim garbageSubFolders
	garbageSubFolders = Array("eec", "gsf", "tmp")
	
	'Experimenter sub folders
	Dim folderName
	For Each folderName In folderNames
		FileSystem.CreateFolder(experimenterPath & "\" & folderName)
	Next
	
	'Experimenter garbage sub folders
	Dim subFolder
	For Each subFolder In garbageSubFolders
		FileSystem.CreateFolder(experimenterPath & "\Garbage\" & subFolder)
	Next
End Function

Function createZTreeShortcuts(experimenterFolderPath, folderEntry)
	Dim FileSystem
	Set FileSystem = CreateObject("Scripting.FileSystemObject")
	Dim ZTreePathConfig
	ZTreePathConfig = " /gsfdir ..\Experimenters\"   & folderEntry & "\Garbage\gsf " &_
			  "/tempdir ..\Experimenters\"  & folderEntry & "\Garbage\tmp " &_
			  "/leafdir ..\Experimenters\"  & folderEntry & "\Garbage\eec " &_
			  "/datadir ..\Experimenters\"  & folderEntry & "\Data " &_
			  "/paydir ..\Experimenters\"   & folderEntry & "\Payments " &_
			  "/language en"
	
	Dim zTreeFolder
	Set zTreeFolder = FileSystem.GetFolder("C:\CESS\Z-Tree")
	Dim zTreeExecutable
	Set zTreeExecutable = zTreeFolder.Files
	
	Dim zTreeShortcut
	Dim serverFile
	Dim WSHShell
	Dim linkName
	Set WSHShell = WScript.CreateObject("WScript.Shell")
	
	Dim regex
	Set regex = New RegExp
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


Function init()
	Dim experimenterFolderPath
	experimenterFolderPath = "C:\CESS\Experimenters"

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

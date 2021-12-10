---
title: JetBrains编辑器清理(mac)
author: Payne
tags:
  - JetBrains
categories:
  - - JetBrains
date: 2021-12-10 13:32:10
---



## 缘由

由于不可描述的原因，我需要将`JetBrains`的所有已安装的编辑器进行清理。但我们知道MAC上单纯将应用软件中的软件拖入废纸篓是无法进行彻底删除的。

> Tip: 有`Cleaner One Pro`或者`clean my mac` 专业版的（也就是付费版）的朋友可以直接在该软件中进行软件的卸载与清理，具体操作便不再此过多赘述



## 关键目录

```dart
~/Library/Application\ Support/JetBrains
~/Library/Logs/JetBrains
~/Library/Preferences/JetBrains.*
~/Library/Caches/JetBrains
/Applications
```



### 删除

> Tip：建议先将`/Applications` 中的内容先进行删除

```
rm -rf ~/Library/Application\ Support/JetBrains/*
rm -rf ~/Library/Logs/JetBrains/*
rm -rf ~/Library/Preferences/JetBrains.*
rm -rf ~/Library/Caches/JetBrains/*
```





## Evalreset Cleanr Script

### Mac/Linux

```sh
#!/usr/bin/env sh
# reset jetbrains ide evals

OS_NAME=$(uname -s)
JB_PRODUCTS="IntelliJIdea CLion PhpStorm GoLand PyCharm WebStorm Rider DataGrip RubyMine AppCode"

if [ $OS_NAME == "Darwin" ]; then
	echo 'macOS:'
	
	rm -rf ~/Library/Logs/JetBrains/*
	rm -rf ~/Library/Caches/JetBrains/*
	rm -rf ~/Library/Preferences/JetBrains.*
	for PRD in $JB_PRODUCTS; do
    	rm -rf ~/Library/Preferences/${PRD}*/*
    	rm -rf ~/Library/Application\ Support/JetBrains/${PRD}*/eval
	done
elif [ $OS_NAME == "Linux" ]; then
	echo 'Linux:'

	for PRD in $JB_PRODUCTS; do
    	rm -rf ~/.${PRD}*/config/eval
    	rm -rf ~/.config/${PRD}*/eval
	done
else
	echo 'unsupport'
	exit
fi

echo 'done.'
```

### Windows

```vbscript
Set oShell = CreateObject("WScript.Shell")
Set oFS = CreateObject("Scripting.FileSystemObject")
sHomeFolder = oShell.ExpandEnvironmentStrings("%USERPROFILE%")
sJBDataFolder = oShell.ExpandEnvironmentStrings("%APPDATA%") + "\JetBrains"

Set re = New RegExp
re.Global     = True
re.IgnoreCase = True
re.Pattern    = "\.?(IntelliJIdea|GoLand|CLion|PyCharm|DataGrip|RubyMine|AppCode|PhpStorm|WebStorm|Rider).*"

Sub removeEval(ByVal file, ByVal sEvalPath)
	bMatch = re.Test(file.Name)
    If Not bMatch Then
		Exit Sub
	End If

	If oFS.FolderExists(sEvalPath) Then
		oFS.DeleteFolder sEvalPath, True 
	End If
End Sub

If oFS.FolderExists(sHomeFolder) Then
	For Each oFile In oFS.GetFolder(sHomeFolder).SubFolders
    	removeEval oFile, sHomeFolder + "\" + oFile.Name + "\config\eval"
	Next
End If

If oFS.FolderExists(sJBDataFolder) Then
	For Each oFile In oFS.GetFolder(sJBDataFolder).SubFolders
	    removeEval oFile, sJBDataFolder + "\" + oFile.Name + "\eval"
	Next
End If

MsgBox "done"
```



[qXHrKqdrtjJX6xtX](https://shimo.im/docs/qXHrKqdrtjJX6xtX/read)

[vrg123](http://vrg123.com/) :  4565

[zhile](https://zhile.io/2020/11/18/jetbrains-eval-reset-da33a93d.html)

[Zhile-plug](https://plugins.zhile.io):	https://plugins.zhile.io

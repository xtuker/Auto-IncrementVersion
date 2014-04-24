function Auto-IncrementVersion
{
<# 
.SYNOPSIS 
Автоматическое инкрементирование версии проектов Visual C++
 
.PARAMETER RCFileName 
Имя файла ресурсов (*.rc)
 
.PARAMETER NewVersion 
Установить версию файла вручную. Формат: 1.2.3.4
 
.EXAMPLE 
Auto-IncrementVersion MyProject.rc

.EXAMPLE 
Auto-IncrementVersion -RCFileName MyProject.rc -NewVersion 2.0.5.16

.FUNCTIONALITY  
PowerShell Language 
 
.NOTES 
Alexander Falkovski
http://www.xtuke.ru
#> 

[cmdletbinding()]
PARAM(
	[parameter(Position=0,Mandatory=$true,ParameterSetName='RCFileName')]
	[ValidateScript({test-path $_})]
		[String]$RCFileName,
	[parameter(Position=1,Mandatory=$false)]
	[ValidatePattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')]
		[String]$NewVersion,
	[parameter(Mandatory=$false)]
		[switch]$Silent
)

BEGIN {
	
	if($Silent -eq $false){
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
		$ret = [System.Windows.Forms.MessageBox]::Show("Вы действительно хотите обновить версию проекта перед сборкой?" , "Внимание" , 4)
		if($ret -ne "YES"){ exit -1 }
	}
	$version = ""
}

PROCESS {

$content = cat $RCFileName
if($content -eq $false){ exit -1 }

$content | foreach{
	if($_.Contains("FILEVERSION")){
		$id = $_.IndexOf("FILEVERSION") + "FILEVERSION".Length
		$left = $_.Substring(0, $id)
		
		if($NewVersion){
			[int]$MajHVer = $NewVersion.split('.')[-4].split(' ')[-1]
			[int]$MajLVer = $NewVersion.split('.')[-3]
			[int]$MinHVer = $NewVersion.split('.')[-2]
			[int]$MinLVer = $NewVersion.split('.')[-1]
		}else{		
			[int]$MajHVer = $_.split(',')[-4].split(' ')[-1]
			[int]$MajLVer = $_.split(',')[-3]
			[int]$MinHVer = $_.split(',')[-2]
			[int]$MinLVer = $_.split(',')[-1]
			
			$MinLVer += 1
		}
		
		"$left $MajHVer,$MajLVer,$MinHVer,$MinLVer"
	}elseif($_.Contains("PRODUCTVERSION")){
		$id = $_.IndexOf("PRODUCTVERSION") + "PRODUCTVERSION".Length
		$left = $_.Substring(0, $id)
		
		if($NewVersion){
			[int]$MajHVer = $NewVersion.split('.')[-4].split(' ')[-1]
			[int]$MajLVer = $NewVersion.split('.')[-3]
			[int]$MinHVer = $NewVersion.split('.')[-2]
			[int]$MinLVer = $NewVersion.split('.')[-1]
		}else{		
			[int]$MajHVer = $_.split(',')[-4].split(' ')[-1]
			[int]$MajLVer = $_.split(',')[-3]
			[int]$MinHVer = $_.split(',')[-2]
			[int]$MinLVer = $_.split(',')[-1]
			
			$MinLVer += 1
		}
		
		"$left $MajHVer,$MajLVer,$MinHVer,$MinLVer"
	}elseif($_.Contains("""FileVersion"",")){
		$id = $_.IndexOf("""FileVersion"",") + """FileVersion"",".Length
		$left = $_.Substring(0, $id)
		
		if($NewVersion){
			[int]$MajHVer = $NewVersion.split('.')[-4].split(' ')[-1]
			[int]$MajLVer = $NewVersion.split('.')[-3]
			[int]$MinHVer = $NewVersion.split('.')[-2]
			[int]$MinLVer = $NewVersion.split('.')[-1]
		}else{
			[int]$MajHVer = $_.split('.')[-4].split('"')[-1]
			[int]$MajLVer = $_.split('.')[-3]
			[int]$MinHVer = $_.split('.')[-2]
			[int]$MinLVer = $_.split('.')[-1].split('"')[0]
			
			$MinLVer += 1
		}

		"$left ""$MajHVer.$MajLVer.$MinHVer.$MinLVer"""
	}elseif($_.Contains("""ProductVersion"",")){
		$id = $_.IndexOf("""ProductVersion"",") + """ProductVersion"",".Length
		$left = $_.Substring(0, $id)
		
		if($NewVersion){
			[int]$MajHVer = $NewVersion.split('.')[-4].split(' ')[-1]
			[int]$MajLVer = $NewVersion.split('.')[-3]
			[int]$MinHVer = $NewVersion.split('.')[-2]
			[int]$MinLVer = $NewVersion.split('.')[-1]
		}else{
			[int]$MajHVer = $_.split('.')[-4].split('"')[-1]
			[int]$MajLVer = $_.split('.')[-3]
			[int]$MinHVer = $_.split('.')[-2]
			[int]$MinLVer = $_.split('.')[-1].split('"')[0]
			
			$MinLVer += 1
		}
		$version = "$MajHVer.$MajLVer.$MinHVer.$MinLVer"
		
		"$left ""$MajHVer.$MajLVer.$MinHVer.$MinLVer"""
	}else{ 
		$_ 
	}
} | Out-File $RCFileName -Encoding Default
}
END {
echo "=========================" ""
echo "New version: $version"
echo "" "========================="
}
}
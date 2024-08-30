@echo off
setlocal
set vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
FOR /F "tokens=* usebackq" %%r IN (`"%vswhere%" -nologo -latest -all -prerelease -products * -property installationPath`) DO SET VsDevCmd=%%r\Common7\Tools\VsDevCmd.bat
CALL "%VsDevCmd%" -no_logo -host_arch=amd64 -arch=amd64
mklink "%UniversalCRTSdkDir%\Include\%UCRTVersion%\ucrt\module.modulemap" S:\SourceCache\swift\stdlib\public\Platform\ucrt.modulemap
mklink "%UniversalCRTSdkDir%\Include\%UCRTVersion%\um\module.modulemap" S:\SourceCache\swift\stdlib\public\Platform\winsdk.modulemap
mklink "%VCToolsInstallDir%\include\module.modulemap" S:\SourceCache\swift\stdlib\public\Platform\vcruntime.modulemap
mklink "%VCToolsInstallDir%\include\vcruntime.apinotes" S:\SourceCache\swift\stdlib\public\Platform\vcruntime.apinotes
endlocal
@echo on

# escape=`

FROM mcr.microsoft.com/windows/servercore:20H2 AS windows

LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

ARG GIT=https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe
ARG INSTALLER=https://download.swift.org/swift-5.7-release/windows10/swift-5.7-RELEASE/swift-5.7-RELEASE-windows10.exe
ARG PYTHON=https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe

# restore the default Windows shell for correct batch processing
SHELL ["cmd", "/S", "/C"]

# Install Visual Studio Build Tools
RUN                                                                             `
  curl -SLo vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe    `
  && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache           `
        --add Microsoft.VisualStudio.Component.Windows11SDK.22000               `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64                 `
      || IF "%EXITCODE%"=="3010" EXIT 0)                                        `
  && del /q vs_buildtools.exe

# Install Swift toolchain.
RUN                                                                             `
  curl -SLo installer.exe %INSTALLER%                                           `
  && (start /w installer.exe -q)                                                `
  && del /q installer.exe

# Install Git.
# See: git-[version]-[bit].exe /SAVEINF=git.inf and /?
RUN                                                                             `
  curl -SLo git.exe %GIT%                                                       `
  && (start /w git.exe /SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /FORCECLOSEAPPLICATIONS /NOICONS /COMPONENTS="gitlfs" /EditorOption=VIM /PathOption=Cmd /SSHOption=OpenSSH /CURLOption=WinSSL /UseCredentialManager=Enabled /PerformanceTweaksFSCache=Enabled /EnableSymlinks=Enabled /EnableFSMonitor=Enabled ) `
  && del /q git.exe

# Install Python.
# See: https://docs.python.org/3.10/using/windows.html
# FIXME: it appears that `PYTHONHOME` and `PYTHONPATH` are unset
RUN                                                                             `
  curl -SLo python.exe %PYTHON%                                                 `
  && (start /w python.exe /quiet InstallAllUsers=1 AssociateFiles=0 PrependPath=1 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_exe=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=0 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0 ) `
  && del /q python.exe

# Default to powershell
# FIXME: we need to grant ContainerUser the SeCreateSymbolicLinkPrivilege
# privilege so that it can create symbolic links.
# USER ContainerUser
CMD ["powershell.exe", "-nologo", "-ExecutionPolicy", "Bypass"]

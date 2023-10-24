# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS windows

LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Git.
# See: git-[version]-[bit].exe /SAVEINF=git.inf and /?
ARG GIT=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe
ARG GIT_SHA256=bd9b41641a258fd16d99beecec66132160331d685dfb4c714cea2bcc78d63bdb
RUN Write-Host ('Downloading {0} ...' -f ${env:GIT}) ;                          `
    Invoke-WebRequest -Uri ${env:GIT} -OutFile git.exe ;                        `
    Write-Host ('Verifying SHA256 ({0}) ...' -f ${env:GIT_SHA256}) ;            `
    if ((Get-FileHash git.exe -Algorithm sha256).Hash -ne ${env:GIT_SHA256}) {  `
      Write-Host 'Hash mismatch';                                               `
      exit 1;                                                                   `
    } ;                                                                         `
    Start-Process git.exe -ArgumentList @(                                      `
      '/SP-',                                                                   `
      '/VERYSILENT',                                                            `
      '/SUPPRESSMSGBOXES',                                                      `
      '/NOCANCEL',                                                              `
      '/NORESTART',                                                             `
      '/CLOSEAPPLICATIONS',                                                     `
      '/FORCECLOSEAPPLICATIONS',                                                `
      '/NOICONS',                                                               `
      '/COMPONENTS="gitlfs"',                                                   `
      '/EditorOption=VIM',                                                      `
      '/PathOption=Cmd',                                                        `
      '/SSHOption=OpenSSH',                                                     `
      '/CURLOption=WinSSL',                                                     `
      '/UseCredentialManager=Enabled',                                          `
      '/EnableSymlinks=Enabled',                                                `
      '/EnableFSMonitor=Enabled'                                                `
    ) -NoNewWindow -Wait ;                                                      `
    Remove-Item -Force git.exe ;                                                `
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Python.
# See: https://docs.python.org/3.10/using/windows.html
# FIXME: it appears that `PYTHONHOME` and `PYTHONPATH` are unset
ARG PYTHON=https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe
ARG PYTHON_SHA256=fb3d0466f3754752ca7fd839a09ffe53375ff2c981279fd4bc23a005458f7f5d
RUN Write-Host ('Downloading {0} ...' -f ${env:PYTHON}) ;                       `
    Invoke-WebRequest -Uri ${env:PYTHON} -OutFile python.exe ;                  `
    Write-Host ('Verifying SHA256 ({0}) ...' -f ${env:PYTHON_SHA256}) ;         `
    if ((Get-FileHash python.exe -Algorithm sha256).Hash -ne ${env:PYTHON_SHA256}) { `
      Write-Host 'Hash mismatch';                                               `
      exit 1;                                                                   `
    } ;                                                                         `
    Start-Process python.exe -ArgumentList @(                                   `
      '/quiet',                                                                 `
      'InstallAllUsers=1',                                                      `
      'AssociateFiles=0',                                                       `
      'PrependPath=1',                                                          `
      'Shortcuts=0',                                                            `
      'Include_doc=0',                                                          `
      'Include_debug=0',                                                        `
      'Include_dev=0',                                                          `
      'Include_exe=0',                                                          `
      'Include_launcher=0',                                                     `
      'InstallLauncherAllUsers=0',                                              `
      'Include_lib=1',                                                          `
      'Include_pip=0',                                                          `
      'Include_symbols=0',                                                      `
      'Include_tcltk=0',                                                        `
      'Include_test=0',                                                         `
      'Include_tools=0'                                                         `
    ) -NoNewWindow -Wait ;                                                      `
    Remove-Item -Force python.exe ;                                             `
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Visual Studio Build Tools
ARG VSB=https://aka.ms/vs/17/release/vs_buildtools.exe
ARG VSB_SHA256=d4e08524cb0e5bd061a24f507928d1cfb91dce192c5e12ed964b8343fc4cdedd
RUN Write-Host ('Downloading {0} ...' -f ${env:VSB}) ;                          `
    Invoke-WebRequest -Uri ${env:VSB} -OutFile vs_buildtools.exe ;              `
    Write-Host ('Verifying SHA256 ({0}) ...' -f ${env:VSB_SHA256}) ;            `
    if ((Get-FileHash vs_buildtools.exe -Algorithm sha256).Hash -ne ${env:VSB_SHA256}) { `
      Write-Host 'Hash mismatch';                                               `
      exit 1;                                                                   `
    } ;                                                                         `
    Start-Process vs_buildtools.exe -ArgumentList @(                            `
      '--quiet',                                                                `
      '--wait',                                                                 `
      '--norestart',                                                            `
      '--nocache',                                                              `
      '--add', 'Microsoft.VisualStudio.Component.Windows11SDK.22000',           `
      '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64'              `
    ) -NoNewWindow -Wait ;                                                      `
    Remove-Item -Force vs_buildtools.exe ;                                      `
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Swift toolchain.
ARG SWIFT=https://download.swift.org/swift-5.9.1-release/windows10/swift-5.9.1-RELEASE/swift-5.9.1-RELEASE-windows10.exe
ARG SWIFT_SHA256=b219d472eeb87612e9977518d2253ed88fba9ce2cd42cb8fef3011583b7d1369
RUN Write-Host ('Downloading {0} ...' -f ${env:SWIFT}) ;                        `
    Invoke-WebRequest -Uri ${env:SWIFT} -OutFile installer.exe ;                `
    Write-Host ('Verifying SHA256 ({0}) ...' -f ${env:SWIFT_SHA256}) ;          `
    if ((Get-FileHash installer.exe -Algorithm sha256).Hash -ne ${env:SWIFT_SHA256}) { `
      Write-Host 'Hash mismatch';                                               `
      exit 1;                                                                   `
    } ;                                                                         `
    Start-Process installer.exe -ArgumentList @(                                `
      '/quiet',                                                                 `
      '/norestart'                                                              `
    ) -NoNewWindow -Wait ;                                                      `
    Remove-Item -Force installer.exe ;                                          `
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Default to powershell
# FIXME: we need to grant ContainerUser the SeCreateSymbolicLinkPrivilege
# privilege so that it can create symbolic links.
# USER ContainerUser
CMD ["powershell.exe", "-nologo", "-ExecutionPolicy", "Bypass"]

FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS windows

LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV PYTHONIOENCODING UTF-8
ENV PYTHONUTF8=1

# Enable Developer Mode.
RUN reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
# Enable Long Paths
RUN reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /t REG_DWORD /f /v "LongPathsEnabled" /d "1"

# Install Git.
# See: git-[version]-[bit].exe /SAVEINF=git.inf and /?
ARG GIT=https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-64-bit.exe
ARG GIT_SHA256=726056328967F242FE6E9AFBFE7823903A928AFF577DCF6F517F2FB6DA6CE83C
RUN Write-Host -NoNewLine ('Downloading {0} ... ' -f ${env:GIT});               \
    Invoke-WebRequest -Uri ${env:GIT} -OutFile git.exe;                         \
    Write-Host '✓';                                                             \
    Write-Host -NoNewLine ('Verifying SHA256 ({0}) ... ' -f ${env:GIT_SHA256}); \
    $Hash = Get-FileHash git.exe -Algorithm sha256;                             \
    if ($Hash.Hash -eq ${env:GIT_SHA256}) {                                     \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Hash.Hash);                                     \
      exit 1;                                                                   \
    }                                                                           \
    Write-Host -NoNewLine 'Installing git ... ';                                \
    $Process =                                                                  \
        Start-Process git.exe -Wait -PassThru -NoNewWindow -ArgumentList @(     \
          '/SP-',                                                               \
          '/VERYSILENT',                                                        \
          '/SUPPRESSMSGBOXES',                                                  \
          '/NOCANCEL',                                                          \
          '/NORESTART',                                                         \
          '/CLOSEAPPLICATIONS',                                                 \
          '/FORCECLOSEAPPLICATIONS',                                            \
          '/NOICONS',                                                           \
          '/COMPONENTS="gitlfs"',                                               \
          '/EditorOption=VIM',                                                  \
          '/PathOption=Cmd',                                                    \
          '/SSHOption=OpenSSH',                                                 \
          '/CURLOption=WinSSL',                                                 \
          '/UseCredentialManager=Enabled',                                      \
          '/EnableSymlinks=Enabled',                                            \
          '/EnableFSMonitor=Enabled'                                            \
        );                                                                      \
    if ($Process.ExitCode -eq 0) {                                              \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }                                                                           \
    Remove-Item -Force git.exe;                                                 \
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Python
ARG PY39=https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe
ARG PY39_SHA256=FB3D0466F3754752CA7FD839A09FFE53375FF2C981279FD4BC23A005458F7F5D
RUN Write-Host -NoNewLine ('Downloading {0} ... ' -f ${env:PY39});              \
    Invoke-WebRequest -Uri ${env:PY39} -OutFile python-3.9.13-amd64.exe;        \
    Write-Host '✓';                                                             \
    Write-Host -NoNewLine ('Verifying SHA256 ({0}) ... ' -f ${env:PY39_SHA256});\
    $Hash = Get-FileHash python-3.9.13-amd64.exe -Algorithm sha256;             \
    if ($Hash.Hash -eq ${env:PY39_SHA256}) {                                    \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Hash.Hash);                                     \
      exit 1;                                                                   \
    }                                                                           \
    Write-Host -NoNewLine 'Installing Python ... ';                             \
    $Process =                                                                  \
        Start-Process python-3.9.13-amd64.exe -Wait -PassThru -NoNewWindow -ArgumentList @( \
           'AssociateFiles=0',                                                  \
           'Include_doc=0',                                                     \
           'Include_debug=0',                                                   \
           'Include_lib=1',                                                     \
           'Include_tcltk=0',                                                   \
           'Include_test=0',                                                    \
           'InstallAllUsers=1',                                                 \
           'InstallLauncherAllUsers=0',                                         \
           'PrependPath=1',                                                     \
           '/quiet'                                                             \
         );                                                                     \
    if ($Process.ExitCode -eq 0) {                                              \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }                                                                           \
    Remove-Item -Force python-3.9.13-amd64.exe;                                 \
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Visual Studio Build Tools
ARG VSB=https://aka.ms/vs/17/release/vs_buildtools.exe
ARG VSB_SHA256=15A2A6591B1E91B63E9909864FCBC68459EB26124B814618947215F754CD9CEE
RUN Write-Host -NoNewLine ('Downloading {0} ... ' -f ${env:VSB});               \
    Invoke-WebRequest -Uri ${env:VSB} -OutFile vs_buildtools.exe;               \
    Write-Host '✓';                                                             \
    Write-Host -NoNewLine ('Verifying SHA256 ({0}) ... ' -f ${env:VSB_SHA256}); \
    $Hash = Get-FileHash vs_buildtools.exe -Algorithm sha256;                   \
    if ($Hash.Hash -eq ${env:VSB_SHA256}) {                                     \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Hash.Hash);                                     \
      exit 1;                                                                   \
    }                                                                           \
    Write-Host -NoNewLine 'Installing Visual Studio Build Tools ... ';          \
    $Process =                                                                  \
        Start-Process vs_buildtools.exe -Wait -PassThru -NoNewWindow -ArgumentList @( \
          '--quiet',                                                            \
          '--wait',                                                             \
          '--norestart',                                                        \
          '--nocache',                                                          \
          '--add', 'Microsoft.VisualStudio.Component.Windows11SDK.22000',       \
          '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64'          \
        );                                                                      \
    if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010) {               \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }                                                                           \
    Remove-Item -Force vs_buildtools.exe;                                       \
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Install Swift toolchain.
ARG SWIFT_RELEASE_METADATA=https://download.swift.org/development/windows10/latest-build.json
RUN $Release = curl.exe -sL ${env:SWIFT_RELEASE_METADATA} | ConvertFrom-JSON;   \
    $SWIFT_URL = "\"https://download.swift.org/development/windows10/$($Release.dir)/$($Release.download)\""; \
    Write-Host -NoNewLine ('Downloading {0} ... ' -f ${SWIFT_URL});             \
    Invoke-WebRequest -Uri ${SWIFT_URL} -OutFile installer.exe;                 \
    Write-Host '✓';                                                             \
    Write-Host -NoNewLine 'Installing Swift ... ';                              \
    $Process =                                                                  \
        Start-Process installer.exe -Wait -PassThru -NoNewWindow -ArgumentList @( \
           '/quiet',                                                            \
           '/norestart'                                                         \
         );                                                                     \
    if ($Process.ExitCode -eq 0) {                                              \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }                                                                           \
    Remove-Item -Force installer.exe;                                           \
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# FIXME: we should use a non-Administrator user
# USER ContainerUser
CMD ["powershell.exe", "-nologo", "-ExecutionPolicy", "Bypass"]

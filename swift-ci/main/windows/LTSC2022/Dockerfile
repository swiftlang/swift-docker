FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS windows

LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV PYTHONIOENCODING UTF-8
ENV PYTHONUTF8 1

# Enable Developer Mode.
RUN Write-Host -NoNewLine "Enabling Developer Mode";                            \
    $Process =                                                                  \
        Start-Process reg.exe -Wait -PassThru -NoNewWindow -ArgumentList @(     \
          'add',                                                                \
          'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock', \
          '/f',                                                                 \
          '/t', 'REG_DWORD',                                                    \
          '/v', 'AllowDevelopmentWithoutDevLicense',                            \
          '/d', '1'                                                             \
        );                                                                      \
    if ($Process.ExitCode -eq 0) {                                              \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }

# Enable Long Paths
# RUN Write-Host -NoNewLine "Enabling Long Paths";                                \
#     $Process =                                                                  \
#         Start-Process reg.exe -Wait -PassThru -NoNewWindow -ArgumentList @(     \
#           'add',                                                                \
#           'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem',     \
#           '/f',                                                                 \
#           '/t', 'REG_DWORD',                                                    \
#           '/v', 'LongPathsEnabled',                                             \
#           '/d' '1'                                                              \
#         );                                                                      \
#     if ($Process.ExitCode -eq 0) {                                              \
#       Write-Host '✓';                                                           \
#     } else {                                                                    \
#       Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
#       exit 1;                                                                   \
#     }

# Install Git.
# See: git-[version]-[bit].exe /SAVEINF=git.inf and /?
ARG GIT=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe
ARG GIT_SHA256=BD9B41641A258FD16D99BEECEC66132160331D685DFB4C714CEA2BCC78D63BDB
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
           'Include_dev=1',                                                     \
           'Include_exe=1',                                                     \
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
ARG VSB_SHA256=C792BDB0FD46155DE19955269CAC85D52C4C63C23DB2CF43D96B9390146F9390
RUN Write-Host -NoNewLine ('Downloading {0} ... ' -f ${env:VSB});               \
    Invoke-WebRequest -Uri ${env:VSB} -OutFile vs_buildtools.exe;               \
    Write-Host '✓';                                                             \
    Write-Host -NoNewLine ('Verifying SHA256 ({0}) ... ' -f ${env:VSB_SHA256}); \
    $Hash = Get-FileHash vs_buildtools.exe -Algorithm sha256;                   \
    if ($Hash.Hash -eq ${env:VSB_SHA256}) {                                     \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Hash.Hash);                                     \
    }                                                                           \
    Write-Host -NoNewLine 'Installing Visual Studio Build Tools ... ';          \
    $Process =                                                                  \
        Start-Process vs_buildtools.exe -Wait -PassThru -NoNewWindow -ArgumentList @( \
          '--quiet',                                                            \
          '--wait',                                                             \
          '--norestart',                                                        \
          '--nocache',                                                          \
          '--add', 'Microsoft.VisualStudio.Component.Windows11SDK.22000',       \
          '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',         \
          '--add', 'Microsoft.VisualStudio.Component.VC.Tools.ARM64',           \
          '--add', 'Microsoft.VisualStudio.Component.VC.ATL',                   \
          '--add', 'Microsoft.VisualStudio.Component.VC.ATL.ARM64',             \
          '--add', 'Microsoft.VisualStudio.Component.CMake.Project',            \
          '--add', 'Microsoft.NetCore.Component.SDK'                            \
        );                                                                      \
    if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010) {               \
      Write-Host '✓';                                                           \
    } else {                                                                    \
      Write-Host ('✘ ({0})' -f $Process.ExitCode);                              \
      exit 1;                                                                   \
    }                                                                           \
    Remove-Item -Force vs_buildtools.exe;                                       \
    Remove-Item -ErrorAction SilentlyContinue -Force -Recurse ${env:TEMP}\*

# Default to powershell
# FIXME: we need to grant ContainerUser the SeCreateSymbolicLinkPrivilege
# privilege so that it can create symbolic links.
# USER ContainerUser
CMD ["powershell.exe", "-nologo", "-ExecutionPolicy", "Bypass"]

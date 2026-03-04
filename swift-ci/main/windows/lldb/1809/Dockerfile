FROM mcr.microsoft.com/windows/servercore:1809

SHELL ["powershell", "-ExecutionPolicy", "Bypass", "-Command"]

# Enable TLS 1.2 for downloads
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Enable long paths and developer mode (symlinks)
RUN Set-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\FileSystem -Name LongPathsEnabled -Value 1
RUN Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1 -Type DWord

# Visual Studio 2022 Community with C++ and Windows SDK components
RUN Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile vs_community.exe; \
    Start-Process -FilePath .\\vs_community.exe -Wait -ArgumentList \
      '--quiet --wait --norestart \
      --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
      --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 \
      --add Microsoft.VisualStudio.Component.VC.14.44.17.14.ARM64 \
      --add Microsoft.VisualStudio.Component.VC.14.44.17.14.x86.x64 \
      --add Microsoft.VisualStudio.Component.VC.ATL \
      --add Microsoft.VisualStudio.Component.VC.ATL.ARM64 \
      --add Microsoft.VisualStudio.Component.Windows10SDK \
      --add Microsoft.VisualStudio.Component.Windows11SDK.22621 \
      --add Microsoft.VisualStudio.Component.VC.CMake.Project \
      --add Microsoft.NetCore.Component.Runtime.9.0'; \
    Remove-Item -Force vs_community.exe

# Git
RUN Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe -OutFile git.exe; \
    Start-Process -FilePath .\\git.exe -Wait -ArgumentList \
      '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=icons,ext\\reg\\shellhere,assoc,assoc_sh'; \
    Remove-Item -Force git.exe

# Python 3.13
RUN Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.13.0/python-3.13.0-amd64.exe -OutFile python.exe; \
    Start-Process -FilePath .\\python.exe -Wait -ArgumentList \
      '/quiet InstallAllUsers=1 PrependPath=1 Include_test=0'; \
    Remove-Item -Force python.exe

# CMake 3.31.8
RUN Invoke-WebRequest -Uri https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-windows-x86_64.msi -OutFile cmake.msi; \
    Start-Process msiexec -Wait -ArgumentList \
      '/i cmake.msi /quiet /norestart ADD_CMAKE_TO_PATH=System'; \
    Remove-Item -Force cmake.msi

# Ninja 1.13.0
RUN Invoke-WebRequest -Uri https://github.com/ninja-build/ninja/releases/download/v1.13.0/ninja-win.zip -OutFile ninja.zip; \
    Expand-Archive -Path ninja.zip -DestinationPath C:\\ninja; \
    Remove-Item -Force ninja.zip; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\\ninja', [EnvironmentVariableTarget]::Machine)

# SWIG 4.3.0
RUN curl.exe -L -o swig.zip https://downloads.sourceforge.net/project/swig/swigwin/swigwin-4.3.0/swigwin-4.3.0.zip; \
    Expand-Archive -Path swig.zip -DestinationPath C:\\; \
    Remove-Item -Force swig.zip; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\\swigwin-4.3.0', [EnvironmentVariableTarget]::Machine)

# Git global config
RUN git config --global core.symlink true; \
    git config --global core.autocrlf false

# vcpkg + libxml2
RUN git clone https://github.com/microsoft/vcpkg C:\\vcpkg; \
    C:\\vcpkg\\bootstrap-vcpkg.bat -disableMetrics
SHELL ["cmd", "/S", "/C"]
RUN ""C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" && C:\vcpkg\vcpkg install libxml2:x64-windows"
SHELL ["powershell", "-ExecutionPolicy", "Bypass", "-Command"]
RUN [Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\\vcpkg', [EnvironmentVariableTarget]::Machine)

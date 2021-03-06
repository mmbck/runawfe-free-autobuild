set JDK8_HOME=C:/jdk1.8.0_191
set WFE_VERSION=4.4.0
set RESULTS_DIR=%~dp0results
set GIT_SOURCE_URL=https://github.com/processtech
set GIT_BRANCH_NAME=master
set GIT_PROJECT_EDITION=free


rem Clean artifacts from previous builds
rd /S /Q build
rd /S /Q %RESULTS_DIR%

rem Create folders for artifacts from new build
mkdir build
mkdir %RESULTS_DIR%

rem Copy required zip files and folders (jboss and so on) into build directory
jar -cMf wildfly.zip wildfly
move wildfly.zip build

copy readme build


rem Export source code
cd /D build
git clone %GIT_SOURCE_URL%/runawfe-%GIT_PROJECT_EDITION%-server.git source/projects/wfe
cd source/projects/wfe
git checkout %GIT_BRANCH_NAME%
cd ../../../
rd /S /Q source\projects\wfe\.git
git clone %GIT_SOURCE_URL%/runawfe-%GIT_PROJECT_EDITION%-devstudio.git source/projects/gpd
cd source/projects/gpd
git checkout %GIT_BRANCH_NAME%
cd ../../../
rd /S /Q source\projects\gpd\.git
git clone %GIT_SOURCE_URL%/runawfe-%GIT_PROJECT_EDITION%-notifier-java.git source/projects/rtn
cd source/projects/rtn
git checkout %GIT_BRANCH_NAME%
cd ../../../
rd /S /Q source\projects\rtn\.git
git clone %GIT_SOURCE_URL%/runawfe-%GIT_PROJECT_EDITION%-installer.git source/projects/installer
cd source/projects/installer
git checkout %GIT_BRANCH_NAME%
cd ../../../
rd /S /Q source\projects\installer\.git

mkdir source\docs
mkdir source\docs\guides
copy readme source\docs\guides\

rem Update projects version
cd source\projects\installer\windows\
call mvn versions:set -DnewVersion=%WFE_VERSION%
cd ../../wfe/wfe-appserver
call mvn versions:set -DnewVersion=%WFE_VERSION%
cd ../wfe-webservice-client
call mvn versions:set -DnewVersion=%WFE_VERSION%
cd ../wfe-app
call mvn versions:set -DnewVersion=%WFE_VERSION%
rem cd ../wfe-remotebots
rem call mvn versions:set -DnewVersion=%WFE_VERSION%
cd ../../rtn
call mvn versions:set -DnewVersion=%WFE_VERSION%
cd ../gpd/plugins
call mvn tycho-versions:set-version -DnewVersion=%WFE_VERSION%

cd ..\..\..\..\
jar -cMf source.zip source
mkdir %RESULTS_DIR%\source
move source.zip %RESULTS_DIR%\source\source-%WFE_VERSION%.zip

cd source\projects\installer\windows\
rem Build distr
call mvn clean package -Djdk.dir="%~dp0jdk" -Djava.home.8=%JDK8_HOME%

xcopy /E /Q target\test-result %RESULTS_DIR%\test-result\
mkdir %RESULTS_DIR%\Execution\wildfly
copy target\artifacts\Installer32\wildfly\RunaWFE-Installer.exe %RESULTS_DIR%\Execution\wildfly\RunaWFE-%WFE_VERSION%-Wildfly-java8_32.exe
copy target\artifacts\Installer64\wildfly\RunaWFE-Installer.exe %RESULTS_DIR%\Execution\wildfly\RunaWFE-%WFE_VERSION%-Wildfly-java8_64.exe
mkdir %RESULTS_DIR%\ISO
copy target\*.iso %RESULTS_DIR%\ISO\

mkdir %RESULTS_DIR%\bin
mkdir %RESULTS_DIR%\bin\server
rem Create bin file for wildfly server
jar xf target\artifacts\wildfly\app-server\wfe-appserver-base-%WFE_VERSION%.zip 
jar xf target\artifacts\wildfly\app-server\wfe-appserver-diff-%WFE_VERSION%.zip 
xcopy /E /Q ..\simulation\* jboss\
move jboss wildfly
jar -cMf runawfe-wildfly-java8-%WFE_VERSION%.zip wildfly
rd /S /Q wildfly
move runawfe-wildfly-java8-%WFE_VERSION%.zip %RESULTS_DIR%\bin\server\runawfe-wildfly-java8-%WFE_VERSION%.zip

rem Create bin file for gpd
xcopy /E /Q target\artifacts\gpd\all %RESULTS_DIR%\bin\gpd\

rem Create bin file for rtn 
mkdir %RESULTS_DIR%\bin\rtn

xcopy /E /Q target\artifacts\rtn\32 rtn\
jar -cMf runawfe-rtn-win32-%WFE_VERSION%.zip rtn
rd /S /Q rtn
move runawfe-rtn-win32-%WFE_VERSION%.zip %RESULTS_DIR%\bin\rtn\runawfe-rtn-win32-%WFE_VERSION%.zip

xcopy /E /Q target\artifacts\rtn\64 rtn\
jar -cMf runawfe-rtn-win64-%WFE_VERSION%.zip rtn
rd /S /Q rtn
move runawfe-rtn-win64-%WFE_VERSION%.zip %RESULTS_DIR%\bin\rtn\runawfe-rtn-win64-%WFE_VERSION%.zip


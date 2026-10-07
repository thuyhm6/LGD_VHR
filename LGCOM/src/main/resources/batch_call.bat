@echo off
@setlocal

@set JAVA_HOME=C:\LGDWork\jdk\1.7.0_80
@set WAS_HOME=C:\LGDWork\was\tomcat\8.0.37
@set PROJECT_HOME=C:\LGDWork\workspace
@set SORC_HOME=%PROJECT_HOME%\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\LGCOM
@set LOG_HOME=%PROJECT_HOME%\LGCOM\batch

@set CLASSPATH=.;%WAS_HOME%\lib\*;%WAS_HOME%\lib\ojdbc6-11.1.0.7.0.jar;%SORC_HOME%\WEB-INF\lib\*;%SORC_HOME%\WEB-INF\classes

echo ***************************************************************
echo   - JAVA_HOME      : %JAVA_HOME%
echo   - WAS_HOME       : %WAS_HOME%
echo   - PROJECT_HOME   : %PROJECT_HOME%
echo   - SORC_HOME      : %SORC_HOME%
echo   - LOG_HOME       : %LOG_HOME%
echo   - CLASSPATH      : %CLASSPATH%
echo   - PARAM1         : %1
echo   - PARAM2         : %2
echo   - PARAM3         : %3
echo   - PARAM4         : %4
echo   - PARAM5         : %5
echo ***************************************************************

@cd %SORC_HOME%\WEB-INF\classes
%JAVA_HOME%\bin\java -Dfile.encoding=utf-8 -cp %CLASSPATH% com.lgd.lgcom.common.batch.BatchRunner %*
@endlocal

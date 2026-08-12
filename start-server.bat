@echo off
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot
set PATH=%JAVA_HOME%\bin;%~dp0tools\apache-maven-3.9.6\bin;%PATH%
cd /d "%~dp0backend"
echo Iniciando servidor em http://localhost:8080/login.jsp
mvn jetty:run

#!/bin/sh
set -e
PORT="${PORT:-8080}"
sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml
exec catalina.sh run

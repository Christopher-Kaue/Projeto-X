#!/bin/sh
PORT="${PORT:-8080}"
sed -i "s|<Connector port=\"8080\"|<Connector port=\"${PORT}\"|" /usr/local/tomcat/conf/server.xml
exec catalina.sh run

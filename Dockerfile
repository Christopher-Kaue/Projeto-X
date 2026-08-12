FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY backend/pom.xml backend/pom.xml
COPY backend/src backend/src
COPY frontend frontend
WORKDIR /app/backend
RUN mvn clean package -DskipTests -q

FROM tomcat:9.0-jdk17-temurin
ENV JAVA_OPTS="-Xmx512m -Xms256m"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/backend/target/projeto-x.war /tmp/app.war
RUN mkdir -p /usr/local/tomcat/webapps/ROOT \
 && cd /usr/local/tomcat/webapps/ROOT \
 && jar xf /tmp/app.war \
 && rm /tmp/app.war
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

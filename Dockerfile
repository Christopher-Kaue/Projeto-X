FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY backend/pom.xml backend/pom.xml
COPY backend/src backend/src
COPY frontend frontend
WORKDIR /app/backend
RUN mvn clean package -DskipTests -q

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN apk add --no-cache wget \
 && wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.54.v20240208/jetty-runner-9.4.54.v20240208.jar -O jetty-runner.jar
COPY --from=build /app/backend/target/projeto-x.war app.war
ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "java -Xmx512m -jar jetty-runner.jar --port ${PORT} --path / app.war"]

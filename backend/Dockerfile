FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline --no-transfer-progress
COPY src ./src
RUN mvn -q -DskipTests clean package --no-transfer-progress

FROM maven:3.9.8-eclipse-temurin-17
WORKDIR /app
COPY --from=build /app/target/backend.jar /app/app.jar
ENV JAVA_OPTS=""
EXPOSE 8083
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]

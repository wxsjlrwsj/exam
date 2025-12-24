FROM mcr.microsoft.com/openjdk/jdk:17 AS build
WORKDIR /app
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*
COPY pom.xml .
COPY src ./src
ENV MAVEN_OPTS="-Dhttps.protocols=TLSv1.2 -Djava.security.egd=file:/dev/./urandom"
RUN mvn -q -Dmaven.test.skip=true clean package --no-transfer-progress

FROM mcr.microsoft.com/openjdk/jre:17
WORKDIR /app
COPY --from=build /app/target/backend.jar /app/app.jar
ENV JAVA_OPTS=""
EXPOSE 8083
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]

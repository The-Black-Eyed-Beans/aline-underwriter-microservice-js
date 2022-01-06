FROM openjdk:11-jre-slim

ENV APP_PORT=8071

COPY underwriter-microservice/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
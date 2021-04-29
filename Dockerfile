FROM adoptopenjdk/openjdk14-openj9:x86_64-alpine-jre-14_36.1_openj9-0.19.0
ARG JAR_FILE=target/*.jar

CMD apk add postgresql-client -y

COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java", "-jar", "app.jar --spring.config.location=file:///application.properties"]

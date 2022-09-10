FROM adoptopenjdk/openjdk14-openj9:x86_64-alpine-jre-14_36.1_openj9-0.19.0
ARG JAR_FILE=target/spring-petclinic-2.4.2.jar

CMD apk add postgresql-client -y

COPY ${JAR_FILE} spring-petclinic-2.4.2.jar

ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.jar --spring.config.location=file:///application.properties"]

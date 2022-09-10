FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE=target/spring-petclinic-2.4.2.jar
COPY ${JAR_FILE} spring-petclinic-2.4.2.jar
ENTRYPOINT ["java","-jar","/spring-petclinic-2.4.2.jar --spring.config.location=file:///application.properties"]
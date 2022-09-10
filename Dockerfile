FROM openjdk:8-jdk-alpine
VOLUME /tmp
#COPY target/*.jar /app.jar
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
EXPOSE 8080
ENTRYPOINT ["java -cp","app:app/lib/* --spring.config.location=file:///application.properties"]
#ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS}","-jar","app.jar --spring.config.location=file:///application.properties"]
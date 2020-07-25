FROM openjdk:8-jre-alpine
FROM tomcat:8.5.54-jdk8-openjdk

ENV TZ=America/Los_Angeles


WORKDIR $CATALINA_HOME
COPY target/JspExample-0.0.2-SNAPSHOT.war /usr/local/tomcat/webapps/

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["catalina.sh", "run"]

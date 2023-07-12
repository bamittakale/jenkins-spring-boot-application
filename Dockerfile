FROM tomcat:9.0.46-jdk8-openjdk
COPY ./target/spring-boot-with-jenkins-test.war ${CATALINA_HOME}/webapps/
RUN sed -i '71 a <Connector port="8484" protocol="HTTP/1.1" maxThreads="150" scheme="http" secure="false" redirectPort="8484" />' ${CATALINA_HOME}/conf/server.xml
RUN sed -i -e '69,71d' ${CATALINA_HOME}/conf/server.xml
RUN sed -i '23 a <security-constraint><web-resource-collection><web-resource-name>Entire Application<web-resource-name><url-pattern>/*</url-pattern></web-resource-collection><user-data-constraint><transport-guarantee>CONFIDENTIAL</transport-guarantee></user-data-constraint></security-constraint>' ${CATALINA_HOME}/conf/web.xml
EXPOSE 8484
ENTRYPOINT ["catalina.sh", "sh"]
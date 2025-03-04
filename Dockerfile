FROM tomcat:9
WORKDIR /usr/local/tomcat/webapps/
COPY ./sample-app-*.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
EXPOSE 8080
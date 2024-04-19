FROM alpine:latest

# def tomcat version
ARG TOMCAT_VERSION=apache-tomcat-10.1.20

# def system env
ENV LANG=C.UTF-8
ENV server_system_os=linux
ENV file_seprator=/

# def java runtime env
ENV datasource_url=jdbc:h2:file:/app/H2_Data/git-package-tool;DB_CLOSE_ON_EXIT=FALSE
ENV war_store_path=/app/targets
ENV git_store_path=/app/git

ENV mvn_jdk8_path=/usr/lib/jvm/java-1.8-openjdk
ENV mvn_jdk11_path=/usr/lib/jvm/java-11-openjdk
ENV mvn_jdk17_path=/usr/lib/jvm/java-17-openjdk

# create folder
RUN mkdir -p /app/H2_Data/git-package-tool && \
    mkdir -p /app/targets

# download tools
RUN apk update && \
    apk add --no-cache \
    git \
    maven \
    openjdk17 \
    openjdk11 \
    openjdk8 && \
    rm -rf /var/cache/apk/*

# install lombok
RUN wget https://projectlombok.org/downloads/lombok.jar -O /tmp/lombok.jar

RUN /usr/lib/jvm/java-1.8-openjdk/bin/java -jar /tmp/lombok.jar install /usr/lib/jvm/java-1.8-openjdk/
RUN /usr/lib/jvm/java-11-openjdk/bin/java -jar /tmp/lombok.jar install /usr/lib/jvm/java-11-openjdk/
RUN /usr/lib/jvm/java-17-openjdk/bin/java -jar /tmp/lombok.jar install /usr/lib/jvm/java-17-openjdk/

RUN rm /tmp/lombok.jar

# copy catalina into container
COPY ./target/${TOMCAT_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/${TOMCAT_VERSION}.tar.gz -C /opt/ && \
    rm /tmp/${TOMCAT_VERSION}.tar.gz && \
    ln -s /opt/$TOMCAT_VERSION /opt/tomcat

# copy server env ( for encrypt & version )
COPY ./target/setenv.sh /opt/tomcat/bin/

# set env path
ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PATH $PATH:$JAVA_HOME/bin
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin
ENV M2_HOME=/usr/share/java/maven-3
ENV PATH $PATH:$M2_HOME/bin

# copy .war file
RUN rm -rf /opt/tomcat/webapps/ROOT
COPY ./target/*.war /opt/tomcat/webapps/ROOT.war

# copy fstop's .jar files ( don't know reason can't compile online bank projects )
# COPY ./target/tw/ /root/.m2/repository/tw/
# COPY ./target/projectlombok/ /root/.m2/repository/org/projectlombok/

# def access 755
RUN chmod -R 755 /opt/tomcat/webapps/

# def workspace
WORKDIR /app

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
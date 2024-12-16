# Base image with JDK 21
FROM docker.io/eclipse-temurin:21-jdk-jammy

# Metadata
LABEL name="WebGoat: A deliberately insecure Web Application"
LABEL maintainer="WebGoat team"

# Create a non-root user and configure permissions
RUN \
  useradd -ms /bin/bash webgoat && \
  chgrp -R 0 /home/webgoat && \
  chmod -R g=u /home/webgoat

# Switch to non-root user
USER webgoat

# Set working directory
WORKDIR /home/webgoat

# Copy the application JAR file to the container
COPY --chown=webgoat target/webgoat-*.jar /home/webgoat/webgoat.jar

# Expose ports
EXPOSE 8080 9090

# Set timezone (optional)
ENV TZ=Europe/Amsterdam

# Java startup options and entrypoint
ENTRYPOINT [ "java", \
   "-Duser.home=/home/webgoat", \
   "-Dfile.encoding=UTF-8", \
   "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
   "--add-opens", "java.base/java.util=ALL-UNNAMED", \
   "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED", \
   "--add-opens", "java.base/java.text=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.beans=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED", \
   "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
   "--add-opens", "java.base/java.io=ALL-UNNAMED", \
   "-Drunning.in.docker=true", \
   "-jar", "webgoat.jar", "--server.address", "0.0.0.0" ]

# Add a health check
HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl --fail http://localhost:8080/WebGoat/actuator/health || exit 1

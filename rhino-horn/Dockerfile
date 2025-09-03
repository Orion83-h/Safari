ARG VERSION=17

# Define base image
FROM bellsoft/liberica-openjdk-alpine:${VERSION}

LABEL Maintainer="Samuel Haddison" \
      Email="samuelhaddison71@gmail.com"

# Set working directory as an environmental variable
ENV WORK_DIR=/app

# Set the working directory
WORKDIR ${WORK_DIR}

# Copy the application JAR
COPY rhino-horn/target/*.jar app.jar

# Set a non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring && \
    chown spring:spring app.jar

# Switch to the non-root user
USER spring:spring

# Define application port
EXPOSE 8084

ENTRYPOINT ["java","-jar","app.jar"]

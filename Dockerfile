# Stage 1: Build the application
# Use a base image that has both Maven and Java 17
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory
WORKDIR /app

# Copy pom.xml first
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy the rest of our source code
COPY src src

# Build the application
RUN mvn package -DskipTests


# Stage 2: Create the final, lightweight image
# This stage stays the same
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy the .jar file from the 'build' stage
# The path is the same: /app/target/*.jar
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# This is the command that will run when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]
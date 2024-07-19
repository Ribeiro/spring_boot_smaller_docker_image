# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-alpine AS build

# Set the working directory
WORKDIR /app

# Copy the Maven or Gradle wrapper and configuration files
COPY . .

# Build the application using Maven or Gradle
# Uncomment the appropriate line based on your build tool
# For Maven:
RUN ./mvnw clean package -DskipTests && rm -rf ~/.m2

# For Gradle:
# RUN ./gradlew build -x test && rm -rf ~/.gradle

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jre-alpine

# Define the application user
ARG APPLICATION_USER=spring

# Create the application user and group
RUN addgroup --system $APPLICATION_USER && adduser --system $APPLICATION_USER --ingroup $APPLICATION_USER

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar /app/app.jar

# Change ownership of the application directory to the application user
RUN chown -R $APPLICATION_USER:$APPLICATION_USER /app

# Switch to the application user
USER $APPLICATION_USER

# Expose the port on which the application will run
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
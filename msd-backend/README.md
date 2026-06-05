# MSD Backend

Spring Boot backend for the MSD project.

## Tech Stack

- Java 25 (Gradle toolchain)
- Spring Boot 4
- Spring Security (OAuth2 Resource Server / JWT)
- Spring Data JPA
- PostgreSQL
- Flyway

## Prerequisites

- JDK 25 installed
- PostgreSQL running

## Run Locally

1. Configure database and local environment values.
2. Run the application:

```bash
./gradlew bootRun
```

## Run Tests

Run all tests:

```bash
./gradlew test
```

## API Documentation

Swagger UI is available when the app is running:

- `http://localhost:8080/swagger-ui/index.html`

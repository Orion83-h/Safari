# Rhino Horn - Jenkins CI/CD Pipeline Project

A comprehensive DevSecOps CI/CD pipeline implementation using Jenkins, demonstrating modern software delivery practices with integrated security scanning, code quality analysis, and automated deployment workflows.

## 🏗️ Project Overview

This project showcases a complete CI/CD pipeline for a Spring Boot application called "Rhino Horn" that implements GitOps and DevSecOps principles. The pipeline includes security scanning, code quality analysis, containerization, vulnerability assessment, and automated deployment with comprehensive monitoring and notification systems.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Pipeline Stages](#pipeline-stages)
- [Configuration](#configuration)
- [Usage](#usage)
- [Security Features](#security-features)
- [Monitoring & Notifications](#monitoring--notifications)
- [Troubleshooting](#troubleshooting)

## 🏛️ Architecture

```
📊 [View CI/CD Pipeline Diagram](https://Orion83-h.github.io/Safari/cicd-pipeline.html)
```

## ✨ Features

### 🔒 Security-First Approach
- **Secrets Detection**: GitLeaks integration for credential scanning
- **Container Security**: Trivy vulnerability scanning with configurable severity levels
- **Secure Dockerfile**: Non-root user validation and security best practices
- **Quality Gates**: SonarCloud/SonarQube integration with quality thresholds

### 🚀 Automated CI/CD
- **Multi-branch Support**: Configurable branch-based deployments
- **Parallel Processing**: Concurrent execution of independent stages
- **Artifact Management**: Nexus repository integration
- **Container Registry**: Docker Hub integration with automated pushes

### 📊 Comprehensive Monitoring
- **Build Retention**: Configurable build and artifact retention policies
- **Email Notifications**: Environment-specific notification system
- **Report Generation**: HTML reports for security scans and code quality
- **S3 Integration**: Automated report storage and archival

## 🛠️ Prerequisites

### Infrastructure Requirements
- Jenkins server with Docker support
- Maven 3.9.11+
- Java 17+
- Docker Engine
- SonarQube/SonarCloud instance
- Nexus Repository Manager
- AWS S3 bucket for reports

### Jenkins Plugins
- Pipeline Plugin
- Docker Pipeline Plugin
- SonarQube Scanner Plugin
- Email Extension Plugin
- AWS Steps Plugin
- Credentials Plugin

### External Tools
- GitLeaks for secrets scanning
- Trivy for container vulnerability scanning
- Docker for containerization

## 📁 Project Structure

```
Safari/
├── .github/workflows/           # GitHub Actions CI pipeline
│   └── rhino-ci.yml
├── rhino-horn/                  # Main Spring Boot application
│   ├── src/
│   │   ├── main/java/           # Application source code
│   │   │   └── com/rhino_horn/safari/rhino_horn/
│   │   │       └── RhinoHornApplication.java
│   │   ├── main/resources/      # Application resources
│   │   │   ├── static/          # CSS, JS files
│   │   │   ├── templates/       # Thymeleaf templates
│   │   │   └── application.properties
│   │   └── test/java/           # Test classes
│   ├── Dockerfile               # Container definition
│   ├── Jenkinsfile             # Jenkins pipeline definition
│   ├── pom.xml                 # Maven configuration
│   ├── test-run.sh             # Smoke test script
│   ├── dockerfile-check.sh     # Dockerfile security validation
│   └── mvnw, mvnw.cmd          # Maven wrapper
└── README.md                   # This file
```

## 🔄 Pipeline Stages

### 1. **Source Code Retrieval**
- Shallow clone from Git repository
- Branch-specific checkout based on parameters
- Clean workspace preparation

### 2. **Security Scanning**
```bash
# GitLeaks secrets detection
gitleaks detect --source rhino-horn \
  --report-format sarif \
  --report-path gitleaks-reports/gitleaks-report.sarif
```

### 3. **Build & Package**
```bash
# Maven build with test skipping for faster builds
mvn clean package -DskipTests
```

### 4. **Artifact Deployment**
```bash
# Deploy to Nexus repository
mvn deploy
```

### 5. **Code Quality Analysis** (Parallel)
- **SonarCloud Analysis**: Code quality metrics and security hotspots
- **SonarQube Quality Gate**: Threshold enforcement with quality gates

### 6. **Docker Operations** (Parallel)
- **Dockerfile Validation**: Security best practices verification
- **Image Building**: Multi-stage Docker build with optimization

### 7. **Container Security Scanning**
```bash
# Trivy vulnerability assessment
trivy image --exit-code 1 \
  --cache-dir /tmp/trivy \
  --severity HIGH,CRITICAL \
  --format table \
  --output trivy-report.html \
  ${IMAGE_NAME}
```

### 8. **Report Management**
- S3 upload for long-term storage
- Jenkins artifact archival
- Email report distribution

### 9. **Container Registry Push**
- Conditional push based on security scan results
- Multi-retry mechanism for reliability

### 10. **Smoke Testing**
```bash
# Application health verification
curl -is --max-time 10 http://localhost:8084
```

### 11. **Cleanup**
- Container and image removal
- Workspace cleanup
- Resource optimization

## ⚙️ Configuration

### Pipeline Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `BUILD_NUM_TO_KEEP` | 2 | Number of builds to retain |
| `BUILD_DAYS_TO_KEEP` | 7 | Days to keep builds |
| `CONTAINER_PORT` | 8084 | Application container port |
| `BRANCH_NAME` | main | Git branch to build |
| `PROJECT_VERSION` | 1.0 | Project version tag |
| `ENVIRONMENT` | dev | Deployment environment |
| `TRIVY_SEVERITY` | HIGH | Vulnerability scan severity |
| `FAIL_ON_LEAKS` | true | Fail build on secrets detection |

### Environment Variables

```groovy
environment {
    GIT_URL = 'https://github.com/Orion83-h/Safari.git'
    DOCKER_NAMESPACE = 'colanta06'
    IMAGE_TAG = "v${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}"
    SONAR_ORG = 'safari'
    SONAR_PROJECT_KEY = 'safari_rhino-horn'
    S3_BUCKET_NAME = "trivy-reports-l7p2cwm0"
}
```

## 🚀 Usage

### Running the Pipeline

1. **Manual Trigger**:
   ```bash
   # Navigate to Jenkins job
   # Click "Build with Parameters"
   # Configure desired parameters
   # Click "Build"
   ```

2. **Automated Trigger**:
   - Git webhook on push to configured branches
   - Scheduled builds via cron expressions
   - Upstream job dependencies

### Local Development

```bash
# Build application locally
cd rhino-horn
./mvnw clean package

# Run application
java -jar target/rhino-horn-0.0.1-SNAPSHOT.jar

# Access application
curl http://localhost:8084
```

### Docker Operations

```bash

# Inspect docker image
docker inspect colanta06/rhino-horn:v1.0 --format '{{.Config.Labels}}'

# Example output
{
  "Maintainer": "Samuel Haddison",
  "Email": "samuelhaddison71@gmail.com", 
  "git.commit": "a1b2c3d4e5f6789..."
}

# Build Docker image
docker build -t rhino-horn:latest -f rhino-horn/Dockerfile .

# Run container
docker run -p 8084:8084 rhino-horn:latest

# Security scan
trivy image rhino-horn:latest
```

## 🔐 Security Features

### Secrets Management
- **GitLeaks Integration**: Prevents credential exposure in source code
- **Jenkins Credentials**: Secure storage of sensitive information
- **Environment Isolation**: Separate credentials per environment

### Container Security
- **Non-root User**: Dockerfile enforces non-privileged execution
- **Vulnerability Scanning**: Trivy integration with configurable thresholds
- **Base Image Security**: Minimal Alpine-based images

### Code Quality
- **SonarCloud Analysis**: Security hotspot detection
- **Quality Gates**: Automated quality threshold enforcement
- **Test Coverage**: JaCoCo integration with 80% minimum coverage

## 📧 Monitoring & Notifications

### Email Notifications

**Success Notifications** (Main branch/Production only):
```html
Subject: [prod] SUCCESS: rhino-horn - Build #123
- Build details and version information
- Security scan results
- Links to reports and dashboards
```

**Failure Notifications** (All environments):
```html
Subject: [dev] FAILED: rhino-horn - Build #123
- Failure details and affected stage
- Console output links
- Troubleshooting resources
```

### Report Generation
- **Security Reports**: Trivy HTML reports with vulnerability details
- **Code Quality**: SonarCloud dashboards and metrics
- **Build Artifacts**: Maven artifacts and test results
- **S3 Storage**: Long-term report archival

## 🔧 Troubleshooting

### Common Issues

**Build Failures**:
```bash
# Check Jenkins console output
# Verify tool installations
# Validate credentials configuration
```

**Security Scan Failures**:
```bash
# Review Trivy report for vulnerabilities
# Update base images
# Apply security patches
```

**Quality Gate Failures**:
```bash
# Check SonarCloud dashboard
# Review code coverage reports
# Address code quality issues
```

### Debug Commands

```bash
# Test GitLeaks locally
gitleaks detect --source rhino-horn --verbose

# Validate Dockerfile
docker run --rm -i hadolint/hadolint < rhino-horn/Dockerfile

# Test application endpoints
curl -v http://localhost:8084/actuator/health
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Ensure security scans pass
5. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Samuel Haddison** - Initial work and pipeline design
- **DevOps Team** - Ongoing maintenance and improvements

## 🔗 Related Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarCloud Documentation](https://sonarcloud.io/documentation)
- [Trivy Security Scanner](https://trivy.dev/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)


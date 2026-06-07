🦏 Rhino Horn — DevSecOps CI/CD Pipeline
A production-grade DevSecOps pipeline for a Spring Boot application built on Jenkins, with integrated secrets detection, code quality analysis, container security gating, artifact management, and environment-scoped notifications.
![Java](https://img.shields.io/badge/java-17%2B-orange)
![Spring Boot](https://img.shields.io/badge/spring--boot-3.x-green)
![Maven](https://img.shields.io/badge/maven-3.9.11-blue)
![Docker](https://img.shields.io/badge/docker-hub-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
---
🏛️ Architecture
📊 View Interactive CI/CD Pipeline Diagram →
---
🔄 Pipeline Stages
```
GitHub push (webhook)
        │
        ▼
   Jenkins CI  [agent any · quietPeriod(30) · timestamps()]
        │
        ├── 01  Pull source code          shallow clone depth:10
        ├── 02  Secrets scan              Gitleaks → SARIF report
        ├── 03  Build Maven project       mvn clean package -DskipTests
        ├── 04  Deploy to Nexus           mvn deploy → Nexus repository
        ├── 05  SonarCloud analysis       quality gate timeout 10 min
        ├── 06  Docker operations ─────────────────── [parallel · failFast:true]
        │            ├── Check Dockerfile    fileExists check
        │            └── Build Docker image  --no-cache --pull
        ├── 07  Trivy scan               retry(3) DB pull · HTML report
        ├── 08  Upload report → S3        aws s3 cp · skip if empty
        │
        ├── [TRIVY_SCAN_STATUS == 0?]
        │       ├── ✕ vuln found → Skip push (image not published)
        │       └── ✓ clean ──────────────────────────────────────┐
        │                                                          ▼
        ├── 09  Push Docker image         retry(3) → Docker Hub
        ├── 10  Smoke test               docker run -p 8084 · sleep 30 · test-run.sh
        ├── 11  Cleanup                  docker stop/rm/rmi
        │
        └── POST BUILD
              ├── success  → email (main branch or prod env only)
              ├── failure  → email (all environments, always)
              └── always   → cleanWs()
```
---
✨ Features
Category	Detail
🔒 Secrets scanning	Gitleaks — SARIF report, configurable fail-on-leak
🧪 Code quality	SonarCloud analysis + quality gate enforcement (10 min timeout)
🐳 Containerisation	Docker build with `--no-cache --pull`, non-root Alpine base
🛡️ Vulnerability scan	Trivy — blocks push and smoke test on HIGH/CRITICAL CVEs
📦 Artifact storage	Nexus Repository Manager via Maven deploy
☁️ Report archival	AWS S3 — Trivy HTML report per build
🔁 Retry logic	Trivy DB download: retry(3) · Docker push: retry(3)
📧 Notifications	Success: main/prod only · Failure: all environments
🧹 Cleanup	Container + image removed post-smoke · `cleanWs()` always
---
🛠️ Prerequisites
Infrastructure
Jenkins server with Docker support
Maven 3.9.11 (configured in Global Tool Configuration as `Maven-3.9.11`)
Java 17+
SonarCloud account (`safari` org)
Nexus Repository Manager (global Maven settings ID: `settings`)
AWS S3 bucket: `trivy-reports-l7p2cwm0`
Gitleaks installed on Jenkins agent
Trivy installed on Jenkins agent
Jenkins Plugins
`Pipeline` · `Docker Pipeline` · `Pipeline Maven Integration` · `SonarQube Scanner` · `Email Extension` · `AWS Steps` · `Credentials`
Jenkins Credentials Required
Credential ID	Type	Used for
`GIT_CREDS`	Username/password	GitHub repo checkout
`gitAuth`	Username/password	Trivy scan (GHCR_TOKEN)
`dockerCreds`	Username/password	Docker Hub push
`SonarCloud`	SonarQube server config	SonarCloud analysis
---
📁 Project Structure
```
Safari/
├── .github/workflows/
│   └── rhino-ci.yml                  # GitHub Actions CI
├── rhino-horn/
│   ├── src/
│   │   ├── main/java/com/rhino_horn/safari/rhino_horn/
│   │   │   └── RhinoHornApplication.java
│   │   ├── main/resources/
│   │   │   ├── static/               # CSS, JS
│   │   │   ├── templates/            # Thymeleaf
│   │   │   └── application.properties
│   │   └── test/java/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   ├── pom.xml
│   ├── test-run.sh                   # Smoke test script
│   └── dockerfile-check.sh           # Dockerfile security validation
├── docs/
│   └── cicd-pipeline.html            # Interactive pipeline diagram
└── README.md
```
---
⚙️ Pipeline Parameters
Parameter	Type	Default	Options / Description
`BUILD_NUM_TO_KEEP`	string	`2`	Builds to retain
`BUILD_DAYS_TO_KEEP`	string	`7`	Days before build discard
`BUILD_ARTIFACT_NUM_TO_KEEP`	string	`2`	Artifact copies to retain
`BUILD_ARTIFACT_DAYS_TO_KEEP`	string	`2`	Days before artifact discard
`CONTAINER_PORT`	string	`8084`	Port inside container
`HOST_PORT`	string	`8084`	Host port for smoke test
`BRANCH_NAME`	choice	`main`	`main` · `dev` · `staging`
`MAIL_TO`	choice	—	`samuelhaddison@gmail.com` · `orionhouse83@gmail.com`
`PROJECT_VERSION`	choice	`1.0`	`1.0` · `1.1` · `1.2`
`ENVIRONMENT`	choice	`dev`	`dev` · `staging` · `prod`
`TRIVY_SEVERITY`	choice	`HIGH`	`HIGH` · `CRITICAL`
`FAIL_ON_LEAKS`	boolean	`true`	Fail build on secrets detection
Environment Variables
```groovy
GIT_URL           = 'https://github.com/Orion83-h/Safari.git'
DOCKERFILE        = 'rhino-horn/Dockerfile'
DOCKER_NAMESPACE  = 'colanta06'
IMAGE_TAG         = "v1.0.${BUILD_NUMBER}"
IMAGE_NAME        = "colanta06/<job-name>:${IMAGE_TAG}"
CONTAINER_NAME    = "rhino-horn-${ENVIRONMENT}"
SONAR_ORG         = 'safari'
SONAR_PROJECT_KEY = 'safari_rhino-horn'
SONARQUBE_URL     = 'https://sonarcloud.io'
TRIVY_CACHE_DIR   = '/tmp/trivy'
S3_BUCKET_NAME    = 'trivy-reports-l7p2cwm0'
```
---
🚀 Usage
Trigger the pipeline
```bash
# Automatic — push to any configured branch
git push origin main

# Manual — Jenkins UI
# → Build with Parameters → configure → Build
```
Run locally
```bash
cd rhino-horn
./mvnw clean package
java -jar target/rhino-horn-0.0.1-SNAPSHOT.jar
curl http://localhost:8084
```
Docker
```bash
# Build
docker build -t rhino-horn:latest -f rhino-horn/Dockerfile .

# Run
docker run -p 8084:8084 rhino-horn:latest

# Inspect labels
docker inspect colanta06/rhino-horn:v1.0.1 --format '{{.Config.Labels}}'

# Security scan locally
trivy image --severity HIGH,CRITICAL colanta06/rhino-horn:latest
```
---
🔐 Security
Gitleaks — blocks build on detected credentials (`FAIL_ON_LEAKS=true`)
SonarCloud quality gate — aborts pipeline on threshold failure
Trivy gate — Docker Hub push and smoke test skipped on HIGH/CRITICAL CVEs
Non-root container — Dockerfile enforces unprivileged execution
Jenkins Credentials — all secrets stored encrypted, never in source
Trivy DB retry — `retry(3)` ensures DB download reliability
---
📧 Notifications
Event	Trigger condition	Includes
✅ Success	`main` branch or `prod` environment	Build info, image tag, Trivy status, links to report + SonarCloud
❌ Failure	All environments, always	Failed stage, console link, Trivy + SonarCloud links
Both emails attach `trivy-reports/**` and link to:
Jenkins build details + console output
Trivy HTML report (S3 + Jenkins artifact)
SonarCloud dashboard
---
🔧 Troubleshooting
```bash
# Test secrets scan locally
gitleaks detect --source rhino-horn --verbose

# Lint Dockerfile
docker run --rm -i hadolint/hadolint < rhino-horn/Dockerfile

# Trivy scan locally
trivy image --severity HIGH,CRITICAL \
  --format table colanta06/rhino-horn:latest

# Health check
curl -v http://localhost:8084/actuator/health

# Maven build debug
cd rhino-horn && ./mvnw clean package -X
```
Common failures
Stage	Symptom	Fix
Secrets scan	`Secrets detected by Gitleaks!!`	Remove credential from source; rotate the secret
SonarCloud	Quality gate timeout	Check SonarCloud dashboard; fix violations or extend timeout
Trivy scan	Vulnerabilities found	Update base image or suppress accepted CVEs
Docker push	Auth error	Verify `dockerCreds` credential ID in Jenkins
Smoke test	`curl` timeout	Check container started; review `test-run.sh`
---
🤝 Contributing
Fork the repository
Create a feature branch: `git checkout -b feature/my-feature`
Commit with tests: `git commit -m 'feat: add my feature'`
Ensure Gitleaks, Trivy, and SonarCloud scans pass
Open a pull request against `main`
---
👥 Authors
Samuel Haddison — pipeline design & initial implementation
---
🔗 Resources
Jenkins Pipeline Docs
SonarCloud Docs
Trivy
Gitleaks
Spring Boot
Nexus Repository
---
📄 License
MIT License — see LICENSE for details.

# DoseMate — iOS Native Medicine Management Application

DoseMate is a full-stack, native iOS medicine-management application designed to help individuals adhere to complex medication schedules with zero friction.

- **iOS Client:** Swift 5.9+ / SwiftUI / MVVM / Combine / UserNotifications
- **Backend:** Java 17 LTS / Spring Boot 3.3+ / Spring Security / JWT (jjwt) / Spring Data JPA / Flyway
- **Database:** MySQL 8.0+ (`utf8mb4_0900_ai_ci`)

---

## 1. Project Directory Structure

```text
DoseMate/
├── ios/
│   └── DoseMate/              # Native SwiftUI iOS application
├── backend/
│   └── dose-mate-api/         # Spring Boot 3.x REST API service
├── docs/
│   ├── implementation-plan/   # Architecture and phase-by-phase roadmap
│   ├── api-contract/          # Complete REST API specification & error codes
│   └── database-schema/       # ERD, DDL schema, and transaction rules
├── scripts/
│   └── setup-database.ps1     # Automated local MySQL database initialization
├── docker-compose.yml         # Optional containerized MySQL service
├── .gitignore                 # Secrets, build artifacts, and user data exclusions
└── .gitattributes             # Cross-platform line ending normalization (LF)
```

---

## 2. Windows Development Setup

### 2.1 Prerequisites
- **Operating System:** Windows 11 Pro (or Windows 10 x64)
- **Java:** OpenJDK 17 LTS (`JAVA_HOME` configured)
- **Build Tool:** Apache Maven 3.9+ (`MAVEN_HOME` and PATH configured)
- **Database:** MySQL Server 8.0 running locally on port 3306

### 2.2 Database Initialization
Run the automated bootstrap script from PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup-database.ps1
```
This script:
1. Prompts securely for your MySQL `root` password (never saved).
2. Creates `dosemate_dev` and `dosemate_test` databases.
3. Generates a dedicated `dosemate` user with a strong randomized password.
4. Generates a cryptographically secure 512-bit JWT secret.
5. Writes the `.env` file to `backend/dose-mate-api/.env` (strictly git-ignored).

### 2.3 Running the Backend
```powershell
cd backend\dose-mate-api
mvn spring-boot:run
```
The REST API will start on `http://localhost:8080/api/v1`.

---

## 3. macOS Build & iOS Simulator Execution

Because Apple's iOS SDK, SwiftUI compiler, and Xcode Simulator require macOS, iOS compilation and simulator testing are delegated to a macOS host:

```text
WINDOWS PC (Editing, Backend, Database)
     │
     │  Git Push / Remote Sync
     ▼
MACOS MACHINE (Xcode, iOS Simulator, Swift Compiler)
```

### Steps on macOS:
1. Clone the repository:
   ```bash
   git clone https://github.com/Burhan9464/DoseMate.git
   cd DoseMate/ios/DoseMate
   ```
2. Open the Xcode project or Swift Package:
   ```bash
   open DoseMate.xcodeproj
   ```
3. Set the backend URL in `AppConfig.swift` (pointing to your Windows IP, e.g. `http://192.168.1.100:8080/api/v1`).
4. Select target simulator: **iPhone 15 Pro** (or any 393 × 852 pt device).
5. Press **Cmd + R** to run.

---

## 4. Documentation Links
- [Implementation Plan](docs/implementation-plan/README.md)
- [Database Schema & ERD](docs/database-schema/README.md)
- [REST API Contract](docs/api-contract/README.md)
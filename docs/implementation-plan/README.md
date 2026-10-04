# DoseMate Implementation Plan & Technical Architecture

## 1. System Overview
DoseMate is a full-stack, native iOS medicine-management application powered by a Spring Boot backend and MySQL 8.0+.

```text
+-----------------------------------------------------------+
|              iOS Native Client (SwiftUI + MVVM)           |
|                                                           |
|  Views -> ViewModels -> Repositories -> NetworkService    |
|  Keychain (Token Storage) | UNUserNotificationCenter      |
+-----------------------------+-----------------------------+
                              |
                     RESTful HTTPS / JSON
                     Authorization: Bearer <JWT>
                              |
                              v
+-----------------------------------------------------------+
|              Spring Boot 3.x Backend (Java 17)            |
|                                                           |
|  Controller -> Service -> Spring Data JPA -> MySQL 8.0    |
|  Spring Security + JWT | Bean Validation | Flyway         |
+-----------------------------------------------------------+
```

---

## 2. Windows Development vs. macOS Compilation Strategy

### 2.1 The Environmental Reality
- **Development Host:** Windows 11 Pro PC.
- **Backend Stack:** Java 17 LTS, Maven 3.9.16, native MySQL 8.0.46 Server, Spring Boot 3.x.
- **iOS Target:** Pure Swift + SwiftUI + MVVM (native iOS).

### 2.2 Strict Separation of Duties
| Activity | Host System | Tooling |
|---|---|---|
| Source code authoring (Backend + iOS) | Windows 11 | VS Code / IDE, Git, PowerShell |
| Backend compilation, testing, execution | Windows 11 | Maven 3.9.16, JDK 17, MySQL 8.0.46 |
| Database migrations & verification | Windows 11 | Flyway, MySQL 8.0 CLI |
| API testing & automated contract tests | Windows 11 | Spring MockMvc, JUnit 5 |
| iOS Swift syntax verification & static structure | Windows 11 | Formatted Swift source tree |
| **iOS Swift Compilation & Linking** | **macOS** | Apple Xcode, Clang/Swiftc |
| **iOS Simulator Execution & Visual Testing** | **macOS** | Xcode iOS Simulator |
| **App Store Packaging & Code Signing** | **macOS** | Apple Developer certs, `xcodebuild` |

---

## 3. Phase-by-Phase Roadmap

- **Phase 0:** Environment audit, prerequisite installation, Git repository & remote configuration. *(Complete)*
- **Phase 1:** Repository structure, database schema, API contract, documentation. *(Current)*
- **Phase 2:** Spring Boot project creation, Flyway migrations, configuration, exception handling.
- **Phase 3:** User authentication, BCrypt hashing, JWT generation/validation, Spring Security filters.
- **Phase 4:** Medicine management backend (CRUD, pause, resume, soft delete, tenant isolation).
- **Phase 5:** Medication scheduling backend (validation, normalized day/time persistence).
- **Phase 6:** Dose tracking, transactional inventory decrement, medication history, dashboard aggregation.
- **Phase 7:** iOS foundation (SwiftUI app shell, MVVM modules, Keychain token storage, API client).
- **Phase 8:** iOS onboarding, authentication screens, interactive guide state.
- **Phase 9:** iOS core feature screens (Dashboard, Medicines list, Add/Edit flow, History, Profile).
- **Phase 10:** Drag-the-Pill interaction, haptics, animations, local notification service.
- **Phase 11:** Full end-to-end integration between iOS ViewModels and backend REST endpoints.
- **Phase 12:** Edge case validation, concurrency testing, idempotent transaction checks.
- **Phase 13:** Visual design polish, accessibility review, responsive layout verification, macOS handoff.

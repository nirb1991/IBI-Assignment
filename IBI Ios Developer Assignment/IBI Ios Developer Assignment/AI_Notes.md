# AI Usage Notes

## AI Tools Used

* OpenAI Codex
* ChatGPT

---

## AI Assisted With

AI was used for:

* Architecture review and validation
* Project structure planning
* Authentication flow design
* Repository design
* Offline caching strategy
* SwiftData architecture discussions
* Keychain implementation assistance
* Biometric authentication implementation assistance
* Product data layer design review

---

## Manually Implemented / Reviewed

The following decisions were made manually:

* MVVM architecture selection
* Dependency Injection strategy (Constructor Injection)
* SwiftData selection over Core Data
* Product cache strategy
* Favorites persistence strategy
* Logout strategy
* Authentication strategy
* Offline-first approach
* Folder structure and project organization

All AI-generated code was manually reviewed before being integrated into the project.

---

## Meaningful Prompts

### Prompt 1

Help me design a clean MVVM architecture for an iOS take-home assignment that includes authentication, offline caching, CRUD operations and SwiftData persistence.

### Prompt 2

Design a secure iOS authentication flow using Keychain and Face ID for a take-home assignment with mocked authentication.

### Prompt 3

Create a production-ready KeychainService in Swift that can store, retrieve and delete Codable objects using Apple's Security framework.

### Prompt 4

Review the current Domain layer and suggest improvements while avoiding over-engineering. Focus on authentication, products, favorites, offline caching, local CRUD, and reset-from-API behavior.

### Prompt 5

Design the complete Products data layer using URLSession, SwiftData, Repository Pattern, DTO models, cache models, and offline-first principles.

---

## Verification Process

To ensure correctness and code quality:

* All AI-generated code was manually reviewed before integration.
* Architecture decisions were reviewed separately before implementation.
* The application was tested manually during development.
* Repository boundaries and dependency injection were reviewed for maintainability and testability.
* Error handling and offline scenarios were considered during implementation.
* SwiftData persistence behavior and authentication flows were validated during development.

---

## Notes

AI was used as a development assistant and implementation accelerator.

Final architectural decisions, code review, integration decisions, and trade-off decisions were made manually.

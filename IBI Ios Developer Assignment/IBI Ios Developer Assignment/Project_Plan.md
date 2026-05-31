# Architecture Decisions

## Architecture
MVVM

Reason:
Simple, testable, and appropriate for the project size.

---

## Persistence
SwiftData

Reason:
Modern Apple persistence framework with less boilerplate than Core Data.

---

## Networking
URLSession

Reason:
No advanced networking requirements justify a third-party dependency.

---

## Dependency Injection
Constructor Injection

Reason:
Simple, explicit, and easy to test.

---

## Navigation
NavigationStack

Reason:
Modern SwiftUI navigation API with clear and predictable navigation flow.

---

## UIKit Usage
Product Details Screen

Reason:
Satisfies the assignment requirement to demonstrate both SwiftUI and UIKit while keeping the majority of the app in SwiftUI.

---

## Images
AsyncImage

Reason:
Sufficient for the assignment requirements without adding external dependencies.

---

## Favorites Persistence Strategy

Store only product IDs.

Reason:
Avoid data duplication and maintain a single source of truth for product data.

---

## Product Cache Strategy

Store products locally using SwiftData.

Reason:
Support offline usage, improve startup performance, and reduce unnecessary network requests.

---

## Logout Strategy

Remove:
- Session
- Authentication state
- Biometric authentication state

Keep:
- Product cache

Reason:
Product data is not user-specific and keeping it improves startup performance and offline support.

---

## Authentication Strategy

Mock authentication.

Reason:
The assignment does not provide an authentication endpoint. The architecture will allow replacing the mock implementation with a real backend service in the future.

Default Credentials:
- Username: admin
- Password: 1234

## Product Data Source Strategy

Source of Truth:
SwiftData cache

Synchronization:
API updates the local cache.

Reason:
Supports offline-first behavior while keeping the UI independent from the network state.

## Repository Strategy

Repositories expose domain models and hide implementation details.

Reason:
Presentation layer should not know whether data comes from API, SwiftData, Keychain, or local storage.

## Authentication Flow

Launch:
- Check session in Keychain
- Restore session if available

Login:
- Mock credentials validation
- Save session in Keychain

Biometric Login:
- Optional after successful login
- Face ID / Touch ID used to restore session

Logout:
- Remove session data
- Remove biometric authentication state
- Keep product cache

## Application State Strategy

AppState is responsible for authentication state and application startup flow.

Responsibilities:
- Restore session
- Track authentication state
- Control root navigation

Reason:
Provides a single source of truth for app-level state.

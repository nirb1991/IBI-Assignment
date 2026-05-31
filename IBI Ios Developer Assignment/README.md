# IBI iOS Developer Assignment

## Project Overview

This project is an iOS take-home assignment implemented with SwiftUI, UIKit, SwiftData, URLSession, Keychain, and LocalAuthentication. It demonstrates a clean, maintainable MVVM architecture with constructor injection, offline-first product caching, local CRUD, favorites, authentication, settings, and a UIKit product details screen bridged into SwiftUI.

## Setup Instructions

1. Open `IBI Ios Developer Assignment.xcodeproj` in Xcode.
2. Select the `IBI Ios Developer Assignment` scheme.
3. Run the app on an iOS simulator.
4. Use the credentials below to log in.

No third-party setup is required beyond Swift Package Manager resolving SnapKit.

## Testing Credentials

- Username: `admin`
- Password: `1234`

Biometric unlock is optional and only unlocks an existing Keychain-backed session. The first login must be done with username and password. On a later app launch with a saved session, the app shows an explicit biometric unlock screen instead of automatically entering the product list, with a password-login fallback if the user does not want to use biometrics.

## Architecture

The app follows MVVM with constructor injection.

- Views render state and forward user actions.
- ViewModels own presentation state, validation, loading flags, and user-intent handling.
- Repositories expose domain models and hide networking/persistence details.
- SwiftData and URLSession are isolated in the data layer.
- Keychain and biometric authentication are isolated in services.
- App composition is centralized in `DI.swift`.

The presentation layer does not know whether products come from the API or local cache.

## Folder Structure

```text
IBI Ios Developer Assignment
├── App
│   ├── AppState.swift
│   └── RootView.swift
├── Core
│   ├── DI.swift
│   └── Services
│       ├── BiometricAuthService.swift
│       └── KeychainService.swift
├── Data
│   ├── Network
│   │   ├── ProductAPIClient.swift
│   │   ├── ProductDTO.swift
│   │   └── ProductsResponseDTO.swift
│   ├── Persistence
│   │   └── CachedProduct.swift
│   └── Repositories
│       └── SwiftDataProductRepository.swift
├── Domain
│   ├── Models
│   └── Repositories
└── Presentation
    ├── Authentication.swift
    ├── Favorites.swift
    ├── ProductDetailsView.swift
    ├── ProductDetailsViewController.swift
    ├── ProductDetailsViewModel.swift
    ├── ProductForm.swift
    ├── Products.swift
    ├── ProductsListView.swift
    └── Settings.swift
```

## Main Features

- Mock authentication with Keychain-backed session persistence.
- Optional Face ID / Touch ID unlock for existing sessions on app relaunch.
- Product list fetched from DummyJSON.
- Pagination using `limit` and `skip`.
- SwiftData product cache.
- Offline-first product loading from cache.
- Search, sort, and category filtering.
- Local create, edit, and delete product operations.
- Reset local product changes from the API.
- UIKit product details screen embedded in SwiftUI.
- Favorites stored as product IDs only.
- Favorites screen with remove and undo.
- Settings screen for appearance, English/Hebrew language selection, and logout.

## Technical Decisions

- **MVVM** keeps UI rendering separate from state and action handling.
- **Constructor injection** keeps services and repositories testable without singletons.
- **SwiftData** is used for local product caching.
- **URLSession** is used directly for networking to avoid unnecessary dependencies.
- **Keychain** stores the authenticated session.
- **LocalAuthentication** handles biometrics, but biometrics are not treated as a source of truth.
- **Favorites store only IDs** so `Product` remains the single source of truth.
- **UIKit details screen** satisfies the assignment requirement while the rest of the app remains SwiftUI.
- **SnapKit** is used for UIKit layout in the product details screen.

## Assumptions

- Authentication is intentionally mocked with fixed credentials.
- Product create/edit/delete operations are local only.
- Reset from API is the explicit way to discard local product changes.
- Language switching uses English and Hebrew `Localizable.strings` files and is driven by the in-app language setting.
- Favorites persistence via `UserDefaults` is sufficient because only integer IDs are stored.

## Tradeoffs

- The app does not track per-product local modification flags. This keeps the data model simple, but means the repository treats reset as the explicit destructive sync operation.
- Pagination and local CRUD share the same cache. API pages are upserted into SwiftData, while reset replaces the cache from all API pages.
- Runtime language switching is implemented with a lightweight localization helper so the in-app language picker can update visible app strings without changing the device language.
- The login UI uses lightweight SwiftUI animation instead of a custom animation framework.

## Known Limitations

- Product CRUD changes are local only and are not sent to DummyJSON.
- Search, sort, and filtering operate on products loaded so far.
- Favorites can only display products currently available from the product repository/cache.
- Language selection does not change the device locale; product data returned by the API remains in its original language.
- Biometric unlock requires a previously stored Keychain session and is not available after logout until the user logs in again with username and password. Users can choose password login instead from the unlock screen.

## Testing Notes

Unit tests cover:

- `MockAuthRepository` login success and failure.
- `AppState` restore, login, and logout flow.
- `ProductsViewModel` loading, search, sort, and filter behavior.
- `ProductFormViewModel` validation and successful creation.
- `FavoritesViewModel` remove and undo behavior.
- DTO/cache/domain product mapping.

Run tests with:

```sh
xcodebuild test -project 'IBI Ios Developer Assignment.xcodeproj' -scheme 'IBI Ios Developer Assignment' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'
```

Run a build with:

```sh
xcodebuild build -project 'IBI Ios Developer Assignment.xcodeproj' -scheme 'IBI Ios Developer Assignment' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1'
```

## AI Usage Report

### AI Tools Used

- OpenAI Codex
- ChatGPT

### What AI Assisted With

- Architecture review and validation.
- Project structure planning.
- Authentication flow design.
- Repository design.
- Offline caching strategy.
- SwiftData architecture discussions.
- Keychain implementation assistance.
- Biometric authentication implementation assistance.
- Product data layer design review.
- Test planning and README drafting.

### What Was Implemented / Reviewed Manually

- MVVM architecture selection.
- Dependency injection strategy.
- SwiftData selection over Core Data.
- Product cache strategy.
- Favorites persistence strategy.
- Logout strategy.
- Authentication strategy.
- Offline-first approach.
- Folder structure and project organization.
- Final integration decisions and tradeoffs.

All AI-generated code was manually reviewed before being integrated.

### Meaningful Prompts Used During Development

1. “Help me design a clean MVVM architecture for an iOS take-home assignment that includes authentication, offline caching, CRUD operations and SwiftData persistence.”
2. “Design a secure iOS authentication flow using Keychain and Face ID for a take-home assignment with mocked authentication.”
3. “Create a production-ready KeychainService in Swift that can store, retrieve and delete Codable objects using Apple's Security framework.”
4. “Review the current Domain layer and suggest improvements while avoiding over-engineering. Focus on authentication, products, favorites, offline caching, local CRUD, and reset-from-API behavior.”
5. “Design the complete Products data layer using URLSession, SwiftData, Repository Pattern, DTO models, cache models, and offline-first principles.”

### Correctness And Code Quality Verification

- Architecture decisions were reviewed before implementation.
- Generated code was manually reviewed before integration.
- Repository boundaries and dependency injection were checked for testability.
- Error handling and offline scenarios were considered during implementation.
- SwiftData persistence behavior and authentication flows were validated during development.
- `xcodebuild test` and `xcodebuild build` were run before final delivery.

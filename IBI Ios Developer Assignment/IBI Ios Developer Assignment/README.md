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

## AI Usage Report

### AI Tools Used

- OpenAI Codex
- ChatGPT

### What AI Assisted With

- Architecture review and validation.
- Project structure planning.
- Authentication flow design.
- Repository design.
- Offline caching implementation.
- SwiftData architecture discussions.
- Keychain implementation assistance.
- Biometric authentication implementation assistance.
- Product cache strategy.
- Test planning and README drafting.

### What Was Implemented Manually

- Folder structure and project organization.
- MVVM architecture selection.
- Dependency injection strategy.
- Logout strategy.
- ProductDetailsView, ProductDetailsViewModel, ProductDetailsViewController, RootView, SettingsView.
- Authentication strategy.
- Offline-first approach.
- All AI generated code was manually reviewed before integration.

### Verification and Validation

All AI-generated code was manually reviewed before integration.

The application was validated through:

- Manual end-to-end testing of authentication flows.
- Manual testing of biometric authentication.
- Manual testing of pagination.
- Manual testing of CRUD operations.
- Manual testing of favorites persistence and undo actions.
- Manual testing of settings and logout flow.
- Unit tests covering core business logic and view models.

### Meaningful Prompts Used During Development

1. “Implement only `BiometricAuthService.swift`.
- The project architecture is already decided: MVVM with constructor injection.
- I want this service to stay small, simple, and testable.
- Use Apple’s `LocalAuthentication` framework.
- Support both Face ID and Touch ID.
- Expose `canAuthenticate() -> Bool`.
- Expose `authenticate() async throws`.
- Avoid singletons.
- Avoid UI code.
- Do not create any additional files.
- Keep the implementation suitable for being injected into higher-level authentication flow objects.”

2. “Implement the authentication flow for this project.
- Create `MockAuthRepository` to conform to `AuthRepository`.
- Use the existing `KeychainService` to persist `UserSession`.
- Keep `UserSession` small and based on `username` only.
- Use mock credentials only: username `admin`, password `1234`.
- Keep biometrics optional and make sure they only unlock an existing Keychain-backed session.
- Let `AppState` own `userSession`, `isLoading`, and `authenticationError`.
- In `AppState`, implement `login(username:password:) async`, `logout() async`, and `restoreSession() async`.
- Implement only the files needed for this authentication flow.
- Do not add UI or extra abstractions that I did not ask for.”

3. “Implement only `KeychainService.swift`.
- Use Apple’s Security framework.
- No singleton.
- No third-party libraries.
- Support storing `Codable` objects.
- Support retrieving `Codable` objects.
- Support deleting stored objects.
- Keep the API simple and testable.
- Keep it suitable for constructor injection.
- Do not create additional files.
- Do not add extra abstractions unless they provide clear value.”

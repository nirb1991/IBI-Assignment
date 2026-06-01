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

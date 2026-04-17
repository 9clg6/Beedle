/// Identifie le provider OAuth utilisé pour l'authentification Firebase.
///
/// Source : Firebase `User.providerData[0].providerId` :
/// - `google.com` → [google]
/// - `apple.com` → [apple]
enum AuthProvider { google, apple }

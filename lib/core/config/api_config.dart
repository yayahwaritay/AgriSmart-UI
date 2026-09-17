/// Backend base URL for the AgriSmart API — see README.mobile.md.
///
/// This is set for a physical device on the same Wi-Fi as the machine
/// running the backend. Android/iOS emulators would use a different host
/// (10.0.2.2 for the Android emulator, localhost for the iOS simulator).
abstract final class ApiConfig {
  // TODO: replace with your PC's LAN IP (ipconfig -> IPv4 Address).
  static const baseUrl = 'https://agrismartsl.onrender.com';
}

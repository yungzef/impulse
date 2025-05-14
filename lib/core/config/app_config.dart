class AppConfig {
  static const String apiBaseUrl = bool.fromEnvironment('dart.vm.product') ? 'https://api.impulsepdr.online' : 'http://localhost:8000';
  static const String appName = 'Impulse';
}
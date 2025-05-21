class AppConfig {
  static const String apiBaseUrl = bool.fromEnvironment('dart.vm.product') ? 'https://api.impulsepdr.online' : 'http://localhost:8000';
  static const String appName = 'Impulse';
  static const String clientId = bool.fromEnvironment('dart.vm.product') ? '147419489204-kgqofiklpa7tskvm2eds34b15ve9anpi.apps.googleusercontent.com' : '147419489204-mcv45kv1ndceffp1efnn2925cfet1ocb.apps.googleusercontent.com';
}
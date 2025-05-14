import 'package:get_it/get_it.dart';
import 'package:impulse/core/services/api_client.dart';
import 'package:impulse/core/services/auth_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerFactoryParam<ApiClient, String?, void>(
        (userId, _) => ApiClient(userId: userId),
  );
}
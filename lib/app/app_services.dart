export 'app_services_model.dart';

import 'app_services_model.dart';
import 'app_services_web.dart' if (dart.library.io) 'app_services_native.dart';

AppServices createAppServices() => createPlatformAppServices();

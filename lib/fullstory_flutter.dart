
import 'fullstory_flutter_platform_interface.dart';

class FullstoryFlutter {
  Future<String?> getPlatformVersion() {
    return FullstoryFlutterPlatform.instance.getPlatformVersion();
  }
}

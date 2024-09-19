
import 'fullstory_platform_interface.dart';

class Fullstory {
  Future<String?> getPlatformVersion() {
    return FullstoryPlatform.instance.getPlatformVersion();
  }
}

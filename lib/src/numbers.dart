import 'package:fullstory_flutter/src/logging.dart';

extension SafeDouble on double {



  int toIntSafe([String? context, String? widgetType]) {
    if (isFinite) {
      return toInt();
    }

    if (isInfinite) {
      Logger.log(
        LogLevel.note,
        'Attempted to convert infinite double to int'
        '${context != null ? ' in $context' : ''}'
        '${widgetType != null ? ' for widget type $widgetType' : ''}',
      );
      return this > 0 ? _approxInfinity : -_approxInfinity;
    }


    return 0;
  }


  int roundSafe() {
    if (isFinite) {
      return round();
    }

    if (isInfinite) {
      Logger.log(LogLevel.note, 'Attempted to round infinite double to int');
      return this > 0 ? _approxInfinity : -_approxInfinity;
    }


    return 0;
  }
  int roundOr(int fallback) => isFinite ? round() : fallback;
}


const _approxInfinity = 102115;

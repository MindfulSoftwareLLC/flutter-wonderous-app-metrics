import 'package:flutter/widgets.dart';

abstract class MetricListenerBase {
  void onPerformanceMetric({
    required String name,
    required Duration duration,
    Map<String, dynamic>? attributes,
  });

  void onError({
    required String error,
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
  });

  void onUserInteraction({
    required String screenName,
    required String actionType,
    Map<String, dynamic>? attributes,
  });

  void reportNavigationChange(Route<dynamic>? route, Route<dynamic>? previousRoute);
}

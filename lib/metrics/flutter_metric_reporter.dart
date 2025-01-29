import 'package:flutter/material.dart';
import 'dart:async';

/// Base class for all metric types that includes required timestamp
abstract class BaseMetric {
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  BaseMetric({DateTime? timestamp, this.attributes})
    : timestamp = timestamp ?? DateTime.now();
}

class PerformanceMetric extends BaseMetric {
  final String name;
  final Duration duration;

  PerformanceMetric({
    required this.name,
    required this.duration,
    super.attributes,
    super.timestamp,
  });
}

class PageLoadMetric extends BaseMetric {
  final String pageName;
  final Duration loadTime;
  final String? transitionType;

  PageLoadMetric({
    required this.pageName,
    required this.loadTime,
    this.transitionType,
    super.attributes,
    super.timestamp,
  });
}

class ErrorMetric extends BaseMetric {
  final String error;
  final StackTrace? stackTrace;

  ErrorMetric({
    required this.error,
    this.stackTrace,
    super.attributes,
    super.timestamp,
  });
}

class UserInteractionMetric extends BaseMetric {
  final String screenName;
  final String actionType;
  final Duration? responseTime;

  UserInteractionMetric({
    required this.screenName,
    required this.actionType,
    this.responseTime,
    super.attributes,
    super.timestamp,
  });
}

class NavigationMetric extends BaseMetric {
  final String? fromRoute;
  final String? toRoute;
  final String navigationType;
  final Duration? duration;

  NavigationMetric({
    this.fromRoute,
    this.toRoute,
    required this.navigationType,
    this.duration,
    super.attributes,
    super.timestamp,
  });
}

class PaintMetric extends BaseMetric {
  final String componentName;
  final Duration paintDuration;
  final String paintType; // 'first_paint', 'first_contentful_paint', 'largest_contentful_paint'

  PaintMetric({
    required this.componentName,
    required this.paintDuration,
    required this.paintType,
    super.attributes,
    super.timestamp,
  });
}

class LayoutShiftMetric extends BaseMetric {
  final String componentName;
  final double shiftScore;
  final String? cause; // e.g., 'animation', 'scroll', 'resize'

  LayoutShiftMetric({
    required this.componentName,
    required this.shiftScore,
    this.cause,
    super.attributes,
    super.timestamp,
  });
}

class FlutterMetricReporter extends NavigatorObserver {
  static final FlutterMetricReporter _instance = FlutterMetricReporter._internal();
  factory FlutterMetricReporter() => _instance;

  FlutterMetricReporter._internal();

  // Stream controllers for each metric type
  final _performanceController = StreamController<PerformanceMetric>.broadcast();
  final _pageLoadController = StreamController<PageLoadMetric>.broadcast();
  final _errorController = StreamController<ErrorMetric>.broadcast();
  final _interactionController = StreamController<UserInteractionMetric>.broadcast();
  final _navigationController = StreamController<NavigationMetric>.broadcast();
  final _paintController = StreamController<PaintMetric>.broadcast();
  final _layoutShiftController = StreamController<LayoutShiftMetric>.broadcast();

  // Public stream getters
  Stream<PerformanceMetric> get performanceStream => _performanceController.stream;
  Stream<PageLoadMetric> get pageLoadStream => _pageLoadController.stream;
  Stream<ErrorMetric> get errorStream => _errorController.stream;
  Stream<UserInteractionMetric> get interactionStream => _interactionController.stream;
  Stream<NavigationMetric> get navigationStream => _navigationController.stream;
  Stream<PaintMetric> get paintStream => _paintController.stream;
  Stream<LayoutShiftMetric> get layoutShiftStream => _layoutShiftController.stream;

  void reportPerformanceMetric(String name, Duration duration, {Map<String, dynamic>? attributes}) {
    _performanceController.add(PerformanceMetric(
      name: name,
      duration: duration,
      attributes: attributes,
    ));
  }

  void reportPageLoad(String pageName, Duration loadTime, {
    String? transitionType,
    Map<String, dynamic>? attributes,
  }) {
    _pageLoadController.add(PageLoadMetric(
      pageName: pageName,
      loadTime: loadTime,
      transitionType: transitionType,
      attributes: attributes,
    ));
  }

  void reportError(String error, {StackTrace? stackTrace, Map<String, dynamic>? attributes}) {
    _errorController.add(ErrorMetric(
      error: error,
      stackTrace: stackTrace,
      attributes: attributes,
    ));
  }

  void reportUserInteraction(String screenName, String actionType, {
    Duration? responseTime,
    Map<String, dynamic>? attributes,
  }) {
    _interactionController.add(UserInteractionMetric(
      screenName: screenName,
      actionType: actionType,
      responseTime: responseTime,
      attributes: attributes,
    ));
  }

  void reportPaint(String componentName, Duration paintDuration, String paintType, {
    Map<String, dynamic>? attributes,
  }) {
    _paintController.add(PaintMetric(
      componentName: componentName,
      paintDuration: paintDuration,
      paintType: paintType,
      attributes: attributes,
    ));
  }

  void reportLayoutShift(String componentName, double shiftScore, {
    String? cause,
    Map<String, dynamic>? attributes,
  }) {
    _layoutShiftController.add(LayoutShiftMetric(
      componentName: componentName,
      shiftScore: shiftScore,
      cause: cause,
      attributes: attributes,
    ));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackNavigation('pop', previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackNavigation('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackNavigation('remove', previousRoute, route);
  }

  void _trackNavigation(String type, Route<dynamic>? toRoute, Route<dynamic>? fromRoute) {
    _navigationController.add(NavigationMetric(
      fromRoute: fromRoute?.settings.name,
      toRoute: toRoute?.settings.name,
      navigationType: type,
    ));
  }

  void dispose() {
    _performanceController.close();
    _pageLoadController.close();
    _errorController.close();
    _interactionController.close();
    _navigationController.close();
    _paintController.close();
    _layoutShiftController.close();
  }
}

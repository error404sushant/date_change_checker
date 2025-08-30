import 'package:flutter/services.dart';
import 'package:ntp/ntp.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'auto_date_time_status.dart';

/// Main class for checking automatic date/time settings and time synchronization across platforms
class DateChangeChecker {
  static const MethodChannel _channel = MethodChannel('date_change_checker');
  
  /// Default time discrepancy threshold in milliseconds (30 seconds)
  static const int defaultTimeThreshold = 30000;
  
  /// Default NTP server for time synchronization
  static const String defaultNtpServer = 'pool.ntp.org';
  
  /// Checks if the device's date/time has been changed (not using automatic settings)
  /// 
  /// For iOS: Uses NTP time comparison to detect if date/time has been changed
  /// For Android: Uses native method channel implementation
  /// 
  /// Returns [true] if date/time has been changed (automatic date/time is OFF)
  /// Returns [false] if date/time has not been changed (automatic date/time is ON)
  /// 
  /// Throws [PlatformException] if platform is not supported or if an error occurs
  static Future<bool> isDateTimeChanged() async {
    try {
      if (Platform.isIOS) {
        // iOS: Use NTP-based time synchronization check
        final status = await _checkAutoDateTimeStatusIOS();
        // Return true if date/time has been changed (AUTO_DATE_TIME_OFF)
        return status == AutoDateTimeStatus.AUTO_DATE_TIME_OFF;
      } else if (Platform.isAndroid) {
        // Android: Use the isDateTimeChanged method directly
        final bool isChanged = await _channel.invokeMethod('isDateTimeChanged');
        return isChanged;
      } else {
        throw PlatformException(
          code: 'UNSUPPORTED_PLATFORM',
          message: 'Platform not supported. Only iOS and Android are supported.',
        );
      }
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to check auto date/time status: ${e.message}',
        details: e.details,
      );
    } catch (e) {
      throw PlatformException(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// iOS-specific implementation for checking automatic date/time status
  /// Uses NTP time comparison to detect if automatic date/time is enabled
  /// 
  /// Returns [AutoDateTimeStatus.AUTO_DATE_TIME_ON] if time is synchronized (auto enabled)
  /// Returns [AutoDateTimeStatus.AUTO_DATE_TIME_OFF] if time is not synchronized (auto disabled)
  static Future<AutoDateTimeStatus> _checkAutoDateTimeStatusIOS({
    int thresholdMs = defaultTimeThreshold,
    String ntpServer = defaultNtpServer,
    int timeout = 5000,
  }) async {
    try {
      developer.log('iOS: Checking auto date/time status using NTP comparison', name: 'DateChangeChecker');
      
      // Get device time in UTC
      final DateTime deviceTimeUtc = DateTime.now().toUtc();
      developer.log('iOS: Device time (UTC): $deviceTimeUtc', name: 'DateChangeChecker');
      
      // Get NTP time (already in UTC)
      final DateTime ntpTimeUtc = await fetchNtpTime(
        ntpServer: ntpServer,
        timeout: timeout,
      );
      developer.log('iOS: NTP time (UTC): $ntpTimeUtc', name: 'DateChangeChecker');
      
      // Calculate time difference in milliseconds
      final int timeDifferenceMs = deviceTimeUtc.difference(ntpTimeUtc).inMilliseconds.abs();
      developer.log('iOS: Time difference: ${timeDifferenceMs}ms (threshold: ${thresholdMs}ms)', name: 'DateChangeChecker');
      
      // If time difference is within threshold, automatic date/time is likely enabled
      final bool isAutoEnabled = timeDifferenceMs <= thresholdMs;
      
      final AutoDateTimeStatus status = isAutoEnabled 
          ? AutoDateTimeStatus.AUTO_DATE_TIME_ON 
          : AutoDateTimeStatus.AUTO_DATE_TIME_OFF;
      
      developer.log(
        'iOS: Auto date/time status determined as: $status (difference: ${timeDifferenceMs}ms)',
        name: 'DateChangeChecker',
      );
      
      return status;
    } catch (e) {
      developer.log('iOS: Failed to check auto date/time status via NTP: $e', name: 'DateChangeChecker', level: 1000);
      
      // Fallback: If NTP fails, we cannot determine the status reliably
      // Return OFF as a conservative approach
      developer.log('iOS: Falling back to AUTO_DATE_TIME_OFF due to NTP failure', name: 'DateChangeChecker', level: 900);
      return AutoDateTimeStatus.AUTO_DATE_TIME_OFF;
    }
  }
  
  /// Performs comprehensive date and time change detection (iOS only)
  /// 
  /// This method detects whether the date, time, or both have been modified
  /// and provides detailed information about the changes and auto date/time status.
  /// 
  /// Returns a [DateTimeChangeResult] with comprehensive change information
  /// Throws [PlatformException] if platform is not supported or if an error occurs
  static Future<DateTimeChangeResult> detectComprehensiveDateTimeChange() async {
    try {
      final Map<String, dynamic> result = 
          await _channel.invokeMethod('detectComprehensiveDateTimeChange');
      return DateTimeChangeResult.fromMap(result);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to detect comprehensive date/time changes: ${e.message}',
        details: e.details,
      );
    }
  }
  
  /// Detects comprehensive date/time changes and automatically shows notifications (iOS only)
  /// 
  /// This method combines detection with user notifications for better UX.
  /// It will show appropriate notifications based on the type of changes detected.
  /// 
  /// Returns a [DateTimeChangeResult] with comprehensive change information
  /// Throws [PlatformException] if platform is not supported or if an error occurs
  static Future<DateTimeChangeResult> detectAndNotifyDateTimeChanges() async {
    try {
      final Map<String, dynamic> result = 
          await _channel.invokeMethod('detectAndNotifyDateTimeChanges');
      return DateTimeChangeResult.fromMap(result);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to detect and notify date/time changes: ${e.message}',
        details: e.details,
      );
    }
  }
  
  /// Detects if only the date has been changed while time remains the same (iOS only)
  /// 
  /// This is useful for detecting when users manually change the date
  /// without modifying the time.
  /// 
  /// Returns true if date-only change is detected, false otherwise
  /// Throws [PlatformException] if platform is not supported or if an error occurs
  static Future<bool> detectDateOnlyChange() async {
    try {
      final bool result = await _channel.invokeMethod('detectDateOnlyChange');
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to detect date-only changes: ${e.message}',
        details: e.details,
      );
    }
  }
  
  /// Fetches the current time from an NTP server
  /// 
  /// [ntpServer] - The NTP server to query (defaults to 'pool.ntp.org')
  /// [timeout] - Connection timeout in milliseconds (defaults to 5000ms)
  /// 
  /// Returns the NTP time as a [DateTime] object
  /// Throws [Exception] if NTP query fails
  static Future<DateTime> fetchNtpTime({
    String ntpServer = defaultNtpServer,
    int timeout = 5000,
  }) async {
    try {
      developer.log('Fetching NTP time from server: $ntpServer', name: 'DateChangeChecker');
      
      final DateTime ntpTime = await NTP.now(
        lookUpAddress: ntpServer,
        timeout: Duration(milliseconds: timeout),
      );
      
      developer.log('Successfully fetched NTP time: $ntpTime', name: 'DateChangeChecker');
      return ntpTime;
    } catch (e) {
      developer.log('Failed to fetch NTP time: $e', name: 'DateChangeChecker', level: 1000);
      throw Exception('NTP time fetch failed: $e');
    }
  }
  
  /// Compares device time with NTP server time to detect time synchronization issues
  /// 
  /// [thresholdMs] - Time difference threshold in milliseconds (defaults to 30 seconds)
  /// [ntpServer] - The NTP server to query (defaults to 'pool.ntp.org')
  /// [timeout] - Connection timeout in milliseconds (defaults to 5000ms)
  /// 
  /// Returns a [TimeSyncResult] containing comparison details
  static Future<TimeSyncResult> detectTimeSyncIssues({
    int thresholdMs = defaultTimeThreshold,
    String ntpServer = defaultNtpServer,
    int timeout = 5000,
  }) async {
    try {
      // Get device time
      final DateTime deviceTime = DateTime.now();
      developer.log('Device time: $deviceTime', name: 'DateChangeChecker');
      
      // Get NTP time
      final DateTime ntpTime = await fetchNtpTime(
        ntpServer: ntpServer,
        timeout: timeout,
      );
      
      // Calculate time difference
      final int timeDifferenceMs = deviceTime.difference(ntpTime).inMilliseconds.abs();
      final bool isSynchronized = timeDifferenceMs <= thresholdMs;
      
      final result = TimeSyncResult(
        deviceTime: deviceTime,
        ntpTime: ntpTime,
        timeDifferenceMs: timeDifferenceMs,
        thresholdMs: thresholdMs,
        isSynchronized: isSynchronized,
        ntpServer: ntpServer,
      );
      
      // Log the result
      if (isSynchronized) {
        developer.log(
          'Time is synchronized. Difference: ${timeDifferenceMs}ms (threshold: ${thresholdMs}ms)',
          name: 'DateChangeChecker',
        );
      } else {
        developer.log(
          'Time synchronization issue detected! Difference: ${timeDifferenceMs}ms (threshold: ${thresholdMs}ms)',
          name: 'DateChangeChecker',
          level: 900,
        );
      }
      
      return result;
    } catch (e) {
      developer.log('Time synchronization check failed: $e', name: 'DateChangeChecker', level: 1000);
      rethrow;
    }
  }
  
  /// Detects if the device's system time has been manually modified
  /// by comparing with NTP server time
  /// 
  /// [thresholdMs] - Time difference threshold in milliseconds (defaults to 30 seconds)
  /// [ntpServer] - The NTP server to query (defaults to 'pool.ntp.org')
  /// [timeout] - Connection timeout in milliseconds (defaults to 5000ms)
  /// 
  /// Returns true if time modification is detected, false otherwise
  static Future<bool> detectTimeModification({
    int thresholdMs = defaultTimeThreshold,
    String ntpServer = defaultNtpServer,
    int timeout = 5000,
  }) async {
    try {
      final TimeSyncResult result = await detectTimeSyncIssues(
        thresholdMs: thresholdMs,
        ntpServer: ntpServer,
        timeout: timeout,
      );
      
      return !result.isSynchronized;
    } catch (e) {
      developer.log('Time modification detection failed: $e', name: 'DateChangeChecker', level: 1000);
      rethrow;
    }
  }
  
  /// Gets the current device time
  /// 
  /// Returns the device's current [DateTime]
  static DateTime getDeviceTime() {
    return DateTime.now();
  }
  
  /// DEPRECATED: Use isDateTimeChanged() instead.
  /// 
  /// Checks if automatic date/time setting is enabled on the device
  /// 
  /// Returns [AutoDateTimeStatus.AUTO_DATE_TIME_ON] if automatic date/time is enabled
  /// Returns [AutoDateTimeStatus.AUTO_DATE_TIME_OFF] if automatic date/time is disabled
  /// 
  /// Throws [PlatformException] if platform is not supported or if an error occurs
  @Deprecated('Use isDateTimeChanged() instead')
  static Future<AutoDateTimeStatus> checkAutoDateTimeStatus() async {
    try {
      // Call the new method and convert the result
      final bool isChanged = await isDateTimeChanged();
      
      // Convert boolean to AutoDateTimeStatus
      return isChanged 
          ? AutoDateTimeStatus.AUTO_DATE_TIME_OFF 
          : AutoDateTimeStatus.AUTO_DATE_TIME_ON;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Comprehensive time analysis combining automatic date/time status check
  /// and NTP-based time synchronization detection
  /// 
  /// [thresholdMs] - Time difference threshold in milliseconds (defaults to 30 seconds)
  /// [ntpServer] - The NTP server to query (defaults to 'pool.ntp.org')
  /// [timeout] - Connection timeout in milliseconds (defaults to 5000ms)
  /// 
  /// Returns a [ComprehensiveTimeAnalysis] with all time-related information
  static Future<ComprehensiveTimeAnalysis> performComprehensiveTimeAnalysis({
    int thresholdMs = defaultTimeThreshold,
    String ntpServer = defaultNtpServer,
    int timeout = 5000,
  }) async {
    try {
      developer.log('Starting comprehensive time analysis', name: 'DateChangeChecker');
      
      // Check automatic date/time status
      final AutoDateTimeStatus autoStatus = await checkAutoDateTimeStatus();
      
      // Perform time synchronization check
      final TimeSyncResult syncResult = await detectTimeSyncIssues(
        thresholdMs: thresholdMs,
        ntpServer: ntpServer,
        timeout: timeout,
      );
      
      final analysis = ComprehensiveTimeAnalysis(
        autoDateTimeStatus: autoStatus,
        timeSyncResult: syncResult,
        analysisTimestamp: DateTime.now(),
      );
      
      developer.log('Comprehensive time analysis completed', name: 'DateChangeChecker');
      return analysis;
    } catch (e) {
      developer.log('Comprehensive time analysis failed: $e', name: 'DateChangeChecker', level: 1000);
      rethrow;
    }
  }
}

/// Result of time synchronization comparison between device and NTP server
class TimeSyncResult {
  /// Device's current time
  final DateTime deviceTime;
  
  /// NTP server time
  final DateTime ntpTime;
  
  /// Time difference in milliseconds (absolute value)
  final int timeDifferenceMs;
  
  /// Threshold used for synchronization check in milliseconds
  final int thresholdMs;
  
  /// Whether the device time is considered synchronized
  final bool isSynchronized;
  
  /// NTP server used for the query
  final String ntpServer;
  
  const TimeSyncResult({
    required this.deviceTime,
    required this.ntpTime,
    required this.timeDifferenceMs,
    required this.thresholdMs,
    required this.isSynchronized,
    required this.ntpServer,
  });
  
  /// Time difference in seconds (with decimal precision)
  double get timeDifferenceSeconds => timeDifferenceMs / 1000.0;
  
  /// Time difference in minutes (with decimal precision)
  double get timeDifferenceMinutes => timeDifferenceSeconds / 60.0;
  
  @override
  String toString() {
    return 'TimeSyncResult(deviceTime: $deviceTime, ntpTime: $ntpTime, '
           'difference: ${timeDifferenceMs}ms, synchronized: $isSynchronized, '
           'server: $ntpServer)';
  }
}

/// Comprehensive analysis combining automatic date/time status and time synchronization
class ComprehensiveTimeAnalysis {
  /// Automatic date/time setting status
  final AutoDateTimeStatus autoDateTimeStatus;
  
  /// Time synchronization result
  final TimeSyncResult timeSyncResult;
  
  /// Timestamp when this analysis was performed
  final DateTime analysisTimestamp;
  
  const ComprehensiveTimeAnalysis({
    required this.autoDateTimeStatus,
    required this.timeSyncResult,
    required this.analysisTimestamp,
  });
  
  /// Whether automatic date/time is enabled
  bool get isAutoDateTimeEnabled => autoDateTimeStatus == AutoDateTimeStatus.AUTO_DATE_TIME_ON;
  
  /// Whether time is synchronized with NTP server
  bool get isTimeSynchronized => timeSyncResult.isSynchronized;
  
  /// Whether there are any time-related issues
  bool get hasTimeIssues => !isAutoDateTimeEnabled || !isTimeSynchronized;
  
  @override
  String toString() {
    return 'ComprehensiveTimeAnalysis(autoDateTime: $autoDateTimeStatus, '
           'synchronized: $isTimeSynchronized, hasIssues: $hasTimeIssues, '
           'timestamp: $analysisTimestamp)';
  }
}

/// Types of date/time changes that can be detected
enum DateTimeChangeType {
  /// No changes detected
  noChange,
  
  /// Only the date has been modified
  dateOnly,
  
  /// Only the time has been modified
  timeOnly,
  
  /// Both date and time have been modified
  dateAndTime;
  
  /// Creates a DateTimeChangeType from a string value
  static DateTimeChangeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'nochange':
        return DateTimeChangeType.noChange;
      case 'dateonly':
        return DateTimeChangeType.dateOnly;
      case 'timeonly':
        return DateTimeChangeType.timeOnly;
      case 'dateandtime':
        return DateTimeChangeType.dateAndTime;
      default:
        return DateTimeChangeType.noChange;
    }
  }
}

/// Result of comprehensive date/time change detection
class DateTimeChangeResult {
  /// Type of change detected
  final DateTimeChangeType changeType;
  
  /// Whether automatic date/time is enabled
  final bool isAutoDateTimeEnabled;
  
  /// Whether the date has changed
  final bool hasDateChanged;
  
  /// Whether the time has changed
  final bool hasTimeChanged;
  
  /// Method used for detection (network or offline)
  final String detectionMethod;
  
  const DateTimeChangeResult({
    required this.changeType,
    required this.isAutoDateTimeEnabled,
    required this.hasDateChanged,
    required this.hasTimeChanged,
    required this.detectionMethod,
  });
  
  /// Creates a DateTimeChangeResult from a map (typically from platform channel)
  factory DateTimeChangeResult.fromMap(Map<String, dynamic> map) {
    return DateTimeChangeResult(
      changeType: DateTimeChangeType.fromString(map['changeType'] ?? 'noChange'),
      isAutoDateTimeEnabled: map['isAutoDateTimeEnabled'] ?? false,
      hasDateChanged: map['hasDateChanged'] ?? false,
      hasTimeChanged: map['hasTimeChanged'] ?? false,
      detectionMethod: map['detectionMethod'] ?? 'unknown',
    );
  }
  
  /// Whether any changes were detected
  bool get hasAnyChanges => changeType != DateTimeChangeType.noChange;
  
  /// Whether only date was modified (useful for specific notifications)
  bool get isDateOnlyChange => changeType == DateTimeChangeType.dateOnly;
  
  /// Whether only time was modified
  bool get isTimeOnlyChange => changeType == DateTimeChangeType.timeOnly;
  
  /// Whether both date and time were modified
  bool get isBothChanged => changeType == DateTimeChangeType.dateAndTime;
  
  @override
  String toString() {
    return 'DateTimeChangeResult(changeType: $changeType, '
           'autoEnabled: $isAutoDateTimeEnabled, dateChanged: $hasDateChanged, '
           'timeChanged: $hasTimeChanged, method: $detectionMethod)';
  }
}
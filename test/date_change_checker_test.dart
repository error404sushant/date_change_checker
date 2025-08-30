import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:date_change_checker/date_change_checker.dart';

void main() {
  const MethodChannel channel = MethodChannel('date_change_checker');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('DateChangeChecker', () {
    test('checkAutoDateTimeStatus returns AUTO_DATE_TIME_ON when native returns true', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'checkAutoDateTimeStatus') {
          return true;
        }
        return null;
      });

      // Act
      final result = await DateChangeChecker.checkAutoDateTimeStatus();

      // Assert
      expect(result, AutoDateTimeStatus.AUTO_DATE_TIME_ON);
    });

    test('checkAutoDateTimeStatus returns AUTO_DATE_TIME_OFF when native returns false', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'checkAutoDateTimeStatus') {
          return false;
        }
        return null;
      });

      // Act
      final result = await DateChangeChecker.checkAutoDateTimeStatus();

      // Assert
      expect(result, AutoDateTimeStatus.AUTO_DATE_TIME_OFF);
    });

    test('checkAutoDateTimeStatus throws PlatformException when native throws error', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'checkAutoDateTimeStatus') {
          throw PlatformException(
            code: 'DETECTION_ERROR',
            message: 'Failed to detect auto date/time status',
          );
        }
        return null;
      });

      // Act & Assert
      expect(
        () => DateChangeChecker.checkAutoDateTimeStatus(),
        throwsA(isA<PlatformException>()),
      );
    });

    test('checkAutoDateTimeStatus calls correct method on channel', () async {
      // Arrange
      String? calledMethod;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        calledMethod = methodCall.method;
        return true;
      });

      // Act
      await DateChangeChecker.checkAutoDateTimeStatus();

      // Assert
      expect(calledMethod, 'checkAutoDateTimeStatus');
    });
  });

  group('AutoDateTimeStatus', () {
    test('enum has correct values', () {
      expect(AutoDateTimeStatus.values.length, 2);
      expect(AutoDateTimeStatus.values, contains(AutoDateTimeStatus.AUTO_DATE_TIME_ON));
      expect(AutoDateTimeStatus.values, contains(AutoDateTimeStatus.AUTO_DATE_TIME_OFF));
    });

    test('enum values have correct string representation', () {
      expect(AutoDateTimeStatus.AUTO_DATE_TIME_ON.toString(), 'AutoDateTimeStatus.AUTO_DATE_TIME_ON');
      expect(AutoDateTimeStatus.AUTO_DATE_TIME_OFF.toString(), 'AutoDateTimeStatus.AUTO_DATE_TIME_OFF');
    });
  });
}
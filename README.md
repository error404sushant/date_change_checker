# Date Change Checker

A cross-platform Flutter package that detects whether the device's automatic date/time setting is disabled, providing unified functionality for both Android and iOS platforms.

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue.svg)](https://github.com/error404sushant/date_change_checker)

## Demo

### iOS Demo
![iOS Demo](https://raw.githubusercontent.com/error404sushant/date_change_checker/refs/heads/main/ios.gif)

### Android Demo
![Android Demo](https://raw.githubusercontent.com/error404sushant/date_change_checker/refs/heads/main/android.gif)

## Features

- ✅ Cross-platform support (Android & iOS)
- ✅ Simple, unified API
- ✅ No special permissions required
- ✅ Lightweight implementation
- ✅ Comprehensive error handling
- ✅ Complete example application

## Platform Support

| Platform | Minimum Version | Implementation |
|----------|-----------------|----------------|
| Android  | API Level 21 (Android 5.0) | `Settings.Global.AUTO_TIME` |
| iOS      | iOS 11.0 | `NSTimeZone.autoupdatingCurrent` |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  date_change_checker: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:date_change_checker/date_change_checker.dart';

// Check if date/time has been changed (automatic date/time is disabled)
try {
  final isChanged = await DateChangeChecker.isDateTimeChanged();
  
  if (isChanged) {
    print('Date/time has been changed (automatic date/time is disabled)');
  } else {
    print('Date/time has not been changed (automatic date/time is enabled)');
  }
} on PlatformException catch (e) {
  print('Error: ${e.message}');
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_change_checker/date_change_checker.dart';

class DateTimeStatusWidget extends StatefulWidget {
  @override
  _DateTimeStatusWidgetState createState() => _DateTimeStatusWidgetState();
}

class _DateTimeStatusWidgetState extends State<DateTimeStatusWidget> {
  AutoDateTimeStatus? _status;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isChanged = await DateChangeChecker.isDateTimeChanged();
      // Convert to status for backward compatibility
      final status = isChanged 
          ? AutoDateTimeStatus.AUTO_DATE_TIME_OFF 
          : AutoDateTimeStatus.AUTO_DATE_TIME_ON;
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          CircularProgressIndicator()
        else if (_errorMessage != null)
          Text('Error: $_errorMessage', style: TextStyle(color: Colors.red))
        else if (_status != null)
          Text(
            _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
                ? 'Auto Date/Time: Enabled'
                : 'Auto Date/Time: Disabled',
            style: TextStyle(
              color: _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ElevatedButton(
          onPressed: _checkStatus,
          child: Text('Refresh Status'),
        ),
      ],
    );
  }
}
```

## API Reference

### DateChangeChecker

Main class for checking automatic date/time settings.

#### Methods

##### `isDateTimeChanged()`

```dart
static Future<bool> isDateTimeChanged()
```

Checks if the device's date/time has been changed (automatic date/time is disabled).

**Returns:**
- `true` if date/time has been changed (automatic date/time is disabled)
- `false` if date/time has not been changed (automatic date/time is enabled)

##### `checkAutoDateTimeStatus()` (Deprecated)

```dart
static Future<AutoDateTimeStatus> checkAutoDateTimeStatus()
```

Deprecated: Use `isDateTimeChanged()` instead.

Checks if automatic date/time is enabled on the device.

**Returns:**
- `AutoDateTimeStatus.AUTO_DATE_TIME_ON` if automatic date/time is enabled
- `AutoDateTimeStatus.AUTO_DATE_TIME_OFF` if automatic date/time is disabled

**Throws:**
- `PlatformException` if the platform is not supported or an error occurs

### AutoDateTimeStatus

Enum representing the status of automatic date/time setting.

```dart
enum AutoDateTimeStatus {
  /// Automatic date/time is enabled
  AUTO_DATE_TIME_ON,
  
  /// Automatic date/time is disabled
  AUTO_DATE_TIME_OFF
}
```

## Platform-Specific Implementation Details

### Android

The Android implementation uses `Settings.Global.AUTO_TIME` to check if automatic date/time is enabled. This setting is publicly readable and doesn't require any special permissions.

```kotlin
Settings.Global.getInt(context.contentResolver, Settings.Global.AUTO_TIME) == 1
```

### iOS

The iOS implementation uses `NSTimeZone.autoupdatingCurrent` to determine if the device is set to automatically update its time zone and date/time settings.

```swift
let autoUpdatingTimeZone = NSTimeZone.autoupdatingCurrent
let systemTimeZone = NSTimeZone.system
return autoUpdatingTimeZone.isEqual(to: systemTimeZone)
```

## Error Handling

The package provides comprehensive error handling:

- **Platform not supported**: Throws `PlatformException` with appropriate error code
- **System API failure**: Returns safe default values with proper error reporting
- **Permission issues**: Handled gracefully with fallback behavior

## Example Application

Run the example application to see the package in action:

```bash
cd example
flutter run
```

The example app demonstrates:
- Basic status checking
- Error handling
- UI integration
- Real-time status updates
- User guidance for enabling automatic date/time

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request on [GitHub](https://github.com/error404sushant/date_change_checker).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-06-30

### Changed
- **BREAKING**: Renamed `checkAutoDateTimeStatus()` to `isDateTimeChanged()`
- **BREAKING**: Changed return type from `AutoDateTimeStatus` enum to `bool`
- Updated documentation and examples to reflect new API
- Improved method naming for better semantic clarity

### Added
- Backward compatibility for existing method channel implementations

## [1.0.1] - 2024-06-29

### Fixed
- Fixed Android method channel implementation to properly handle `isAutoDateTimeEnabled` method
- Resolved MissingPluginException when automatic date/time is disabled on Android devices
- Improved platform-specific implementation with better error handling

## [1.0.0] - 2024-01-29

### Added
- Initial release of date_change_checker package
- Cross-platform support for Android and iOS
- `DateChangeChecker` class with `checkAutoDateTimeStatus()` method
- `AutoDateTimeStatus` enum with `AUTO_DATE_TIME_ON` and `AUTO_DATE_TIME_OFF` values
- Android implementation using `Settings.Global.AUTO_TIME`
- iOS implementation using `NSTimeZone.autoupdatingCurrent`
- Method channel communication between Dart and native platforms
- Comprehensive error handling with `PlatformException`
- Complete example application demonstrating package functionality
- Detailed documentation and API reference
- Unit tests for core functionality

### Platform Support
- Android: Minimum API Level 21 (Android 5.0)
- iOS: Minimum iOS 11.0
- Flutter: SDK 3.0.0 or higher

### Features
- No special permissions required
- Lightweight implementation with minimal memory footprint
- Real-time status detection
- Graceful error handling and fallback behavior
- Material Design example UI with status indicators
- User guidance for enabling automatic date/time settings

### Technical Details
- Method channel name: `date_change_checker`
- Package structure follows Flutter plugin best practices
- Proper resource cleanup and memory management
- Thread-safe implementation on both platforms
- Comprehensive documentation with usage examples
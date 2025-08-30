import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_change_checker/date_change_checker.dart';

/// Entry point of the application
void main() {
  runApp(const MyApp());
}

//region App Configuration
/// Root application widget that configures the app theme and home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Change Checker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Date Change Checker Demo'),
    );
  }
//endregion
}

//region Home Page Widget
/// Main page widget that demonstrates the Date Change Checker functionality
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //region State Variables
  /// Stores the current auto date time status result
  AutoDateTimeStatus? _status;

  /// Indicates whether a check operation is in progress
  bool _isLoading = false;

  /// Stores error message if any operation fails
  String? _errorMessage;
  //endregion

  //region Lifecycle Methods
  /// Initialize the widget and perform initial status check
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }
  //endregion

  //region Date Change Checking Logic
  /// Checks if the device's date/time settings have been manually changed
  ///
  /// This method calls the DateChangeChecker plugin to determine if
  /// automatic date/time is disabled or if manual changes were made.
  /// Updates the UI state based on the result or displays errors if any occur.
  Future<void> _checkStatus() async {
    print('DEBUG: _checkStatus called');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    print('DEBUG: Loading state set to true');

    try {
      print('DEBUG: Calling DateChangeChecker.isDateTimeChanged()');
      // Call the plugin to check if date/time has been manually changed
      final isChanged = await DateChangeChecker.isDateTimeChanged();
      print('DEBUG: Date/time changed: $isChanged');

      // Convert boolean to AutoDateTimeStatus for backward compatibility in the example
      // - If isChanged is true: automatic date/time is OFF or manual changes detected
      // - If isChanged is false: automatic date/time is ON and no manual changes
      final status = isChanged
          ? AutoDateTimeStatus.AUTO_DATE_TIME_OFF
          : AutoDateTimeStatus.AUTO_DATE_TIME_ON;

      setState(() {
        _status = status;
        _isLoading = false;
      });
      print('DEBUG: State updated with status');
    } on PlatformException catch (e) {
      // Handle platform-specific errors (iOS/Android native code issues)
      print('DEBUG: Platform exception: ${e.message}');
      setState(() {
        _errorMessage = 'Platform Error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      // Handle any other unexpected errors
      print('DEBUG: General exception: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }
  //endregion

  //region UI Helper Methods
  /// Returns the appropriate color based on the current status
  ///
  /// - Grey: Status unknown
  /// - Green: Auto date/time ON (no changes detected)
  /// - Red: Auto date/time OFF (changes detected)
  Color _getStatusColor() {
    if (_status == null) return Colors.grey;
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? Colors.green
        : Colors.red;
  }

  /// Returns the appropriate icon based on the current status
  ///
  /// - Question mark: Status unknown
  /// - Check circle: Auto date/time ON (no changes detected)
  /// - Error icon: Auto date/time OFF (changes detected)
  IconData _getStatusIcon() {
    if (_status == null) return Icons.help_outline;
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? Icons.check_circle
        : Icons.error;
  }

  /// Returns the appropriate status text based on the current status
  ///
  /// - Unknown: Status not determined yet
  /// - NOT DETECTED: No date/time changes found
  /// - DETECTED: Date/time changes found
  String _getStatusText() {
    if (_status == null) return 'Unknown';
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? 'Date/Time Change: NOT DETECTED'
        : 'Date/Time Change: DETECTED';
  }

  /// Returns a detailed description of the current status
  ///
  /// Provides more context about what the status means in terms of
  /// automatic date/time settings and potential manual changes
  String _getStatusDescription() {
    if (_status == null) return 'Unable to determine status';
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? 'Automatic date/time is enabled - no manual changes detected.'
        : 'Automatic date/time is disabled - manual changes may have been made.';
    //endregion
  }

  //region UI Build Method
  /// Builds the main UI of the application
  ///
  /// Creates a scaffold with:
  /// - AppBar with the title
  /// - Refresh button to manually check date/time status
  /// - Status card that displays different UI based on current state:
  ///   - Loading indicator when checking
  ///   - Error message when an error occurs
  ///   - Status information when check completes successfully
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //region Refresh Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            //endregion
            const SizedBox(height: 32),
            //region Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //region Loading State
                    if (_isLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Checking date/time change status...'),
                        ],
                      )
                    //endregion
                    //region Error State
                    else if (_errorMessage != null)
                      Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                    //endregion
                    //region Result State
                    else
                      Column(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 64,
                            color: _getStatusColor(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getStatusText(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getStatusDescription(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    //endregion
                  ],
                ),
              ),
            ),
            //endregion
          ],
        ),
      ),
    );
    //endregion
  }
}
//endregion

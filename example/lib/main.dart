import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_change_checker/date_change_checker.dart';

void main() {
  runApp(const MyApp());
}

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
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AutoDateTimeStatus? _status;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    print('DEBUG: _checkStatus called');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    print('DEBUG: Loading state set to true');

    try {
      print('DEBUG: Calling DateChangeChecker.checkAutoDateTimeStatus()');
      final status = await DateChangeChecker.checkAutoDateTimeStatus();
      print('DEBUG: Received status: $status');
      setState(() {
        _status = status;
        _isLoading = false;
      });
      print('DEBUG: State updated with status');
    } on PlatformException catch (e) {
      print('DEBUG: Platform exception: ${e.message}');
      setState(() {
        _errorMessage = 'Platform Error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: General exception: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor() {
    if (_status == null) return Colors.grey;
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? Colors.green
        : Colors.red;
  }

  IconData _getStatusIcon() {
    if (_status == null) return Icons.help_outline;
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? Icons.check_circle
        : Icons.error;
  }

  String _getStatusText() {
    if (_status == null) return 'Unknown';
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? 'Date/Time Change: NOT DETECTED'
        : 'Date/Time Change: DETECTED';
  }

  String _getStatusDescription() {
    if (_status == null) return 'Unable to determine status';
    return _status == AutoDateTimeStatus.AUTO_DATE_TIME_ON
        ? 'Automatic date/time is enabled - no manual changes detected.'
        : 'Automatic date/time is disabled - manual changes may have been made.';
  }

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
            // Refresh Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            // Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Checking date/time change status...'),
                        ],
                      )
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

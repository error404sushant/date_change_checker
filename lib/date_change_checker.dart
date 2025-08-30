/// A cross-platform Flutter package that detects whether the device's automatic date/time setting is disabled.
library date_change_checker;

export 'src/date_change_checker_base.dart';
export 'src/auto_date_time_status.dart';

// Export new comprehensive date/time detection classes
export 'src/date_change_checker_base.dart'
    show DateTimeChangeType, DateTimeChangeResult;

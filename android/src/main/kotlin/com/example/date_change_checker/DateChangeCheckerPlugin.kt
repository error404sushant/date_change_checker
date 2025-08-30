package com.example.date_change_checker

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DateChangeCheckerPlugin */
class DateChangeCheckerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: android.content.Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "date_change_checker")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "checkAutoDateTimeStatus" -> {
        try {
          val isEnabled = AutoDateTimeDetector.isAutoDateTimeEnabled(context)
          result.success(isEnabled)
        } catch (e: Exception) {
          result.error("DETECTION_ERROR", "Failed to detect auto date/time status: ${e.message}", null)
        }
      }
      "isAutoDateTimeEnabled" -> {
        try {
          val isEnabled = AutoDateTimeDetector.isAutoDateTimeEnabled(context)
          result.success(isEnabled)
        } catch (e: Exception) {
          result.error("DETECTION_ERROR", "Failed to detect auto date/time status: ${e.message}", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
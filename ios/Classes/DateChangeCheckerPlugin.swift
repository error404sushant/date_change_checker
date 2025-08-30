import Flutter
import UIKit

public class DateChangeCheckerPlugin: NSObject, FlutterPlugin {
  
  override init() {
    super.init()
    // Initialize the AutoDateTimeDetector
    AutoDateTimeDetector.initialize()
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "date_change_checker", binaryMessenger: registrar.messenger())
    let instance = DateChangeCheckerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  deinit {
    // Clean up network monitoring when plugin is deallocated
    AutoDateTimeDetector.stopNetworkMonitoring()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAutoDateTimeEnabled":
      AutoDateTimeDetector.isAutoDateTimeEnabled { isEnabled in
        DispatchQueue.main.async {
          result(isEnabled)
        }
      }
      
    case "detectDateTimeChange":
      AutoDateTimeDetector.detectDateTimeChange { changeDetected in
        DispatchQueue.main.async {
          result(changeDetected)
        }
      }
      
    case "detectComprehensiveDateTimeChange":
      AutoDateTimeDetector.detectComprehensiveDateTimeChange { changeDetected in
        DispatchQueue.main.async {
          result(changeDetected)
        }
      }
      
    case "detectAndNotifyDateTimeChanges":
      AutoDateTimeDetector.detectAndNotifyDateTimeChanges { changeDetected in
        DispatchQueue.main.async {
          result(changeDetected)
        }
      }
      
    case "detectDateOnlyChange":
      AutoDateTimeDetector.detectDateOnlyChange { changeDetected in
        DispatchQueue.main.async {
          result(changeDetected)
        }
      }
      
    case "getLocalTime":
      let currentTime = AutoDateTimeDetector.getCurrentLocalTime()
      let timestamp = currentTime.timeIntervalSince1970
      result(timestamp)
      
    case "getInternetUTCTime":
      AutoDateTimeDetector.fetchInternetUTCTime { fetchResult in
        DispatchQueue.main.async {
          switch fetchResult {
          case .success(let utcTime):
            let timestamp = utcTime.timeIntervalSince1970
            result(timestamp)
          case .failure(let error):
            result(FlutterError(code: "NETWORK_ERROR",
                              message: "Failed to fetch internet time: \(error.localizedDescription)",
                              details: nil))
          }
        }
      }
      
    case "convertToLocalTime":
      guard let args = call.arguments as? [String: Any],
            let timestamp = args["timestamp"] as? Double else {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                          message: "Invalid timestamp argument",
                          details: nil))
        return
      }
      
      let localTime = Date(timeIntervalSince1970: timestamp)
      let utcTime = AutoDateTimeDetector.convertLocalTimeToUTC(localTime)
      let utcTimestamp = utcTime.timeIntervalSince1970
      result(utcTimestamp)
      
    case "setStoredTimestamp":
      handleSetStoredTimestamp(call: call, result: result)
      
    case "getStoredTimestamp":
      if let storedTime = AutoDateTimeDetector.getStoredTimestamp() {
        let timestamp = storedTime.timeIntervalSince1970
        result(timestamp)
      } else {
        result(nil)
      }
      
    case "resetDetector":
      AutoDateTimeDetector.reset()
      result(true)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleSetStoredTimestamp(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let args = call.arguments as? [String: Any],
            let timestamp = args["timestamp"] as? Double else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid timestamp", details: nil))
          return
      }
      
      let date = Date(timeIntervalSince1970: timestamp)
      AutoDateTimeDetector.setStoredTimestamp(date)
      result(nil)
  }
  
  private func handleDetectComprehensiveDateTimeChange(result: @escaping FlutterResult) {
      AutoDateTimeDetector.detectComprehensiveDateTimeChange { changeResult in
          DispatchQueue.main.async {
              let resultDict: [String: Any] = [
                    "changeType": String(describing: changeResult.changeType),
                    "isAutoDateTimeEnabled": changeResult.isAutoDateTimeEnabled,
                    "dateChanged": changeResult.dateChanged,
                    "timeChanged": changeResult.timeChanged,
                    "timeDifference": changeResult.timeDifference
                ]
              result(resultDict)
          }
      }
  }
  
  private func handleDetectAndNotifyDateTimeChanges(result: @escaping FlutterResult) {
      AutoDateTimeDetector.detectAndNotifyDateTimeChanges { changeResult in
          DispatchQueue.main.async {
              let resultDict: [String: Any] = [
                  "changeType": String(describing: changeResult.changeType),
                  "isAutoDateTimeEnabled": changeResult.isAutoDateTimeEnabled,
                  "dateChanged": changeResult.dateChanged,
                  "timeChanged": changeResult.timeChanged,
                  "timeDifference": changeResult.timeDifference
              ]
              result(resultDict)
          }
      }
  }
  
  private func handleDetectDateOnlyChange(result: @escaping FlutterResult) {
      AutoDateTimeDetector.detectDateOnlyChange { hasDateChanged in
          DispatchQueue.main.async {
              result(hasDateChanged)
          }
      }
  }
}
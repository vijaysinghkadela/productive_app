import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register MethodChannel for Screen Time API
    let controller = window?.rootViewController as! FlutterViewController
    
    let screenTimeChannel = FlutterMethodChannel(
      name: "com.focusguard/screentime",
      binaryMessenger: controller.binaryMessenger
    )
    
    let screenTimeManager = ScreenTimeManager()
    
    screenTimeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "requestAuthorization":
        screenTimeManager.requestAuthorization(result: result)
      case "shieldApps":
        if let args = call.arguments as? [String: Any],
           let bundleIds = args["bundleIds"] as? [String] {
          screenTimeManager.shieldApps(bundleIds: bundleIds, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing bundleIds", details: nil))
        }
      case "removeShields":
        screenTimeManager.removeShields(result: result)
      case "isAuthorized":
        screenTimeManager.isAuthorized(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register MethodChannel for App Blocker
    let blockerChannel = FlutterMethodChannel(
      name: "com.focusguard/app_blocker",
      binaryMessenger: controller.binaryMessenger
    )

    blockerChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "startBlocking":
        if let args = call.arguments as? [String: Any],
           let packages = args["packages"] as? [String] {
          screenTimeManager.shieldApps(bundleIds: packages, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing packages", details: nil))
        }
      case "stopBlocking":
        screenTimeManager.removeShields(result: result)
      case "checkPermissions":
        screenTimeManager.isAuthorized(result: result)
      case "openPermissionSettings":
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register MethodChannel for Usage Tracker
    let usageChannel = FlutterMethodChannel(
      name: "com.focusguard/usage_tracker",
      binaryMessenger: controller.binaryMessenger
    )

    usageChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "hasUsagePermission":
        screenTimeManager.isAuthorized(result: result)
      case "requestUsagePermission":
        screenTimeManager.requestAuthorization(result: result)
      case "getUsageStats":
        // iOS usage stats are accessed via DeviceActivityReport
        // which requires a separate app extension
        result([:] as [String: Int])
      case "getInstalledApps":
        result([] as [[String: String]])
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Security Method Channel
    let securityChannel = FlutterMethodChannel(
      name: "com.edukkit.app/security",
      binaryMessenger: controller.binaryMessenger
    )

    securityChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "isScreenCaptured":
        if #available(iOS 11.0, *) {
          let isCaptured = UIScreen.main.isCaptured
          result(isCaptured)
        } else {
          result(false)
        }
      case "getSecurityInfo":
        result([
          "platform": "iOS",
          "systemVersion": UIDevice.current.systemVersion,
          "model": UIDevice.current.model,
          "fairPlaySupported": true
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    // Screen Capture Event Channel
    let captureEventChannel = FlutterEventChannel(
      name: "com.edukkit.app/screen_capture_events",
      binaryMessenger: controller.binaryMessenger
    )
    captureEventChannel.setStreamHandler(self)

    // Register screen capture observers
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(screenCaptureChanged),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userTookScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func screenCaptureChanged() {
    if #available(iOS 11.0, *) {
      let isCaptured = UIScreen.main.isCaptured
      eventSink?(["type": "capture_changed", "isCaptured": isCaptured])
    }
  }

  @objc private func userTookScreenshot() {
    eventSink?(["type": "screenshot_taken", "isCaptured": false])
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    if #available(iOS 11.0, *) {
      events(["type": "initial_state", "isCaptured": UIScreen.main.isCaptured])
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}

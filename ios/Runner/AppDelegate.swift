import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle universal links - return true to prevent Safari from opening
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Let the app_links plugin handle the link
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      // Return true immediately to tell iOS we're handling this
      // This prevents Safari from opening as a fallback
      let result = super.application(application, continue: userActivity, restorationHandler: restorationHandler)
      return true  // Always return true for web activities to prevent Safari fallback
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}

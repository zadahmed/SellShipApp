import UIKit
import Flutter
import GoogleMaps
import FirebaseAuth


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAL0gczX37-cNVHC_4aV6lWE3RSNqeamf4")
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
             let firebaseAuth = Auth.auth()
             firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
   }
   override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
             let firebaseAuth = Auth.auth()
             if (firebaseAuth.canHandleNotification(userInfo)){
                 print(userInfo)
                 return
             }
  }
}

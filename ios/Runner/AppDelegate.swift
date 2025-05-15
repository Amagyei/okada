import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let GoogleMapsAPIKey = "AIzaSyAKL2jbKsO2XHoreH_sxQ8243AkOB1GbkA" as? String {
        print("Api key  has been found ")
      GMSServices.provideAPIKey(GoogleMapsAPIKey)
    }
    else {
      print("ERROR: AppDelegate.swift - GOOGLE_MAPS_API_KEY is not set. Maps will not work on iOS.")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

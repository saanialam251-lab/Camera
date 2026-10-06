import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register native AR bridges (P1–P5)
    if let registrar = self.registrar(forPlugin: "ArBridge") {
      ArBridge.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "SensorFusion") {
      SensorFusion.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "DepthProcessor") {
      DepthProcessor.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "ThermalMonitor") {
      ThermalMonitor.register(with: registrar)
    }
    if let registrar = self.registrar(forPlugin: "ScreenRecorder") {
      ScreenRecorder.register(with: registrar)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

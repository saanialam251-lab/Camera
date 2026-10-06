import Flutter
import Foundation
import ReplayKit

/// Screen / AR session video capture  P5
class ScreenRecorder: NSObject, FlutterPlugin {
    private var recording = false
    private var outputPath: String?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ScreenRecorder()
        let channel = FlutterMethodChannel(
            name: "measure_reality/recorder",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler(instance.handle)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            if recording {
                result(FlutterError(
                    code: "already_recording",
                    message: "Already recording",
                    details: nil
                ))
                return
            }
            if let args = call.arguments as? [String: Any] {
                outputPath = args["path"] as? String
            }
            // TODO: RPScreenRecorder.shared().startCapture
            recording = true
            result(["path": outputPath as Any, "recording": true])
        case "stop":
            recording = false
            result(["path": outputPath as Any, "recording": false])
        case "isRecording":
            result(recording)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

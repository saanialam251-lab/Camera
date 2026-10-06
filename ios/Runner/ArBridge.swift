import Flutter
import Foundation
import ARKit

/// ARKit bridge – P1
/// Session, raycast, LiDAR when available.
/// Produces immutable frame snapshots on the AR/tracking thread.
class ArBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var session: ARSession?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ArBridge()
        let method = FlutterMethodChannel(name: "measure_reality/ar", binaryMessenger: registrar.messenger())
        method.setMethodCallHandler(instance.handle)
        let event = FlutterEventChannel(name: "measure_reality/ar_frames", binaryMessenger: registrar.messenger())
        event.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startSession":
            // TODO: ARWorldTrackingConfiguration, planeDetection, sceneReconstruction if LiDAR
            result([
                "tracking": "normal",
                "depthSupported": ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh),
                "lidar": ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh),
                "depthType": ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) ? "hardware" : "estimated"
            ])
        case "stopSession":
            session?.pause()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        // TODO: ARSessionDelegate → raycast → push dictionary
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

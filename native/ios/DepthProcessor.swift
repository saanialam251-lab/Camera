import Flutter
import Foundation
import ARKit

/// Depth image sampling  P3
/// LiDAR scene depth when available, otherwise estimated.
/// 1530 Hz while render stays 60 Hz.
class DepthProcessor: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var targetHz: Int = 20
    private var timer: Timer?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = DepthProcessor()
        let method = FlutterMethodChannel(
            name: "measure_reality/depth",
            binaryMessenger: registrar.messenger()
        )
        method.setMethodCallHandler(instance.handle)
        let event = FlutterEventChannel(
            name: "measure_reality/depth_frames",
            binaryMessenger: registrar.messenger()
        )
        event.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            if let args = call.arguments as? [String: Any],
               let hz = args["hz"] as? Int {
                targetHz = max(15, min(30, hz))
            }
            start()
            let hasLidar = ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
            result([
                "depthSupported": hasLidar,
                "source": hasLidar ? "hardware" : "estimated"
            ])
        case "stop":
            stop()
            result(nil)
        case "setHz":
            if let args = call.arguments as? [String: Any],
               let hz = args["hz"] as? Int {
                targetHz = max(15, min(30, hz))
            }
            result(targetHz)
        case "hitTest":
            // TODO: sample ARFrame.sceneDepth at (u, v)
            result([
                "x": 0.0, "y": 0.0, "z": -1.0,
                "source": ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
                    ? "hardware" : "estimated",
                "confidence": 0.8,
                "distance": 1.0
            ])
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        start()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        stop()
        return nil
    }

    private func start() {
        stop()
        // TODO: drive from ARSessionDelegate at targetHz
        // Push: { t, w, h, samples: [{u,v,d,src,conf}], primarySource }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }
}

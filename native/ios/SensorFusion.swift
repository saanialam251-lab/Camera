import Flutter
import Foundation
import CoreMotion

/// Sensor fusion for Level / Vertical  P2
/// Accelerometer + Gyroscope via CMMotionManager.
/// Complementary filter lives in Dart (LevelEngine).
class SensorFusion: NSObject, FlutterPlugin, FlutterStreamHandler {
    private let motion = CMMotionManager()
    private var eventSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SensorFusion()
        let method = FlutterMethodChannel(
            name: "measure_reality/sensors",
            binaryMessenger: registrar.messenger()
        )
        method.setMethodCallHandler(instance.handle)
        let event = FlutterEventChannel(
            name: "measure_reality/sensor_stream",
            binaryMessenger: registrar.messenger()
        )
        event.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            start()
            result(true)
        case "stop":
            stop()
            result(nil)
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
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data = data, let sink = self?.eventSink else { return }
            let a = data.userAcceleration
            let g = data.rotationRate
            // Also include gravity for more stable tilt
            let grav = data.gravity
            sink([
                "ax": grav.x + a.x,
                "ay": grav.y + a.y,
                "az": grav.z + a.z,
                "gx": g.x,
                "gy": g.y,
                "gz": g.z,
                "t": Date().timeIntervalSince1970
            ])
        }
    }

    private func stop() {
        motion.stopDeviceMotionUpdates()
    }
}

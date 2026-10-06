import Flutter
import Foundation

/// Thermal + battery monitor for Adaptive Quality Governor  P4
/// Uses ProcessInfo thermalState and battery notifications.
class ThermalMonitor: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ThermalMonitor()
        let method = FlutterMethodChannel(
            name: "measure_reality/thermal",
            binaryMessenger: registrar.messenger()
        )
        method.setMethodCallHandler(instance.handle)
        let event = FlutterEventChannel(
            name: "measure_reality/thermal_stream",
            binaryMessenger: registrar.messenger()
        )
        event.setStreamHandler(instance)

        // Observe thermal changes
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(instance.thermalChanged),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getStatus":
            result(currentStatus())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        eventSink?(currentStatus())
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    @objc private func thermalChanged() {
        eventSink?(currentStatus())
    }

    private func currentStatus() -> [String: Any] {
        let state = ProcessInfo.processInfo.thermalState
        var thermalStatus = "none"
        var isHot = false
        var isThrottling = false

        switch state {
        case .nominal:
            thermalStatus = "none"
        case .fair:
            thermalStatus = "light"; isHot = true
        case .serious:
            thermalStatus = "moderate"; isHot = true
        case .critical:
            thermalStatus = "severe"; isHot = true; isThrottling = true
        @unknown default:
            thermalStatus = "none"
        }

        UIDevice.current.isBatteryMonitoringEnabled = true
        let batterySaver = ProcessInfo.processInfo.isLowPowerModeEnabled

        return [
            "thermalStatus": thermalStatus,
            "isHot": isHot,
            "isThrottling": isThrottling,
            "batterySaver": batterySaver
        ]
    }
}

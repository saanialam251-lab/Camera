package com.measurereality

import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Thermal + battery monitor for Adaptive Quality Governor  P4
 * Reads OS thermal status and battery; streams to Dart PerfGovernor.
 */
class ThermalMonitor(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    private var eventSink: EventChannel.EventSink? = null

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "measure_reality/thermal")
            .setMethodCallHandler(this)
        EventChannel(engine.dartExecutor.binaryMessenger, "measure_reality/thermal_stream")
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(currentStatus())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        // Push initial
        eventSink?.success(currentStatus())
        // TODO: register PowerManager.OnThermalStatusChangedListener (API 29+)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun currentStatus(): Map<String, Any> {
        var thermalStatus = "none"
        var isHot = false
        var isThrottling = false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            when (powerManager.currentThermalStatus) {
                PowerManager.THERMAL_STATUS_NONE -> thermalStatus = "none"
                PowerManager.THERMAL_STATUS_LIGHT -> {
                    thermalStatus = "light"; isHot = true
                }
                PowerManager.THERMAL_STATUS_MODERATE -> {
                    thermalStatus = "moderate"; isHot = true
                }
                PowerManager.THERMAL_STATUS_SEVERE -> {
                    thermalStatus = "severe"; isHot = true; isThrottling = true
                }
                PowerManager.THERMAL_STATUS_CRITICAL,
                PowerManager.THERMAL_STATUS_EMERGENCY,
                PowerManager.THERMAL_STATUS_SHUTDOWN -> {
                    thermalStatus = "critical"; isHot = true; isThrottling = true
                }
            }
        }

        return mapOf(
            "thermalStatus" to thermalStatus,
            "isHot" to isHot,
            "isThrottling" to isThrottling,
            "batterySaver" to powerManager.isPowerSaveMode
        )
    }
}

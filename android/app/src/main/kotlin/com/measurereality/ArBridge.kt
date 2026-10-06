package com.measurereality

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * ARCore bridge – P1
 * Session, camera, hit-test (depth > plane > feature > instant placement).
 * Produces immutable frame snapshots on the AR/tracking thread.
 */
class ArBridge(private val activity: Activity) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "measure_reality/ar")
            .setMethodCallHandler(this)
        EventChannel(engine.dartExecutor.binaryMessenger, "measure_reality/ar_frames")
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startSession" -> {
                // TODO: ArSession creation, install ARCore if needed, request camera permission
                result.success(mapOf(
                    "tracking" to "normal",
                    "depthSupported" to true,
                    "lidar" to false,
                    "depthType" to "hardware"
                ))
            }
            "stopSession" -> {
                // TODO: pause / close session
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        // TODO: start frame loop → hit-test → push map {x,y,z,t,tq,dq,cs,fd,lt,plane,depth}
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}

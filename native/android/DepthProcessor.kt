package com.measurereality

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Depth image sampling  P3
 * Runs at 1530 Hz while render stays at 60 Hz.
 * Priority: hardware (ToF) > depth model > plane > feature.
 * Produces sparse DepthSample maps for the Dart side.
 */
class DepthProcessor(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var targetHz = 20
    private var running = false

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "measure_reality/depth")
            .setMethodCallHandler(this)
        EventChannel(engine.dartExecutor.binaryMessenger, "measure_reality/depth_frames")
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                targetHz = (call.argument<Int>("hz") ?: 20).coerceIn(15, 30)
                start()
                result.success(mapOf(
                    "depthSupported" to hasHardwareDepth(),
                    "source" to primarySource()
                ))
            }
            "stop" -> {
                stop()
                result.success(null)
            }
            "setHz" -> {
                targetHz = (call.argument<Int>("hz") ?: 20).coerceIn(15, 30)
                result.success(targetHz)
            }
            "hitTest" -> {
                // u, v normalized screen coords
                val u = call.argument<Double>("u") ?: 0.5
                val v = call.argument<Double>("v") ?: 0.5
                // TODO: sample depth image / ARCore Depth API at (u,v)
                result.success(mapOf(
                    "x" to 0.0, "y" to 0.0, "z" to -1.0,
                    "source" to primarySource(),
                    "confidence" to 0.8,
                    "distance" to 1.0
                ))
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        start()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stop()
    }

    private fun start() {
        if (running) return
        running = true
        // TODO: ARCore session depth image acquisition loop at targetHz
        // Push frames: { t, w, h, samples: [{u,v,d,src,conf}], primarySource }
    }

    private fun stop() {
        running = false
    }

    private fun hasHardwareDepth(): Boolean {
        // TODO: check PackageManager / ARCore Depth API availability
        return false
    }

    private fun primarySource(): String {
        return if (hasHardwareDepth()) "hardware" else "plane"
    }
}

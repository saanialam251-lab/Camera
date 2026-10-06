package com.measurereality

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Screen / AR session video capture  P5
 * Stream-encode to disk (Section 2.5 memory rules).
 */
class ScreenRecorder(private val context: Context) : MethodChannel.MethodCallHandler {

    private var recording = false
    private var outputPath: String? = null

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "measure_reality/recorder")
            .setMethodCallHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                if (recording) {
                    result.error("already_recording", "Already recording", null)
                    return
                }
                outputPath = call.argument<String>("path")
                // TODO: MediaRecorder + MediaProjection or AR frame encoder
                recording = true
                result.success(mapOf("path" to outputPath, "recording" to true))
            }
            "stop" -> {
                if (!recording) {
                    result.success(mapOf("path" to outputPath, "recording" to false))
                    return
                }
                recording = false
                result.success(mapOf("path" to outputPath, "recording" to false))
            }
            "isRecording" -> result.success(recording)
            else -> result.notImplemented()
        }
    }
}

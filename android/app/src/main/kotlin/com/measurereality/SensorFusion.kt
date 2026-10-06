package com.measurereality

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Sensor fusion for Level / Vertical  P2
 * Accelerometer + Gyroscope at sensor rate.
 * Complementary filter lives in Dart (LevelEngine); this only streams raw data.
 */
class SensorFusion(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    SensorEventListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val accel = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    private val gyro = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

    private var eventSink: EventChannel.EventSink? = null
    private var listening = false

    // Latest values
    private var ax = 0f; private var ay = 0f; private var az = 0f
    private var gx = 0f; private var gy = 0f; private var gz = 0f

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "measure_reality/sensors")
            .setMethodCallHandler(this)
        EventChannel(engine.dartExecutor.binaryMessenger, "measure_reality/sensor_stream")
            .setStreamHandler(this)
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                startListening()
                result.success(true)
            }
            "stop" -> {
                stopListening()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startListening()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopListening()
    }

    private fun startListening() {
        if (listening) return
        listening = true
        accel?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        gyro?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
    }

    private fun stopListening() {
        if (!listening) return
        listening = false
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                ax = event.values[0]; ay = event.values[1]; az = event.values[2]
            }
            Sensor.TYPE_GYROSCOPE -> {
                gx = event.values[0]; gy = event.values[1]; gz = event.values[2]
            }
        }
        eventSink?.success(mapOf(
            "ax" to ax.toDouble(), "ay" to ay.toDouble(), "az" to az.toDouble(),
            "gx" to gx.toDouble(), "gy" to gy.toDouble(), "gz" to gz.toDouble(),
            "t" to (System.nanoTime() / 1e9)
        ))
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}

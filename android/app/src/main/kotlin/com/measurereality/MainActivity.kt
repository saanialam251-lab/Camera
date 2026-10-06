package com.measurereality

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var arBridge: ArBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        arBridge = ArBridge(this)
        arBridge.register(flutterEngine)
        SensorFusion(this).register(flutterEngine)
        DepthProcessor(this).register(flutterEngine)
        ThermalMonitor(this).register(flutterEngine)
        ScreenRecorder(this).register(flutterEngine)
    }
}

package com.example.fullstory_flutter

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.fullstory.FS

/** FullstoryFlutterPlugin */
class FullstoryFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fullstory_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    println("\n\nFullStory method call received: ${call.method}, ${call.arguments}\n\n")
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "shutdown" -> {
        FS.shutdown()
        result.success(null)
      }
      "restart" -> {
        FS.restart()
        result.success(null)
      }
      "log" -> {
        val levelB = call.argument<Int>("level")
        val message = call.argument<String>("message")
        val level = when (levelB) {
          0 -> FS.LogLevel.LOG // A.K.A. Verbose
          1 -> FS.LogLevel.DEBUG
          2 -> FS.LogLevel.INFO
          3 -> FS.LogLevel.WARN
          4 -> FS.LogLevel.ERROR
          5 -> FS.LogLevel.ERROR // Assert on iOS; not actually enabled at the moment because it's a reserved keyword in dart.
          else -> FS.LogLevel.INFO // default. Alternatively we could error here.
        }
        FS.log(level, message)
        result.success(null)
      }
      "getCurrentSession" -> result.success(FS.getCurrentSession())
      "getCurrentSessionURL" -> {
        val now = call.arguments as Boolean
        result.success(FS.getCurrentSessionURL(now))
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

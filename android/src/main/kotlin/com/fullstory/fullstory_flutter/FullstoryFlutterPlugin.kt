package com.fullstory.fullstory_flutter

import com.fullstory.DefaultFSStatusListener

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.fullstory.FS
import com.fullstory.FSSessionData
import com.fullstory.FSStatusListener

/** FullstoryFlutterPlugin */
class FullstoryFlutterPlugin() : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var statusListener : FSStatusListener

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fullstory_flutter")
    channel.setMethodCallHandler(this)
    statusListener = StatusListener(channel)
    FS.registerStatusListener(statusListener)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    //println("\n\nFullStory method call received: ${call.method}, ${call.arguments}\n\n")
    when (call.method) {
      "fsVersion" -> result.success(FS.fsVersion())
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
          1 -> FS.LogLevel.INFO
          2 -> FS.LogLevel.WARN
          3 -> FS.LogLevel.ERROR
          else -> result.error("INVALID_ARGUMENTS", "Unexpected log level, expected value 0-3, got ${levelB}")
        }
        FS.log(level, message)
        result.success(null)
      }
      "resetIdleTimer" -> {
        FS.resetIdleTimer()
        result.success(null)
      }
      "event" -> {
        val name = call.argument<String>("name")
        val properties = call.argument<Map<String, *>>("properties")
        if (name == null) {
          result.error(
            "INVALID_ARGUMENTS",
            "Invalid arguments for event: expected name and properties, got ${call.arguments})",
            null
          )
          return
        }
        FS.event(name, properties)
        result.success(null)
      }
      "identify" -> {
        val uid = call.argument<String>("uid")
        val userVars = call.argument<Map<String, *>>("userVars")
        if (uid == null) {
          result.error(
            "INVALID_ARGUMENTS",
            "Invalid arguments for identify: expected string uid and optional map userVars, got ${call.arguments})",
            null
          )
          return
        }
        if (userVars != null) {
          FS.identify(uid, userVars)
        } else {
          FS.identify(uid)
        }
        result.success(null)
      }
      "anonymize" -> {
        FS.anonymize()
        result.success(null)
      }
      "setUserVars" -> {
        val userVars: Map<String, *>? = call.arguments as? Map<String, *>
        if(userVars != null) {
          FS.setUserVars(userVars)
          result.success(null)
        } else {
          result.error(
            "INVALID_ARGUMENTS",
            "Invalid argument for setUserVars. Expected Map<String, *>, got ${call.arguments})",
            null
          )
        }
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

  private class StatusListener(private var channel: MethodChannel) : DefaultFSStatusListener() {

    override fun onSession(sessionData: FSSessionData) {
      //println("Fullstory", "FS session URL: ${sessionData.currentSessionURL}")
      channel.invokeMethod("onSession", sessionData.currentSessionURL)
    }

    // omitting these for now since they don't align perfectly with the iOS version
    // override fun onSessionDisabled(reason: FSReason) {
    //   println("Fullstory", "Session disabled (${reason.code}): ${reason.message}")
    //   channel.invokeMethod("onError", reason)
    // }

    // override fun onFSError(error: FSReason) {
    //   println("Fullstory", "FS Error (${error.code}): ${error.message}")
    //   channel.invokeMethod("onError", error)
    // }

    // override fun onFSDisabled(reason: FSReason) {
    //   println("Fullstory", "FS disabled (${reason.code}): ${reason.message}")
    //   channel.invokeMethod("onError", reason)
    // }
  }
}

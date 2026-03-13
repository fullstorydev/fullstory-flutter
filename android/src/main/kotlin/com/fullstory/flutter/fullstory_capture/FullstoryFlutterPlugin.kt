package com.fullstory.flutter.fullstory_capture

import android.util.Log
import com.fullstory.DefaultFSStatusListener
import com.fullstory.FS
import com.fullstory.FSSessionData
import com.fullstory.FSStatusListener
import com.fullstory.FSPage
import com.fullstory.fetchBlockRules
import com.fullstory.fetchPrivacyRules
import com.fullstory.fetchSessionData
import com.fullstory.flutterEvent
import com.fullstory.registerSelf
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FullstoryFlutterPlugin() : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var statusListener : FSStatusListener
  private var attached : Boolean = false
  private val pages = mutableMapOf<Int, FSPage>()
  private var nextPageID = 0

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fullstory_flutter")
    channel.setMethodCallHandler(this)
    statusListener = StatusListener(channel)
    FS.registerStatusListener(statusListener)

    attached = true
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    attached = false
  }

  fun scanUi(scanMode: Int, consent: Boolean, result: Result) {
    if (!attached) {
      Log.w("FullstoryFlutterPlugin", "Plugin not attached, Flutter is not in foreground, but a UI scan was requested")
      result.error("CHANNEL_NOT_ATTACHED", "FullstoryFlutterPlugin not attached when scanUi requested. Is Flutter actually on screen?", null)
      return
    }

    channel.invokeMethod("scanUi", mapOf<String, Any?>("mode" to scanMode, "consent" to consent), result)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    //println("\n\nFullstory method call received: ${call.method}, ${call.arguments}\n\n")
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
          else -> {
            result.error(
              "INVALID_ARGUMENTS",
              "Unexpected log level, expected value 0-3, got ${levelB}",
              null
            )
            return
          }
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
      // Pages API
      "page" -> {
        val pageName = call.argument<String>("pageName")
        val properties = call.argument<Map<String, Any>>("properties")

        if (pageName != null) {
          val page = FS.page(pageName, properties)
          val pageId = nextPageID++
          pages[pageId] = page
          result.success(pageId)
        } else {
          result.error("INVALID_ARGUMENT", "Page name is required", null)
        }
      }
      "startPage" -> {
        val pageId = call.argument<Int>("pageId")
        val propertyUpdates = call.argument<Map<String, Any>>("propertyUpdates")
        val page = pages[pageId]
        if (page != null) {
          page.start(propertyUpdates)
          result.success(null)
        } else {
          result.error("INVALID_PAGE", "No active page found with the given ID", null)
        }
      }
      "endPage" -> {
        val pageId: Int? = call.arguments as? Int;
        val page = pages[pageId]
        if (page != null) {
          page.end()
          result.success(null)
        } else {
          result.error("INVALID_PAGE", "No active page found with the given ID", null)
        }
      }
      "updatePageProperties" -> {
        val pageId = call.argument<Int>("pageId")
        val properties = call.argument<Map<String, Any>>("properties")
        val page = pages[pageId]
        if (page != null) {
          page.updateProperties(properties)
          result.success(null)
        } else {
          result.error("INVALID_PAGE", "No active page found with the given ID", null)
        }
      }
      "releasePage" -> {
        val pageId: Int? = call.arguments as? Int;
        if (pages.remove(pageId) != null) {
          result.success(null)
        } else {
          result.error("INVALID_PAGE", "No active page found with the given ID", null)
        }
      }
      "consent" -> {
        FS.consent(call.arguments as Boolean)
        result.success(null)
      }
      "captureEvent" -> {
        val args = call.arguments as? Map<String, Any?>
        if(args == null) {
            result.error(
                "INVALID_ARGUMENTS",
                "Invalid arguments for captureEvent: expected map, got null",
                null
            )
            return
        }
        flutterEvent(args)
      }
      // Session replay APIs
      "register" -> {
        Log.d("FullstoryFlutterPlugin", "Registering plugin with FS SDK")
        val canvasDefinition = call.argument<ByteArray?>("canvasDefinition")
        if(canvasDefinition == null) {
          Log.w("FullstoryFlutterPlugin", "Flutter canvas definition missing from registration")
          result.error("FullsoryCapture", "Canvas definition missing", null)
        } else {
          registerSelf(this, canvasDefinition)
          result.success(null)
        }
      }
      "fetchSessionData" -> result.success(fetchSessionData())
      "fetchBlockRules" -> result.success(fetchBlockRules())
      "fetchPrivacyRules" -> result.success(fetchPrivacyRules())
      else -> result.notImplemented()
    }
  }

  private class StatusListener(private var channel: MethodChannel) : DefaultFSStatusListener() {

    override fun onSession(sessionData: FSSessionData) {
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

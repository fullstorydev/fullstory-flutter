package com.fullstory

import android.util.Log
import com.fullstory.flutter.fullstory_capture.FullstoryFlutterPlugin
import io.flutter.plugin.common.MethodChannel

/**
 * Send arbitrary flutter events to Fullstory SDK for mapping to other event types
 * such as network events, crashes, and so on.
 *
 * The SDK API is package private to avoid polluting non-Flutter namespace, and exposed via this
 * function.
 */
fun flutterEvent(properties: Map<String, Any?>) {
    FS.__flutterEvent(properties)
}

fun registerSelf(plugin: FullstoryFlutterPlugin, canvasDefinition: ByteArray) {
    FS.__registerFlutter(FlutterPluginDelegate(plugin), canvasDefinition)
}

internal class FlutterPluginDelegate(val plugin: FullstoryFlutterPlugin) : FSFlutterDelegate {
    override fun captureFlutterView(
        id: Int,
        scanMode: Int,
        consented: Boolean,
        callback: FSFlutterDelegate.OnScanResult
    ) {
        plugin.scanUi(scanMode, consented, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result == null) {
                    Log.w("FullstoryFlutterPlugin", "Flutter scanUi returned null result")
                    callback.onScanResult(
                        FSFlutterDelegate.FlutterScanResult(
                            null,
                            id,
                            null,
                            null,
                            null
                        )
                    )
                    return
                }
                val map = result as Map<*, *>
                val viewData = map["views"] as ByteArray?
                val canvases = map["canvases"] as ByteArray?
                val stringTable = map["strings"] as List<String>?
                val blockRegions = map["blockedRegions"] as List<List<Int>>?
                callback.onScanResult(
                    FSFlutterDelegate.FlutterScanResult(
                        viewData,
                        id,
                        canvases,
                        stringTable?.toTypedArray(),
                        null,
                        // TODO(connerkasten): uncomment to enable after 1.68 release.
                        //mapOf(FSFlutterDelegate.FlutterScanResult.BLOCKED_REGIONS_KEY to blockRegions)
                    )
                )
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback.onScanResult(
                    FSFlutterDelegate.FlutterScanResult(
                        null,
                        id,
                        null,
                        null,
                        "Flutter scanUi returned error: $errorCode $errorMessage",
                    )
                )
            }

            override fun notImplemented() {
                callback.onScanResult(
                    FSFlutterDelegate.FlutterScanResult(
                        null,
                        id,
                        null,
                        null,
                        "Flutter scanUi not implemented"
                    )
                )
            }
        })
    }
}

/**
 * Fetch the encoded block rules from the Fullstory SDK.
 *
 * The SDK API is package private to avoid polluting non-Flutter namespace, and exposed via this
 * function.
 */
fun fetchBlockRules(): ByteArray? {
    return FS.__fetchBlockRules()
}

/**
 * Fetch the encoded privacy rules from the Fullstory SDK.
 *
 * The SDK API is package private to avoid polluting non-Flutter namespace, and exposed via this
 * function.
 */
fun fetchPrivacyRules(): Map<String, ByteArray?>? {
    return FS.__fetchPrivacyRules()
}

/**
 * Fetch the encoded session data from the Fullstory SDK.
 *
 * The SDK API is package private to avoid polluting non-Flutter namespace, and exposed via this
 * function.
 */
// TODO: uncomment this when FS 1.67.0 is released.
fun fetchSessionData(): ByteArray? {
    //return FS.__fetchSessionData()
    return null
} 

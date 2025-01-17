package com.example.fullstory_flutter

import com.fullstory.fullstory_flutter.FullstoryFlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */
internal class FullstoryFlutterPluginTest {
  @Test
  fun onMethodCall_logWithBadLevel_returnsError() {
    val plugin = FullstoryFlutterPlugin()

    val call = MethodCall("log", mapOf("level" to 10, "message" to "test"))
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).error(
      "INVALID_ARGUMENTS", "Unexpected log level, expected value 0-3, got 10", null)
  }
}

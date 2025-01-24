package com.example.fullstory_flutter

import com.fullstory.FS
import com.fullstory.fullstory_flutter.FullstoryFlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.powermock.api.mockito.PowerMockito.mockStatic
import org.powermock.api.mockito.PowerMockito.verifyStatic
import org.powermock.core.classloader.annotations.PrepareForTest
import org.powermock.modules.junit4.PowerMockRunner

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */
@RunWith(PowerMockRunner::class)
@PrepareForTest(FS::class)
internal class FullstoryFlutterPluginTest {
  private lateinit var result: MethodChannel.Result
  private lateinit var plugin: FullstoryFlutterPlugin

  @Before
  fun setUp() {
    mockStatic(FS::class.java)
    result = mock(MethodChannel.Result::class.java)
    plugin = FullstoryFlutterPlugin()
  }

  @Test
  fun onMethodCall_logWithBadLevel_returnsError() {
    val call = MethodCall("log", mapOf("level" to 4, "message" to "test"))
    plugin.onMethodCall(call, result)

    verify(result).error(
      "INVALID_ARGUMENTS", "Unexpected log level, expected value 0-3, got 4", null)
  }

  @Test
  fun onMethodCall_log_logsAndReturnsSuccess() {
    val call = MethodCall("log", mapOf("level" to 1, "message" to "test message"))
    val mockResult: MethodChannel.Result = mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    verify(mockResult).success(null)
    verifyStatic(FS::class.java)
    FS.log(FS.LogLevel.INFO, "test message")
  }
}

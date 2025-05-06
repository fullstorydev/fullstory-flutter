package com.fullstory

/**
 * Send arbitrary flutter events to Fullstory SDK for mapping to other event types
 * such as network events, crashes, and so on.
 *
 * The SDK API is package private to avoid polluting non-Flutter namespace, and exposed via this
 * function.
 */
fun flutterEvent(properties: Map<String, Any>) {
    FS.__flutterEvent(properties)
}
package com.dynamicdevices.visionclaw.gemini

import com.dynamicdevices.visionclaw.settings.SettingsProvider

object GeminiConfig {
    const val WEBSOCKET_BASE_URL = "wss://generativelanguage.googleapis.com/ws/" +
        "google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"
    const val MODEL = "models/gemini-2.5-flash-native-audio-preview-12-2025"

    const val INPUT_AUDIO_SAMPLE_RATE = 16000.0
    const val OUTPUT_AUDIO_SAMPLE_RATE = 24000.0
    const val AUDIO_CHANNELS = 1
    const val AUDIO_BITS_PER_SAMPLE = 16

    const val VIDEO_JPEG_QUALITY = 0.5f

    var apiKey: String
        get() = SettingsProvider.geminiApiKey.ifEmpty { "" }
        set(value) { SettingsProvider.geminiApiKey = value }
    var openClawHost: String
        get() = SettingsProvider.openClawHost.ifEmpty { "" }
        set(value) { SettingsProvider.openClawHost = value }
    var openClawPort: Int
        get() = if (SettingsProvider.openClawPort > 0) SettingsProvider.openClawPort else 18789
        set(value) { SettingsProvider.openClawPort = value }
    var openClawHookToken: String
        get() = SettingsProvider.openClawHookToken.ifEmpty { "" }
        set(value) { SettingsProvider.openClawHookToken = value }
    var openClawGatewayToken: String
        get() = SettingsProvider.openClawGatewayToken.ifEmpty { "" }
        set(value) { SettingsProvider.openClawGatewayToken = value }
    val systemInstruction: String
        get() = SettingsProvider.geminiSystemPrompt.ifEmpty { DEFAULT_SYSTEM_INSTRUCTION }

    fun websocketUrl(): String? {
        val key = apiKey
        if (key.isBlank() || key == "YOUR_GEMINI_API_KEY") return null
        return "$WEBSOCKET_BASE_URL?key=$key"
    }

    val isConfigured: Boolean
        get() = apiKey.isNotBlank() && apiKey != "YOUR_GEMINI_API_KEY"

    val isOpenClawConfigured: Boolean
        get() = openClawGatewayToken.isNotBlank() &&
            openClawGatewayToken != "YOUR_OPENCLAW_GATEWAY_TOKEN" &&
            openClawHost != "http://YOUR_MAC_HOSTNAME.local"

    const val DEFAULT_SYSTEM_INSTRUCTION: String = "You are an AI assistant for someone wearing Meta Ray-Ban smart glasses. You can see through their camera and have a voice conversation. Keep responses concise and natural. You have exactly ONE tool: execute. Use it for sending messages, searching, lists, reminders, notes, etc. Always acknowledge briefly before calling execute."
}

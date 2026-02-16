package com.dynamicdevices.visionclaw.settings

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object SettingsProvider {
    private const val PREFS_NAME = "visionclaw_settings"
    private const val KEY_GEMINI_API_KEY = "gemini_api_key"
    private const val KEY_OPENCLAW_HOST = "openclaw_host"
    private const val KEY_OPENCLAW_PORT = "openclaw_port"
    private const val KEY_OPENCLAW_HOOK_TOKEN = "openclaw_hook_token"
    private const val KEY_OPENCLAW_GATEWAY_TOKEN = "openclaw_gateway_token"
    private const val KEY_GEMINI_SYSTEM_PROMPT = "gemini_system_prompt"

    private var prefs: SharedPreferences? = null

    fun init(context: Context) {
        if (prefs == null) prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    var geminiApiKey: String
        get() = prefs?.getString(KEY_GEMINI_API_KEY, "") ?: ""
        set(value) = prefs?.edit { putString(KEY_GEMINI_API_KEY, value) } ?: Unit

    var openClawHost: String
        get() = prefs?.getString(KEY_OPENCLAW_HOST, "") ?: ""
        set(value) = prefs?.edit { putString(KEY_OPENCLAW_HOST, value) } ?: Unit

    var openClawPort: Int
        get() = prefs?.getInt(KEY_OPENCLAW_PORT, 18789) ?: 18789
        set(value) = prefs?.edit { putInt(KEY_OPENCLAW_PORT, value) } ?: Unit

    var openClawHookToken: String
        get() = prefs?.getString(KEY_OPENCLAW_HOOK_TOKEN, "") ?: ""
        set(value) = prefs?.edit { putString(KEY_OPENCLAW_HOOK_TOKEN, value) } ?: Unit

    var openClawGatewayToken: String
        get() = prefs?.getString(KEY_OPENCLAW_GATEWAY_TOKEN, "") ?: ""
        set(value) = prefs?.edit { putString(KEY_OPENCLAW_GATEWAY_TOKEN, value) } ?: Unit

    var geminiSystemPrompt: String
        get() = prefs?.getString(KEY_GEMINI_SYSTEM_PROMPT, "") ?: ""
        set(value) = prefs?.edit { putString(KEY_GEMINI_SYSTEM_PROMPT, value) } ?: Unit
}

package com.dynamicdevices.visionclaw.openclaw

import com.dynamicdevices.visionclaw.gemini.GeminiConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

sealed class OpenClawConnectionState {
    data object NotConfigured : OpenClawConnectionState()
    data object Checking : OpenClawConnectionState()
    data object Connected : OpenClawConnectionState()
    data class Unreachable(val message: String) : OpenClawConnectionState()
}

data class ToolResult(val success: Boolean, val message: String) {
    fun toResponseJson(): JSONObject = JSONObject().apply {
        if (success) put("result", message) else put("error", message)
    }
}

class OpenClawBridge {
    private val client = OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.SECONDS)
        .readTimeout(120, TimeUnit.SECONDS)
        .writeTimeout(120, TimeUnit.SECONDS)
        .build()

    private var sessionKey: String = newSessionKey()

    private fun newSessionKey(): String {
        val iso = java.time.Instant.now().toString()
        return "agent:main:glass:$iso"
    }

    suspend fun checkConnection(): OpenClawConnectionState = withContext(Dispatchers.IO) {
        if (!GeminiConfig.isOpenClawConfigured) return@withContext OpenClawConnectionState.NotConfigured
        val url = "${GeminiConfig.openClawHost}:${GeminiConfig.openClawPort}/v1/chat/completions"
        val request = Request.Builder()
            .url(url)
            .get()
            .addHeader("Authorization", "Bearer ${GeminiConfig.openClawGatewayToken}")
            .build()
        return@withContext try {
            client.newCall(request).execute()
            OpenClawConnectionState.Connected
        } catch (e: Exception) {
            OpenClawConnectionState.Unreachable(e.message ?: "Unknown error")
        }
    }

    fun resetSession() {
        sessionKey = newSessionKey()
    }

    suspend fun delegateTask(task: String, toolName: String = "execute"): ToolResult = withContext(Dispatchers.IO) {
        val url = "${GeminiConfig.openClawHost}:${GeminiConfig.openClawPort}/v1/chat/completions"
        val body = JSONObject().apply {
            put("model", "gpt-4o")
            put("messages", JSONArray().put(JSONObject().apply {
                put("role", "user")
                put("content", task)
            }))
        }.toString()
        val request = Request.Builder()
            .url(url)
            .post(body.toRequestBody("application/json".toMediaType()))
            .addHeader("Authorization", "Bearer ${GeminiConfig.openClawGatewayToken}")
            .addHeader("x-openclaw-session-key", sessionKey)
            .build()
        try {
            val response = client.newCall(request).execute()
            val responseBody = response.body?.string() ?: ""
            if (!response.isSuccessful) return@withContext ToolResult(false, "HTTP ${response.code}: $responseBody")
            val json = JSONObject(responseBody)
            val choices = json.optJSONArray("choices") ?: return@withContext ToolResult(false, "No choices")
            val first = choices.optJSONObject(0)?.optJSONObject("message")?.optString("content") ?: ""
            ToolResult(true, first)
        } catch (e: Exception) {
            ToolResult(false, e.message ?: "Unknown error")
        }
    }
}

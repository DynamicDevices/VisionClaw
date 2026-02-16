package com.dynamicdevices.visionclaw.gemini

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import org.json.JSONObject
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

sealed class GeminiConnectionState {
    data object Disconnected : GeminiConnectionState()
    data object Connecting : GeminiConnectionState()
    data object SettingUp : GeminiConnectionState()
    data object Ready : GeminiConnectionState()
    data class Error(val message: String) : GeminiConnectionState()
}

data class GeminiFunctionCall(val id: String, val name: String, val args: Map<String, Any?>)
data class GeminiToolCall(val functionCalls: List<GeminiFunctionCall>)

class GeminiLiveService {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(0, TimeUnit.MILLISECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private var webSocket: WebSocket? = null
    private val sendQueue = ConcurrentLinkedQueue<String>()
    private val connectResult = AtomicBoolean(false)

    private val _connectionState = MutableStateFlow<GeminiConnectionState>(GeminiConnectionState.Disconnected)
    val connectionState: StateFlow<GeminiConnectionState> = _connectionState.asStateFlow()

    private val _isModelSpeaking = MutableStateFlow(false)
    val isModelSpeaking: StateFlow<Boolean> = _isModelSpeaking.asStateFlow()

    var onAudioReceived: ((ByteArray) -> Unit)? = null
    var onTurnComplete: (() -> Unit)? = null
    var onInterrupted: (() -> Unit)? = null
    var onDisconnected: ((String?) -> Unit)? = null
    var onInputTranscription: ((String) -> Unit)? = null
    var onOutputTranscription: ((String) -> Unit)? = null
    var onToolCall: ((GeminiToolCall) -> Unit)? = null
    var onToolCallCancellation: ((List<String>) -> Unit)? = null

    fun connect() = scope.async(Dispatchers.Main) {
        val url = GeminiConfig.websocketUrl()
        if (url == null) {
            _connectionState.value = GeminiConnectionState.Error("No API key configured")
            return@async false
        }
        _connectionState.value = GeminiConnectionState.Connecting
        connectResult.set(false)

        val request = Request.Builder().url(url).build()
        webSocket = client.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                scope.launch {
                    _connectionState.value = GeminiConnectionState.SettingUp
                    sendSetupMessage()
                    startSendingLoop()
                }
            }

            override fun onMessage(webSocket: WebSocket, text: String) {
                scope.launch { handleMessage(text) }
            }

            override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
                scope.launch {
                    _connectionState.value = GeminiConnectionState.Disconnected
                    _isModelSpeaking.value = false
                    onDisconnected?.invoke("Connection closed (code $code: $reason)")
                }
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                scope.launch {
                    connectResult.set(false)
                    _connectionState.value = GeminiConnectionState.Error(t.message ?: "Unknown error")
                    _isModelSpeaking.value = false
                    onDisconnected?.invoke(t.message)
                }
            }
        })

        // Timeout
        kotlinx.coroutines.delay(15_000)
        if (!connectResult.get()) {
            if (_connectionState.value is GeminiConnectionState.Connecting ||
                _connectionState.value is GeminiConnectionState.SettingUp
            ) {
                _connectionState.value = GeminiConnectionState.Error("Connection timed out")
            }
        }
        connectResult.get()
    }

    fun disconnect() {
        webSocket?.close(1000, null)
        webSocket = null
        _connectionState.value = GeminiConnectionState.Disconnected
        _isModelSpeaking.value = false
        onToolCall = null
        onToolCallCancellation = null
    }

    fun sendAudio(data: ByteArray) {
        if (_connectionState.value != GeminiConnectionState.Ready) return
        val base64 = android.util.Base64.encodeToString(data, android.util.Base64.NO_WRAP)
        val json = JSONObject().apply {
            put("realtimeInput", JSONObject().apply {
                put("audio", JSONObject().apply {
                    put("mimeType", "audio/pcm;rate=16000")
                    put("data", base64)
                })
            })
        }
        sendQueue.offer(json.toString())
    }

    fun sendVideoFrame(jpegBytes: ByteArray) {
        if (_connectionState.value != GeminiConnectionState.Ready) return
        val base64 = android.util.Base64.encodeToString(jpegBytes, android.util.Base64.NO_WRAP)
        val json = JSONObject().apply {
            put("realtimeInput", JSONObject().apply {
                put("video", JSONObject().apply {
                    put("mimeType", "image/jpeg")
                    put("data", base64)
                })
            })
        }
        sendQueue.offer(json.toString())
    }

    fun sendToolResponse(response: Map<String, Any?>) {
        val json = JSONObject(response)
        sendQueue.offer(json.toString())
    }

    private fun sendSetupMessage() {
        val tools = JSONObject().apply {
            put("functionDeclarations", org.json.JSONArray().put(
                JSONObject().apply {
                    put("name", "execute")
                    put("description", "Your only way to take action. Use for sending messages, searching, lists, reminders, notes, etc.")
                    put("parameters", JSONObject().apply {
                        put("type", "object")
                        put("properties", JSONObject().apply {
                            put("task", JSONObject().apply {
                                put("type", "string")
                                put("description", "Clear, detailed description of what to do.")
                            })
                        })
                        put("required", org.json.JSONArray().put("task"))
                    })
                    put("behavior", "BLOCKING")
                }
            ))
        }
        val setup = JSONObject().apply {
            put("setup", JSONObject().apply {
                put("model", GeminiConfig.MODEL)
                put("generationConfig", JSONObject().apply {
                    put("responseModalities", org.json.JSONArray().put("AUDIO"))
                    put("thinkingConfig", JSONObject().put("thinkingBudget", 0))
                })
                put("systemInstruction", JSONObject().apply {
                    put("parts", org.json.JSONArray().put(
                        org.json.JSONArray().put(JSONObject().put("text", GeminiConfig.systemInstruction))
                    ))
                })
                put("tools", org.json.JSONArray().put(tools))
                put("realtimeInputConfig", JSONObject().apply {
                    put("automaticActivityDetection", JSONObject().apply {
                        put("disabled", false)
                        put("startOfSpeechSensitivity", "START_SENSITIVITY_HIGH")
                        put("endOfSpeechSensitivity", "END_SENSITIVITY_LOW")
                        put("silenceDurationMs", 500)
                        put("prefixPaddingMs", 40)
                    })
                    put("activityHandling", "START_OF_ACTIVITY_INTERRUPTS")
                    put("turnCoverage", "TURN_INCLUDES_ALL_INPUT")
                })
                put("inputAudioTranscription", JSONObject())
                put("outputAudioTranscription", JSONObject())
            })
        }
        sendQueue.offer(setup.toString())
    }

    private var sendJob: Job? = null
    private fun startSendingLoop() {
        sendJob?.cancel()
        sendJob = scope.launch {
            while (true) {
                val msg = withContext(Dispatchers.IO) {
                    sendQueue.poll() ?: run {
                        kotlinx.coroutines.delay(50)
                        return@withContext null
                    }
                } ?: continue
                webSocket?.send(msg)
            }
        }
    }

    private suspend fun handleMessage(text: String) {
        val json = try {
            JSONObject(text)
        } catch (_: Exception) { return }

        if (json.has("setupComplete")) {
            _connectionState.value = GeminiConnectionState.Ready
            connectResult.set(true)
            return
        }

        if (json.has("goAway")) {
            val goAway = json.getJSONObject("goAway")
            val timeLeft = goAway.optJSONObject("timeLeft")
            val seconds = timeLeft?.optInt("seconds", 0) ?: 0
            _connectionState.value = GeminiConnectionState.Disconnected
            _isModelSpeaking.value = false
            onDisconnected?.invoke("Server closing (time left: ${seconds}s)")
            return
        }

        if (json.has("toolCall")) {
            val toolCall = json.getJSONObject("toolCall")
            val calls = toolCall.optJSONArray("functionCalls") ?: return
            val list = (0 until calls.length()).map { i ->
                val c = calls.getJSONObject(i)
                GeminiFunctionCall(
                    id = c.optString("id", ""),
                    name = c.optString("name", ""),
                    args = c.optJSONObject("args")?.let { argsObj ->
                    val keys = mutableListOf<String>()
                    val iter = argsObj.keys()
                    while (iter.hasNext()) keys.add(iter.next())
                    keys.associateWith { argsObj.opt(it) }
                } ?: emptyMap()
                )
            }
            onToolCall?.invoke(GeminiToolCall(list))
            return
        }

        if (json.has("toolCallCancellation")) {
            val canc = json.getJSONObject("toolCallCancellation")
            val ids = canc.optJSONArray("ids")?.let { a -> (0 until a.length()).map { a.getString(it) } } ?: emptyList()
            onToolCallCancellation?.invoke(ids)
            return
        }

        val serverContent = json.optJSONObject("serverContent") ?: return
        if (serverContent.optBoolean("interrupted", false)) {
            _isModelSpeaking.value = false
            onInterrupted?.invoke()
            return
        }

        serverContent.optJSONObject("modelTurn")?.optJSONArray("parts")?.let { parts ->
            for (i in 0 until parts.length()) {
                val part = parts.getJSONObject(i)
                part.optJSONObject("inlineData")?.let { data ->
                    if (data.optString("mimeType", "").startsWith("audio/pcm")) {
                        val b64 = data.optString("data", "")
                        if (b64.isNotEmpty()) {
                            val audio = android.util.Base64.decode(b64, android.util.Base64.DEFAULT)
                            if (!_isModelSpeaking.value) _isModelSpeaking.value = true
                            onAudioReceived?.invoke(audio)
                        }
                    }
                }
                part.optString("text", "").takeIf { it.isNotEmpty() }?.let { /* log */ }
            }
        }

        if (serverContent.optBoolean("turnComplete", false)) {
            _isModelSpeaking.value = false
            onTurnComplete?.invoke()
        }

        serverContent.optJSONObject("inputTranscription")?.optString("text", "")?.takeIf { it.isNotEmpty() }?.let {
            onInputTranscription?.invoke(it)
        }
        serverContent.optJSONObject("outputTranscription")?.optString("text", "")?.takeIf { it.isNotEmpty() }?.let {
            onOutputTranscription?.invoke(it)
        }
    }
}

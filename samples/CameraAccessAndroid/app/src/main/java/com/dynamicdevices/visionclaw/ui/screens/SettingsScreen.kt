package com.dynamicdevices.visionclaw.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.ui.unit.dp
import androidx.compose.material3.ExperimentalMaterial3Api
import com.dynamicdevices.visionclaw.gemini.GeminiConfig
import com.dynamicdevices.visionclaw.settings.SettingsProvider

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(onBack: () -> Unit) {
    var apiKey by rememberSaveable { mutableStateOf(SettingsProvider.geminiApiKey) }
    var openClawHost by rememberSaveable { mutableStateOf(SettingsProvider.openClawHost) }
    var openClawPort by rememberSaveable { mutableStateOf(SettingsProvider.openClawPort.toString()) }
    var gatewayToken by rememberSaveable { mutableStateOf(SettingsProvider.openClawGatewayToken) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") }
            )
        }
        ) { padding ->
        Button(onClick = onBack, modifier = Modifier.padding(8.dp)) { Text("Back") }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text("Gemini API Key", modifier = Modifier.padding(vertical = 4.dp))
            OutlinedTextField(
                value = apiKey,
                onValueChange = { apiKey = it; SettingsProvider.geminiApiKey = it },
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                singleLine = true,
                placeholder = { Text("From aistudio.google.com/apikey") }
            )
            Text("OpenClaw Host", modifier = Modifier.padding(vertical = 4.dp))
            OutlinedTextField(
                value = openClawHost,
                onValueChange = { openClawHost = it; SettingsProvider.openClawHost = it },
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                singleLine = true,
                placeholder = { Text("http://your-mac.local") }
            )
            Text("OpenClaw Port", modifier = Modifier.padding(vertical = 4.dp))
            OutlinedTextField(
                value = openClawPort,
                onValueChange = {
                    openClawPort = it
                    it.toIntOrNull()?.let { n -> SettingsProvider.openClawPort = n }
                },
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                placeholder = { Text("18789") }
            )
            Text("OpenClaw Gateway Token", modifier = Modifier.padding(vertical = 4.dp))
            OutlinedTextField(
                value = gatewayToken,
                onValueChange = { gatewayToken = it; SettingsProvider.openClawGatewayToken = it },
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                singleLine = true,
                placeholder = { Text("Gateway auth token") }
            )
        }
    }
}

package com.dynamicdevices.visionclaw.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.dynamicdevices.visionclaw.gemini.GeminiConfig

@Composable
fun HomeScreen(
    onOpenSettings: () -> Unit,
    onStartStream: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "VisionClaw",
            style = MaterialTheme.typography.headlineLarge
        )
        Text(
            text = "AI assistant for Meta Ray-Ban glasses",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(32.dp))
        if (!GeminiConfig.isConfigured) {
            Text(
                text = "Add your Gemini API key in Settings",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error
            )
            Spacer(modifier = Modifier.height(16.dp))
        }
        Button(onClick = onStartStream, enabled = GeminiConfig.isConfigured) {
            Text("Start AI session")
        }
        Spacer(modifier = Modifier.height(12.dp))
        Button(
            onClick = onOpenSettings,
            colors = androidx.compose.material3.ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.surfaceVariant,
                contentColor = MaterialTheme.colorScheme.onSurfaceVariant
            )
        ) {
            Text("Settings")
        }
    }
}

# QR Code Configuration

VisionClaw supports configuration via QR code scanning for easy setup without rebuilding the app.

## Quick Start

1. Open VisionClaw app on your iPhone
2. Tap Settings (gear icon)
3. Tap "Scan QR Code for Config"
4. Point camera at QR code containing your API key(s)
5. Tap "Save" to apply settings

## QR Code Formats

### Simple API Key

For just a Gemini API key, create a QR code containing only the key:

```
AIzaSyD_your_gemini_api_key_here
```

### Full JSON Configuration

For multiple settings, create a QR code with JSON:

```json
{
  "geminiAPIKey": "AIzaSyD_your_gemini_api_key_here",
  "openClawHost": "http://your-mac.local",
  "openClawPort": 18789,
  "openClawHookToken": "your_hook_token",
  "openClawGatewayToken": "your_gateway_token",
  "webrtcSignalingURL": "wss://your-server.example.com",
  "geminiSystemPrompt": "Custom system prompt"
}
```

All fields are optional - include only what you want to configure.

## Generating QR Codes

### Online Tools

Use any QR code generator:
- [QR Code Generator](https://www.qr-code-generator.com/)
- [QRCode Monkey](https://www.qrcode-monkey.com/)
- [goqr.me](https://www.goqr.me/)

Simply paste your API key or JSON configuration and generate.

### Command Line (macOS/Linux)

Install `qrencode`:

```bash
# macOS
brew install qrencode

# Linux
sudo apt install qrencode
```

Generate QR code:

```bash
# Simple API key
echo "AIzaSyD_your_api_key" | qrencode -o api_key.png

# JSON configuration
cat > config.json << 'EOF'
{
  "geminiAPIKey": "AIzaSyD_your_api_key",
  "openClawHost": "http://192.168.1.100",
  "openClawPort": 18789
}
EOF

qrencode -r config.json -o config_qr.png
```

### Python Script

```python
#!/usr/bin/env python3
import qrcode
import json
import sys

# Your configuration
config = {
    "geminiAPIKey": "AIzaSyD_your_gemini_api_key_here",
    "openClawHost": "http://your-mac.local",
    "openClawPort": 18789
}

# Generate QR code
qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data(json.dumps(config))
qr.make(fit=True)

# Save as image
img = qr.make_image(fill_color="black", back_color="white")
img.save("visionclaw_config.png")
print("QR code saved to visionclaw_config.png")
```

Install dependencies: `pip3 install qrcode pillow`

## Security Notes

⚠️ **Important Security Considerations:**

1. **QR codes are visible** - Anyone who can see the QR code can read your API keys
2. **Store securely** - Keep QR code images in a secure location
3. **Don't share** - Never share QR codes containing API keys publicly
4. **Rotate keys** - If a QR code is exposed, rotate your API keys immediately
5. **Physical security** - Don't display QR codes on public screens

### Best Practices

- Generate QR codes on a trusted device
- Delete QR code images after scanning
- Use a password manager to store QR codes securely
- Consider printing QR codes and storing physically in a secure location
- For shared devices, use temporary API keys with limited scope

## Example Workflow

1. **Generate QR code** on your Mac/PC with your API keys
2. **Display on screen** or print it
3. **Open VisionClaw** on iPhone
4. **Scan QR code** in Settings
5. **Verify configuration** in Settings UI
6. **Save settings**
7. **Delete QR code image** for security

## Troubleshooting

### QR Code Not Scanning

- Ensure good lighting
- Hold phone steady 6-12 inches from code
- Make sure QR code is in focus
- Try increasing QR code size
- Check camera permissions in iOS Settings

### Invalid Configuration

- Verify JSON is valid (use https://jsonlint.com/)
- Check for typos in field names (case-sensitive)
- Ensure string values are in quotes
- Ensure numeric values are NOT in quotes

### Settings Not Applied

- Tap "Save" after scanning
- Restart the app if needed
- Check Settings view shows updated values
- Try manually entering to verify field names

## JSON Field Reference

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `geminiAPIKey` | String | Google Gemini API key | `"AIzaSyD..."` |
| `openClawHost` | String | OpenClaw server URL | `"http://192.168.1.100"` |
| `openClawPort` | Number | OpenClaw server port | `18789` |
| `openClawHookToken` | String | OpenClaw hook token | `"token123"` |
| `openClawGatewayToken` | String | OpenClaw gateway token | `"gateway456"` |
| `webrtcSignalingURL` | String | WebRTC signaling server | `"wss://example.com"` |
| `geminiSystemPrompt` | String | Custom AI prompt | `"You are..."` |

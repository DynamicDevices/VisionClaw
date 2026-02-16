import SwiftUI
import AVFoundation

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  private let settings = SettingsManager.shared

  @State private var geminiAPIKey: String = ""
  @State private var openClawHost: String = ""
  @State private var openClawPort: String = ""
  @State private var openClawHookToken: String = ""
  @State private var openClawGatewayToken: String = ""
  @State private var geminiSystemPrompt: String = ""
  @State private var webrtcSignalingURL: String = ""
  @State private var showResetConfirmation = false
  @State private var showQRScanner = false
  @State private var showQRSuccess = false
  @State private var qrSuccessMessage = ""

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Gemini API")) {
          VStack(alignment: .leading, spacing: 4) {
            Text("API Key")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("Enter Gemini API key", text: $geminiAPIKey)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .font(.system(.body, design: .monospaced))
          }

          Button {
            showQRScanner = true
          } label: {
            HStack {
              Image(systemName: "qrcode.viewfinder")
              Text("Scan QR Code for Config")
            }
          }
        }

        Section(
          header: Text("System Prompt"),
          footer: Text(
            "Customize the AI assistant's behavior and personality. " +
            "Changes take effect on the next Gemini session."
          )
        ) {
          TextEditor(text: $geminiSystemPrompt)
            .font(.system(.body, design: .monospaced))
            .frame(minHeight: 200)
        }

        Section(
          header: Text("OpenClaw"),
          footer: Text("Connect to an OpenClaw gateway running on your Mac for agentic tool-calling.")
        ) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Host")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("http://your-mac.local", text: $openClawHost)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .keyboardType(.URL)
              .font(.system(.body, design: .monospaced))
          }

          VStack(alignment: .leading, spacing: 4) {
            Text("Port")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("18789", text: $openClawPort)
              .keyboardType(.numberPad)
              .font(.system(.body, design: .monospaced))
          }

          VStack(alignment: .leading, spacing: 4) {
            Text("Hook Token")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("Hook token", text: $openClawHookToken)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .font(.system(.body, design: .monospaced))
          }

          VStack(alignment: .leading, spacing: 4) {
            Text("Gateway Token")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("Gateway auth token", text: $openClawGatewayToken)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .font(.system(.body, design: .monospaced))
          }
        }

        Section(header: Text("WebRTC")) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Signaling URL")
              .font(.caption)
              .foregroundColor(.secondary)
            TextField("wss://your-server.example.com", text: $webrtcSignalingURL)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .keyboardType(.URL)
              .font(.system(.body, design: .monospaced))
          }
        }

        Section {
          Button("Reset to Defaults") {
            showResetConfirmation = true
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            save()
            dismiss()
          }
          .fontWeight(.semibold)
        }
      }
      .alert("Reset Settings", isPresented: $showResetConfirmation) {
        Button("Reset", role: .destructive) {
          settings.resetAll()
          loadCurrentValues()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This will reset all settings to the values built into the app.")
      }
      .alert("QR Code Scanned", isPresented: $showQRSuccess) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(qrSuccessMessage)
      }
      .sheet(isPresented: $showQRScanner) {
        QRCodeScannerView { qrCode in
          handleScannedQRCode(qrCode)
        }
      }
      .onAppear {
        loadCurrentValues()
      }
    }
  }

  private func loadCurrentValues() {
    geminiAPIKey = settings.geminiAPIKey
    geminiSystemPrompt = settings.geminiSystemPrompt
    openClawHost = settings.openClawHost
    openClawPort = String(settings.openClawPort)
    openClawHookToken = settings.openClawHookToken
    openClawGatewayToken = settings.openClawGatewayToken
    webrtcSignalingURL = settings.webrtcSignalingURL
  }

  private func save() {
    settings.geminiAPIKey = geminiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
    settings.geminiSystemPrompt = geminiSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    settings.openClawHost = openClawHost.trimmingCharacters(in: .whitespacesAndNewlines)
    if let port = Int(openClawPort.trimmingCharacters(in: .whitespacesAndNewlines)) {
      settings.openClawPort = port
    }
    settings.openClawHookToken = openClawHookToken.trimmingCharacters(in: .whitespacesAndNewlines)
    settings.openClawGatewayToken = openClawGatewayToken.trimmingCharacters(in: .whitespacesAndNewlines)
    settings.webrtcSignalingURL = webrtcSignalingURL.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func handleScannedQRCode(_ qrCode: String) {
    // Try to parse as JSON
    guard let data = qrCode.data(using: .utf8) else {
      importPlainAPIKey(qrCode)
      return
    }

    do {
      if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
        importFromJSON(json)
      } else {
        importPlainAPIKey(qrCode)
      }
    } catch {
      importPlainAPIKey(qrCode)
    }
  }

  private func importPlainAPIKey(_ key: String) {
    geminiAPIKey = key
    qrSuccessMessage = "Gemini API key imported"
    showQRSuccess = true
  }

  private func importFromJSON(_ json: [String: Any]) {
    var updatedFields: [String] = []

    if let key = json["geminiAPIKey"] as? String, !key.isEmpty {
      geminiAPIKey = key
      updatedFields.append("Gemini API Key")
    }

    if let host = json["openClawHost"] as? String, !host.isEmpty {
      openClawHost = host
      updatedFields.append("OpenClaw Host")
    }

    if let port = json["openClawPort"] as? Int {
      openClawPort = String(port)
      updatedFields.append("OpenClaw Port")
    }

    if let token = json["openClawHookToken"] as? String, !token.isEmpty {
      openClawHookToken = token
      updatedFields.append("OpenClaw Hook Token")
    }

    if let token = json["openClawGatewayToken"] as? String, !token.isEmpty {
      openClawGatewayToken = token
      updatedFields.append("OpenClaw Gateway Token")
    }

    if let url = json["webrtcSignalingURL"] as? String, !url.isEmpty {
      webrtcSignalingURL = url
      updatedFields.append("WebRTC Signaling URL")
    }

    if let prompt = json["geminiSystemPrompt"] as? String, !prompt.isEmpty {
      geminiSystemPrompt = prompt
      updatedFields.append("Gemini System Prompt")
    }

    if updatedFields.isEmpty {
      qrSuccessMessage = "No valid configuration found in QR code"
    } else {
      qrSuccessMessage = "Imported: \(updatedFields.joined(separator: ", "))"
    }
    showQRSuccess = true
  }
}

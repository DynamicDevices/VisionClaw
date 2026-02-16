import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = QRCodeScannerViewModel()
  var onCodeScanned: (String) -> Void

  var body: some View {
    NavigationView {
      ZStack {
        QRCodeCameraView(viewModel: viewModel)
          .edgesIgnoringSafeArea(.all)

        VStack {
          Spacer()

          if viewModel.isScanning {
            Text("Scanning for QR code...")
              .font(.headline)
              .foregroundColor(.white)
              .padding()
              .background(Color.black.opacity(0.7))
              .cornerRadius(10)
          } else if let error = viewModel.errorMessage {
            Text(error)
              .font(.subheadline)
              .foregroundColor(.white)
              .padding()
              .background(Color.red.opacity(0.8))
              .cornerRadius(10)
          }

          Spacer()

          Button("Cancel") {
            dismiss()
          }
          .padding()
          .background(Color.black.opacity(0.7))
          .foregroundColor(.white)
          .cornerRadius(10)
          .padding(.bottom, 50)
        }
      }
      .navigationBarHidden(true)
      .onAppear {
        viewModel.startScanning()
        viewModel.onCodeScanned = { code in
          onCodeScanned(code)
          dismiss()
        }
      }
      .onDisappear {
        viewModel.stopScanning()
      }
    }
  }
}

struct QRCodeCameraView: UIViewRepresentable {
  @ObservedObject var viewModel: QRCodeScannerViewModel

  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .black

    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      viewModel.errorMessage = "Camera not available"
      return view
    }

    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)

      let session = AVCaptureSession()
      session.addInput(input)

      let output = AVCaptureMetadataOutput()
      session.addOutput(output)

      output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
      output.metadataObjectTypes = [.qr]

      let previewLayer = AVCaptureVideoPreviewLayer(session: session)
      previewLayer.frame = view.bounds
      previewLayer.videoGravity = .resizeAspectFill
      view.layer.addSublayer(previewLayer)

      viewModel.captureSession = session

      DispatchQueue.global(qos: .userInitiated).async {
        session.startRunning()
      }

    } catch {
      viewModel.errorMessage = "Camera error: \(error.localizedDescription)"
    }

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
      return
    }
    previewLayer.frame = uiView.bounds
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(viewModel: viewModel)
  }

  class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let viewModel: QRCodeScannerViewModel

    init(viewModel: QRCodeScannerViewModel) {
      self.viewModel = viewModel
    }

    func metadataOutput(
      _ output: AVCaptureMetadataOutput,
      didOutput metadataObjects: [AVMetadataObject],
      from connection: AVCaptureConnection
    ) {
      guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let stringValue = metadataObject.stringValue,
            !stringValue.isEmpty else {
        return
      }

      viewModel.handleScannedCode(stringValue)
    }
  }
}

class QRCodeScannerViewModel: ObservableObject {
  @Published var isScanning = true
  @Published var errorMessage: String?
  var captureSession: AVCaptureSession?
  var onCodeScanned: ((String) -> Void)?

  private var hasScanned = false

  func startScanning() {
    isScanning = true
    hasScanned = false
    errorMessage = nil
  }

  func stopScanning() {
    isScanning = false
    captureSession?.stopRunning()
  }

  func handleScannedCode(_ code: String) {
    guard !hasScanned else { return }
    hasScanned = true
    isScanning = false

    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)

    stopScanning()
    onCodeScanned?(code)
  }
}

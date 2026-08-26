// Role: Vision VNDetectBarcodesRequest on the live video buffer.

import AVFoundation
import UIKit
import Vision

@MainActor
protocol VaultLiveScannerSink: AnyObject {
    func scannerDidRead(_ payload: String)
}

/// Capture session and Vision hop are isolated to the session queue.
final class VaultLiveScanner: NSObject, @unchecked Sendable {
    weak var sink: VaultLiveScannerSink?
    let preview = AVCaptureVideoPreviewLayer()
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "gvt.scan.session")
    private var lastPayload = ""
    private var lastStamp = Date.distantPast

    var hasDevice: Bool {
        AVCaptureDevice.default(for: .video) != nil
    }

    func authorization() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func start() {
        queue.async { [weak self] in
            self?.configureIfNeeded()
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func configureIfNeeded() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        preview.session = session
        preview.videoGravity = .resizeAspectFill
        session.commitConfiguration()
    }
}

extension VaultLiveScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectBarcodesRequest { [weak self] request, _ in
            self?.handle(request)
        }
        request.symbologies = [.ean8, .ean13, .upce, .qr]
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
        try? handler.perform([request])
    }

    private func handle(_ request: VNRequest) {
        guard let payload = (request.results as? [VNBarcodeObservation])?
            .compactMap(\.payloadStringValue)
            .first
        else { return }
        let now = Date()
        if payload == lastPayload, now.timeIntervalSince(lastStamp) < 1.7 {
            return
        }
        lastPayload = payload
        lastStamp = now
        Task { @MainActor [weak self] in
            self?.sink?.scannerDidRead(payload)
        }
    }
}

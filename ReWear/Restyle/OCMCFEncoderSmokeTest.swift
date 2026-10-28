
import Foundation
import UIKit
import CoreML

enum OCMCFEncoderSmokeTest {

    static func run() throws {

        let service = RestyleOCMCFRecommendationService.shared

        guard let garment = service.catalog.first,
              let image = service.image(for: garment) else {
            print("OCMCF: No catalog image available")
            return
        }

        guard let modelURL = Bundle.main.url(
            forResource: "OCMCFImageEncoder",
            withExtension: "mlmodelc"
        ) else {
            print("OCMCF: Compiled encoder not found")
            return
        }

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly

        let model = try MLModel(
            contentsOf: modelURL,
            configuration: configuration
        )

        let input = try makeInput(from: image)

        let features = try MLDictionaryFeatureProvider(
            dictionary: ["garment_image": input]
        )

        let prediction = try model.prediction(from: features)

        guard let embedding = prediction
            .featureValue(for: "embedding")?
            .multiArrayValue else {
            print("OCMCF: Embedding output missing")
            return
        }

        let values = (0..<embedding.count).map {
            embedding[$0].floatValue
        }

        print("===== OCMCF CORE ML ENCODER =====")
        print("Garment ID:", garment.id)
        print("Garment:", garment.name)
        print("Input shape:", input.shape)
        print("Embedding count:", values.count)
        print("All 64 values:", values)
        print("All values finite:", values.allSatisfy { $0.isFinite })
        print("================================")
    }

    // MARK: - OCMCF Image Preprocessing

    static func makeInput(from image: UIImage) throws -> MLMultiArray {

        let size = 112
        let side = CGFloat(size)

        guard image.size.width > 0,
              image.size.height > 0 else {
            throw preprocessingError("Invalid image dimensions")
        }

        // torchvision Resize(112) scales the shorter side
        // to 112 while preserving the original aspect ratio.
        //
        // Drawing into a 112x112 canvas with aspect fill
        // and centered positioning combines Resize
        // and CenterCrop for our fixed-size input.

        let scale = max(
            side / image.size.width,
            side / image.size.height
        )

        let newWidth = image.size.width * scale
        let newHeight = image.size.height * scale

        let drawRect = CGRect(
            x: (side - newWidth) / 2,
            y: (side - newHeight) / 2,
            width: newWidth,
            height: newHeight
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: side, height: side),
            format: format
        )

        let resized = renderer.image { context in
            context.cgContext.interpolationQuality = .high
            image.draw(in: drawRect)
        }

        guard let cgImage = resized.cgImage else {
            throw preprocessingError("Image rendering failed")
        }

        // Explicit RGBA byte layout:
        // Red, Green, Blue, Alpha.
        var pixels = [UInt8](
            repeating: 0,
            count: size * size * 4
        )

        let contextCreated = pixels.withUnsafeMutableBytes { buffer in

            guard let context = CGContext(
                data: buffer.baseAddress,
                width: size,
                height: size,
                bitsPerComponent: 8,
                bytesPerRow: size * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo:
                    CGBitmapInfo.byteOrder32Big.rawValue |
                    CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }

            context.draw(
                cgImage,
                in: CGRect(x: 0, y: 0, width: side, height: side)
            )

            return true
        }

        guard contextCreated else {
            throw preprocessingError("Could not read RGB pixels")
        }

        let tensor = try MLMultiArray(
            shape: [1, 3, 112, 112],
            dataType: .float32
        )

        let mean: [Float] = [0.485, 0.456, 0.406]
        let std: [Float] = [0.229, 0.224, 0.225]

        let planeSize = size * size

        for pixel in 0..<planeSize {
            let rgbaOffset = pixel * 4

            for channel in 0..<3 {

                // Equivalent to torchvision ToTensor().
                let value = Float(
                    pixels[rgbaOffset + channel]
                ) / 255.0

                // Equivalent to torchvision Normalize().
                let normalized = (
                    value - mean[channel]
                ) / std[channel]

                // NCHW: [1, 3, 112, 112].
                let offset = channel * planeSize + pixel

                tensor[offset] = NSNumber(value: normalized)
            }
        }

        return tensor
    }

    private static func preprocessingError(
        _ message: String
    ) -> NSError {
        NSError(
            domain: "OCMCFPreprocessing",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: message
            ]
        )
    }
}

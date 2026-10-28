
import Foundation
import CoreML
import UIKit

enum InceptionFeatureError: LocalizedError {
    case invalidImage
    case invalidOutput
    case invalidPixelBuffer

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The selected image could not be processed."
        case .invalidOutput:
            return "InceptionV3 did not return the expected features."
        case .invalidPixelBuffer:
            return "Unable to prepare the image pixels."
        }
    }
}

final class InceptionFeatureService {

    private let model: InceptionV3Features

    private let imageSize = 229

    init() throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        model = try InceptionV3Features(
            configuration: configuration
        )
    }

    func extractFeatures(from image: UIImage) throws -> MLMultiArray {

        let inputArray = try prepareImage(image)

        let provider = try MLDictionaryFeatureProvider(
            dictionary: [
                "keras_tensor": MLFeatureValue(
                    multiArray: inputArray
                )
            ]
        )

        let prediction = try model.model.prediction(
            from: provider
        )

        guard let features = prediction
            .featureValue(for: "Identity")?
            .multiArrayValue,
              features.count == 2048 else {
            throw InceptionFeatureError.invalidOutput
        }

        return features
    }

    private func prepareImage(
        _ image: UIImage
    ) throws -> MLMultiArray {

        // Draw using UIKit to respect UIImage orientation.
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: imageSize,
                height: imageSize
            ),
            format: format
        )

        let resized = renderer.image { _ in
            image.draw(
                in: CGRect(
                    x: 0,
                    y: 0,
                    width: imageSize,
                    height: imageSize
                )
            )
        }

        guard let cgImage = resized.cgImage else {
            throw InceptionFeatureError.invalidImage
        }

        // Read pixels in RGBA order.
        let bytesPerPixel = 4
        let bytesPerRow = imageSize * bytesPerPixel

        var pixels = [UInt8](
            repeating: 0,
            count: imageSize * imageSize * bytesPerPixel
        )

        guard let colorSpace = CGColorSpace(
            name: CGColorSpace.sRGB
        ) else {
            throw InceptionFeatureError.invalidPixelBuffer
        }

        let rendered = pixels.withUnsafeMutableBytes { bytes in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: imageSize,
                height: imageSize,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                    | CGBitmapInfo.byteOrder32Big.rawValue
            ) else {
                return false
            }

            context.translateBy(
                x: 0,
                y: CGFloat(imageSize)
            )
            context.scaleBy(x: 1, y: -1)

            context.draw(
                cgImage,
                in: CGRect(
                    x: 0,
                    y: 0,
                    width: imageSize,
                    height: imageSize
                )
            )

            return true
        }

        guard rendered else {
            throw InceptionFeatureError.invalidPixelBuffer
        }

        // Core ML expects NHWC: [1, 229, 229, 3].
        let input = try MLMultiArray(
            shape: [1, 229, 229, 3],
            dataType: .float32
        )

        let output = input.dataPointer
            .bindMemory(
                to: Float32.self,
                capacity: imageSize * imageSize * 3
            )

        for pixelIndex in 0..<(imageSize * imageSize) {
            let source = pixelIndex * 4
            let destination = pixelIndex * 3

            // Keras InceptionV3 preprocessing:
            // RGB values 0...255 become -1...1.
            output[destination] =
                Float32(pixels[source]) / 127.5 - 1.0

            output[destination + 1] =
                Float32(pixels[source + 1]) / 127.5 - 1.0

            output[destination + 2] =
                Float32(pixels[source + 2]) / 127.5 - 1.0
        }

        return input
    }
}


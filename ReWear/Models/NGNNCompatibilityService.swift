import Foundation
import CoreML

enum NGNNCompatibilityError: LocalizedError {
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .invalidOutput:
            return "The NGNN model did not return a valid compatibility score."
        }
    }
}

final class NGNNCompatibilityService {

    private let model: NGNNCompatibility

    init() throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        self.model = try NGNNCompatibility(
            configuration: configuration
        )
    }

    func predict(
        images: MLMultiArray,
        graph: MLMultiArray
    ) throws -> Float {

        let prediction = try model.prediction(
            images: images,
            graph: graph
        )

        let output = prediction.compatibility_score

        guard output.count > 0 else {
            throw NGNNCompatibilityError.invalidOutput
        }

        return output[0].floatValue
    }
}


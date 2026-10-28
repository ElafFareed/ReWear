
import Foundation
import UIKit
import CoreML

// MARK: - Catalog Garment

struct OCMCFGarment: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let imageName: String
}

// MARK: - OCMCF Recommendation Service

final class RestyleOCMCFRecommendationService {

    static let shared = RestyleOCMCFRecommendationService()

    private(set) var catalog: [OCMCFGarment] = []

    private let catalogFolder = "Restyle-Garment-Catalog"

    private init() {}

    // MARK: - Load Catalog

    func loadCatalog() throws {

        let url =
            Bundle.main.url(
                forResource: "garments",
                withExtension: "json",
                subdirectory: catalogFolder
            )
            ?? Bundle.main.url(
                forResource: "garments",
                withExtension: "json"
            )

        guard let url else {
            print("Catalog missing from app bundle")
            print("Bundle location:", Bundle.main.bundleURL.path)
            throw OCMCFError.catalogNotFound
        }

        let data = try Data(contentsOf: url)

        catalog = try JSONDecoder().decode(
            [OCMCFGarment].self,
            from: data
        )

        print("OCMCF catalog loaded:", catalog.count)
        print("Catalog URL:", url.path)
    }

    // MARK: - Load Garment Image

    func image(for garment: OCMCFGarment) -> UIImage? {

        let filename = garment.imageName as NSString
        let name = filename.deletingPathExtension
        let ext = filename.pathExtension

        // Xcode may preserve folders or copy resources
        // directly into the application bundle.
        let possibleFolders: [String?] = [
            "\(catalogFolder)/images",
            "images",
            catalogFolder,
            nil
        ]

        for folder in possibleFolders {

            if let url = Bundle.main.url(
                forResource: name,
                withExtension: ext,
                subdirectory: folder
            ) {

                guard let image = UIImage(
                    contentsOfFile: url.path
                ) else {
                    print(
                        "Unable to decode image:",
                        garment.imageName
                    )
                    return nil
                }

                print("OCMCF image found:", url.path)
                return image
            }
        }

        print("OCMCF image missing:", garment.imageName)

        return nil
    }

    // MARK: - Filter by Category

    func garments(in category: String) -> [OCMCFGarment] {

        catalog.filter {
            $0.category == category
        }
    }
}

// MARK: - Errors

enum OCMCFError: LocalizedError {

    case catalogNotFound

    var errorDescription: String? {

        switch self {

        case .catalogNotFound:
            return "Restyle garment catalog was not found in the app bundle."
        }
    }
}


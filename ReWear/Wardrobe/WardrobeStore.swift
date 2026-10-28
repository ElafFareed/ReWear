
import SwiftUI
import Combine

@MainActor
final class WardrobeStore: ObservableObject {

    // MARK: - Saved Garments

    @Published private(set) var garments: [Garment] = []

    private let storageKey = "rewear.savedGarments"

    // MARK: - Initialization

    init() {
        loadGarments()
    }

    // MARK: - Add Garment

    func addGarment(
        category: String,
        subcategory: String,
        image: UIImage?
    ) throws {

        var garment = Garment(
            name: subcategory,
            category: category,
            subcategory: subcategory
        )

        // Save photo if one was selected
        if let image {

            let filename = "\(garment.id.uuidString).jpg"
            let url = photosFolder.appendingPathComponent(filename)

            try FileManager.default.createDirectory(
                at: photosFolder,
                withIntermediateDirectories: true
            )

            guard let imageData = image.jpegData(
                compressionQuality: 0.8
            ) else {
                throw WardrobeError.imageEncodingFailed
            }

            try imageData.write(
                to: url,
                options: .atomic
            )

            garment.photoFilename = filename
        }

        // Add garment to the beginning of the list
        garments.insert(garment, at: 0)

        // Save the updated wardrobe
        saveGarments()
    }

    // MARK: - Update Garment

    func updateGarment(_ updatedGarment: Garment) {

        // Find the garment using its unique ID
        guard let index = garments.firstIndex(
            where: { $0.id == updatedGarment.id }
        ) else {
            return
        }

        // Replace the old garment with the edited one
        garments[index] = updatedGarment

        // Save changes to local storage
        saveGarments()
    }

    // MARK: - Remove Garment

    func removeGarment(id: UUID) {

        // Find the garment
        guard let garment = garments.first(
            where: { $0.id == id }
        ) else {
            return
        }

        // Remove it from the wardrobe
        garments.removeAll { $0.id == id }

        // Save the updated wardrobe
        saveGarments()

        // Delete its saved photo, if available
        if let filename = garment.photoFilename {

            let url = photosFolder.appendingPathComponent(filename)

            try? FileManager.default.removeItem(
                at: url
            )
        }
    }

    // MARK: - Get Garment Photo

    func image(for garment: Garment) -> UIImage? {

        guard let filename = garment.photoFilename else {
            return nil
        }

        let url = photosFolder.appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }

    // MARK: - Photos Folder

    private var photosFolder: URL {

        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("WardrobePhotos")
    }

    // MARK: - Save Garments Locally

    private func saveGarments() {

        guard let data = try? JSONEncoder().encode(garments) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    // MARK: - Load Saved Garments

    private func loadGarments() {

        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ),
        let saved = try? JSONDecoder().decode(
            [Garment].self,
            from: data
        ) else {
            return
        }

        garments = saved
    }

    // MARK: - Errors

    enum WardrobeError: Error {
        case imageEncodingFailed
    }
}


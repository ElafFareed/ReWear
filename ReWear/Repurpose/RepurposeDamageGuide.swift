import Foundation

/// One damage type from "What's the damage?" and the single guide it opens.
/// Text is copied word for word from the final design (final sketch → R02*/U02*).
struct RepurposeDamageGuide: Identifiable, Hashable {
    enum Layout: Hashable {
        case standard
        /// R02D1 "The Little Fixes": "Tools & materials" with two larger chips.
        case quickFix
    }

    let id: String
    let mode: RepairMode
    /// Damage list card.
    let damage: String
    let damageDetail: String
    /// Guide screen.
    let headline: String
    let intro: String?
    let needsHeading: String
    let needs: [String]
    let steps: [String]
    var layout: Layout = .standard

    static func all(for mode: RepairMode) -> [RepurposeDamageGuide] { all.filter { $0.mode == mode } }
    static func guide(withID id: String) -> RepurposeDamageGuide? { all.first { $0.id == id } }

    static let all: [RepurposeDamageGuide] = [
        // R01 — Repair & Rewear
        RepurposeDamageGuide(
            id: "bleach-marks", mode: .repair,
            damage: "Bleach Marks", damageDetail: "Color loss or small bleached areas.",
            headline: "REWORK THE MARK.",
            intro: "Bleach removes color. A decorative patch can hide a stable mark without applying more chemicals.",
            needsHeading: "YOU WILL NEED", needs: ["Fabric patch", "Needle", "Thread", "Pins"],
            steps: [
                "Check the care label. Make sure the marked fabric is still strong and dry.",
                "Choose a washable patch that covers the discolored area with a margin.",
                "Keep fabric layers separate; pin the patch flat and stitch around its edges.",
                "Secure thread ends and check comfort before washing as the label allows.",
            ]),
        RepurposeDamageGuide(
            id: "stubborn-stains", mode: .repair,
            damage: "Stubborn Stains", damageDetail: "Marks that cannot be washed away.",
            headline: "RECLAIM THE STAIN.",
            intro: "When a washable garment has a permanent cosmetic stain, disguise it using a decorative patch.",
            needsHeading: "YOU WILL NEED", needs: ["Fabric patch", "Needle", "Thread", "Pins"],
            steps: [
                "Follow the care label first. Do not work on contaminated or unwashed items.",
                "Choose a suitable patch larger than the visible stain.",
                "Protect the second fabric layer and sew the patch around all sides.",
                "Check that the patch is secure and the garment remains comfortable.",
            ]),
        RepurposeDamageGuide(
            id: "small-tears-holes", mode: .repair,
            damage: "Small Tears & Holes", damageDetail: "Minor tears, punctures or tiny holes.",
            headline: "MEND IN PLAIN SIGHT.",
            intro: "Give a small tear a new personality with a visible, reinforced hand-sewn patch.",
            needsHeading: "YOU WILL NEED", needs: ["Scrap fabric", "Needle", "Thread", "Pins"],
            steps: [
                "Lay the garment flat and inspect the tear and surrounding fabric.",
                "Cut a similar-weight backing patch slightly larger than the opening.",
                "Keep layers separate and secure the patch with small, even stitches.",
                "Fasten thread ends and gently check the repair for loose edges.",
            ]),
        RepurposeDamageGuide(
            id: "missing-buttons", mode: .repair,
            // The design's card reads " missing button." with its first word cut off. On the
            // latest canvas this guide's intro and steps were pasted from Small Tears & Holes,
            // so it keeps the button text from the exported R02D1 screen and has no intro.
            damage: "Missing Buttons", damageDetail: "A missing button.",
            headline: "THE LITTLE FIXES.",
            intro: nil,
            needsHeading: "TOOLS & MATERIALS", needs: ["Needle + thread", "Button + scissors"],
            steps: [
                "Find a matching button and mark its original position.",
                "Thread a needle; knot the thread on the inside of the garment.",
                "Stitch through the button holes several times without pulling the fabric too tightly.",
                "Secure the thread on the inside. Check the button fastens without strain.",
            ],
            layout: .quickFix),

        // U01 — Repurpose It
        RepurposeDamageGuide(
            id: "severe-bleach-damage", mode: .repurpose,
            damage: "Severe Bleach Damage", damageDetail: "Extensive discoloration or weakened areas.",
            headline: "SAVE THE STRONG PARTS.",
            intro: "Use unaffected, sturdy denim panels for a simple pocket pouch.",
            needsHeading: "YOU WILL NEED", needs: ["Denim panels", "Scissors", "Needle", "Thread"],
            steps: [
                "Inspect the denim. Set aside any brittle, thinning or chemically damaged sections.",
                "Cut two similarly sized rectangles from sound, clean fabric.",
                "Place right sides together and sew three edges with secure seams.",
                "Turn right-side out, finish the open edge and inspect the stitching.",
            ]),
        RepurposeDamageGuide(
            id: "permanent-stains", mode: .repurpose,
            damage: "Permanent Stains", damageDetail: "Large marks unsuitable for regular wear.",
            headline: "USE THE CLEAN PARTS.",
            intro: "Make a simple fabric scrunchie from a clean, intact section of clothing.",
            needsHeading: "YOU WILL NEED", needs: ["Fabric strip", "Elastic", "Needle", "Scissors"],
            steps: [
                "Wash per the care label; select a clean, sound fabric section.",
                "Cut a fabric strip; fold it lengthwise and stitch the long edge.",
                "Turn the tube, thread elastic through and secure the ends.",
                "Tuck raw ends inward, stitch closed and gently test the seam.",
            ]),
        RepurposeDamageGuide(
            id: "large-tears-holes", mode: .repurpose,
            damage: "Large Tears & Holes", damageDetail: "Damage that prevents wearing as usual.",
            headline: "MAKE A NEW CARRY.",
            intro: "Transform unaffected sturdy panels into a lightweight patchwork tote.",
            needsHeading: "YOU WILL NEED", needs: ["Strong fabric", "Scissors", "Needle", "Thread"],
            steps: [
                "Inspect the garment; select only strong, clean fabric away from tears.",
                "Cut two panels and two handle strips, allowing extra fabric for seams.",
                "Join side and bottom seams; fold and stitch each handle securely.",
                "Attach handles to reinforced areas and test with a light load only.",
            ]),
        RepurposeDamageGuide(
            id: "worn-out-fabric", mode: .repurpose,
            damage: "Worn-Out Fabric", damageDetail: "Fabric that has become thin or weak.",
            headline: "THE SECOND USE.",
            intro: "Turn clean, intact absorbent cotton sections into reusable dusting cloths.",
            needsHeading: "YOU WILL NEED", needs: ["Cotton garment", "Scissors", "Ruler"],
            steps: [
                "Wash the garment and identify the areas that remain sound and clean.",
                "Lay flat; measure and mark practical cloth sizes.",
                "Cut away damaged seams and weak fabric to form soft cloth pieces.",
                "Use for light household dusting; wash and replace when worn out.",
            ]),
    ]
}

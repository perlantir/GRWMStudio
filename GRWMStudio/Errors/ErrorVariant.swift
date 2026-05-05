import SwiftUI

enum ErrorVariant: Hashable, Identifiable, CaseIterable {
    case camDenied
    case micDenied
    case photoDenied
    case license
    case licenseInvalid
    case effectFail
    case recFail
    case saveFail
    case noFace
    case lowStorage

    var id: String {
        rawValue
    }

    var rawValue: String {
        switch self {
        case .camDenied:
            "cam-denied"
        case .micDenied:
            "mic-denied"
        case .photoDenied:
            "photo-denied"
        case .license:
            "license"
        case .licenseInvalid:
            "license-invalid"
        case .effectFail:
            "effect-fail"
        case .recFail:
            "rec-fail"
        case .saveFail:
            "save-fail"
        case .noFace:
            "no-face"
        case .lowStorage:
            "low-storage"
        }
    }

    var tone: ErrorTone {
        switch self {
        case .camDenied, .license, .licenseInvalid, .recFail, .lowStorage:
            .pink
        case .micDenied, .noFace:
            .lav
        case .photoDenied, .saveFail:
            .butter
        case .effectFail:
            .mint
        }
    }

    var emoji: String {
        switch self {
        case .camDenied:
            "📷"
        case .micDenied:
            "🎙️"
        case .photoDenied:
            "🖼️"
        case .license:
            "🔒"
        case .licenseInvalid:
            "🪄"
        case .effectFail:
            "✨"
        case .recFail:
            "🎬"
        case .saveFail:
            "💼"
        case .noFace:
            "👀"
        case .lowStorage:
            "📦"
        }
    }

    @ViewBuilder
    var sticker: some View {
        switch self {
        case .camDenied, .recFail, .lowStorage:
            StickerHeart(size: 26, fill: DH.pinkDeep, stroke: .white, strokeWidth: 2.5)
        case .micDenied:
            StickerSparkle(size: 24, fill: DH.lavender, stroke: .white, strokeWidth: 2.2)
        case .effectFail:
            StickerSparkle(size: 24, fill: DH.mint, stroke: .white, strokeWidth: 2.2)
        case .photoDenied, .saveFail:
            StickerStar(size: 24, fill: DH.butter, stroke: .white, strokeWidth: 2.5)
        case .license:
            ZStack {
                Circle()
                    .fill(DH.butter)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(.white, lineWidth: 2.5))

                Text("👑")
                    .font(.system(size: 14))
            }
        case .noFace:
            StickerFlower(size: 24, petal: DH.pinkLight, stroke: .white, strokeWidth: 2.5)
        case .licenseInvalid:
            StickerSparkle(size: 24, fill: DH.mint, stroke: .white, strokeWidth: 2.2)
        }
    }

    var title: String {
        switch self {
        case .camDenied:
            L10n.string("errors.cam_denied.title")
        case .micDenied:
            L10n.string("errors.mic_denied.title")
        case .photoDenied:
            L10n.string("errors.photo_denied.title")
        case .license:
            L10n.string("errors.license.title")
        case .licenseInvalid:
            L10n.string("errors.license_invalid.title")
        case .effectFail:
            L10n.string("errors.effect_fail.title")
        case .recFail:
            L10n.string("errors.rec_fail.title")
        case .saveFail:
            L10n.string("errors.save_fail.title")
        case .noFace:
            L10n.string("errors.no_face.title")
        case .lowStorage:
            L10n.string("errors.low_storage.title")
        }
    }

    var sub: String {
        switch self {
        case .camDenied:
            L10n.string("errors.cam_denied.sub")
        case .micDenied:
            L10n.string("errors.mic_denied.sub")
        case .photoDenied:
            L10n.string("errors.photo_denied.sub")
        case .license:
            L10n.string("errors.license.sub")
        case .licenseInvalid:
            L10n.string("errors.license_invalid.sub")
        case .effectFail:
            L10n.string("errors.effect_fail.sub")
        case .recFail:
            L10n.string("errors.rec_fail.sub")
        case .saveFail:
            L10n.string("errors.save_fail.sub")
        case .noFace:
            L10n.string("errors.no_face.sub")
        case .lowStorage:
            L10n.string("errors.low_storage.sub")
        }
    }

    var ctaLabel: String {
        switch self {
        case .camDenied:
            L10n.string("errors.cam_denied.cta")
        case .micDenied:
            L10n.string("errors.mic_denied.cta")
        case .photoDenied:
            L10n.string("errors.photo_denied.cta")
        case .license:
            L10n.string("errors.license.cta")
        case .licenseInvalid:
            L10n.string("errors.license_invalid.cta")
        case .effectFail:
            L10n.string("errors.effect_fail.cta")
        case .recFail:
            L10n.string("errors.rec_fail.cta")
        case .saveFail:
            L10n.string("errors.save_fail.cta")
        case .noFace:
            L10n.string("errors.no_face.cta")
        case .lowStorage:
            L10n.string("errors.low_storage.cta")
        }
    }

    var altLabel: String {
        switch self {
        case .camDenied:
            L10n.string("errors.cam_denied.alt")
        case .micDenied:
            L10n.string("errors.mic_denied.alt")
        case .photoDenied:
            L10n.string("errors.photo_denied.alt")
        case .license:
            L10n.string("errors.license.alt")
        case .licenseInvalid:
            L10n.string("errors.license_invalid.alt")
        case .effectFail:
            L10n.string("errors.effect_fail.alt")
        case .recFail:
            L10n.string("errors.rec_fail.alt")
        case .saveFail:
            L10n.string("errors.save_fail.alt")
        case .noFace:
            L10n.string("errors.no_face.alt")
        case .lowStorage:
            L10n.string("errors.low_storage.alt")
        }
    }

    var chipTitle: String {
        L10n.format("errors.chip_title", rawValue.uppercased())
    }

    var opensSystemSettings: Bool {
        switch self {
        case .camDenied, .micDenied, .photoDenied, .lowStorage:
            true
        default:
            false
        }
    }

    var hidesAltCTAInRelease: Bool {
        self == .noFace
    }

    static var allCases: [ErrorVariant] {
        [
            .camDenied,
            .micDenied,
            .photoDenied,
            .license,
            .effectFail,
            .recFail,
            .saveFail,
            .noFace,
            .lowStorage
        ]
    }
}

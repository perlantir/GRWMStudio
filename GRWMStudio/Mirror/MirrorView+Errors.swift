extension MirrorView {
    func errorMessage(for variant: ErrorVariant) -> String {
        switch variant {
        case .license:
            L10n.string("mirror.failed.license")
        case .licenseInvalid:
            L10n.string("mirror.failed.license_invalid")
        case .effectFail:
            L10n.string("mirror.failed.effect_fail")
        case .camDenied:
            L10n.string("mirror.failed.cam_denied")
        case .micDenied:
            L10n.string("mirror.failed.mic_denied")
        case .photoDenied:
            L10n.string("mirror.failed.photo_denied")
        case .recFail:
            L10n.string("mirror.failed.rec_fail")
        case .saveFail:
            L10n.string("mirror.failed.save_fail")
        case .noFace:
            L10n.string("mirror.failed.no_face")
        case .lowStorage:
            L10n.string("mirror.failed.low_storage")
        }
    }
}

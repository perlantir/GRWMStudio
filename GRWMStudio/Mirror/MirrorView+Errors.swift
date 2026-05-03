extension MirrorView {
    func errorMessage(for variant: ErrorVariant) -> String {
        switch variant {
        case .license:
            "Studio Pro needs a grown-up."
        case .licenseInvalid:
            "License check needs attention."
        case .effectFail:
            "The mirror effect needs a reset."
        case .camDenied:
            "Camera access is off."
        case .micDenied:
            "Microphone access is off."
        case .photoDenied:
            "Photos access is off."
        case .recFail:
            "Recording needs a reset."
        case .saveFail:
            "Saving needs a reset."
        case .noFace:
            "Move your face into the mirror."
        case .lowStorage:
            "This phone needs more free space."
        }
    }
}

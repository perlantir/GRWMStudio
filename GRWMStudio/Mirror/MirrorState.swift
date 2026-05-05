enum MirrorState: Equatable {
    case idle
    case starting
    case running
    case needsPermission
    case failed(ErrorVariant)
}

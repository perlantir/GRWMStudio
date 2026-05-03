/// Normalized permission state used by GRWM Studio UI.
public enum AppPermissionStatus: String, Sendable, Equatable {
    /// The user has not been prompted yet.
    case notDetermined
    /// The user granted access.
    case granted
    /// The user denied access.
    case denied
    /// Access is blocked by device or parental restrictions.
    case restricted
}

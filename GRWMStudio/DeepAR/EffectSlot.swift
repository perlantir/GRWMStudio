/// DeepAR slot names reserved for GRWM Studio's makeup layers.
public enum EffectSlot: String, CaseIterable, Sendable {
    /// Skin smoothing and foundation effect layer.
    case skin = "slot_skin"
    /// Base LUT and color-correction effect layer.
    case base = "slot_base"
    /// Eye makeup effect layer.
    case eyes = "slot_eyes"
    /// Brow makeup effect layer.
    case brows = "slot_brows"
    /// Cheek makeup effect layer.
    case cheeks = "slot_cheeks"
    /// Lip makeup effect layer.
    case lips = "slot_lips"
    /// Full preset look effect layer.
    case looks = "slot_looks"
}

/// Contract map from manifest parameter refs to DeepAR node/component/parameter triples.
public enum EffectParameterMap {
    // -- Skin (foundation) --
    /// Foundation tint color parameter.
    public static let foundationColor = EffectParameter(
        nodeName: "face_makeup",
        component: "MeshRenderer",
        parameter: "u_color"
    )
    /// Foundation alpha mask texture parameter.
    public static let foundationMask = EffectParameter(
        nodeName: "face_makeup",
        component: "MeshRenderer",
        parameter: "s_texMask"
    )

    // -- Base (LUT) --
    /// Base LUT node enabled-state parameter.
    public static let lutEnabled = EffectParameter(
        nodeName: "PostprocessLUT",
        component: "",
        parameter: "enabled"
    )
    /// Base LUT texture parameter.
    public static let lutTexture = EffectParameter(
        nodeName: "PostprocessLUT",
        component: "MeshRenderer",
        parameter: "s_texLut"
    )

    // -- Eyes --
    /// Eyeshadow tint color parameter.
    public static let eyeshadowColor = EffectParameter(
        nodeName: "eyeshadow",
        component: "MeshRenderer",
        parameter: "u_color"
    )
    /// Eyeshadow alpha mask texture parameter.
    public static let eyeshadowMask = EffectParameter(
        nodeName: "eyeshadow",
        component: "MeshRenderer",
        parameter: "s_texMask"
    )
    /// Eyeliner texture parameter.
    public static let eyelinerTexture = EffectParameter(
        nodeName: "eyeliner",
        component: "MeshRenderer",
        parameter: "s_texColor"
    )
    /// Eyeliner enabled-state parameter.
    public static let eyelinerEnabled = EffectParameter(
        nodeName: "eyeliner",
        component: "",
        parameter: "enabled"
    )
    /// Eyelashes texture parameter.
    public static let eyelashesTexture = EffectParameter(
        nodeName: "eyelashes",
        component: "MeshRenderer",
        parameter: "s_texColor"
    )
    /// Eyelashes enabled-state parameter.
    public static let eyelashesEnabled = EffectParameter(
        nodeName: "eyelashes",
        component: "",
        parameter: "enabled"
    )

    // -- Brows --
    // VERIFY: Not in free pack - comes from larger pack.
    /// Brow tint color parameter.
    public static let browColor = EffectParameter(
        nodeName: "browMesh",
        component: "MeshRenderer",
        parameter: "u_color"
    )
    // VERIFY: Not in free pack - comes from larger pack.
    /// Brow texture parameter.
    public static let browTexture = EffectParameter(
        nodeName: "browMesh",
        component: "MeshRenderer",
        parameter: "s_texColor"
    )
    // VERIFY: Not in free pack - comes from larger pack.
    /// Brow enabled-state parameter.
    public static let browEnabled = EffectParameter(
        nodeName: "browMesh",
        component: "",
        parameter: "enabled"
    )

    // -- Cheeks --
    // VERIFY: Not in free pack - comes from larger pack.
    /// Blush tint color parameter.
    public static let blushColor = EffectParameter(
        nodeName: "blushMesh",
        component: "MeshRenderer",
        parameter: "u_color"
    )
    // VERIFY: Not in free pack - comes from larger pack.
    /// Blush alpha mask texture parameter.
    public static let blushMask = EffectParameter(
        nodeName: "blushMesh",
        component: "MeshRenderer",
        parameter: "s_texMask"
    )
    // VERIFY: Not in free pack - comes from larger pack.
    /// Blush enabled-state parameter.
    public static let blushEnabled = EffectParameter(
        nodeName: "blushMesh",
        component: "",
        parameter: "enabled"
    )

    // -- Lips --
    /// Lip tint color parameter.
    public static let lipsColor = EffectParameter(
        nodeName: "lips",
        component: "MeshRenderer",
        parameter: "u_color"
    )
    /// Lip texture parameter.
    public static let lipsTexture = EffectParameter(
        nodeName: "lips",
        component: "MeshRenderer",
        parameter: "s_texColor"
    )
    /// Lip enabled-state parameter.
    public static let lipsEnabled = EffectParameter(
        nodeName: "lips",
        component: "",
        parameter: "enabled"
    )

    /// Resolves a manifest `ref` string to a DeepAR runtime parameter target.
    public static func resolve(_ ref: String) -> EffectParameter? {
        map[ref]
    }

    private static let map: [String: EffectParameter] = [
        "foundationColor": foundationColor,
        "foundationMask": foundationMask,
        "lutEnabled": lutEnabled,
        "lutTexture": lutTexture,
        "eyeshadowColor": eyeshadowColor,
        "eyeshadowMask": eyeshadowMask,
        "eyelinerTexture": eyelinerTexture,
        "eyelinerEnabled": eyelinerEnabled,
        "eyelashesTexture": eyelashesTexture,
        "eyelashesEnabled": eyelashesEnabled,
        "browColor": browColor,
        "browTexture": browTexture,
        "browEnabled": browEnabled,
        "blushColor": blushColor,
        "blushMask": blushMask,
        "blushEnabled": blushEnabled,
        "lipsColor": lipsColor,
        "lipsTexture": lipsTexture,
        "lipsEnabled": lipsEnabled
    ]
}

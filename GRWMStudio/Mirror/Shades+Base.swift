extension Shade {
    static let baseShades: [Shade] = [
        Shade(
            id: "base.none",
            name: "None",
            swatchColor: DH.cream,
            effectID: "baseBeauty",
            parameters: [EffectParam(ref: "lutEnabled", value: .enabled(false))],
            isPro: false
        ),
        Shade(
            id: "base.soft",
            name: "Soft",
            swatchColor: DH.pinkLight,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_soft"))
            ],
            isPro: false
        ),
        Shade(
            id: "base.glow",
            name: "Glow",
            swatchColor: DH.butter,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_glow"))
            ],
            isPro: false
        ),
        Shade(
            id: "base.glam",
            name: "Glam",
            swatchColor: DH.lavender,
            effectID: "baseBeauty",
            parameters: [
                EffectParam(ref: "lutEnabled", value: .enabled(true)),
                EffectParam(ref: "lutTexture", value: .texture("lut_glam"))
            ],
            isPro: false
        )
    ]
}

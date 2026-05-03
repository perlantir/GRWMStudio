struct SlotSelection: Equatable, Sendable {
    let effectID: EffectFile.ID?
    let shadeID: String?
    let shade: MakeupShade?
    let isPro: Bool

    init(effectID: EffectFile.ID?, shade: MakeupShade?, isPro: Bool) {
        self.effectID = effectID
        shadeID = shade?.id
        self.shade = shade
        self.isPro = isPro
    }

    init(effectID: EffectFile.ID?, shadeID: String?, isPro: Bool) {
        self.effectID = effectID
        self.shadeID = shadeID
        shade = nil
        self.isPro = isPro
    }
}

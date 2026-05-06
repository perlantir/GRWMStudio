extension MirrorViewModel {
    func resetAllSharedBeautyParameters() async {
        guard !shouldSkipControllerCallsForSimulator else {
            return
        }

        await resetFoundationParameters()
        await resetBaseLUTParameters()
        await resetEnabledParameters([
            "eyeshadowEnabled",
            "eyelinerEnabled",
            "eyelashesEnabled",
            "browEnabled",
            "blushEnabled",
            "lipsEnabled"
        ])
    }

    func resetSharedBeautyParameters(for slot: EffectSlot) async {
        guard !shouldSkipControllerCallsForSimulator else {
            return
        }

        switch slot {
        case .skin:
            await resetFoundationParameters()
        case .base:
            await resetFoundationParameters()
            await resetBaseLUTParameters()
        case .eyes:
            await resetEnabledParameters(["eyeshadowEnabled", "eyelinerEnabled", "eyelashesEnabled"])
        case .brows:
            await resetEnabledParameters(["browEnabled"])
        case .cheeks:
            await resetEnabledParameters(["blushEnabled"])
        case .lips:
            await resetEnabledParameters(["lipsEnabled"])
        case .looks:
            break
        }
    }

    private func resetFoundationParameters() async {
        guard let foundationAmount = EffectParameterMap.resolve("foundationAmount") else {
            return
        }
        await setBlendshape(0, on: foundationAmount)
    }

    private func resetBaseLUTParameters() async {
        if let lutEnabled = EffectParameterMap.resolve("lutEnabled") {
            await setEnabled(false, on: lutEnabled)
        }

        if let lutAmount = EffectParameterMap.resolve("lutAmount") {
            await setBlendshape(0, on: lutAmount)
        }
    }

    private func resetEnabledParameters(_ refs: [String]) async {
        for ref in refs {
            guard let parameter = EffectParameterMap.resolve(ref) else {
                continue
            }
            await setEnabled(false, on: parameter)
        }
    }
}

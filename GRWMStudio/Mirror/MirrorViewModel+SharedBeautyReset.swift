extension MirrorViewModel {
    func resetAllSharedBeautyParameters() async {
        guard !shouldSkipControllerCallsForSimulator else {
            return
        }

        await resetFoundationParameters()
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

    private func resetEnabledParameters(_ refs: [String]) async {
        for ref in refs {
            guard let parameter = EffectParameterMap.resolve(ref) else {
                continue
            }
            await setEnabled(false, on: parameter)
        }
    }
}

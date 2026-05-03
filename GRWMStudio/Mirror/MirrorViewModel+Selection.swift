import OSLog
import UIKit

extension MirrorViewModel {
    func selectShade(in slot: EffectSlot, shade: MakeupShade) async {
        await selectShade(in: slot, effectID: nil, shade: shade)
    }

    func selectShade(in slot: EffectSlot, effectID: EffectFile.ID?, shade: MakeupShade) async {
        do {
            let effect = try await effect(containing: shade, in: slot, preferredID: effectID)
            let isPro = effect.isPro || (shade.isPro ?? false)
            guard canUseProContent(isPro: isPro) else {
                lastError = .license
                Logger.mirror.info("Blocked pro shade without entitlement: \(shade.id, privacy: .public)")
                return
            }

            if slot == .looks {
                try await selectLook(effect)
                resetEffectFailureCounter()
                return
            }

            if !shouldSkipControllerCallsForSimulator {
                if controller.loadedEffects[slot] != effect.id {
                    try await controller.loadEffect(effect, slot: slot)
                }
                try await applyShadeParameters(shade)
            } else {
                Logger.mirror.info("Simulator placeholder selected shade without DeepAR load: \(shade.id, privacy: .public)")
            }

            selections[slot] = SlotSelection(effectID: effect.id, shade: shade, isPro: isPro)
            resetEffectFailureCounter()
        } catch {
            recordEffectFailure()
            lastError = .effectFail
            Logger.mirror.error("selectShade failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func selectShade(in slot: EffectSlot, shade: Shade) async {
        lastShadeSelection = (slot, shade)

        do {
            guard let effect = try await catalog.effect(byID: shade.effectID) else {
                throw MirrorActionError.effectMissing(shade.effectID)
            }

            let isPro = effect.isPro || shade.isPro
            guard canUseProContent(isPro: isPro) else {
                lastError = .license
                Logger.mirror.info("Blocked pro shade without entitlement: \(shade.id, privacy: .public)")
                return
            }

            if !shouldSkipControllerCallsForSimulator {
                if controller.loadedEffects[slot] != effect.id {
                    try await controller.loadEffect(effect, slot: slot)
                }
                try await applyShadeParameters(shade.parameters)
            } else {
                Logger.mirror.info("Simulator placeholder selected shade without DeepAR load: \(shade.id, privacy: .public)")
            }

            selections[slot] = SlotSelection(effectID: effect.id, shadeID: shade.id, isPro: isPro)
            if slot == .eyes {
                eyeSelections[eyesSubCategory] = shade.id
            }
            resetEffectFailureCounter()
        } catch {
            recordEffectFailure()
            lastError = .effectFail
            Logger.mirror.error("selectShade failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func retryLastSelection() async {
        guard let lastShadeSelection else {
            return
        }

        lastError = nil
        await Task.yield()
        await selectShade(in: lastShadeSelection.slot, shade: lastShadeSelection.shade)
    }

    func dismissEffectFailureBanner() {
        guard lastError == .effectFail else {
            return
        }
        lastError = nil
    }

    func selectLook(_ effect: EffectFile) async throws {
        guard canUseProContent(isPro: effect.isPro) else {
            lastError = .license
            Logger.mirror.info("Blocked pro look without entitlement: \(effect.id, privacy: .public)")
            return
        }

        if !shouldSkipControllerCallsForSimulator {
            if controller.loadedEffects[.looks] != effect.id {
                try await controller.loadEffect(effect, slot: .looks)
            }
        } else {
            Logger.mirror.info("Simulator placeholder selected look without DeepAR load: \(effect.id, privacy: .public)")
        }

        selections[.looks] = SlotSelection(effectID: effect.id, shade: nil, isPro: effect.isPro)
        activeLookName = effect.displayName
        resetEffectFailureCounter()
    }

    func clear(slot: EffectSlot) async {
        if !shouldSkipControllerCallsForSimulator {
            await controller.clearEffect(slot: slot)
        }
        selections[slot] = nil
        if slot == .eyes {
            eyeSelections.removeAll()
        } else if slot == .looks {
            activeLookName = nil
        }
    }

    func selectedShadeID(for slot: EffectSlot) -> String? {
        selections[slot]?.shadeID
    }

    var selectedLookEffectID: EffectFile.ID? {
        selections[.looks]?.effectID
    }

    func selectedEyeShadeID(for subCategory: EyesSubCategory) -> String? {
        if let shadeID = eyeSelections[subCategory] {
            return shadeID
        }

        switch subCategory {
        case .shadow:
            return nil
        case .liner:
            return "eyeliner.none"
        case .lashes:
            return "eyelashes.none"
        }
    }

    private func effect(
        containing shade: MakeupShade,
        in slot: EffectSlot,
        preferredID: EffectFile.ID?
    ) async throws -> EffectFile {
        if let preferredID, let effect = try await catalog.effect(byID: preferredID) {
            return effect
        }

        guard let category = MakeupCategory.allCases.first(where: { $0.slot == slot }) else {
            throw MirrorActionError.effectMissing(shade.id)
        }

        let effects = try await catalog.effects(for: category)
        guard let effect = effects.first(where: { effect in
            effect.shades.contains(where: { $0.id == shade.id })
        }) else {
            throw MirrorActionError.effectMissing(shade.id)
        }

        return effect
    }

    private func applyShadeParameters(_ shade: MakeupShade) async throws {
        for change in shade.parameters {
            guard let parameter = EffectParameterMap.resolve(change.ref) else {
                throw MirrorActionError.unresolvedParameter(change.ref)
            }

            switch change.kind {
            case .color:
                guard let rgba = change.rgba, rgba.count == 4 else {
                    throw MirrorActionError.invalidParameter(change.ref)
                }
                let color = UIColor(
                    red: CGFloat(rgba[0]),
                    green: CGFloat(rgba[1]),
                    blue: CGFloat(rgba[2]),
                    alpha: CGFloat(rgba[3])
                )
                await controller.setColor(color, on: parameter)
            case .texture:
                guard
                    let assetName = change.asset,
                    let image = image(named: assetName)
                else {
                    throw MirrorActionError.missingTexture(change.asset ?? change.ref)
                }
                await controller.setTexture(image, on: parameter)
            case .blendshape:
                guard let value = change.value else {
                    throw MirrorActionError.invalidParameter(change.ref)
                }
                await controller.setBlendshape(Float(value), on: parameter)
            case .bool:
                guard let value = change.value else {
                    throw MirrorActionError.invalidParameter(change.ref)
                }
                await controller.setEnabled(value != 0, on: parameter)
            }
        }
    }

    private func applyShadeParameters(_ parameters: [EffectParam]) async throws {
        for parameterChange in parameters {
            guard let parameter = EffectParameterMap.resolve(parameterChange.ref) else {
                throw MirrorActionError.unresolvedParameter(parameterChange.ref)
            }

            switch parameterChange.value {
            case .color(let rgba):
                let color = UIColor(
                    red: CGFloat(rgba.red),
                    green: CGFloat(rgba.green),
                    blue: CGFloat(rgba.blue),
                    alpha: CGFloat(rgba.alpha)
                )
                await controller.setColor(color, on: parameter)
            case .texture(let assetName):
                guard let image = image(named: assetName) else {
                    throw MirrorActionError.missingTexture(assetName)
                }
                await controller.setTexture(image, on: parameter)
            case .blendshape(let value):
                await controller.setBlendshape(value, on: parameter)
            case .enabled(let enabled):
                await controller.setEnabled(enabled, on: parameter)
            }
        }
    }

    private func recordEffectFailure() {
        let now = currentDate()
        if let start = effectFailureWindowStart, now.timeIntervalSince(start) <= 60 {
            effectFailureCount += 1
        } else {
            effectFailureCount = 1
            effectFailureWindowStart = now
        }

        if effectFailureCount >= 3 {
            escalateEffectFailure()
        }
    }

    private func resetEffectFailureCounter() {
        effectFailureCount = 0
        effectFailureWindowStart = nil
        if lastError == .effectFail {
            lastError = nil
        }
    }

    private func image(named assetName: String) -> UIImage? {
        if let image = UIImage(named: assetName) {
            return image
        }

        let resourceName = (assetName as NSString).deletingPathExtension
        let resourceExtension = (assetName as NSString).pathExtension.isEmpty ? "png" : (assetName as NSString).pathExtension

        for subdirectory in ["Effects/luts", "Effects/textures"] {
            if let url = Bundle.main.url(
                forResource: resourceName,
                withExtension: resourceExtension,
                subdirectory: subdirectory
            ),
                let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }

        return nil
    }
}

private enum MirrorActionError: LocalizedError {
    case effectMissing(String)
    case invalidParameter(String)
    case missingTexture(String)
    case unresolvedParameter(String)

    var errorDescription: String? {
        switch self {
        case .effectMissing(let id):
            "Effect missing for shade \(id)"
        case .invalidParameter(let ref):
            "Invalid parameter value for \(ref)"
        case .missingTexture(let asset):
            "Missing texture asset \(asset)"
        case .unresolvedParameter(let ref):
            "Unresolved parameter \(ref)"
        }
    }
}

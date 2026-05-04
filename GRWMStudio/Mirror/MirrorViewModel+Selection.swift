import OSLog
import UIKit

extension MirrorViewModel {
    func selectShade(in slot: EffectSlot, shade: MakeupShade) async {
        await selectShade(in: slot, effectID: nil, shade: shade)
    }

    func selectShade(in slot: EffectSlot, effectID: EffectFile.ID?, shade: MakeupShade) async {
        guard beginSelectionIfPossible(label: shade.id) else {
            return
        }
        defer { endSelection() }

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
                try await ensureEffectReady(effect, requestedSlot: slot)
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
        guard beginSelectionIfPossible(label: shade.id) else {
            return
        }
        defer { endSelection() }

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
                try await ensureEffectReady(effect, requestedSlot: slot)
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

    private func beginSelectionIfPossible(label: String) -> Bool {
        guard !isApplyingSelection else {
            Logger.mirror.info("Ignored overlapping selection: \(label, privacy: .public)")
            return false
        }

        isApplyingSelection = true
        return true
    }

    private func endSelection() {
        isApplyingSelection = false
    }

    private func ensureEffectReady(_ effect: EffectFile, requestedSlot slot: EffectSlot) async throws {
        if effect.file == "baseBeauty.deepar" {
            if sharedBeautyEffectLoaded || controller.loadedEffects.values.contains("baseBeauty") {
                return
            }

            let baseEffect = try await catalog.effect(byID: "baseBeauty") ?? effect
            appliedParameterValues.removeAll()
            try await controller.loadEffect(baseEffect, slot: .skin)
            sharedBeautyEffectLoaded = true
            return
        }

        if controller.loadedEffects[slot] != effect.id {
            appliedParameterValues.removeAll()
            try await controller.loadEffect(effect, slot: slot)
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
        appliedParameterValues.removeAll()
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
            try await applyManifestParameter(change)
        }
    }

    private func applyShadeParameters(_ parameters: [EffectParam]) async throws {
        for parameterChange in parameters {
            try await applyTypedParameter(parameterChange)
        }
    }

    private func applyManifestParameter(_ change: MakeupShade.ParameterChange) async throws {
        let parameter = try resolvedParameter(for: change.ref)

        switch change.kind {
        case .color:
            guard let rgba = change.rgba, rgba.count == 4 else {
                throw MirrorActionError.invalidParameter(change.ref)
            }
            await setColor(rgba, on: parameter)
        case .texture:
            guard let assetName = change.asset else {
                throw MirrorActionError.missingTexture(change.ref)
            }
            try await setTexture(assetName, on: parameter)
        case .blendshape:
            guard let value = change.value else {
                throw MirrorActionError.invalidParameter(change.ref)
            }
            await setBlendshape(Float(value), on: parameter)
        case .bool:
            guard let value = change.value else {
                throw MirrorActionError.invalidParameter(change.ref)
            }
            await setEnabled(value != 0, on: parameter)
        }
    }

    private func applyTypedParameter(_ parameterChange: EffectParam) async throws {
        let parameter = try resolvedParameter(for: parameterChange.ref)

        switch parameterChange.value {
        case .color(let rgba):
            await setColor(rgba, on: parameter)
        case .texture(let assetName):
            try await setTexture(assetName, on: parameter)
        case .tintedTexture(let assetName, let rgba):
            try await setTintedTexture(assetName, tint: rgba, on: parameter)
        case .blendshape(let value):
            await setBlendshape(value, on: parameter)
        case .enabled(let enabled):
            await setEnabled(enabled, on: parameter)
        }
    }

    private func resolvedParameter(for ref: String) throws -> EffectParameter {
        guard let parameter = EffectParameterMap.resolve(ref) else {
            throw MirrorActionError.unresolvedParameter(ref)
        }
        return parameter
    }

    private func setColor(_ rgba: [Double], on parameter: EffectParameter) async {
        let color = UIColor(
            red: CGFloat(rgba[0]),
            green: CGFloat(rgba[1]),
            blue: CGFloat(rgba[2]),
            alpha: CGFloat(rgba[3])
        )
        await setColor(
            color,
            value: .color(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3]),
            on: parameter
        )
    }

    private func setColor(_ rgba: RGBA, on parameter: EffectParameter) async {
        let color = UIColor(
            red: CGFloat(rgba.red),
            green: CGFloat(rgba.green),
            blue: CGFloat(rgba.blue),
            alpha: CGFloat(rgba.alpha)
        )
        await setColor(
            color,
            value: .color(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha),
            on: parameter
        )
    }

    private func setColor(
        _ color: UIColor,
        value: AppliedParameterValue,
        on parameter: EffectParameter
    ) async {
        guard shouldApply(value, on: parameter) else {
            return
        }
        await controller.setColor(color, on: parameter)
    }

    private func setTexture(_ assetName: String, on parameter: EffectParameter) async throws {
        guard let image = image(named: assetName) else {
            throw MirrorActionError.missingTexture(assetName)
        }
        guard shouldApply(.texture(assetName), on: parameter) else {
            return
        }
        await controller.setTexture(image, on: parameter)
    }

    private func setBlendshape(_ value: Float, on parameter: EffectParameter) async {
        guard shouldApply(.blendshape(value), on: parameter) else {
            return
        }
        await controller.setBlendshape(value, on: parameter)
    }

    private func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async {
        guard shouldApply(.enabled(enabled), on: parameter) else {
            return
        }
        await controller.setEnabled(enabled, on: parameter)
    }

    func shouldApply(_ value: AppliedParameterValue, on parameter: EffectParameter) -> Bool {
        let key = EffectParameterKey(parameter)
        guard appliedParameterValues[key] != value else {
            return false
        }

        appliedParameterValues[key] = value
        return true
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

    func image(named assetName: String) -> UIImage? {
        if let image = textureImageCache[assetName] {
            return image
        }

        if let image = UIImage(named: assetName) {
            textureImageCache[assetName] = image
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
                textureImageCache[assetName] = image
                return image
            }
        }

        return nil
    }
}

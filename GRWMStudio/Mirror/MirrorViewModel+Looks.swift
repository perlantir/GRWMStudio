import OSLog

extension MirrorViewModel {
    func selectLook(_ look: LookPreset) async {
        guard catalog.containsSync(effectID: look.effectID) else {
            Logger.mirror.info("Blocked unavailable look: \(look.effectID, privacy: .public)")
            return
        }

        guard canUseProContent(isPro: look.isPro) else {
            lastError = .license
            Logger.mirror.info("Blocked pro look without entitlement: \(look.effectID, privacy: .public)")
            return
        }

        do {
            guard let effect = try await catalog.effect(byID: look.effectID) else {
                lastError = .effectFail
                Logger.mirror.error("Look effect missing: \(look.effectID, privacy: .public)")
                return
            }
            try await selectLook(effect)
            activeLookName = look.name
        } catch {
            lastError = .effectFail
            Logger.mirror.error("selectLook failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}

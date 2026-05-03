import Foundation
import Observation
import OSLog
import UIKit

@MainActor
@Observable
final class MirrorViewModel {
    let controller: DeepARController
    let catalog: EffectCatalog

    private(set) var state: MirrorState = .idle
    private(set) var selections: [EffectSlot: SlotSelection] = [:]
    private(set) var isFaceDetected = false
    private(set) var lastError: ErrorVariant?
    var activeCategory: FilterCategory?
    var activeTraySlot: EffectSlot? {
        activeCategory?.slot
    }

    @ObservationIgnored private var env: AppEnvironment?
    @ObservationIgnored private var faceTask: Task<Void, Never>?
    @ObservationIgnored private let licenseLoader: () throws -> String
    @ObservationIgnored private let usesSimulatorPlaceholder: Bool

    init(
        controller: DeepARController = DeepARController(),
        catalog: EffectCatalog = .shared,
        licenseLoader: @escaping () throws -> String = { try DeepARLicense.key() },
        usesSimulatorPlaceholder: Bool = MirrorViewModel.defaultUsesSimulatorPlaceholder
    ) {
        self.controller = controller
        self.catalog = catalog
        self.licenseLoader = licenseLoader
        self.usesSimulatorPlaceholder = usesSimulatorPlaceholder
    }

    func start(env: AppEnvironment) async {
        guard state != .starting && state != .running else {
            return
        }

        self.env = env
        state = .starting
        let cameraStatus = await env.permissions.cameraStatus()
        guard cameraStatus == .granted else {
            state = .needsPermission
            Logger.deepAR.info("Mirror camera permission needed: \(String(describing: cameraStatus))")
            return
        }

        observeFaceVisibility()

        let licenseKey: String
        do {
            licenseKey = try licenseLoader()
        } catch {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license missing or empty")
            return
        }

        if usesSimulatorPlaceholder {
            state = .running
            Logger.deepAR.info("Mirror using simulator DeepAR placeholder")
            return
        }

        do {
            if controller.state == .uninitialized {
                try await controller.bootstrap(licenseKey: licenseKey)
            }

            try await controller.startCamera(includeAudio: false)
            state = .running
        } catch DeepARController.SetupError.missingLicenseKey {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license rejected as missing during bootstrap")
        } catch DeepARController.SetupError.sdkInitTimeout {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.mirror.error("DeepAR bootstrap timed out")
        } catch {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.deepAR.error("Mirror start failed: \(error.localizedDescription)")
        }
    }

    func pause() {
        faceTask?.cancel()
        faceTask = nil
        isFaceDetected = false

        if state == .running || state == .starting {
            Task { @MainActor [controller] in
                await controller.stopCamera()
            }
            state = .idle
        }
    }

    private func observeFaceVisibility() {
        faceTask?.cancel()
        let stream = controller.faceVisibilityStream
        isFaceDetected = controller.trackedFace
        faceTask = Task { @MainActor [weak self] in
            for await visible in stream {
                guard let self else {
                    return
                }
                self.isFaceDetected = visible
            }
        }
    }

    private var shouldSkipControllerCallsForSimulator: Bool {
        #if targetEnvironment(simulator)
        controller.state != .ready
        #else
        false
        #endif
    }

    private static var defaultUsesSimulatorPlaceholder: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }
}

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
        } catch {
            lastError = .effectFail
            Logger.mirror.error("selectShade failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func selectShade(in slot: EffectSlot, shade: Shade) async {
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
        } catch {
            lastError = .effectFail
            Logger.mirror.error("selectShade failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func selectLook(_ effect: EffectFile) async throws {
        guard canUseProContent(isPro: effect.isPro) else {
            lastError = .license
            Logger.mirror.info("Blocked pro look without entitlement: \(effect.id, privacy: .public)")
            return
        }

        for other in EffectSlot.allCases where other != .looks {
            selections[other] = nil
            if !shouldSkipControllerCallsForSimulator {
                await controller.clearEffect(slot: other)
            }
        }

        if !shouldSkipControllerCallsForSimulator {
            if controller.loadedEffects[.looks] != effect.id {
                try await controller.loadEffect(effect, slot: .looks)
            }
        } else {
            Logger.mirror.info("Simulator placeholder selected look without DeepAR load: \(effect.id, privacy: .public)")
        }

        selections[.looks] = SlotSelection(effectID: effect.id, shade: nil, isPro: effect.isPro)
    }

    func clear(slot: EffectSlot) async {
        if !shouldSkipControllerCallsForSimulator {
            await controller.clearEffect(slot: slot)
        }
        selections[slot] = nil
    }

    func selectedShadeID(for slot: EffectSlot) -> String? {
        selections[slot]?.shadeID
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

    private func canUseProContent(isPro: Bool) -> Bool {
        guard isPro else {
            return true
        }
        return env?.proEntitlement.hasPro == true
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

    private func image(named assetName: String) -> UIImage? {
        if let image = UIImage(named: assetName) {
            return image
        }

        guard let url = Bundle.main.url(forResource: assetName, withExtension: "png", subdirectory: "Effects/luts") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
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

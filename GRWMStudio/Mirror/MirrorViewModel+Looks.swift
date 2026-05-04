import OSLog
import UIKit

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

    func setTintedTexture(_ assetName: String, tint: RGBA, on parameter: EffectParameter) async throws {
        guard let baseImage = image(named: assetName) else {
            throw MirrorActionError.missingTexture(assetName)
        }
        guard shouldApply(.tintedTexture(assetName, tint), on: parameter) else {
            return
        }

        let cacheKey = "tinted:\(assetName):\(tint.red):\(tint.green):\(tint.blue):\(tint.alpha)"
        let image = textureImageCache[cacheKey] ?? tintedImage(baseImage, tint: tint)
        textureImageCache[cacheKey] = image
        await controller.setTexture(image, on: parameter)
    }

    private func tintedImage(_ image: UIImage, tint: RGBA) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: image.size, format: format).image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            image.draw(in: rect)
            context.cgContext.setBlendMode(.sourceAtop)
            UIColor(
                red: CGFloat(tint.red),
                green: CGFloat(tint.green),
                blue: CGFloat(tint.blue),
                alpha: CGFloat(tint.alpha)
            ).setFill()
            context.fill(rect)
        }
    }
}

import OSLog
import UIKit

extension DeepARController {
    /// Sets a color parameter on the active DeepAR scene.
    public func setColor(_ color: UIColor, on parameter: EffectParameter) async {
        guard let client = parameterClient(method: "setColor") else {
            return
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        Logger.deepAR.debug(
            "setColor \(parameter.nodeName).\(parameter.component).\(parameter.parameter) = \(red), \(green), \(blue), \(alpha)"
        )
        client.setVectorParameter(
            parameter.nodeName,
            component: parameter.component,
            parameter: parameter.parameter,
            value: DeepARVectorParameter(
                red: Float(red),
                green: Float(green),
                blue: Float(blue),
                alpha: Float(alpha)
            )
        )
    }

    /// Sets a texture parameter on the active DeepAR scene.
    public func setTexture(_ image: UIImage, on parameter: EffectParameter) async {
        guard let client = parameterClient(method: "setTexture") else {
            return
        }

        Logger.deepAR.debug(
            "setTexture \(parameter.nodeName).\(parameter.component).\(parameter.parameter) = \(String(describing: image.size))"
        )
        client.setImageParameter(
            parameter.nodeName,
            component: parameter.component,
            parameter: parameter.parameter,
            image: image
        )
    }

    /// Sets a blendshape parameter on the active DeepAR scene.
    public func setBlendshape(_ value: Float, on parameter: EffectParameter) async {
        guard let client = parameterClient(method: "setBlendshape") else {
            return
        }

        Logger.deepAR.debug(
            "setBlendshape \(parameter.nodeName).\(parameter.component).\(parameter.parameter) = \(value)"
        )
        client.setFloatParameter(
            parameter.nodeName,
            component: parameter.component,
            parameter: parameter.parameter,
            value: value
        )
    }

    /// Sets an enabled-state parameter on the active DeepAR scene.
    public func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async {
        guard let client = parameterClient(method: "setEnabled") else {
            return
        }

        Logger.deepAR.debug(
            "setEnabled \(parameter.nodeName).\(parameter.component).\(parameter.parameter) = \(enabled)"
        )
        client.setBoolParameter(
            parameter.nodeName,
            component: parameter.component,
            parameter: parameter.parameter,
            value: enabled
        )
    }

    private func parameterClient(method: String) -> (any DeepARClient)? {
        guard state == .ready, let client = _client else {
            Logger.deepAR.info("\(method) skipped (not ready)")
            return nil
        }
        return client
    }
}

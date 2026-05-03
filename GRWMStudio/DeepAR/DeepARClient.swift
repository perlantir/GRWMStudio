import DeepAR
import UIKit

/// Swift-native vector parameter value used before crossing into the DeepAR SDK.
struct DeepARVectorParameter: Equatable, Sendable {
    /// Red or x component.
    let red: Float
    /// Green or y component.
    let green: Float
    /// Blue or z component.
    let blue: Float
    /// Alpha or w component.
    let alpha: Float
}

/// Adapter protocol for the live DeepAR SDK.
@MainActor
protocol DeepARClient: AnyObject {
    /// Applies a DeepAR license key.
    func setLicenseKey(_ licenseKey: String)
    /// Installs the DeepAR delegate proxy.
    func setDelegate(_ delegate: DeepARDelegateProxy)
    /// Creates the SDK-rendered AR view.
    func createARView(frame: CGRect) -> UIView
    /// Switches or clears an effect for a slot.
    func switchEffect(withSlot slot: String, path: String?)
    /// Captures the current SDK frame.
    func takeScreenshot()
    /// Starts SDK video recording.
    func startVideoRecording(outputWidth: Int32, outputHeight: Int32)
    /// Sets the directory where the SDK should write video recordings.
    func setVideoRecordingOutputPath(_ path: String)
    /// Sets the SDK output file name without extension.
    func setVideoRecordingOutputName(_ name: String)
    /// Finishes SDK video recording.
    func finishVideoRecording()
    /// Applies a Vector4 runtime parameter.
    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    )
    /// Applies a UIImage runtime parameter.
    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage)
    /// Applies a Float runtime parameter.
    func setFloatParameter(_ gameObject: String, component: String, parameter: String, value: Float)
    /// Applies a Bool runtime parameter.
    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool)
}

extension DeepARClient {
    func takeScreenshot() {}

    func startVideoRecording(outputWidth: Int32, outputHeight: Int32) {}

    func setVideoRecordingOutputPath(_ path: String) {}

    func setVideoRecordingOutputName(_ name: String) {}

    func finishVideoRecording() {}

    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    ) {}

    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage) {}

    func setFloatParameter(_ gameObject: String, component: String, parameter: String, value: Float) {}

    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool) {}
}

/// Live adapter that owns the DeepAR SDK instance.
@MainActor
final class LiveDeepARClient: DeepARClient {
    /// Underlying DeepAR SDK object.
    let sdk: DeepAR

    /// Creates a live SDK adapter.
    init(sdk: DeepAR = DeepAR()) {
        self.sdk = sdk
    }

    func setLicenseKey(_ licenseKey: String) {
        sdk.setLicenseKey(licenseKey)
    }

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        sdk.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        sdk.createARView(withFrame: frame)
    }

    func switchEffect(withSlot slot: String, path: String?) {
        sdk.switchEffect(withSlot: slot, path: path)
    }

    func takeScreenshot() {
        sdk.takeScreenshot()
    }

    func startVideoRecording(outputWidth: Int32, outputHeight: Int32) {
        sdk.startVideoRecording(withOutputWidth: outputWidth, outputHeight: outputHeight)
    }

    func setVideoRecordingOutputPath(_ path: String) {
        sdk.setVideoRecordingOutputPath(path)
    }

    func setVideoRecordingOutputName(_ name: String) {
        sdk.setVideoRecordingOutputName(name)
    }

    func finishVideoRecording() {
        sdk.finishVideoRecording()
    }

    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    ) {
        let vector = Vector4(x: value.red, y: value.green, z: value.blue, w: value.alpha)
        sdk.changeParameter(gameObject, component: component, parameter: parameter, vectorValue: vector)
    }

    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage) {
        sdk.changeParameter(gameObject, component: component, parameter: parameter, image: image)
    }

    func setFloatParameter(_ gameObject: String, component: String, parameter: String, value: Float) {
        sdk.changeParameter(gameObject, component: component, parameter: parameter, floatValue: value)
    }

    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool) {
        sdk.changeParameter(gameObject, component: component, parameter: parameter, boolValue: value)
    }
}

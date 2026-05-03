/// A resolved DeepAR runtime parameter target.
public struct EffectParameter: Equatable, Hashable, Sendable {
    /// Exact node name from the `.deeparproj` hierarchy.
    public let nodeName: String
    /// Component name, usually `MeshRenderer`.
    public let component: String
    /// Shader parameter or object property name.
    public let parameter: String

    /// Creates a DeepAR runtime parameter target.
    public init(nodeName: String, component: String, parameter: String) {
        self.nodeName = nodeName
        self.component = component
        self.parameter = parameter
    }
}

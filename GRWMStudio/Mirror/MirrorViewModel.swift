import Foundation
import Observation
import OSLog
import SwiftUI
import UIKit

@MainActor
@Observable
final class MirrorViewModel {
    let controller: DeepARController
    let catalog: EffectCatalog

    var state: MirrorState = .idle
    var selections: [EffectSlot: SlotSelection] = [:]
    var eyeSelections: [EyesSubCategory: String] = [:]
    var isFaceDetected = false
    var cameraIsFront = true
    var flashEnabled = false
    var lastError: ErrorVariant?
    var pendingFullScreenError: ErrorVariant?
    var activeLookName: String?
    var activeCategory: FilterCategory?
    var eyesSubCategory: EyesSubCategory = .shadow
    var selectedCaptureKind: CaptureKind = .photo
    var activeCaptureMode: CaptureMode = .idle
    var lastCaptureEvent: CaptureEvent?
    var pendingPreviewAsset: CapturedAsset?
    var previewRouteID: UUID?
    var pendingRecordingProGateClipURL: URL?
    var recordingProGateRouteID: UUID?
    var activeTraySlot: EffectSlot? {
        activeCategory?.slot
    }

    @ObservationIgnored var env: AppEnvironment?
    @ObservationIgnored var faceTask: Task<Void, Never>?
    @ObservationIgnored var recordWithoutAudioTask: Task<Void, Never>?
    @ObservationIgnored var retryEffectTask: Task<Void, Never>?
    @ObservationIgnored var retryRecordingTask: Task<Void, Never>?
    @ObservationIgnored var useSampleFaceTask: Task<Void, Never>?
    @ObservationIgnored var noFaceErrorTask: Task<Void, Never>?
    @ObservationIgnored let licenseLoader: () throws -> String
    @ObservationIgnored let usesSimulatorPlaceholder: Bool
    @ObservationIgnored let notificationCenter: NotificationCenter
    @ObservationIgnored var lastShadeSelection: (slot: EffectSlot, shade: Shade)?
    @ObservationIgnored var lastEffectIntent: LastEffectIntent?
    @ObservationIgnored var effectFailureCount = 0
    @ObservationIgnored var effectFailureWindowStart: Date?
    @ObservationIgnored let currentDate: () -> Date
    @ObservationIgnored let noFaceDelay: Duration
    @ObservationIgnored var capturePressStartedAt: Date?
    @ObservationIgnored var captureTickTask: Task<Void, Never>?
    @ObservationIgnored var recordingTimer: Timer?
    @ObservationIgnored var recordingStart: Date?
    @ObservationIgnored let photoCapture: (@MainActor () async throws -> UIImage)?
    @ObservationIgnored let videoRecording: any VideoRecordingCoordinating
    @ObservationIgnored let entitlements: ProEntitlements
    @ObservationIgnored let sampleFaceLoader: (@MainActor () async -> Bool)?
    @ObservationIgnored var isApplyingSelection = false
    @ObservationIgnored var sharedBeautyEffectLoaded = false
    @ObservationIgnored var appliedParameterValues: [EffectParameterKey: AppliedParameterValue] = [:]
    @ObservationIgnored var lastCaptureFailureKind: CaptureKind?
    @ObservationIgnored let effectTextureCache: EffectTextureCache
    @ObservationIgnored var backgroundReleaseTask: Task<Void, Never>?
    @ObservationIgnored let backgroundRetention: Duration

    init(
        controller: DeepARController = DeepARController(),
        catalog: EffectCatalog = .shared,
        licenseLoader: @escaping () throws -> String = { try DeepARLicense.key() },
        usesSimulatorPlaceholder: Bool = MirrorViewModel.defaultUsesSimulatorPlaceholder,
        currentDate: @escaping () -> Date = Date.init,
        noFaceDelay: Duration = .seconds(6),
        backgroundRetention: Duration = .seconds(60),
        photoCapture: (@MainActor () async throws -> UIImage)? = nil,
        videoRecording: (any VideoRecordingCoordinating)? = nil,
        entitlements: ProEntitlements = ProEntitlementsHolder.shared.entitlements,
        notificationCenter: NotificationCenter = .default,
        sampleFaceLoader: (@MainActor () async -> Bool)? = nil,
        effectTextureCache: EffectTextureCache = EffectTextureCache()
    ) {
        self.controller = controller
        self.catalog = catalog
        self.licenseLoader = licenseLoader
        self.usesSimulatorPlaceholder = usesSimulatorPlaceholder
        self.photoCapture = photoCapture
        self.currentDate = currentDate
        self.noFaceDelay = noFaceDelay
        self.entitlements = entitlements
        self.notificationCenter = notificationCenter
        self.sampleFaceLoader = sampleFaceLoader
        self.backgroundRetention = backgroundRetention
        self.effectTextureCache = effectTextureCache
        self.videoRecording = videoRecording ?? VideoRecordingCoordinator(
            controller: controller,
            allowSimulatorPlaceholder: usesSimulatorPlaceholder
        )
    }

}

struct EffectParameterKey: Hashable {
    let nodeName: String
    let component: String
    let parameter: String

    init(_ parameter: EffectParameter) {
        nodeName = parameter.nodeName
        component = parameter.component
        self.parameter = parameter.parameter
    }
}

enum AppliedParameterValue: Equatable {
    case color(red: Double, green: Double, blue: Double, alpha: Double)
    case texture(String)
    case tintedTexture(String, RGBA)
    case blendshape(Float)
    case enabled(Bool)
}

enum LastEffectIntent {
    case shade(slot: EffectSlot, shade: Shade)
    case look(LookPreset)
}

enum MirrorActionError: LocalizedError {
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

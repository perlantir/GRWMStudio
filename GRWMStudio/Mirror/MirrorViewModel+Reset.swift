extension MirrorViewModel {
    func resetAll() async {
        DHHaptics.heavy()
        #if targetEnvironment(simulator)
        let shouldClearControllerEffects = controller.state == .ready
        #else
        let shouldClearControllerEffects = true
        #endif
        if shouldClearControllerEffects {
            await controller.clearAllEffects()
        }
        selections.removeAll()
        eyeSelections.removeAll()
        sharedBeautyEffectLoaded = false
        activeLookName = nil
        activeCategory = nil
        eyesSubCategory = .shadow
    }
}

struct LookSection: Identifiable, Hashable {
    var id: String { titleKey }
    let titleKey: String
    let subtitleKey: String
    let looks: [LookPreset]

    var title: String {
        L10n.string(titleKey)
    }

    var subtitle: String {
        L10n.string(subtitleKey)
    }
}

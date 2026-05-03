import CoreText
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerFontsIfNeeded()
        return true
    }

    private func registerFontsIfNeeded() {
        let fontNames = [
            "Fredoka-Regular",
            "Fredoka-Medium",
            "Fredoka-SemiBold",
            "Fredoka-Bold",
            "Quicksand-Regular",
            "Quicksand-Medium",
            "Quicksand-SemiBold",
            "Quicksand-Bold"
        ]

        for name in fontNames {
            guard UIFont(name: name, size: 12) == nil,
                  let url = Bundle.main.url(forResource: name, withExtension: "ttf")
            else {
                continue
            }

            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }
}

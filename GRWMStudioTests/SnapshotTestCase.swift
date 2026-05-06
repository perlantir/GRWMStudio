import SwiftUI
import XCTest

@MainActor
class SnapshotTestCase: XCTestCase {
    func assertScreen<V: View>(
        _ view: V,
        named name: String,
        width: CGFloat = 393,
        height: CGFloat = 852,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let controller = UIHostingController(rootView: view.frame(width: width, height: height))
        controller.view.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        controller.view.backgroundColor = .clear
        controller.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        let data = try XCTUnwrap(image.pngData(), file: file, line: line)
        XCTAssertGreaterThan(data.count, 1024, "Snapshot \(name) rendered too small.", file: file, line: line)

        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

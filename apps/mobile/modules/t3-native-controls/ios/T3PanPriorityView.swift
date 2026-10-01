import ExpoModulesCore
import UIKit

/// Lets a local pan finish before iOS 26's content-wide Back gesture begins.
/// The screen-edge Back recognizer keeps its normal priority.
final class T3PanPriorityView: ExpoView {
  override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    super.addGestureRecognizer(gestureRecognizer)
    prioritizePan(gestureRecognizer)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    for recognizer in gestureRecognizers ?? [] {
      prioritizePan(recognizer)
    }
  }

  private func prioritizePan(_ recognizer: UIGestureRecognizer) {
    guard #available(iOS 26.0, *), window != nil,
          recognizer is UIPanGestureRecognizer else { return }
    // Nested native stacks can each own a content Back recognizer.
    var responder: UIResponder? = self
    while let current = responder {
      if let controller = current as? UIViewController {
        controller.navigationController?.interactiveContentPopGestureRecognizer?
          .require(toFail: recognizer)
      }
      responder = current.next
    }
  }
}

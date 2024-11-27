//
//  PresentedSimpleViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//


// MARK: - PresentedSimpleViewController
class PresentedSimpleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDismissButton()
        setupCloseBarButton()
        
        // Add a double tap gesture recognizer
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func setupCloseBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissView)
        )
    }
    
    func setupDismissButton() {
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss Me", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func dismissView() {
        if presentingViewController != nil ||
            navigationController?.presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            // If there's no presenting view controller, it could be in a navigation stack
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .recognized {
            
            if #available(iOS 15.0, *) {
                if let sheet = sheetPresentationController {
                    let nextDetent: UISheetPresentationController.Detent.Identifier
                    
                    switch sheet.selectedDetentIdentifier {
                    case .medium:
                        nextDetent = .large
                    case .large:
                        nextDetent = .medium
                    default:
                        nextDetent = .medium
                    }
                    sheet.animateChanges {
                        sheet.detents = [UISheetPresentationController.Detent.custom(identifier: nextDetent) { _ in
                            return nextDetent == .medium ?  200 :  UIScreen.main.bounds.height * 0.9 // You can adjust the height for medium size
                        }
                        ]
                    }
                }
            }
        }
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        guard #available(iOS 15.0, *), let sheet = sheetPresentationController else { return }
        
        switch recognizer.state {
        case .began:
            // Optionally, pause other recognizers that might interfere with the pinch
            recognizer.view?.gestureRecognizers?.filter { $0 != recognizer }.forEach { $0.isEnabled = false }
        case .changed:
            let currentHeight = sheet.detents.contains(.large()) ? view.frame.height : sheet.detents.contains(.medium()) ? 200 : view.frame.height * recognizer.scale
            
            // Ensure the scaled height stays within a reasonable range
            let scaledHeight = max(100, min(currentHeight, view.frame.height * 0.9))
            sheet.animateChanges {
                sheet.detents = [.custom(identifier: .large) { _ in scaledHeight }]
            }
            
        case .ended, .cancelled, .failed:
            let currentHeight = sheet.detents.contains(.large()) ? view.frame.height : sheet.detents.contains(.medium()) ? 200 :  view.frame.height * recognizer.scale // Limit max height to 90%
            let velocity = recognizer.velocity
            
            let targetDetent: UISheetPresentationController.Detent.Identifier
            
            if velocity > 0 {
                // Pinch out - move to large
                targetDetent = .large
            } else if velocity < 0 {
                // Pinch in - move to medium or small
                targetDetent = currentHeight > (view.frame.height * 0.5) ? (currentHeight > view.frame.height * 0.8 ? .large : .medium) : .medium
            } else {
                // Determine target detent based on the nearest default detent when velocity is 0
                if currentHeight < (view.frame.height * 0.4) {
                    targetDetent = .medium
                }  else if currentHeight > (view.frame.height * 0.8){
                    targetDetent = .large
                }
                else {
                    targetDetent =  currentHeight > (view.frame.height * 0.5) ?  .large : .medium
                }
            }
            
            sheet.animateChanges {
                sheet.detents = targetDetent == .medium ?  [.medium()] : [.large()]
                if targetDetent == .medium {
                    sheet.preferredCornerRadius = 25
                } else {
                    sheet.preferredCornerRadius = 0
                }
            }
            // Re-enable other recognizers
            recognizer.view?.gestureRecognizers?.filter { $0 != recognizer }.forEach { $0.isEnabled = true }
        default:
            break
        }
    }
}

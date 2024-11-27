//
//  PresentingSimpleViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//


// MARK: - PresentingSimpleViewController
class PresentingSimpleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupButtons()
    }
    
    func setupButtons() {
        let buttonTitles = [
            "Default",
            "Page Sheet",
            "Half Sheet",
            "Form Sheet",
            "Current Context",
            "Custom",
            "Popover",
            "Adaptive Sheet",
            "Automatic"
        ]
        
        let buttonActions: [Selector] = [
            #selector(presentDefault),
            #selector(presentPageSheet),
            #selector(presentHalfSheet),
            #selector(presentFormSheet),
            #selector(presentCurrentContext),
            #selector(presentCustomTransition),
            #selector(presentPopover),
            #selector(presentAdaptiveSheet),
            #selector(presentAutomatic)
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: buttonActions[index], for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Presentation Actions
    
    @objc func presentDefault() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .fullScreen
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentPageSheet() {
        let presentedVC = PresentedSimpleViewController()
        if #available(iOS 15.0, *) {
            if let sheet = presentedVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentHalfSheet() {
        let presentedVC = PresentedSimpleViewController()
        if #available(iOS 15.0, *) {
            if let sheet = presentedVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            presentPageSheet()
            return
        }
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentFormSheet() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .formSheet
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentCurrentContext() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .currentContext
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentAutomatic() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .automatic
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentCustomTransition() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .fullScreen // or any other style
        presentedVC.transitioningDelegate = self
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentPopover() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .popover
        presentedVC.preferredContentSize = CGSize(width: 300, height: 200)
        
        if let popoverController = presentedVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = self.view  // Use the main view as the source view
            
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            ) // Anchored at center
            
            popoverController.permittedArrowDirections = .any
        }
        
        present(presentedVC, animated: true, completion: nil)
    }
    
    @objc func presentAdaptiveSheet() {
        let presentedVC = PresentedSimpleViewController()
        presentedVC.modalPresentationStyle = .popover  // Use Popover for Adaptive Sheet
        presentedVC.preferredContentSize = CGSize(width: 300, height: 200)
        
        if let popoverController = presentedVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = view // Specify source view
            
            popoverController.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            ) // Anchored at center
            
            popoverController.permittedArrowDirections = [] // No arrow for adaptive sheet
            if #available(iOS 16.0, *) {
                popoverController.canOverlapSourceViewRect = true
                popoverController.adaptiveSheetPresentationController.detents = [.medium(), .large()]
                popoverController.adaptiveSheetPresentationController.prefersGrabberVisible = true
                popoverController.adaptiveSheetPresentationController.preferredCornerRadius = 25
            }
        }
        present(presentedVC, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension PresentingSimpleViewController: UIPopoverPresentationControllerDelegate {
    // Popover Presentation Controller Delegate for adaptive presentation
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // Do not adapt; keep the specified style (popover)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true // Allow dismissal by tapping outside
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PresentingSimpleViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator(isPresenting: false)
    }
}


// MARK: - Custom Transition Animator

// Custom animator for the transition
class CustomTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        if isPresenting {
            containerView.addSubview(toView)
            toView.alpha = 0.0
            toView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.alpha = 1.0
                toView.transform = .identity
            }) { finished in
                transitionContext.completeTransition(finished)
            }
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView.alpha = 0.0
                fromView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                
            }) { finished in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }
}

//
//  ViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/30/24.
//



import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    private let labelFont: UIFont = {
        if let font = UIFont(name: "Menlo", size: 8) {
            return font
        } else {
            return UIFont.systemFont(ofSize: 8)
        }
    }()
    
    private let maxImageSize = CGSize(width: 310, height: 310)
    private lazy var palette = AsciiPalette(font: self.labelFont)
    
    
    
    private var currentLabel: UILabel?
    private let busyView = UIView()  // Programmatically created
    private let scrollView = UIScrollView() // Programmatically created
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureZoomSupport()
    }

    private func setupUI() {
        view.backgroundColor = .white // Set background color

        // Busy View
        busyView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        busyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(busyView)
        NSLayoutConstraint.activate([
            busyView.topAnchor.constraint(equalTo: view.topAnchor),
            busyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            busyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            busyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        busyView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: busyView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: busyView.centerYAnchor)
        ])


        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])


        // Buttons
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        let kermitButton = createButton(title: "Kermit")
        kermitButton.addTarget(self, action: #selector(handleKermitTapped), for: .touchUpInside)
        let batmanButton = createButton(title: "Batman")
        batmanButton.addTarget(self, action: #selector(handleBatmanTapped), for: .touchUpInside)
        let monkeyButton = createButton(title: "Monkey")
        monkeyButton.addTarget(self, action: #selector(handleMonkeyTapped), for: .touchUpInside)
        let pickImageButton = createButton(title: "Pick Image")
        pickImageButton.addTarget(self, action: #selector(handlePickImageTapped), for: .touchUpInside)

        buttonStackView.addArrangedSubview(kermitButton)
        buttonStackView.addArrangedSubview(batmanButton)
        buttonStackView.addArrangedSubview(monkeyButton)
        buttonStackView.addArrangedSubview(pickImageButton)


        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -20)
        ])

        busyView.isHidden = true // Initially hide busy view
    }

    // Helper function to create buttons programmatically
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func handleKermitTapped() {
        print("handleKermitTapped")
        self.displayImageNamed("kermit")
    }
    
    @objc private func handleBatmanTapped() {
        print("handleBatmanTapped")
        self.displayImageNamed("batman")
    }
    
    @objc private func handleMonkeyTapped() {
        print("handleMonkeyTapped")
        self.displayImageNamed("monkey")
    }
    
    @objc private func handlePickImageTapped() {
        print("handlePickImageTapped")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true) // Use present() for image picker
    }

    // MARK: - Image Picker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            displayImage(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Display Methods

    private func displayImageNamed(_ imageName: String) {
        if let image = UIImage(named: imageName) { // Safe unwrap
            displayImage(image)
        } else {
            print("Image named '\(imageName)' not found")
        }
    }

    private func displayImage(_ image: UIImage) {
        busyView.isHidden = false
        DispatchQueue.global(qos: .userInitiated).async { [self] in // Capture self weakly
            let rotatedImage = image.imageRotatedToPortraitOrientation()
            let resizedImage = rotatedImage.imageConstrainedToMaxSize(maxImageSize)
            let asciiArtist = AsciiArtist(resizedImage, palette)
            let asciiArt = asciiArtist.createAsciiArt()

            DispatchQueue.main.async { [self] in // Capture self weakly
                displayAsciiArt(asciiArt)
                busyView.isHidden = true
            }
            print(asciiArt)
        }
    }

    private func displayAsciiArt(_ asciiArt: String) {
        let label = UILabel()
        label.font = labelFont
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.text = asciiArt
        label.sizeToFit()
        
        currentLabel?.removeFromSuperview()
        currentLabel = label
        scrollView.addSubview(label)
        scrollView.contentSize = label.frame.size
        updateZoomSettings(animated: false)
        scrollView.setContentOffset(.zero, animated: false)
    }

    // MARK: - Zoom Support

    private func configureZoomSupport() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = self
    }

    private func updateZoomSettings(animated: Bool) {
        guard let label = currentLabel else { return } // Add guard

        let scrollSize = scrollView.frame.size
        let contentSize = label.frame.size // use label size directly
        let scaleWidth = scrollSize.width / contentSize.width
        let scaleHeight = scrollSize.height / contentSize.height
        let scale = max(scaleWidth, scaleHeight)

        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: animated)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentLabel
    }
}

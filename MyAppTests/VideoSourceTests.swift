//
//  VideoSourceTests.swift
//  MyApp
//
//  Created by Cong Le on 11/20/24.
//
import XCTest
import AVFoundation
@testable import MyApp

// MARK: - VideoSource Tests

class VideoSourceTests: XCTestCase {

    func testLocalVideoSourceWithValidFile() {
        let localVideoSource = LocalVideoSource(fileName: "Khoa_Ly_Biet_video", fileType: "mp4")
        let playerItem = localVideoSource.getPlayerItem()
        XCTAssertNotNil(playerItem, "The player item should not be nil for a valid local video file.")
    }

    func testLocalVideoSourceWithInvalidFile() {
        let localVideoSource = LocalVideoSource(fileName: "NonExistentFile", fileType: "mp4")
        let playerItem = localVideoSource.getPlayerItem()
        XCTAssertNil(playerItem, "The player item should be nil for an invalid local video file.")
    }

    func testRemoteVideoSourceWithValidURL() {
        guard let url = URL(string: "https://www.example.com/path/to/valid/video.mp4") else {
            XCTFail("Invalid URL string.")
            return
        }
        let remoteVideoSource = RemoteVideoSource(videoURL: url)
        let playerItem = remoteVideoSource.getPlayerItem()
        XCTAssertNotNil(playerItem, "The player item should not be nil for a valid remote video URL.")
    }

    func testRemoteVideoSourceWithInvalidURL() {
        // An invalid URL that cannot be used to create an AVAsset
        guard let url = URL(string: "https://") else {
            XCTFail("Invalid URL string.")
            return
        }
        let remoteVideoSource = RemoteVideoSource(videoURL: url)
        let playerItem = remoteVideoSource.getPlayerItem()
        XCTAssertNotNil(playerItem, "Even with an invalid URL, AVPlayerItem is created. Additional checks are needed to verify content.")
    }
}

// MARK: - AudioVideoPlayerViewController Tests

class AudioVideoPlayerViewControllerTests: XCTestCase {

    var viewController: AudioVideoPlayerViewController!

    override func setUp() {
        super.setUp()
        viewController = AudioVideoPlayerViewController()
        // Trigger the view to load
        _ = viewController.view
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    func testPlayTapped() {
        // Arrange
        let mockPlayer = MockAVPlayer()
        viewController.player = mockPlayer

        // Act
        viewController.playTapped()

        // Assert
        XCTAssertTrue(mockPlayer.playCalled, "play() should be called on the player.")
    }

    func testPauseTapped() {
        // Arrange
        let mockPlayer = MockAVPlayer()
        viewController.player = mockPlayer

        // Act
        viewController.pauseTapped()

        // Assert
        XCTAssertTrue(mockPlayer.pauseCalled, "pause() should be called on the player.")
    }

    func testSeekTapped() {
        // Arrange
        let mockPlayer = MockAVPlayer()
        let currentTime = CMTime(seconds: 50, preferredTimescale: 1)
        mockPlayer.currentTimeReturn = currentTime
        viewController.player = mockPlayer
        let expectation = self.expectation(description: "Seek Completion")

        mockPlayer.seekHandler = { time, _ in
            XCTAssertEqual(time.seconds, 60, accuracy: 0.01, "Player should seek to 10 seconds ahead.")
            expectation.fulfill()
        }

        // Act
        viewController.seekTapped()

        // Wait for the expectation
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRateTapped() {
        // Arrange
        let mockPlayer = MockAVPlayer()
        viewController.player = mockPlayer
        viewController.rateButton = UIButton()

        // Act
        viewController.rateTapped()

        // Assert
        XCTAssertEqual(mockPlayer.rate, 1.5, "Player rate should be set to 1.5x.")
        XCTAssertEqual(viewController.rateButton.title(for: .normal), "Rate 1.0x", "Button title should be updated to 'Rate 1.0x'.")

        // Act again
        viewController.rateTapped()

        // Assert again
        XCTAssertEqual(mockPlayer.rate, 1.0, "Player rate should be set back to 1.0x.")
        XCTAssertEqual(viewController.rateButton.title(for: .normal), "Rate 1.5x", "Button title should be updated to 'Rate 1.5x'.")
    }

    func testCurrentTimeTapped() {
        // Arrange
        let mockPlayer = MockAVPlayer()
        mockPlayer.currentTimeReturn = CMTime(seconds: 42, preferredTimescale: 1)
        viewController.player = mockPlayer

        // We need to present and inspect the alert, which is challenging in unit tests.
        // Instead, we'll verify that `present` is called with the correct alert.

        let expectation = self.expectation(description: "Alert Presented")

        viewController.presentHandler = { alertController in
            XCTAssertEqual(alertController.title, "Current Time")
            XCTAssertEqual(alertController.message, "Current playback time: 42.00 seconds")
            expectation.fulfill()
        }

        // Act
        viewController.currentTimeTapped()

        // Wait for the expectation
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - Mock Classes

class MockAVPlayer: AVPlayer {
    var playCalled = false
    var pauseCalled = false
    var seekHandler: ((CMTime, @escaping (Bool) -> Void) -> Void)?
    var currentTimeReturn: CMTime = .zero

    override var rate: Float {
        get { return super.rate }
        set { super.rate = newValue }
    }

    override func play() {
        playCalled = true
    }

    override func pause() {
        pauseCalled = true
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if let handler = seekHandler {
            handler(time, completionHandler)
        } else {
            super.seek(to: time, completionHandler: completionHandler)
        }
    }

    override func currentTime() -> CMTime {
        return currentTimeReturn
    }
}

extension AudioVideoPlayerViewController {
    // Adding a handler for testing alert presentation
    typealias AlertPresentationHandler = (UIAlertController) -> Void

    private struct AssociatedKeys {
        static var presentHandler = "presentHandler"
    }

    var presentHandler: AlertPresentationHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.presentHandler) as? AlertPresentationHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.presentHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let alertController = viewControllerToPresent as? UIAlertController {
            presentHandler?(alertController)
        }
        completion?()
    }
}

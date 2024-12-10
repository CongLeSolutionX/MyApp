//
//  YOLOStatisticsViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/9/24.
//

// StatisticsViewController.swift

import UIKit

/// A view controller for displaying various statistics.
class YOLOStatisticsViewController: UIViewController {

    // MARK: - UI Elements

    private var inferenceTimeLabel: UILabel!
    private var fpsLabel: UILabel!
    private var memoryUsageLabel: UILabel!
    private var storageUsageLabel: UILabel!

    // MARK: - Properties

    /// Array containing recent inference times.
    var inferenceTimes: [Double] = []

    /// Array containing recent FPS values.
    var fpsValues: [Double] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Statistics"

        inferenceTimeLabel = createLabel()
        fpsLabel = createLabel()
        memoryUsageLabel = createLabel()
        storageUsageLabel = createLabel()

        // Add subviews
        let stackView = UIStackView(arrangedSubviews: [
            inferenceTimeLabel,
            fpsLabel,
            memoryUsageLabel,
            storageUsageLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        // Layout
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        ])
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Data Updates

    /// Updates the statistics displayed on the screen.
    func updateStatistics() {
        let avgInferenceTime = inferenceTimes.isEmpty ? 0 : inferenceTimes.reduce(0, +) / Double(inferenceTimes.count)
        let avgFPS = fpsValues.isEmpty ? 0 : fpsValues.reduce(0, +) / Double(fpsValues.count)

        inferenceTimeLabel.text = String(format: "Avg Inference Time: %.2f ms", avgInferenceTime * 1000) // Convert seconds to ms
        fpsLabel.text = String(format: "Avg FPS: %.2f", avgFPS)
        memoryUsageLabel.text = String(format: "Memory Usage: %.2f MB", memoryUsage())
        storageUsageLabel.text = String(format: "Free Storage: %.2f GB", freeSpace())
    }

    // MARK: - Utility Functions

    /// Returns the amount of free storage space in GB.
    private func freeSpace() -> Double {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let availableCapacity = values.volumeAvailableCapacityForImportantUsage {
                return Double(availableCapacity) / 1_000_000_000 // Bytes to GB
            }
        } catch {
            print("Error retrieving storage capacity: \(error.localizedDescription)")
        }
        return 0
    }

    /// Returns the current memory usage in MB.
    private func memoryUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: taskInfo) / MemoryLayout<Int32>.size)
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            return Double(taskInfo.resident_size) / 1_000_000 // Bytes to MB
        } else {
            return 0
        }
    }
}

//
//  AverageRatesView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import UIKit

class AverageRatesViewController: UIViewController {
    // Navigation Bar
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Average Rates"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Segmented Control
    let segmentedControl: UISegmentedControl = {
        let items = ["MND", "FREDDIE MAC", "MBA"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // Mortgage Data Section
    let mortgageDataContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let mortgageDataTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mortgage News Daily (daily)"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Table Header
    let tableHeaderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let headerSpacer = UILabel()
    let headerCurrentLabel: UILabel = {
        let label = UILabel()
        label.text = "Current"
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()
    let header52WeekRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "52 Week Range"
        label.textColor = UIColor.lightGray
        label.textAlignment = .right
        return label
    }()

    // Data Rows (Example for one row)
    let dataRow1StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let dataLabel1Left: UILabel = {
        let label = UILabel()
        label.text = "30 Yr. Fixed"
        label.textColor = .white
        return label
    }()
    let dataLabel1CenterA: UILabel = {
        let label = UILabel()
        label.text = "6.80%"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    let dataLabel1CenterB: UILabel = {
        let label = UILabel()
        label.text = "+0.00%"
        label.textColor = UIColor.green
        label.textAlignment = .center
        return label
    }()
    let dataLabel1RightA: UILabel = {
        let label = UILabel()
        label.text = "6.11%"
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    let progressBar1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let progressBarTrack1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let dataLabel1RightB: UILabel = {
        let label = UILabel()
        label.text = "7.52%"
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    // Time Segmented Control
    let timeSegmentedControl: UISegmentedControl = {
        let items = ["1M", "3M", "6M", "1Y", "5Y", "ALL"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 2
        control.backgroundColor = UIColor.darkGray
        control.tintColor = UIColor.systemBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // Graph View (Simplified placeholder)
    let graphContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Legend View
    let legendStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    // Example Legend Item
    func createLegendItem(color: UIColor, text: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 4
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        let label = UILabel()
        label.text = text
        label.textColor = .white
        stack.addArrangedSubview(colorView)
        stack.addArrangedSubview(label)
        return stack
    }

    // Tab Bar
    let tabBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    func createTabBarButton(title: String, imageName: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: UIImage(systemName: imageName))
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = title
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -8)
        ])
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return view
    }
    let lendersButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: UIImage(systemName: "person.3.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Lenders"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        let badgeLabel: UILabel = {
            let label = UILabel()
            label.text = "6"
            label.textColor = .white
            label.backgroundColor = .red
            label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -2),
            badgeLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 8),
            badgeLabel.widthAnchor.constraint(equalToConstant: 16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(mortgageDataContainer)
        mortgageDataContainer.addSubview(mortgageDataTitleLabel)
        mortgageDataContainer.addSubview(tableHeaderStackView)
        tableHeaderStackView.addArrangedSubview(headerSpacer)
        tableHeaderStackView.addArrangedSubview(headerCurrentLabel)
        tableHeaderStackView.addArrangedSubview(header52WeekRangeLabel)
        mortgageDataContainer.addSubview(dataRow1StackView)
        dataRow1StackView.addArrangedSubview(dataLabel1Left)
        let centerStack1 = UIStackView(arrangedSubviews: [dataLabel1CenterA, dataLabel1CenterB])
        centerStack1.axis = .vertical
        centerStack1.alignment = .center
        dataRow1StackView.addArrangedSubview(centerStack1)
        let rightStack1 = UIStackView()
        rightStack1.axis = .vertical
        rightStack1.alignment = .trailing
        let rangeStack1 = UIStackView(arrangedSubviews: [dataLabel1RightA, dataLabel1RightB])
        rangeStack1.axis = .horizontal
        rangeStack1.spacing = 8
        rightStack1.addArrangedSubview(rangeStack1)
        progressBarTrack1.addSubview(progressBar1)
        rightStack1.addArrangedSubview(progressBarTrack1)
        dataRow1StackView.addArrangedSubview(rightStack1)

        view.addSubview(timeSegmentedControl)
        view.addSubview(graphContainerView)
        view.addSubview(legendStackView)
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 31/255, green: 119/255, blue: 180/255, alpha: 1), text: "15YR Fixed"))
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 255/255, green: 127/255, blue: 14/255, alpha: 1), text: "30YR FHA"))
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 44/255, green: 160/255, blue: 44/255, alpha: 1), text: "30YR Fixed"))
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 148/255, green: 103/255, blue: 189/255, alpha: 1), text: "30YR Jumbo"))
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 140/255, green: 86/255, blue: 75/255, alpha: 1), text: "5/1 ARM"))
        legendStackView.addArrangedSubview(createLegendItem(color: UIColor(red: 227/255, green: 119/255, blue: 194/255, alpha: 1), text: "30YR VA"))

        view.addSubview(tabBarStackView)
        tabBarStackView.addArrangedSubview(createTabBarButton(title: "Rates", imageName: "percent"))
        tabBarStackView.addArrangedSubview(createTabBarButton(title: "Alerts", imageName: "bell"))
        tabBarStackView.addArrangedSubview(createTabBarButton(title: "Calculators", imageName: "function"))
        tabBarStackView.addArrangedSubview(createTabBarButton(title: "News", imageName: "doc.text.fill"))
        tabBarStackView.addArrangedSubview(lendersButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            segmentedControl.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),

            mortgageDataContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            mortgageDataContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mortgageDataContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            mortgageDataTitleLabel.topAnchor.constraint(equalTo: mortgageDataContainer.topAnchor, constant: 16),
            mortgageDataTitleLabel.leadingAnchor.constraint(equalTo: mortgageDataContainer.leadingAnchor, constant: 16),
            mortgageDataTitleLabel.trailingAnchor.constraint(equalTo: mortgageDataContainer.trailingAnchor, constant: 16),

            tableHeaderStackView.topAnchor.constraint(equalTo: mortgageDataTitleLabel.bottomAnchor, constant: 12),
            tableHeaderStackView.leadingAnchor.constraint(equalTo: mortgageDataContainer.leadingAnchor, constant: 16),
            tableHeaderStackView.trailingAnchor.constraint(equalTo: mortgageDataContainer.trailingAnchor, constant: 16),
            tableHeaderStackView.heightAnchor.constraint(equalToConstant: 20),
            headerSpacer.widthAnchor.constraint(equalToConstant: 100),
            headerCurrentLabel.widthAnchor.constraint(equalToConstant: 80),
            header52WeekRangeLabel.widthAnchor.constraint(equalToConstant: 120),

            dataRow1StackView.topAnchor.constraint(equalTo: tableHeaderStackView.bottomAnchor, constant: 8),
            dataRow1StackView.leadingAnchor.constraint(equalTo: mortgageDataContainer.leadingAnchor, constant: 16),
            dataRow1StackView.trailingAnchor.constraint(equalTo: mortgageDataContainer.trailingAnchor, constant: 16),
            dataRow1StackView.heightAnchor.constraint(equalToConstant: 30),
            dataLabel1Left.widthAnchor.constraint(equalToConstant: 100),
            dataLabel1CenterA.widthAnchor.constraint(equalToConstant: 50),
            dataLabel1RightA.widthAnchor.constraint(equalToConstant: 50),
            progressBarTrack1.leadingAnchor.constraint(equalTo: dataLabel1RightA.trailingAnchor, constant: 8),
            progressBarTrack1.centerYAnchor.constraint(equalTo: dataRow1StackView.centerYAnchor),
            progressBarTrack1.heightAnchor.constraint(equalToConstant: 8),
            progressBarTrack1.widthAnchor.constraint(equalToConstant: 80),
            progressBar1.leadingAnchor.constraint(equalTo: progressBarTrack1.leadingAnchor),
            progressBar1.topAnchor.constraint(equalTo: progressBarTrack1.topAnchor),
            progressBar1.bottomAnchor.constraint(equalTo: progressBarTrack1.bottomAnchor),
            progressBar1.widthAnchor.constraint(equalTo: progressBarTrack1.widthAnchor, multiplier: 0.6),
            dataLabel1RightB.leadingAnchor.constraint(equalTo: progressBarTrack1.trailingAnchor, constant: 8),
            dataLabel1RightB.widthAnchor.constraint(equalToConstant: 50),

            timeSegmentedControl.topAnchor.constraint(equalTo: mortgageDataContainer.bottomAnchor, constant: 20),
            timeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            timeSegmentedControl.heightAnchor.constraint(equalToConstant: 30),

            graphContainerView.topAnchor.constraint(equalTo: timeSegmentedControl.bottomAnchor, constant: 16),
            graphContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            graphContainerView.heightAnchor.constraint(equalToConstant: 150),

            legendStackView.topAnchor.constraint(equalTo: graphContainerView.bottomAnchor, constant: 16),
            legendStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            legendStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),

            tabBarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

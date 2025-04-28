//
//  FactoryPatterns_AbstractFactoryPatternPatternDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

// Abstract Product Protocols
protocol Button {
    var color: String { get }
    func render()
}

protocol Label {
    var textColor: String { get }
    func display(text: String)
}

// Concrete Products - Light Theme
struct LightButton: Button {
    let color = "LightGray"
    func render() { print("Rendering Button with color: \(color)") }
}

struct LightLabel: Label {
    let textColor = "Black"
    func display(text: String) { print("Displaying Label with text '\(text)' in color: \(textColor)") }
}

// Concrete Products - Dark Theme
struct DarkButton: Button {
    let color = "DarkGray"
    func render() { print("Rendering Button with color: \(color)") }
}

struct DarkLabel: Label {
    let textColor = "White"
    func display(text: String) { print("Displaying Label with text '\(text)' in color: \(textColor)") }
}

// Abstract Factory Protocol
protocol UIFactory {
    func createButton() -> Button
    func createLabel() -> Label
}

// Concrete Factories
struct LightThemeFactory: UIFactory {
    func createButton() -> Button { return LightButton() }
    func createLabel() -> Label { return LightLabel() }
}

struct DarkThemeFactory: UIFactory {
    func createButton() -> Button { return DarkButton() }
    func createLabel() -> Label { return DarkLabel() }
}

// Client Code - Represents a View or ViewController
struct SettingsScreen {
    let factory: UIFactory // Injected factory

    func displayUI() {
        let saveButton = factory.createButton()
        let titleLabel = factory.createLabel()

        titleLabel.display(text: "User Preferences")
        saveButton.render()
    }
}

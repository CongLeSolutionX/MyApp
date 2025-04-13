//
//  ExecutorHierarchyView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

// MARK: - Reusable Components

/// A view representing a protocol or struct box in the hierarchy.
struct BoxView: View {
    let title: String
    let color: Color
    let methods: [String]? = nil
    let additionalInfo: [String]? = nil // For things like preconditions/assertions

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 2)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            if let methods = methods, !methods.isEmpty {
                Text("Methods:")
                    .font(.caption.weight(.semibold))
                ForEach(methods, id: \.self) { method in
                    Text("• \(method)")
                        .font(.caption)
                }
            }

            if let additionalInfo = additionalInfo, !additionalInfo.isEmpty {
                 if methods != nil && !methods!.isEmpty {
                    Divider().padding(.vertical, 2)
                 }
                 Text("Isolation:")
                     .font(.caption.weight(.semibold))
                ForEach(additionalInfo, id: \.self) { info in
                    Text("• \(info)")
                        .font(.caption)
                }
            }
        }
        .padding(10)
        .background(color.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: 1.5)
        )
        .cornerRadius(8)
         .frame(minWidth: 150, maxWidth: 200) // Control width
         .fixedSize(horizontal: true, vertical: true) // Prevent vertical stretching
    }
}

/// A view representing a Job or Unowned Reference box.
struct SimpleBoxView: View {
    let title: String
    let color: Color
    let isDeprecated: Bool = false

    var body: some View {
        Text(title)
            .font(.caption)
            .padding(8)
            .background(color.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color, lineWidth: 1)
                    .strikethrough(isDeprecated, color: .red)
            )
            .cornerRadius(5)
            .strikethrough(isDeprecated, color: .red)
             .fixedSize() // Prevent stretching
    }
}

/// A simple arrow shape.
struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.midX - 5, y: rect.maxY - 5))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.maxY - 5))
        }
    }
}

// MARK: - Main Hierarchy View

struct ExecutorHierarchyView: View {
    let baseColor = Color.blue
    let serialColor = Color.purple
    let taskColor = Color.green
    let jobColor = Color.orange
    let refColor = Color.gray
    let lineColor = Color.secondary

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 30) {
                // Executor Protocol
                BoxView(
                    title: "Executor",
                    color: baseColor
//                    methods: ["enqueue(_: UnownedJob)", "enqueue(_: ExecutorJob)"]
                )

                // Arrows down from Executor
                HStack(spacing: 80) {
                    Arrow().stroke(lineColor, lineWidth: 1.5).frame(width: 20, height: 30)
                    Arrow().stroke(lineColor, lineWidth: 1.5).frame(width: 20, height: 30)
                }
                .padding(.bottom, -15) // Adjust spacing

                // SerialExecutor and TaskExecutor side-by-side
                HStack(alignment: .top, spacing: 60) {
                    // SerialExecutor Branch
                    VStack(spacing: 30) {
                        BoxView(
                            title: "SerialExecutor",
                            color: serialColor
//                            methods: [
//                                "enqueue(...)",
//                                "asUnownedSerialExecutor()",
//                                "isSameExclusiveExecutionContext(other:)",
//                                "checkIsolated()"
//                            ],
//                            additionalInfo: [
//                                "preconditionIsolated(...)",
//                                "assertIsolated(...)"
//                            ]
                        )
                        Arrow().stroke(lineColor, lineWidth: 1.5).frame(width: 20, height: 30)
                            .padding(.bottom, -15)
                    }

                    // TaskExecutor Branch
                    VStack(spacing: 30) {
                        BoxView(
                            title: "TaskExecutor",
                            color: taskColor
//                            methods: [
//                                "enqueue(...)",
//                                "asUnownedTaskExecutor()"
//                            ]
                        )
                         Arrow().stroke(lineColor, lineWidth: 1.5).frame(width: 20, height: 30)
                            .padding(.bottom, -15)
                    }
                }

                // Unowned References Group
                GroupBox("Unowned References") {
                    HStack(spacing: 40) {
                        SimpleBoxView(title: "UnownedSerialExecutor", color: refColor)
                        SimpleBoxView(title: "UnownedTaskExecutor", color: refColor)
                    }
                }
                 .groupBoxStyle(PlainGroupBoxStyle()) // Basic style
                 .padding(.horizontal, 20) // Add some padding

                // Jobs Group (connect arrows implicitly)
                 GroupBox("Jobs") {
                    HStack(spacing: 20) {
                        SimpleBoxView(title: "UnownedJob", color: jobColor)
                        SimpleBoxView(title: "ExecutorJob", color: jobColor)
                        SimpleBoxView(title: "Job\n(Deprecated)", color: jobColor.opacity(0.7))
                    }
                    Text("Jobs are passed to enqueue(...) methods")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
                 .groupBoxStyle(PlainGroupBoxStyle()) // Basic style
                 .padding(.horizontal, 20) // Add some padding

            }
            .padding(40) // Overall padding for the scroll view content
            .frame(minWidth: 600) // Ensure minimum width
        }
        .navigationTitle("Executor Hierarchy") // Example title if used in NavigationView
    }
}

// MARK: - GroupBox Style Helper (Optional)
struct PlainGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center) {
            configuration.label
                .font(.caption.weight(.bold))
                .foregroundColor(.gray)
            configuration.content
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Preview
struct ExecutorHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add NavigationView for better preview context
             ExecutorHierarchyView()
        }
        .previewLayout(.sizeThatFits) // Adjust preview layout
        .padding()
    }
}

//
//  SortableTableView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import SwiftUI

struct SortableTableView: View {
    
    @State var viewModel: SortableTableViewModel
    
    var body: some View {
        Group {
            Table(viewModel.students,
                  sortOrder: $viewModel.sortOrder) {
                TableColumn("Index") { student in
                    let index = (viewModel.students.firstIndex(
                        where: { $0.id == student
                            .id }) ?? 0)
                    Text("No. \(index + 1)")
                }
                
                TableColumn("Id", value: \.id)
                
                TableColumn("Name", value: \.name)
                    .width(min: 150)
                
                TableColumn("Math", value:\.gradeHistory.subjects.math) {
                    Text("\($0.gradeHistory.subjects.math)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.math))
                }
                TableColumn("Science", value: \.gradeHistory.subjects.science) {
                    Text("\($0.gradeHistory.subjects.science)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.science))
                }
                TableColumn("English", value: \.gradeHistory.subjects.english) {
                    Text("\($0.gradeHistory.subjects.english)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.english))
                }
                TableColumn("Physics", value: \.gradeHistory.subjects.physics) {
                    Text("\($0.gradeHistory.subjects.physics)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.physics))
                }
                TableColumn("Computer", value: \.gradeHistory.subjects.computer) {
                    Text("\($0.gradeHistory.subjects.computer)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.computer))
                }
                TableColumn("Social Science", value: \.gradeHistory.subjects.socialScience) {
                    Text("\($0.gradeHistory.subjects.socialScience)")
                        .foregroundStyle(gradeColor(for: $0.gradeHistory.subjects.socialScience))
                }
            }
                  .tint(Color.purple.opacity(0.7))
                  .onChange(of: viewModel.sortOrder) {
                      viewModel.students.sort(using: viewModel.sortOrder)
                  }
                  .navigationTitle("Sortable Table")
                  .task {
                      await viewModel.fetchStudents()
                  }
        }
    }
    
    // Helper function to set color based on grade
    private func gradeColor(for grade: Int) -> Color {
        switch grade {
        case 90...100:
            return .green
        case 75..<90:
            return .yellow
        default:
            return .red
        }
    }
}

// MARK: - Preview
#Preview("Sortable Table View") {
    SortableTableView(viewModel: SortableTableViewModel())
}

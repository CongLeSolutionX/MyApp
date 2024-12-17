//
//  StudentDetailView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import SwiftUI

// MARK: - Student Detail View
struct StudentDetailView: View {
    @State var viewModel: StudentDetailViewModel
    
    var body: some View {
        List {
            Group {
                Text(viewModel.student.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("ID: \(viewModel.student.id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                StudentGradeListView(student: viewModel.student)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.student.name)
    }
}

private struct StudentGradeListView: View {
    let student: Student
    
    var body: some View {
        Group {
            let history = student.gradeHistory
            Section {
                Group {
                    GradeView(subject: "Math", grade: history.subjects.math)
                    GradeView(subject: "Science", grade: history.subjects.science)
                    GradeView(subject: "English", grade: history.subjects.english)
                    GradeView(subject: "Physics", grade: history.subjects.physics)
                    GradeView(subject: "Computer", grade: history.subjects.computer)
                    GradeView(subject: "Social Science", grade: history.subjects.socialScience)
                }
                .padding()
                .cornerRadius(10)
                .background(Color.purple.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            } header: {
                Text(history.semester)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
// MARK: - Grade View
struct GradeView: View {
    let subject: String
    let grade: Int
    
    var body: some View {
        Group {
            HStack {
                Text(subject)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(grade)")
                    .font(.body)
                    .foregroundColor(gradeColor(for: grade))
                    .fontWeight(.bold)
            }
            .padding(.vertical, 4)
        }
    }
}

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

// MARK: - Preview
#Preview("Student Detail View") {
    let studentDetails = Student(
        id: "random-id",
        name: "Khoa Nguyen",
        gradeHistory: GradeHistory(
            semester: "This semester",
            subjects: Subjects(
                math: 100,
                science: 100,
                english: 100,
                physics: 100,
                computer: 100,
                socialScience: 100
            )
        )
    )
    
    StudentDetailView(
        viewModel: StudentDetailViewModel(
            student: studentDetails
        )
    )
}

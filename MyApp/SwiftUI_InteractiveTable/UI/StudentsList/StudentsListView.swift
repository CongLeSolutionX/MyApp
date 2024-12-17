//
//  StudentsListView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import SwiftUI

struct StudentsListView: View {
    
    @State var viewModel: StudentsListViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.students, id: \.id) { student in
                NavigationLink(
                    destination: StudentDetailView(viewModel: StudentDetailViewModel(student: student))
                ) {
                    VStack(alignment: .leading) {
                        Text(student.name)
                            .font(.headline)
                        Text("ID: \(student.id)")
                            .font(.subheadline)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Students")
            .task {
                await viewModel.fetchStudents()
            }
        }
        .alertPrompt(item: $viewModel.alertPrompt)
    }
}

//MARK: - Preview
#Preview("Students List View") {
    let studentsListVM = StudentsListViewModel()
    
    StudentsListView(viewModel: studentsListVM)
}

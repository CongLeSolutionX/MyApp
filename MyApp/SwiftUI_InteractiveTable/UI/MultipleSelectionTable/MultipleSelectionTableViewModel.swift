//
//  MultipleSelectionTableViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import SwiftUI

@Observable
class MultipleSelectionTableViewModel {
    var students: [Student] = []
    
    var alertPrompt: AlertPrompt?
    
    var selectedStudents: Set<Student.ID> = []
    
    private let studentRepository: StudentRepository
    
    init() {
        studentRepository = StudentRepository()
    }
    
    func fetchStudents() async {
        
        let result = await studentRepository.getStudents()
        switch result {
        case .success(let students):
            self.students = students.students
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}

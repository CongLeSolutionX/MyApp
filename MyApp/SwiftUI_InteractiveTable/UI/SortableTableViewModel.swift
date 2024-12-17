//
//  SortableTableViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//


import SwiftUI

@Observable
class SortableTableViewModel {
    
    var students: [Student] = []
    var sortOrder = [
        KeyPathComparator(\Student.name),
        KeyPathComparator(\Student.gradeHistory.subjects.math)
    ]
    
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
